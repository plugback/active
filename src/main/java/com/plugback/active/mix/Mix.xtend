package com.plugback.active.mix

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension com.plugback.active.comparable.ASTExtensions.*

@Active(MixProcessor)
annotation Mix {
	Class<?> value;
}

class MixProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {

		val a = cls.annotations.filter[a | a.annotationTypeDeclaration.qualifiedName == Mix.name].head
		val c = a.getClassValue("value")
		val decoratorInterfaces = <String>newArrayList
		findClass(c.type.qualifiedName).implementedInterfaces.map[name].forEach[
			decoratorInterfaces.add(it)
		]
		val classInterfaces = cls.implementedInterfaces.map[name]
		val iName = classInterfaces.filter[decoratorInterfaces.contains(it)].head
		
		val i = findTypeGlobally(iName) as InterfaceDeclaration
		
		i.declaredMethods.forEach [ declared |
			if (!cls.hasExecutable(declared.signature)) {
				cls.addImplementationFor(declared) [
					'''
						«declared.maybeReturn» __mixed.«declared.simpleName»(«declared.parameters.join(",")[simpleName]»);
					'''
				]
			}
		]

		cls.addField("__mixed") [
			initializer = ['''new «toJavaCode(c)»()''']
			type = i.newTypeReference
		]
	}

	def maybeReturn(MethodDeclaration declared) {
		if(!declared.returnType.void) "return"
	}
}
