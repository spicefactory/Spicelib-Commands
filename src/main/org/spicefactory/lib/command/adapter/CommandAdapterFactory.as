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

	
/**
 * Represents a factory for command adapters.
 * 
 * @author Jens Halm
 */
public interface CommandAdapterFactory {
	
	
	/**
	 * Creates a new adapter for the specified target command.
	 * 
	 * @param instance the target command that usually does not implement one of the Command interfaces
	 * @param domain the ApplicationDomain to use for reflection
	 * @return a new adapter for the specified target command or null if the specified instance cannot
	 * be handled by this factory
	 */
	function createAdapter (instance:Object, domain:ApplicationDomain = null) : CommandAdapter;

	
}
}
