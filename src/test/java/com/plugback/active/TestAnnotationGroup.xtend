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
			import com.plugback.active.fields.CreateField
			
			@AnnotationGroup(name = "MyGroup", annotations = #[CreateField])
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
					@AnnotationGroup(name = "MyGroup", annotations = { CreateField.class })
					@SuppressWarnings("all")
					public class Me {
					  @MyGroup
					  @CreateField
					  public String myMethod(final String ciao) {
					    return InputOutput.<String>println("ok");
					  }
					}'''))
		]
	}
}
