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
import org.spicefactory.lib.command.CommandExecutor;
	
/**
 * Represents a flow that executes multiple commands with a dynamic
 * execution order that depends on links that decide which command to execute
 * next, usually based on the result of the preceding command.
 * 
 * <p>For creating a simple linear sequence of commands you should create
 * a <code>CommandGroup</code> instead.</p>
 * 
 * @author Jens Halm
 */
public interface CommandFlow extends CommandExecutor {
	
	/**
	 * Adds a command and associated link to this flow.
	 * The link is invoked after the specified command finished
	 * executing and should determine the next command to execute
	 * (or end the flow execution).
	 * 
	 * <p>The first invocation of this method also specifies
	 * the first command to execute in this flow.</p>
	 * 
	 * @param command the command to add to the flow
	 * @param link the link associated with the command 
	 */
	function addLink (command:Command, link:CommandLink) : void;

	/**
	 * Sets the default link to use when a command in the flow
	 * has no matching link.
	 * 
	 * @param link the default link to use when a command in the flow
	 * has no matching link
	 */
	function setDefaultLink (link:CommandLink) : void;

}
}
