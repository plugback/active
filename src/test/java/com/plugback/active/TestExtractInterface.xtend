package com.plugback.active

import com.plugback.active.interfaces.GenerateInterface
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import static org.junit.Assert.*

class TestExtractInterface {
	
	extension XtendCompilerTester compilerTester = 
      XtendCompilerTester.newXtendCompilerTester(GenerateInterface)
      
     
     @Test 
     def void testExtractInterface() {
     	'''
	package com.salvatoreromeo.x
	import com.plugback.active.interfaces.GenerateInterface

	
	@GenerateInterface
	class Password{
	}

	@GenerateInterface("Context")
	class UserContext{
	}
	
	 
    '''.compile[compiledClass | 
    	val generatedCode = compiledClass.generatedCode.values.join(" ")
    	assertTrue(generatedCode.contains("public interface IPassword {"))
    	assertTrue(generatedCode.contains("public class Password implements IPassword {"))
    	assertTrue(generatedCode.contains("public interface Context {"))
    	assertTrue(generatedCode.contains("public class UserContext implements Context {"))
    	
    ]
     }
     
}