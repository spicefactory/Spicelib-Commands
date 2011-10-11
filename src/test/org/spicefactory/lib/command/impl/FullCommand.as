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

import org.flexunit.assertThat;
import org.hamcrest.object.equalTo;
import org.spicefactory.lib.command.base.AbstractSuspendableCommand;

/**
 * @author Jens Halm
 */
public class FullCommand extends AbstractSuspendableCommand {


	private var _executions: int = 0;
	private var _completions: int = 0;
	private var _errors: int = 0;
	private var _cancellations: int = 0;
	private var _suspensions: int = 0;
	private var _resumptions: int = 0;


	public function get executions (): int {
		return _executions;
	}

	public function get completions (): int {
		return _completions;
	}

	public function get errors (): int {
		return _errors;
	}

	public function get cancellations (): int {
		return _cancellations;
	}

	public function get suspensions (): int {
		return _suspensions;
	}

	public function get resumptions (): int {
		return _resumptions;
	}

	public function forceCompletion (result: Object = null): void {
		_completions++;
		complete(result);
	}

	public function forceError (cause: Object = null): void {
		_errors++;
		error(cause);
	}
	
	protected override function doCancel (): void {
		_cancellations++;
	}
	
	protected override function doResume (): void {
		_resumptions++;
	}
	
	protected override function doSuspend (): void {
		_suspensions++;
	}

	protected override function doExecute (): void {
		_executions++;
	}

	public function assertStatus (active: Boolean, executions: uint, completions: uint, errors: uint = 0, cancellations: uint = 0, suspensions: uint = 0, resumptions: uint = 0): void {
		assertThat(this.active, equalTo(active));
		assertThat(this.executions, equalTo(executions));
		assertThat(this.completions, equalTo(completions));
		assertThat(this.errors, equalTo(errors));
		assertThat(this.cancellations, equalTo(cancellations));
		assertThat(this.suspensions, equalTo(suspensions));
		assertThat(this.resumptions, equalTo(resumptions));
	}
	
	
}
}
