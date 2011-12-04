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

import org.spicefactory.lib.command.model.CommandModel;
import org.spicefactory.lib.command.model.FlowModel;
import org.spicefactory.lib.errors.IllegalStateError;
/**
 * @author Jens Halm
 */
public class SyncLightDataCommand {
	
	
	public var model: CommandModel;
	
	private var throwError: Boolean;
	
	function SyncLightDataCommand (throwError: Boolean = false) {
		this.throwError = throwError;
	}
	
	
	public function execute (param:CommandModel, flow:FlowModel = null) : Object {
		model = param;
		if (throwError) {
			throw new IllegalStateError("Sorry, I was told to throw an Error");
		}
		if (flow) {
			flow.addCommand(model.value.toString());
		}
		return model.value;
	}
	
	
}
}
