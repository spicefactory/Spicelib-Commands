/*
 * Copyright 2011 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.spicefactory.lib.command.adapter {

import org.spicefactory.lib.errors.IllegalStateError;
	
/**
 * @author Jens Halm
 */
public class CommandAdapters {
	
	
	private static var factories:Array = new Array();
	
	
	public static function addFactory (factory:CommandAdapterFactory, order:int = 2147483647) : void {
		factories.push(new FactoryRegistration(factory, order));
		factories.sortOn("order", Array.NUMERIC);
	}
	
	
	public static function createAdapter (instance:Object) : CommandAdapter {
		var adapter:CommandAdapter;
		for each (var reg:FactoryRegistration in factories) {
			adapter = reg.factory.createAdapter(instance);
			if (adapter) {
				return adapter;
			}
		}
		throw new IllegalStateError("No command adapter factory registered for instance " + instance);
	}
	
	
}
}

import org.spicefactory.lib.command.adapter.CommandAdapterFactory;
class FactoryRegistration {
	
	public var factory:CommandAdapterFactory;
	public var order:int;
	
	function FactoryRegistration (factory:CommandAdapterFactory, order:int) {
		this.factory = factory;
		this.order = order;
	}
	
}
