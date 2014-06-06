package com.plugback.active.fields

import com.plugback.active.properties.PropertyGeneratorHelper
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration

@Target(ElementType.CONSTRUCTOR)
@Active(DataProcessor)
annotation Data {
}

class DataProcessor implements TransformationParticipant<MutableConstructorDeclaration> {

	def doTransform(MutableConstructorDeclaration constructor, extension TransformationContext context) {
		val c = constructor.declaringType
		constructor.parameters.forEach [ p |
			if (c.declaredFields.filter[p.simpleName == simpleName].size == 0) {
				val field = c.addField(p.simpleName) [
					type = p.type
				]
				PropertyGeneratorHelper.addReadPropertyMethod(field)
			}
		]

		constructor.body = '''«FOR p : constructor.parameters»
				this.«p.simpleName» = «p.simpleName»;
			«ENDFOR»
		'''
	}

	override doTransform(List<? extends MutableConstructorDeclaration> annotatedTargetElements,
		extension TransformationContext context) {
		annotatedTargetElements.forEach[doTransform(it, context)]

	}

}
