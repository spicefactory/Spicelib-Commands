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
 * Represents a failure of a command executor.
 * This class does not extend Error or ErrorEvent. It is the type of cause 
 * an comand executor like a group or flow would pass to the error callbacks.
 * It allows to inspect the cause of the error as well as the executor and
 * the target command that caused the error.
 * 
 * @author Jens Halm
 */
public class CommandFailure {
	
	
	private var _executor:CommandExecutor;
	
	private var _target:Object;
	
	private var _cause:Object;
	

	/**
	 * Creates a new instance.
	 * 
	 * @param executor the instance that executed the target command that caused the error
	 * @param target the target command that caused the error
	 * @param cause the cause of the error
	 */
	function CommandFailure (executor:CommandExecutor, target:Object, cause:Object) {
		_executor = executor;
		_target = target;
		_cause = cause;
	}
	
	/**
	 * The instance that executed the target command that caused the error.
	 */
	public function get executor () : CommandExecutor {
		return _executor;
	}
	
	/**
	 * The target command that caused the error.
	 */
	public function get target () : Object {
		return _target;
	}
	
	/**
	 * The cause of the error.
	 * Usually an instance of <code>Error</code>, <code>ErrorEvent</code>
	 * or <code>CommandTimeout</code>, but may be any type like a simple String.
	 */
	public function get cause () : Object {
		return _cause;
	}
	
	/**
	 * The root cause of the error in case of nested commands.
	 * When executing a command sequence or flow the individual
	 * commands might themselves be sequences or flows. In this
	 * case the <code>cause</code> property may hold another
	 * instance of <code>CommandFailure</code>. This property
	 * always returns the root cause as produced by the actual
	 * target command.
	 */
	public function get rootCause (): Object {
		return (cause is CommandFailure) 
			? CommandFailure(cause).rootCause
			: cause;
	}
	
	/**
	 * A textual representation of the failure.
	 */
	public function get message () : String {
		var msg:String = "Execution of " + executor + " failed.";
		if (!(cause is CommandFailure)) {
			msg += "\nCause: Target command " + target + " failed.";
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
