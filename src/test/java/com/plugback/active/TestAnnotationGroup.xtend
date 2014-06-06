package com.plugback.active

import com.plugback.active.mix.Mix
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static org.junit.Assert.*

class TestAnnotationGroup {
	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Mix)

	@Test def void testAnnotationGroup() {
		'''
			package com.salvatoreromeo.x
			import com.plugback.active.annotation.AnnotationGroup
			import com.plugback.active.async.Async
			
			@AnnotationGroup(name = "MyGroup", annotations = #[Async])
			class Me{
				
				@MyGroup
				def String myMethod(String ciao){
					println("ok")
				}
				
			}
		'''.compile [ compiledClass |
			val generatedCode = compiledClass.getGeneratedCode("com.salvatoreromeo.x.Me")
			println(generatedCode)
			assertTrue(
				generatedCode.contains(
					'''
					@AnnotationGroup(name = "MyGroup", annotations = { Async.class })
					@SuppressWarnings("all")
					public class Me {
					  @MyGroup
					  @Async
					  public String myMethod(final String ciao) {
					    return InputOutput.<String>println("ok");
					  }
					}'''))
		]
	}
}
