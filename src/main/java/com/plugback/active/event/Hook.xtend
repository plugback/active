package com.plugback.active.event

import de.oehme.xtend.contrib.macro.CommonTransformations
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration

/**
 * Using the <b>Hook</b> active annotation any method can be intercepted before or after it is executed.<br><br>
 * 
 * Place the <code>@Hook(register=true)</code> annotation everywhere you want the method to be intercepted.<br>
 * This will generate two event classes: <code>BeforeClassNameMethodName</code> and <code>AfterClassNameMethodName</code>.<br>
 * These two classes contain the parameters of the original method that can be manipulated before and after the 
 * methiod execution. The <code>AfterClassNameMethodName</code> type contains the returned object too.<br><br>
 * You can use these two classes in any other class to intercept that method call:<br>
 * <ol><li>create a method with just one argument of type <code>BeforeClassNameMethodName</code> or <code>AfterClassNameMethodName</code>;</li>
 * <li>annotate the method using the <code>@Hook</code> annotation;</li>
 * <li>use the parameter of the method to manipulate the execution. </li>
 * </ol>
 *
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Active(SubscribeProcessor)
annotation Hook {
	boolean register = false
	Priority value = Priority.normal
}

enum Priority {
	lowest,
	low,
	normal,
	high,
	highest
}

class SubscribeProcessor extends AbstractMethodProcessor {

	override doRegisterGlobals(MethodDeclaration annotatedMethod, extension RegisterGlobalsContext context) {
		if (annotatedMethod.shouldRegister) {
			context.registerClass(annotatedMethod.newClassName("Before"))
			context.registerClass(annotatedMethod.newClassName("After"))
		}
	}

	override doTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {

		if (annotatedMethod.shouldRegister)
			registerNewClass(annotatedMethod, context)
		else {
			if (annotationUsedCorrectly(annotatedMethod, context))
				subscribeMethod(annotatedMethod, context)
		}
	}

	def boolean annotationUsedCorrectly(MutableMethodDeclaration annotatedMethod,
		extension TransformationContext context) {
		val sizeIsCorrect = annotatedMethod.parameters.size == 1
		val parameterPrefixIsBefore = annotatedMethod.parameters.head.type.simpleName.startsWith("Before")
		val parameterPrefixIsAfter = annotatedMethod.parameters.head.type.simpleName.startsWith("After")

		val wrongUsage = !(sizeIsCorrect && (parameterPrefixIsBefore || parameterPrefixIsAfter))
		if (wrongUsage) {
			annotatedMethod.addError(
				'''
					A method that listens to an event should have only one argument of type BeforeSomething or AfterSomething.
					If the intention was to generate an event when this method will be called, then add the parameter register to the @Hook annotation:
					
					@Hook(register=true)
					
				'''.toString)
		}

		return !wrongUsage
	}

	private def subscribeMethod(MutableMethodDeclaration m, extension TransformationContext context) {
		val methodSubscriberType = m.parameters.head.type
		if (m.declaringType.declaredFields.filter[simpleName == "__subscriberField"].size == 0)
			m.declaringType.addField("__subscriberField") [
				type = newTypeReference(Object)
				initializer = ['''«methodSubscriberType.name».addSubscriber(this);''']
			]
	}

	private def registerNewClass(MutableMethodDeclaration m, extension TransformationContext context) {
		val extension c = new CommonTransformations(context)
		val beforeClass = findClass(m.newClassName("Before"))
		beforeClass.extendedClass = newTypeReference(SubscribersContainer)
		val afterClass = findClass(m.newClassName("After"))
		afterClass.extendedClass = newTypeReference(SubscribersContainer)
		val beforeFields = newArrayList
		val afterFields = newArrayList
		m.parameters.forEach [ p |
			beforeFields.add(
				beforeClass.addField(p.simpleName) [
					type = p.type
				])
			afterFields.add(
				afterClass.addField(p.simpleName) [
					type = p.type
					final = true
				])
		]
		beforeClass.addDataConstructor(beforeFields)
		beforeFields.forEach[addGetter]
		beforeFields.forEach[addSetter]

		val hasReturnType = m.returnType.toString != "void"
		if (hasReturnType) {
			val f = afterClass.addField("returned") [
				type = m.returnType
			]
			afterFields.add(f)
			f.addSetter
		}
		afterClass.addDataConstructor(afterFields)
		afterFields.forEach[addGetter]

		m.addIndirection("_inner_" + m.simpleName) [
			'''
				«beforeClass.simpleName» bc = new «beforeClass.simpleName»(«beforeFields.map[simpleName].join(",")»);
				bc.handleSubscribers();
				«IF hasReturnType»
					«m.returnType.name» returned = _inner_«m.simpleName»(«m.parameters.map["bc.get" + simpleName.toFirstUpper + "()"].
					join(",")»);
					«afterClass.simpleName» ac = new «afterClass.simpleName»(«m.parameters.map[
					"bc.get" + simpleName.toFirstUpper + "()"].join(",")», returned);
					ac.handleSubscribers();
					return ac.getReturned();
				«ELSE»
					_inner_«m.simpleName»(«m.parameters.map["bc.get" + simpleName.toFirstUpper + "()"].join(",")»);
					«afterClass.simpleName» ac = new «afterClass.simpleName»(«m.parameters.map[
					"bc.get" + simpleName.toFirstUpper + "()"].join(",")»);
					ac.handleSubscribers();
				«ENDIF»
				
				
			'''
		]

	}

	private def addDataConstructor(MutableClassDeclaration cls, MutableFieldDeclaration... fields) {
		cls.addConstructor [
			fields.forEach [ f |
				addParameter(f.simpleName, f.type)
			]
			body = '''
				«FOR f : fields»
					this.«f.simpleName» = «f.simpleName»;
				«ENDFOR»
			'''
		]
	}

	private def newClassName(MethodDeclaration annotatedMethod, String prefix) {
		return annotatedMethod.declaringType.packageName + prefix + annotatedMethod.declaringType.simpleName +
			annotatedMethod.simpleName.toFirstUpper
	}

	private def getAnnotation(MethodDeclaration annotatedMethod, Class<?> a) {
		annotatedMethod.annotations.filter[it.annotationTypeDeclaration.qualifiedName == a.name].head
	}

	private def packageName(TypeDeclaration c) {
		c.qualifiedName.replace(c.simpleName, "")
	}

	private def shouldRegister(MethodDeclaration m) {
		return m.getAnnotation(Hook).getBooleanValue("register")
	}

}
