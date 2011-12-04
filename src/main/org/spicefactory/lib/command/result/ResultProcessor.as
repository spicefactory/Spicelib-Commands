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

package org.spicefactory.lib.command.result {
import org.spicefactory.lib.errors.IllegalStateError;

/**
 * Represents the registration for a single result processor.
 * Use the <code>exists</code> property to determine whether
 * an actual processor had been registered for this particular
 * command or result type.
 * 
 * @author Jens Halm
 */
public class ResultProcessor {
	
	
	private var type: Class;
	
	/**
	 * @private
	 */
	function ResultProcessor (type: Class) {
		this.type = type;
	}
	
	
	private var _processorFactory: Function;
	
	/**
	 * Specifies the factory to use whenever a new processor
	 * must be created for a matching result. The function must
	 * not expect any parameter (the actual result can get passed
	 * to the execute method of the new instance).
	 * 
	 * @param factory the factory to use whenever a new processor
	 * must be created for a matching result
	 */
	public function processorFactory (factory: Function): void {
		_processorFactory = factory;
	}
	
	
	private var _processorType: Class;
	
	/**
	 * Specified the type of command to instantiate and use
	 * as a result processor for each matching result.
	 * Instances of this type must be a command that can
	 * get executed through calling <code>Commands.wrap(instance).execute()</code>.
	 * 
	 * @param type the type of command to instantiate and use
	 * as a result processor for each matching result
	 */
	public function processorType (type: Class): void {
		_processorType = type;
	}
	
	
	/**
	 * Indicates whether any command type of factory has been specified
	 * for this result processor registration.
	 */
	public function get exists (): Boolean {
		return (_processorFactory != null || _processorType != null);
	}
	
	
	/**
	 * Indicates whether this result processor can handle the specified 
	 * result.
	 * 
	 * @param result the result produced by a command
	 * @return true when this result processor can handle the specified 
	 * result
	 */
	public function supports (result: Object): Boolean {
		return (result is type);
	}
	
	/**
	 * Creates a new instance of the result processor.
	 * 
	 * @return a new instance of the result processor
	 */
	public function newInstance (): Object {
		if (!exists) {
			throw new IllegalStateError("Neither type nor factory have been specified for this result processor");
		}
		return (_processorType) ? new _processorType() : _processorFactory(); 
	}
	
	
}
}
