package com.plugback.active.fields

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext

@Target(ElementType.METHOD)
@Active(CreateFieldProcessor)
annotation CreateField {
}

class CreateFieldProcessor extends AbstractMethodProcessor {

	override doTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {

		val addedFields = newArrayList

		annotatedMethod.parameters.forEach [ p |
			if (annotatedMethod.declaringType.declaredFields.filter[simpleName == p.simpleName].size == 0) {
				val f = annotatedMethod.declaringType.addField(p.simpleName) [
					type = p.type
				]
				addedFields.add(f)
			}
		]

		val nm = annotatedMethod.declaringType.addMethod("new_" + annotatedMethod.simpleName) [
			body = annotatedMethod.body
			returnType = annotatedMethod.returnType
		]
		annotatedMethod.parameters.forEach [
			nm.addParameter(simpleName, type)
		]

		annotatedMethod.setBody [
			'''
				«FOR f : addedFields»
					this.«f.simpleName» = «f.simpleName»;
				«ENDFOR»
				«IF annotatedMethod.returnType.void»
					this.new_«annotatedMethod.simpleName»(«nm.parameters.map[simpleName].join(",")»);
				«ENDIF»
				«IF !annotatedMethod.returnType.void»
					return this.new_«annotatedMethod.simpleName»(«nm.parameters.map[simpleName].join(",")»);
				«ENDIF»
			'''
		]
	}

}
