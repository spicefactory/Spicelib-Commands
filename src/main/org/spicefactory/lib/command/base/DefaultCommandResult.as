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

import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.CommandResult;
	
/**
 * @author Jens Halm
 */
public class DefaultCommandResult implements CommandResult {


	private var _command:Command;
	private var _value:Object;
	private var _success:Boolean;

	function DefaultCommandResult (command:Command, value:Object = null, success:Boolean = true) {
		_command = command;
		_value = value;
		_success = success;
	}
	
	public static function forCompletion (command:Command, result:Object) : CommandResult {
		return new DefaultCommandResult(command, result);
	}
	
	public static function forError (command:Command, cause:Object) : CommandResult {
		return new DefaultCommandResult(command, cause, false);
	}
	
	public static function forCancellation (command:Command) : CommandResult {
		return new DefaultCommandResult(command, null, false);
	}

	public function get command () : Command {
		return null;
	}

	public function get value () : Object {
		return null;
	}

	public function get complete () : Boolean {
		return false;
	}
}
}
