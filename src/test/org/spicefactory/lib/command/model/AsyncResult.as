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

package org.spicefactory.lib.command.model {
	
/**
 * @author Jens Halm
 */
public class AsyncResult {
	
	
	private var complete: Function;
	private var error: Function;
	
	
	public function addHandler (complete: Function, error: Function): void {
		this.complete = complete;
		this.error = error;
	}
	
	
	public function invokeCompleteHandler (result: Object): void {
		complete(result);
	}
	
	public function invokeErrorHandler (cause: Object): void {
		error(cause);
	}
	
	public function cancel (): void {
		complete(undefined);
	}
	
	
}
}
