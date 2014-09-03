#Plugback Active - Active Annotations for the Xtend Java language
Plugback Active contains a set of active annotations useful for everyday work. 
===

##What do you need
To use Plugback Active you need:

<ul>
	<li>the latest version of Plugback Active, available on the maven repository. 
	Check http://mvnrepository.com/artifact/com.plugback/active</li>
	<li>the Xtend library</li>
</ul>


##Available annotations

<h3>Hook</h3>
Using the <b>Hook</b> active annotation any method can be intercepted before or after it is executed.<br><br>

Place the <code>@Hook(register=true)</code> annotation everywhere you want the method to be intercepted.<br>
This will generate two event classes: <code>BeforeClassNameMethodName</code> and <code>AfterClassNameMethodName</code>.<br>
These two classes contain the parameters of the original method that can be manipulated before and after the 
methiod execution. The <code>AfterClassNameMethodName</code> type contains the returned object too.<br><br>
You can use these two classes in any other class to intercept that method call:<br>
<ol><li>create a method with just one argument of type <code>BeforeClassNameMethodName</code> or <code>AfterClassNameMethodName</code>;</li>
<li>annotate the method using the <code>@Hook</code> annotation;</li>
<li>use the parameter of the method to manipulate the execution. </li>
</ol>

The following is an example taken from the unit test, where the methods into the Me class are intercepted into the You class:

```xtend
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
``` 

