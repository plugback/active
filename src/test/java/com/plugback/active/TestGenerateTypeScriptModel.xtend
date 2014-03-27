package com.plugback.active

import com.plugback.active.typescript.GenerateTypeScriptModel
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test
import static org.junit.Assert.*

class TestGenerateTypeScriptModel {
	
	
	 extension XtendCompilerTester compilerTester = 
      XtendCompilerTester.newXtendCompilerTester(GenerateTypeScriptModel)
      
     @Test
     def void testGeneration() {
     	'''
		package com.salvatoreromeo.x
		import com.plugback.active.typescript.GenerateTypeScriptModel
		import com.plugback.active.properties.Property
		import com.plugback.active.properties.ReadOnly

		@GenerateTypeScriptModel
		class BasePrize{
			
		}

		@GenerateTypeScriptModel
		class Prize extends BasePrize{
			
			@ReadOnly var Long id;
			
			@Property String name
			@Property String image
			
			@Property Store store
			
		}
		
		class Store{
			
		}
    '''.compile[compilation | 
    		val generatedSources = compilation.generatedCode
    		val prize = generatedSources.get("com.salvatoreromeo.x.Prize").toString
    		assertTrue(prize.contains("private Long id;"))
    		assertTrue(prize.contains("public Long getId() {"))
    		assertTrue(prize.contains("return id;"))
    		assertTrue(prize.contains("public String getName() {"))
    		assertTrue(prize.contains("return name;"))
    		assertTrue(prize.contains("public Prize setName(final String name) {"))
    		assertTrue(prize.contains("this.name = name;"))
    		assertTrue(prize.contains("return this;"))
    ]
     }
	
}