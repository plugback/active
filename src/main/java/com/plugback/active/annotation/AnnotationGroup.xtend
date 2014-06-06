package com.plugback.active.annotation

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration



/**
 * AnnotationGroup let's you define a group of annotations to be added using a single annotation just generated.
 * 
 * For example, by adding the @AnnotationGroup(name="SecurePersistenceService", annotations=#[RequiresUser, Transactional, Service])
 * annotation before a class declaration, the @SecurePersistenceService generated annotation can be used on a method and
 * @RequiresUser, @Transactional, @Service annotations will be added to the method.
 */
@Target(ElementType.TYPE)
@Active(AnnotationGroupProcessor)
annotation AnnotationGroup {
	String name
	Class<?>[] annotations
}

class AnnotationGroupProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val a = annotatedClass.getAnnotation(AnnotationGroup)
		val na = annotatedClass.getNewAnnotationName(a.getStringValue("name"))
		annotatedClass.declaredMethods.filter[
			it.annotations.filter[it.annotationTypeDeclaration.qualifiedName == na].size > 0].forEach [ m |
			a.getClassArrayValue("annotations").forEach [ annotation |
				m.addAnnotation(annotation.type.newAnnotationReference)
			]
		]
	}

	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		val a = annotatedClass.getAnnotation(AnnotationGroup)
		context.registerAnnotationType(annotatedClass.getNewAnnotationName(a.getStringValue("name")))
	}

	def getAnnotation(ClassDeclaration annotatedClass, Class<?> a) {
		annotatedClass.annotations.filter[it.annotationTypeDeclaration.qualifiedName == a.name].head
	}

	def getNewAnnotationName(ClassDeclaration annotatedClass, String name) {
		annotatedClass.qualifiedName.replace(annotatedClass.simpleName, "") + name
	}

}
