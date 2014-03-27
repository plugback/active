package com.plugback.active.typescript

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtext.common.types.JvmGenericType
import org.eclipse.xtend.core.macro.declaration.AbstractElementImpl

@Target(ElementType.TYPE)
@Active(GenerateTypeScriptModelProcessor)
annotation GenerateTypeScriptModel {
	
}

class GenerateTypeScriptModelProcessor extends AbstractClassProcessor {

	StringBuilder ts
	StringBuilder log

	override doGenerateCode(ClassDeclaration cls, extension CodeGenerationContext context) {
		val targetFolder = cls.compilationUnit.filePath.targetFolder
		val file = targetFolder.append(cls.qualifiedName.replace('.', '/') + ".ts")
//		val logFile = targetFolder.append(cls.qualifiedName.replace('.', '/') + ".log")
//		logFile.contents = log.toString
		file.contents = ts.toString
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		
		var className = cls.simpleName
		
		val extended = (cls.extendedClass.type as AbstractElementImpl<?>).delegate as JvmGenericType
		
		val anns = extended?.annotations
		log.append(anns.size + " ")
		
		val extendsGenerated = anns.size > 0 && anns.filter[a | a.annotation.simpleName == "GenerateTypeScriptModel"].size > 0
		
		log.append(extended.simpleName)
		val parentGenerated = extendsGenerated
		val ext = if(parentGenerated) '''extends «extended.simpleName» ''' else ""
		ts.append('''interface «className» «ext»{
		''')
		
		cls.declaredFields.forEach [ f |
			val ans = f.annotations
			if(ans.filter[a | 
				val name = a.annotationTypeDeclaration.qualifiedName
				name == "com.rollnext.kernel.active.Property" || name == "com.rollnext.kernel.active.ReadOnly"
			].size > 0){
				val ct = f.type.name
				val t = switch(ct){
					case "java.lang.String" : "string"
					case "java.lang.Integer" : "number"
					case "java.lang.int" : "number"
					case "java.lang.Long" : "number"
					case "java.lang.long" : "number"
					case "java.lang.Boolean" : "boolean"
					case "java.lang.boolean" : "boolean"
					default : f.type.simpleName
				}
				ts.append('''	«f.simpleName» : «t»;
				''')
			}
		]
		
		ts.append('''
		}''')
	}

	override doRegisterGlobals(ClassDeclaration cls, extension RegisterGlobalsContext context) {
		ts = new StringBuilder
		log = new StringBuilder
	}
}
	