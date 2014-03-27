package com.plugback.active.fields

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import com.plugback.active.properties.PropertyGeneratorHelper

@Target(ElementType.TYPE)
@Active(DataProcessor)
annotation Data {
}

class DataProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val constructor = annotatedClass.declaredConstructors.head
		constructor.parameters.forEach [p |
			if (annotatedClass.declaredFields.filter[p.simpleName == simpleName].size == 0) {
				val field = annotatedClass.addField(p.simpleName) [
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

}
