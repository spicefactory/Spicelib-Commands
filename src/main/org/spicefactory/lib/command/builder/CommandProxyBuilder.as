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

import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.command.proxy.DefaultCommandProxy;
import org.spicefactory.lib.logging.LogUtil;

import flash.system.ApplicationDomain;
	
/**
 * A builder DSL for creating CommandProxy instances, responsible for executing a single command.
 * 
 * @author Jens Halm
 */
public class CommandProxyBuilder extends AbstractCommandBuilder {
	
	
	private var target:Object;
	
	/**
	 * @private
	 */
	function CommandProxyBuilder (target:Object, proxy:DefaultCommandProxy = null) {
		super(proxy);
		this.target = target;
	}
	
	/**
	 * The domain to use for reflecting on command classes.
	 * 
	 * @param domain the domain to use for reflecting on command classes
	 * @return this builder instance for method chaining
	 */
	public function domain (domain:ApplicationDomain) : CommandProxyBuilder {
		setDomain(domain);
		return this;
	}
	
	/**
	 * A description of the command proxy produced by this builder.
	 * 
	 * @param description a description of the command proxy produced by this builder
	 * @param params parameters to insert into the description in case in contains placeholders (like {0})
	 * @return this builder instance for method chaining
	 */
	public function description (description:String, ...params) : CommandProxyBuilder {
		setDescription(LogUtil.buildLogMessage(description, params));
		return this;
	}
	
	/**
	 * Sets the timeout for the command execution. When the specified
	 * amount of time is elapsed the proxy will abort with an error.
	 * 
	 * @param milliseconds the timeout for the command execution in milliseconds
	 * @return this builder instance for method chaining
	 */
	public function timeout (milliseconds:uint) : CommandProxyBuilder {
		setTimeout(milliseconds);
		return this;
	}
	
	/**
	 * Adds a value that can get passed to the command
	 * executed by the proxy this builder creates.
	 * 
	 * @param value the value to pass to the command
	 * @return this builder instance for method chaining
	 */
	public function data (value:Object) : CommandProxyBuilder {
		addData(value);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command completes successfully.
	 * The result produced by the command will get passed to the callback.
	 * 
	 * @param callback the callback to invoke when the command completes successfully
	 * @return this builder instance for method chaining
	 */
	public function result (callback:Function) : CommandProxyBuilder {
		addResultCallback(callback);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command produced an error.
	 * The cause of the error will get passed to the callback.
	 * 
	 * @param callback the callback to invoke when the command produced an error
	 * @return this builder instance for method chaining
	 */
	public function error (callback:Function) : CommandProxyBuilder {
		addErrorCallback(callback);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command gets cancelled.
	 * The callback should not expect any parameters.
	 * 
	 * @param callback the callback to invoke when the command gets cancelled
	 * @return this builder instance for method chaining
	 */
	public function cancel (callback:Function) : CommandProxyBuilder {
		addCancelCallback(callback);
		return this;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function build () : CommandProxy {
		if (target is Class) {
			setType(target as Class);
		}
		else {
			setTarget(asCommand(target));
		}
		return super.build();
	}
	
	
}
}
