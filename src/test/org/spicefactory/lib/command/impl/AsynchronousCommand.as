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
package org.spicefactory.lib.command.impl {

import org.spicefactory.lib.command.base.AbstractAsyncCommand;

/**
 * @author Jens Halm
 */
public class AsynchronousCommand extends AbstractAsyncCommand {


	private var _executions:int = 0;
	private var _completions:int = 0;
	private var _errors:int = 0;
	
	private var _injection: Object;
	
	function AsynchronousCommand (optionalInjection: CommandModel = null) {
		if (optionalInjection) {
			_injection = optionalInjection.value;
			optionalInjection.markAsInjected();
		}
	}
	
	
	public function get injection () : Object {
		return _injection;
	}
	
	public function get executions () : int {
		return _executions;
	}

	public function get completions () : int {
		return _completions;
	}
	
	public function get errors () : int {
		return _errors;
	}
	
	public function forceCompletion (result:Object = null): void {
		_completions++;
		complete(result);
	}
	
	public function forceError (cause:Object = null): void {
		_errors++;
		error(cause);
	}

	protected override function doExecute () : void {
		_executions++;
	}

	
}
}
