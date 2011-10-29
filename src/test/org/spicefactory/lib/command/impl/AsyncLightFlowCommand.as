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
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.command.model.FlowModel;
/**
 * @author Jens Halm
 */
public class AsyncLightFlowCommand {
	
	
	private var result: Object;
	private var id: String;
	
	public var callback:Function;
	
	function AsyncLightFlowCommand (id: String, result: Object) {
		this.result = result;
		this.id = id;
	}
	
	
	public function execute (model: FlowModel) : void {
		model.addCommand(id);
	}

	public function complete () : void {
		callback(result);
	}
	
	public function error () : void {
		callback(new IllegalStateError("This error is expected"));
	}
	
	public function cancel () : void {
		
	}
	
	public function forceCancellation () : void {
		callback();
	}
	
	
}
}
