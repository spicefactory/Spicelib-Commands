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
 
package org.spicefactory.lib.command.base {

import org.spicefactory.lib.command.CommandResult;
	
/**
 * Default implementation of the CommandResult interface.
 * 
 * @author Jens Halm
 */
public class DefaultCommandResult implements CommandResult {


	private var _command:Object;
	private var _value:Object;
	private var _complete:Boolean;


	/**
	 * @private
	 */
	function DefaultCommandResult (command:Object, value:Object = null, complete:Boolean = true) {
		_command = command;
		_value = value;
		_complete = complete;
	}
	
	/**
	 * Creates a new instance for a command that successfully completed.
	 * 
	 * @param command the command that completed its execution
	 * @param result the result produced by the command
	 */
	public static function forCompletion (command:Object, result:Object) : CommandResult {
		return new DefaultCommandResult(command, result);
	}
	
	/**
	 * Creates a new instance for a command that failed to execute.
	 * 
	 * @param command the command that failed to execute
	 * @param cause the cause of the error
	 */
	public static function forError (command:Object, cause:Object) : CommandResult {
		return new DefaultCommandResult(command, cause, false);
	}
	
	/**
	 * Creates a new instance for a command that has been cancelled.
	 * 
	 * @param command the command that has been cancelled
	 */
	public static function forCancellation (command:Object) : CommandResult {
		return new DefaultCommandResult(command, null, false);
	}

	/**
	 * @inheritDoc
	 */
	public function get command () : Object {
		return _command;
	}

	/**
	 * @inheritDoc
	 */
	public function get value () : Object {
		return _value;
	}

	/**
	 * @inheritDoc
	 */
	public function get complete () : Boolean {
		return _complete;
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "CommandResult: value = " + value + ", command = " + command;
	}
	
	
}
}
