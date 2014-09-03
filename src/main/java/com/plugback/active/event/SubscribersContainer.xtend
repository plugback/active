package com.plugback.active.event

import java.lang.ref.WeakReference
import java.util.concurrent.ConcurrentHashMap

import static com.plugback.active.event.Priority.*

class SubscribersContainer {

	static val subscribers = new ConcurrentHashMap<WeakReference<?>, Integer>

	def static addSubscriber(Object s) {
		if (subscribers.values.filter[it == s.hashCode].size == 0) {
			val reference = new WeakReference(s)
			subscribers.put(reference, s.hashCode)
		}
		return s
	}

	def handleSubscribers() {
		val me = this
		for (priority : #[highest, high, normal, low, lowest]) {
			subscribers.forEach [ s, b |
				s.get.class.methods.filter[isAnnotationPresent(Hook)].forEach [ m |
					if (priority == m.getAnnotation(Hook).value) {
						if (m.parameterTypes.head == me.class)
							m.invoke(s.get, me)
					}
				]
			]
		}
	}

}
