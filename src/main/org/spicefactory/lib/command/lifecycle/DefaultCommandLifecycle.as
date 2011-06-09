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

package org.spicefactory.lib.command.lifecycle {

import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Parameter;

	
/**
 * @author Jens Halm
 */
public class DefaultCommandLifecycle implements CommandLifecycle {


	public function createInstance (type:Class, data:CommandData) : Object {
		var info:ClassInfo = ClassInfo.forClass(type); // TODO - handle ApplicationDomains
		var params:Array = [];
		for each (var param:Parameter in info.getConstructor().parameters) {
			var value:Object = data.getLastResult(param.type.getClass());
			if (value) {
				params.push(value);
			}
			else if (param.required) {
				throw new IllegalStateError("No data available for required constructor parameter of type " 
						+ param.type.name);
			}
			else {
				params.push(undefined);
			}
		}
		return info.newInstance(params);
	}

	public function beforeExecution (command:Object, data:CommandData) : void {
		/* default implementation does nothing */
	}

	public function afterCompletion (command:Object) : void {
		/* default implementation does nothing */
	}
	
	
}
}
