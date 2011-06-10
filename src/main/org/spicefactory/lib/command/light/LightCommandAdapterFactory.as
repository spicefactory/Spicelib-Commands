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

package org.spicefactory.lib.command.light {

import org.spicefactory.lib.command.CommandAdapter;
import org.spicefactory.lib.command.adapter.CommandAdapterFactory;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.lib.reflect.types.Void;

/**
 * @author Jens Halm
 */
public class LightCommandAdapterFactory implements CommandAdapterFactory {


	private static const log:Logger = LogContext.getLogger(LightCommandAdapterFactory);


	public function createAdapter (instance:Object) : CommandAdapter {
		var info:ClassInfo = ClassInfo.forInstance(instance); // TODO - handle ApplicationDomains
		var execute:Method = info.getMethod("execute");
		if (!execute) return null;
		var async:Boolean;
		for each (var param:Parameter in execute.parameters) {
			if (param.type.getClass() == Function) {
				async = true;
				break;
			}
		}
		if (async) {
			if (execute.returnType.getClass() != Void) {
				throw new IllegalStateError("Asynchronous light commands with a callback parameter"
				 + " must have a void return type");
			}
		}
		return new LightCommandAdapter(instance, info, async);
	}
	
	
}
}
