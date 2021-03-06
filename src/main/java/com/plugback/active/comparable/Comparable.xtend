package com.plugback.active.comparable

import de.oehme.xtend.contrib.macro.CommonTransformations
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension de.oehme.xtend.contrib.macro.CommonQueries.*

@Target(ElementType.TYPE)
@Active(ComparableProcessor)
annotation Comparable {
}

class ComparableProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val extension transformations = new CommonTransformations(context)
		if(!cls.hasEquals) cls.addDataEquals
		if(!cls.hasHashCode) cls.addDataHashCode
		if(!cls.hasToString) cls.addDataToString
	}

}
