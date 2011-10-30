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

import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.lifecycle.CommandLifecycle;
	
/**
 * Represents a command that executes one or more other commands.
 * 
 * <p>This is the base interface for all command types that group, link or proxy
 * other commands. Since these commands may implement any of the optional <code>Command</code>
 * subinterface, this interface introduces properties that determine the capabilities
 * of this executor.</p>
 * 
 * @author Jens Halm
 */
public interface CommandExecutor extends SuspendableCommand {
	
	
	/**
	 * Indicates whether this executor can be cancelled.
	 * 
	 * <p>This property should be true when all currently active commands can be cancelled.</p>
	 */
	function get cancellable () : Boolean;
    
    /**
	 * Indicates whether this executor can be suspended.
	 * 
	 * <p>This property should be true when all currently active commands can be suspended.</p>
	 */
    function get suspendable () : Boolean;
    
    /**
     * Method that may be called by frameworks before executing this command to hook
     * into the lifecycle and data handling of this executor.
     * 
     * @param lifecycle the lifecycle hooks this executor should use
     * @param data data that can be passed to commands executed by this instance 
     */
    function prepare (lifecycle:CommandLifecycle, data:CommandData) : void;
	
	
}
}
