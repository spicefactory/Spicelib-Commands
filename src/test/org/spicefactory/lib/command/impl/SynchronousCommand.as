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

import org.spicefactory.lib.command.Command;

/**
 * @author Jens Halm
 */
public class SynchronousCommand implements Command {


	private var _executions:uint = 0;
	private static var _totalExecutions: uint = 0;
	private var throwError: Boolean;
	
	
	function SynchronousCommand (throwError: Boolean = false) {
		this.throwError = throwError;
	}
	
	public static function get totalExecutions (): uint {
		return _totalExecutions;
	}
	
	public static function resetTotalExecutions (): void {
		_totalExecutions = 0;
	}
	
	
	public function get executions (): uint {
		return _executions;
	}


	public function execute () : void {
		_executions++;
		_totalExecutions++;
		if (throwError) throw new Error("This error is expected");
	}
	
	
}
}
