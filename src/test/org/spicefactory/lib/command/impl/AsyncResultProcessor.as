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

	import org.spicefactory.lib.errors.NestedError;
	import org.spicefactory.lib.command.model.AsyncResult;
/**
 * @author Jens Halm
 */
public class AsyncResultProcessor {
	
	
	public static var cancellations:int;

	private var callback: Function;
	
	
	
	public function execute (async: AsyncResult, callback: Function): void {
		this.callback = callback;
		async.addHandler(result, error);
	}
	
	private function result (value: *): void {
		callback(value);
	}
	
	private function error (cause: Object): void {
		callback(new NestedError("Expected Error", cause as Error));
	}
	
	public function cancel (): void {
		cancellations++;
	}
	
	
}
}
