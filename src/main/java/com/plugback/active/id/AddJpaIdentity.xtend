package com.plugback.active.id

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(ElementType.TYPE)
@Active(JpaIdentityProcessor)
annotation AddJpaIdentity {
}

class JpaIdentityProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces +
			#[newTypeReference("com.plugback.active.id.Identifiable")]

		annotatedClass.addField("id") [
			type = newTypeReference(Long)
			visibility = Visibility.PRIVATE
			addAnnotation(context.findTypeGlobally("javax.persistence.Id").newAnnotationReference)
			addAnnotation(context.findTypeGlobally("com.plugback.active.properties.Property").newAnnotationReference)
		]

		annotatedClass.addMethod('getId') [
			body = [
				'''
					return this.id;
				''']
			returnType = newTypeReference(Long)
		]
		annotatedClass.addMethod('setId') [
			addParameter("id", context.newTypeReference(Long))
			body = [
				'''
					this.id = id;
					return this;
				''']
			returnType = newTypeReference(annotatedClass)
		]

	}

}
