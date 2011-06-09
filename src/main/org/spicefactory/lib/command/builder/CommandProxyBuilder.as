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
 
package org.spicefactory.lib.command.builder {

import org.spicefactory.lib.logging.LogUtil;
	
/**
 * @author Jens Halm
 */
public class CommandProxyBuilder extends AbstractCommandBuilder {
	
	
	function CommandProxyBuilder (target:Object) {
		if (target is Class) {
			setType(target as Class);
		}
		else {
			setTarget(asCommand(target));
		}
	}
	
	public function description (description:String, ...params) : CommandProxyBuilder {
		setDescription(LogUtil.buildLogMessage(description, params));
		return this;
	}
	
	public function timeout (milliseconds:uint) : CommandProxyBuilder {
		setTimeout(milliseconds);
		return this;
	}
	
	public function result (callback:Function) : CommandProxyBuilder {
		addResultCallback(callback);
		return this;
	}
	
	public function error (callback:Function) : CommandProxyBuilder {
		addErrorCallback(callback);
		return this;
	}
	
	public function cancel (callback:Function) : CommandProxyBuilder {
		addCancelCallback(callback);
		return this;
	}
	
	
}
}
