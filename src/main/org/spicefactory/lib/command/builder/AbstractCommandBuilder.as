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

import org.spicefactory.lib.command.light.LightCommandAdapterFactory;
import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.adapter.CommandAdapters;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.command.proxy.DefaultCommandProxy;
import org.spicefactory.lib.reflect.ClassInfo;

import flash.system.ApplicationDomain;
	
/**
 * Abstract base class for all builder types.
 * The builder always produces a proxy responsible for executing
 * the actual command.
 * 
 * @author Jens Halm
 */
public class AbstractCommandBuilder implements CommandBuilder {


	private var proxy:DefaultCommandProxy;
	private var _domain:ApplicationDomain;
	
	private static var lightAdapterInitialized: Boolean;


	/**
	 * Creates a new instance. If no proxy gets passed to this constructor
	 * a default implementation will be used.
	 * 
	 * @param the proxy to use for executing the target command
	 */
	function AbstractCommandBuilder (proxy:DefaultCommandProxy = null) {
		this.proxy = proxy || new DefaultCommandProxy();
	}

	/**
	 * Sets the target command to execute.
	 * 
	 * @param target the target command to execute 
	 */
	protected function setTarget (target:Command) : void {
		proxy.target = target;
	}
	
	/**
	 * Sets the type of the command to execute. In this case
	 * the actual instance will be created by the proxy.
	 * 
	 * @param type the type of the command to execute
	 */
	protected function setType (type:Class) : void {
		proxy.type = type;
	}
	
	/**
	 * Sets the domain to use for reflecting on command classes.
	 * 
	 * @param domain the domain to use for reflecting on command classes
	 */
	protected function setDomain (domain:ApplicationDomain) : void {
		_domain = domain;;
	}
	
	/**
	 * Adds a value that can get passed to any command
	 * executed by the command proxy this builder creates.
	 * 
	 * @param value the value to pass to the command proxy
	 */
	protected function addData (value:Object) : void {
		proxy.addData(value);
	}
	
	/**
	 * Sets the timeout for this proxy. When the specified
	 * amount of time is elapsed the command execution will abort with an error.
	 * 
	 * @param milliseconds the timeout for this proxy in milliseconds
	 */
	protected function setTimeout (milliseconds:uint) : void {
		proxy.timeout = milliseconds;
	}
	
	/**
	 * Sets a description of the target command.
	 * This is primarily useful for logging purposes.
	 * 
	 * @param description a description of the target command
	 */
	protected function setDescription (description:String) : void {
		proxy.description = description;
	}
	
	/**
	 * Adds a callback to invoke when the target command completes successfully.
	 * The result produced by the command will get passed to the callback.
	 * 
	 * @param callback the callback to invoke when the target command completes successfully
	 */
	protected function addResultCallback (callback:Function) : void {
		proxy.addEventListener(CommandResultEvent.COMPLETE, function (event:CommandResultEvent) : void {
			callback(event.value);
		});
	}
	
	/**
	 * Adds a callback to invoke when the target command produced an error.
	 * The cause of the error will get passed to the callback.
	 * 
	 * @param callback the callback to invoke when the target command produced an error
	 */
	protected function addErrorCallback (callback:Function) : void {
		proxy.addEventListener(CommandResultEvent.ERROR, function (event:CommandResultEvent) : void {
			callback(event.value);
		});
	}
	
	/**
	 * Adds a callback to invoke when the target command gets cancelled.
	 * The callback should not expect any parameters.
	 * 
	 * @param callback the callback to invoke when the target command gets cancelled
	 */
	protected function addCancelCallback (callback:Function) : void {
		proxy.addEventListener(CommandEvent.CANCEL, function (event:CommandEvent) : void {
			callback();
		});
	}
	
	private function get domain () : ApplicationDomain {
		return _domain || Commands.defaultDomain || ClassInfo.currentDomain;
	}
	
	/**
	 * Turns the specified instance into a command that can be executed by the proxy
	 * created by this builder. Legal parameters are any instances that implement either
	 * <code>Command</code> or <code>CommandBuilder</code>, a <code>Class</code> reference
	 * that specifies the type of the target command to create, or any other type in case
	 * an adapter is registered that knows how to turn the type into a command.
	 * 
	 * @param the instance to turn into a command
	 * @return the command created from the specified instance 
	 */
	protected function asCommand (command:Object) : Command {
		if (command is Command) {
			return command as Command;
		}
		else if (command is CommandBuilder) {
			return CommandBuilder(command).build();
		}
		else if (command is Class) {
			return Commands.create(command as Class).build();
		}
		else {
			initializeLightAdapter();
			return CommandAdapters.createAdapter(command, domain);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function execute () : CommandProxy {
		var proxy:CommandProxy = build();
		proxy.execute();
		return proxy;
	}

	/**
	 * @inheritDoc
	 */
	public function build () : CommandProxy {
		proxy.domain = domain;
		return proxy;
	}
	
	
	private static function initializeLightAdapter (): void {
		if (!lightAdapterInitialized) {
			lightAdapterInitialized = true;
			CommandAdapters.addFactory(new LightCommandAdapterFactory());
		}
	}
	
	
}
}
