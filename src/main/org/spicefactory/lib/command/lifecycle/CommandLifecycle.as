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

package org.spicefactory.lib.command.lifecycle {

import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.data.CommandData;

import flash.system.ApplicationDomain;

/**
 * Represents the lifecycle of a command.
 * This is a hook that can be used by frameworks to add functionality to the command execution.
 * A typical example is integration into an IOC container where the command is supposed to be
 * managed by the container for the time it is getting executed and where the creation of the
 * command instance may also be managed by the container. But this in entirely generic hook
 * that can be used for any kind of additional functionality.
 * 
 * @author Jens Halm
 */
public interface CommandLifecycle {
	
	
	/**
	 * Creates a new command instance of the specified type.
	 * The data passed to this method may be used to perform constructor 
	 * injection or similar tasks.
	 * 
	 * @param type the type of command to create
	 * @param data the data passed to the command by the executor
	 * @return a new command instance
	 */
	function createInstance (type:Class, data:CommandData) : Object;
	
	/**
	 * Lifecycle hook to be invoked immediately before the command gets executed.
	 * 
	 * @param command the command to be executed
	 * @param data the data passed to the command by the executor
	 */
	function beforeExecution (command:Object, data:CommandData) : void;
	
	/**
	 * Lifecycle hook to be invoked after the command finished execution.
	 * This includes successful completion as well as cancellation and errors.
	 * 
	 * @param command the command that finished executing
	 * @param result the result produced by the command
	 */
	function afterCompletion (command:Object, result:CommandResult) : void;
	
	/**
	 * Lifecycle access to the domain for this command.
	 */
	function get domain () : ApplicationDomain;
}
}
