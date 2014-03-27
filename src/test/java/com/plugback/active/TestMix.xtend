package com.plugback.active

import com.plugback.active.mix.Mix
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import static org.junit.Assert.*

class TestMix {
	
	extension XtendCompilerTester compilerTester = 
      XtendCompilerTester.newXtendCompilerTester(Mix)
      
     
     @Test def void testMix() {
     	'''
	package com.salvatoreromeo.x
	import com.plugback.active.mix.Mix

	
	@Mix(DefaultPassword)
	class Password implements IPassword{
	}
	
	interface IPassword{
		def Boolean check()
	}
	
	class DefaultPassword implements IPassword{
		override check(){
			return true	
		}
	}
	
	 
    '''.compile[compiledClass | 
    	val generatedCode = compiledClass.getGeneratedCode("com.salvatoreromeo.x.Password")
		assertTrue(generatedCode.contains('''import com.salvatoreromeo.x.DefaultPassword;'''))
  assertTrue(generatedCode.contains('''public Boolean check() {'''))    	
		assertTrue(generatedCode.contains('''return __mixed.check();'''))    	
		assertTrue(generatedCode.contains('''private IPassword __mixed = new DefaultPassword();'''))    	
    	
    ]
     }
	
}