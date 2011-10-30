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
 
package org.spicefactory.lib.command.flow {
import org.spicefactory.lib.command.Command;
	
/**
 * Allows a CommandLink to specify the next action to perform 
 * by a CommandFlow.
 * 
 * @author Jens Halm
 */
public interface CommandLinkProcessor {
	
	
	/**
	 * Executes the specified command in the flow.
	 * 
	 * @param command the command to execute
	 */
	function execute (command:Command) : void;
	
	/**
	 * Causes the flow to signal successfull completion.
	 */
	function complete () : void;
	
	/**
	 * Causes the flow to get cancelled.
	 */
	function cancel () : void;
	
	/**
	 * Causes the flow to abort with the specified error.
	 * 
	 * @param cause the error the flow should abort with
	 */
	function error (cause:Object) : void;
	
	
}
}
