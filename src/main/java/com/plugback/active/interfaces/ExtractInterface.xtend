package com.plugback.active.interfaces

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility


/**
 * IMPORTANT NOTE: all methods that will be generated should have an explicit return value declared 
 */
@Active(GenerateInterfaceProcessor)
annotation GenerateInterface {
	String value = ""
}

class GenerateInterfaceProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration cls, RegisterGlobalsContext context) {
		val i = cls.qualifiedInterfaceName
		context.registerInterface(i)
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		findInterface(cls.qualifiedInterfaceName) => [ iface |
			cls.implementedInterfaces = cls.implementedInterfaces + #[iface.newTypeReference]
			cls.declaredMethods.filter[visibility == Visibility.PUBLIC && static == false].forEach [ method |
				iface.addMethod(method.simpleName) [ extracted |
					extracted.visibility = Visibility.PUBLIC
					//TODO https://bugs.eclipse.org/bugs/show_bug.cgi?id=412361
					//method.typeParameters.forEach[extracted.addTypeParameter(simpleName, upperBounds)]
					extracted.returnType = method.returnType
					method.parameters.forEach[extracted.addParameter(simpleName, type)]
					extracted.varArgs = method.varArgs
					extracted.docComment = method.docComment
					extracted.exceptions = method.exceptions
				]
			]
		]
	}

	def String qualifiedInterfaceName(ClassDeclaration cls) '''«cls.packageName».«cls.
		simpleInterfaceName»'''
	
	def getPackageName(ClassDeclaration cls){
		val parts = cls.qualifiedName.split("\\.")
		return parts.take(parts.size - 1).join(".")
	}

	def simpleInterfaceName(ClassDeclaration cls) {
		val a = cls.annotations.filter[a | a.annotationTypeDeclaration.qualifiedName == GenerateInterface.name].head
		val interfaceName = a.getStringValue("value")
		if(interfaceName != "")
			return interfaceName
		val simpleName = cls.simpleName
		if(simpleName.startsWith("Default")) {
			simpleName.substring(7)
		} else if(simpleName.endsWith("Impl")) {
			simpleName.substring(0, simpleName.length - 4)
		} else {
			"I" + simpleName
		}
	}
}
