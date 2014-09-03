package com.plugback.active

import com.plugback.active.mix.Mix
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static org.junit.Assert.*

class TestEvent {
	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(Mix)

	@Test
	def void testEvent() {
		'''
			package com.salvatoreromeo.x
			import com.plugback.active.event.Hook
			
			class Me{
				
				@Hook(register = true)
				def String myMethod(String ciao){
					println("ok")
				}
				
				@Hook(register = true)
				def void myMethod2(){
				}
				
			}
			
			
			class You{
				@Hook
				def String yourMethod(BeforeMeMyMethod b){
					println("ok")
				}
				
				@Hook
				def String yourMethod2(AfterMeMyMethod2 a){
					println("ok")
				}
				
				
			}
		'''.compile [ compiledClass |
			val resources = compiledClass.generatedCode
			assertTrue(resources.containsKey("com.salvatoreromeo.x.BeforeMeMyMethod"))
			assertTrue(resources.containsKey("com.salvatoreromeo.x.AfterMeMyMethod"))
			assertTrue(resources.containsKey("com.salvatoreromeo.x.BeforeMeMyMethod2"))
			assertTrue(resources.containsKey("com.salvatoreromeo.x.AfterMeMyMethod2"))
			val beforeClass = compiledClass.getGeneratedCode("com.salvatoreromeo.x.BeforeMeMyMethod")
			beforeClass.assertContains('''public class BeforeMeMyMethod extends SubscribersContainer''')
			beforeClass.assertContains('''private String ciao;''')
			beforeClass.assertContains('''public BeforeMeMyMethod(final String ciao) {''')
			beforeClass.assertContains('''this.ciao = ciao;''')
			beforeClass.assertContains('''public String getCiao() {''')
			beforeClass.assertContains('''return ciao;''')
			beforeClass.assertContains('''public void setCiao(final String ciao) {''')
			val afterClass = compiledClass.getGeneratedCode("com.salvatoreromeo.x.AfterMeMyMethod")
			afterClass.assertContains('''private String returned;''')
			afterClass.assertContains('''public void setReturned(final String returned) {''')
			afterClass.assertContains('''this.returned = returned;''')
			afterClass.assertContains('''public AfterMeMyMethod(final String ciao, final String returned) {''')
			afterClass.assertContains('''public String getReturned() {''')
			afterClass.assertContains('''return returned;''')
			val afterClass2 = compiledClass.getGeneratedCode("com.salvatoreromeo.x.AfterMeMyMethod2")
			println(afterClass2)
			afterClass2.assertContains('''public AfterMeMyMethod2() {''')
			val generatedCode = compiledClass.getGeneratedCode("com.salvatoreromeo.x.Me")
			println(generatedCode)
			generatedCode.assertContains('''BeforeMeMyMethod bc = new BeforeMeMyMethod(ciao);''')
			generatedCode.assertContains('''bc.handleSubscribers();''')
			generatedCode.assertContains('''java.lang.String returned = _inner_myMethod(bc.getCiao());''')
			generatedCode.assertContains('''AfterMeMyMethod ac = new AfterMeMyMethod(bc.getCiao(), returned);''')
			generatedCode.assertContains('''ac.handleSubscribers();''')
			generatedCode.assertContains('''return ac.getReturned();''')
			generatedCode.assertContains('''private String _inner_myMethod(final String ciao) {''')
			generatedCode.assertContains('''BeforeMeMyMethod2 bc = new BeforeMeMyMethod2();''')
			generatedCode.assertContains('''bc.handleSubscribers();''')
			generatedCode.assertContains('''bc.handleSubscribers();''')
			generatedCode.assertContains('''AfterMeMyMethod2 ac = new AfterMeMyMethod2();''')
			generatedCode.assertContains('''ac.handleSubscribers();''')
			println(compiledClass.getGeneratedCode("com.salvatoreromeo.x.You"))
		]
	}

	def assertContains(String gc, String s) {
		assertTrue(gc.normalized.contains(s.normalized))
	}

	def normalized(CharSequence string) {
		return string.toString.replace("\t", "").replace("\n", "")
	}

}
