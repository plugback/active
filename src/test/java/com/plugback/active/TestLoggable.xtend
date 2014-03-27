package com.plugback.active

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import static org.junit.Assert.*
import com.plugback.active.log.Loggable

class TestLoggable {
	
	
	 extension XtendCompilerTester compilerTester = 
      XtendCompilerTester.newXtendCompilerTester(Loggable)
      
     
     @Test def void testLoggable() {
     	'''
	package com.salvatoreromeo.x
	import com.plugback.active.log.Loggable

	
	@Loggable
	class Password{
		
		
		
		
		
	}
	
	 
    '''.compile[compiledClass | 
    	val generatedCode = compiledClass.getGeneratedCode("com.salvatoreromeo.x.Password")
		assertTrue(generatedCode.contains('''@Transient'''))
  assertTrue(generatedCode.contains('''public Logger __log = org.slf4j.LoggerFactory.getLogger(Password.class);'''))    	
		assertTrue(generatedCode.contains('''public void info(final CharSequence message)'''))    	
		assertTrue(generatedCode.contains('''__log.info(message.toString());'''))    	
    	
    ]
     }
	
}