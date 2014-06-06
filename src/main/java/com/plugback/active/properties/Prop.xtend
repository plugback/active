package com.plugback.active.properties

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
@Active(PropertyProcessor)
annotation Property {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
@Active(ReadOnlyPropertyProcessor)
annotation ReadOnly {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Active(ReadOnlyConstructorPropertyProcessor)
annotation ReadOnlyConstructor {
}

class PropertyGeneratorHelper {

	def static addReadPropertyMethod(MutableFieldDeclaration field) {

		field.markAsRead

		if (field.type.name.contains("Boolean") &&
			field.declaringType.findDeclaredMethod('is' + field.simpleName.toFirstUpper) == null)
			field.declaringType.addMethod('is' + field.simpleName.toFirstUpper) [
				returnType = field.type
				body = [
					'''
						return «field.simpleName»;
					''']
			]
		else if (field.declaringType.findDeclaredMethod('get' + field.simpleName.toFirstUpper) == null)
			field.declaringType.addMethod('get' + field.simpleName.toFirstUpper) [
				returnType = field.type
				body = [
					'''
						return «field.simpleName»;
					''']
			]
	}

}

class ReadOnlyConstructorPropertyProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val fields = cls.declaredFields.filter[
			annotations.filter[it.annotationTypeDeclaration.simpleName == ReadOnly.simpleName].size > 0]

		val constructor = cls.addConstructor[]

		val constructorBody = new StringBuilder

		fields.forEach [ f |
			f.markAsInitialized
			constructor.addParameter(f.simpleName, f.type)
			constructorBody.append('''«constructor.body»this.«f.simpleName» = «f.simpleName»;''')
		]
		constructor.body = '''«constructorBody»'''
	}

}

class ReadOnlyPropertyProcessor extends AbstractFieldProcessor {

	override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
		PropertyGeneratorHelper.addReadPropertyMethod(field)
	}

}

class PropertyProcessor extends AbstractFieldProcessor {

	override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {

		PropertyGeneratorHelper.addReadPropertyMethod(field)

		field.declaringType.addMethod('set' + field.simpleName.toFirstUpper) [
			returnType = context.newTypeReference(field.declaringType)
			addParameter(field.simpleName, field.type)
			body = [
				'''
					this.«field.simpleName» = «field.simpleName»;
					return this;
				''']
		]
	}

}
