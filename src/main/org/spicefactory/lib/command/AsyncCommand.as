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

package org.spicefactory.lib.command {

import flash.events.IEventDispatcher;

/**
 * Dispatched when the command execution completed successfully.
 */
[Event(name="complete", type="org.spicefactory.lib.command.events.CommandResultEvent")]

/**
 * Dispatched when the command execution failed.
 */
[Event(name="error", type="org.spicefactory.lib.command.events.CommandResultEvent")]

/**
 * Represents a command that executes asynchronously.
 * 
 * @author Jens Halm
 */
public interface AsyncCommand extends Command, IEventDispatcher {
	
	/**
	 * Indicates whether this command is currently executing.
	 */
	function get active () : Boolean;
	
}
}
