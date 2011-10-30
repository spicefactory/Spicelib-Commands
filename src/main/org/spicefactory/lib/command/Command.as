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
 * Represents a single command. The base interface for all commands.
 * If only this interface is implemented by a command, it is treated
 * as a synchronous command. For additional features like asynchronous 
 * execution, cancellation or suspension, several subinterfaces are available.
 * 
 * <p>This interface is used by all internal command executors and builders.
 * But application classes do not have to implement this interface when they
 * use the Light Command functionality where execution is based on 
 * naming conventions instead.</p>
 * 
 * @author Jens Halm
 */
public interface Command {
	
	/**
	 * Executes the command.
	 */
	function execute () : void;
	
}
}
