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

import flash.system.ApplicationDomain;

import org.spicefactory.lib.errors.IllegalStateError;
	
/**
 * Central registry for all available command adapters.
 * An adapter must be registered before executing or configuring one of the commands
 * handled by the adapter.
 * 
 * @author Jens Halm
 */
public class CommandAdapters {
	
	
	private static var factories:Array = new Array();
	
	
	/**
	 * Adds a factory to this registry. The order attributes allows to sort all available
	 * factories. For each new command instance that does not implement one of the command
	 * interfaces the factories get asked to create a new adapter in the specified order
	 * until one factory was able to handle the command (Chain of Responsibility).
	 * 
	 * @param the factory to add to this registry.
	 * @param order the order to use for this factory
	 */
	public static function addFactory (factory:CommandAdapterFactory, order:int = 2147483647) : void {
		factories.push(new FactoryRegistration(factory, order));
		factories.sortOn("order", Array.NUMERIC);
	}
	
	
	/**
	 * Creates a new adapter for the specified target command.
	 * Throws an error if the instance cannot be handled by any of the available adapters
	 * 
	 * @param instance the target command that usually does not implement one of the Command interfaces
	 * @param domain the ApplicationDomain to use for reflection
	 * @return a new adapter for the specified target command
	 */
	public static function createAdapter (instance:Object, domain:ApplicationDomain = null) : CommandAdapter {
		var adapter:CommandAdapter;
		for each (var reg:FactoryRegistration in factories) {
			adapter = reg.factory.createAdapter(instance, domain);
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
