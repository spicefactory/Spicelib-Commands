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
 
package org.spicefactory.lib.command.events {

import org.spicefactory.lib.command.CommandExecutor;

import flash.events.ErrorEvent;
	
/**
 * @author Jens Halm
 */
public class CommandExecutorFailure {
	
	
	private var _executor:CommandExecutor;
	
	private var _target:Object;
	
	private var _cause:Object;
	

	function CommandExecutorFailure (executor:CommandExecutor, target:Object, cause:Object) {
		_executor = executor;
		_target = target;
		_cause = cause;
	}
	
	public function get executor () : CommandExecutor {
		return _executor;
	}
	
	public function get target () : Object {
		return _target;
	}
	
	public function get cause () : Object {
		return _cause;
	}
	
	public function get message () : String {
		var msg:String = "Execution of " + executor + " failed.";
		if (!(cause is CommandExecutorFailure)) {
			msg += "\nCause: Target command" + target + " failed.";
		}
		msg +=	"\nCause: ";
		if (cause is Error) {
			msg += (cause as Error).getStackTrace();
		}
		else if (cause is ErrorEvent) {
			msg += ErrorEvent(cause).text;
		}
		else {
			msg += cause.toString();
		}
		return msg;
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return message;
	}
	
	
}
}
