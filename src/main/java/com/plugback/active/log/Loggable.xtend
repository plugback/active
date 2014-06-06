package com.plugback.active.log

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(ElementType.TYPE)
@Active(LoggableProcessor)
annotation Loggable {
}

class LoggableProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		cls.addField("__log") [
			type = context.newTypeReference("org.slf4j.Logger")
			initializer = ['''org.slf4j.LoggerFactory.getLogger(«cls.simpleName».class)''']
			visibility = Visibility.PUBLIC
			addAnnotation(context.findTypeGlobally("javax.persistence.Transient").newAnnotationReference)
		]

		cls.addMethod('info') [
			addParameter("message", context.newTypeReference("java.lang.CharSequence"))
			body = [
				'''
					__log.info(message.toString());
				''']
		]
		cls.addMethod('log') [
			addParameter("message", context.newTypeReference("java.lang.CharSequence"))
			body = [
				'''
					__log.info(message.toString());
				''']
		]
		cls.addMethod('warn') [
			addParameter("message", context.newTypeReference("java.lang.CharSequence"))
			body = [
				'''
					__log.warn(message.toString());
				''']
		]
	}
}
