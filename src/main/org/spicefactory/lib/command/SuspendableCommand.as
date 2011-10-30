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
	
/**
 * Dispatched when the command is suspended.
 */
[Event(name="suspend", type="org.spicefactory.lib.command.events.CommandEvent")]

/**
 * Dispatched when the command is resumed.
 */
[Event(name="resume", type="org.spicefactory.lib.command.events.CommandEvent")]
	
/**
 * Represents a command that can get cancelled and suspended.
 * 
 * @author Jens Halm
 */
public interface SuspendableCommand extends CancellableCommand {
	
	/**
	 * Indicates whether this command is currently suspended.
	 */
	function get suspended () : Boolean;
    
    /**
     * Suspends the command. 
     * Calling this method only has an effect if the command is currently executing.
     */
    function suspend () : void;
    
    /**
     * Resumes the command. 
     * Calling this method only has an effect if the command is currently suspended.
     */
    function resume () : void;
	
}
}
