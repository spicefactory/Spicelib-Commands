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

import org.spicefactory.lib.collection.Map;
import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.flow.CommandFlow;
import org.spicefactory.lib.command.flow.CommandLink;
import org.spicefactory.lib.command.flow.DefaultCommandFlow;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.logging.LogUtil;

import flash.system.ApplicationDomain;
	
/**
 * A builder DSL for creating CommandFlow instances.
 * 
 * @author Jens Halm
 */
public class CommandFlowBuilder extends AbstractCommandBuilder {
	
	
	private var _description:String;
	private var _defaultLink: DefaultLinkBuilder;
	private var links:Array = new Array();
	
	/**
	 * Adds a new command instance to this flow.
	 * 
	 * @param command the command to add to this flow
	 * @return a builder to specify links for this command
	 */
	public function add (command:Object) : CommandLinkBuilder {
		var link:CommandLinkBuilder = new CommandLinkBuilder(command);
		links.push(link);
		return link;
	}
	
	/**
	 * Adds a new command type to this flow.
	 * 
	 * @param command the command type to add to this flow
	 * @return a builder to specify links for this command type
	 */
	public function create (commandType:Class) : CommandLinkBuilder {
		var link:CommandLinkBuilder = new CommandLinkBuilder(commandType);
		links.push(link);
		return link;
	}
	
	/**
	 * Returns a builder to use for specifying the default link in case
	 * a command result is not processed by any of the explicit links specified
	 * for that command.
	 * 
	 * @return a builder to use for specifying the default link
	 */
	public function defaultLink (): DefaultLinkBuilder {
		_defaultLink = new DefaultLinkBuilder(this);
		return _defaultLink;
	}
	
	/**
	 * The domain to use for reflecting on command classes.
	 * 
	 * @param domain the domain to use for reflecting on command classes
	 * @return this builder instance for method chaining
	 */
	public function domain (domain:ApplicationDomain) : CommandFlowBuilder {
		setDomain(domain);
		return this;
	}
	
	/**
	 * A description of the command flow produced by this builder.
	 * 
	 * @param description a description of the command flow produced by this builder
	 * @param params parameters to insert into the description in case in contains placeholders (like {0})
	 * @return this builder instance for method chaining
	 */
	public function description (description:String, ...params) : CommandFlowBuilder {
		_description = LogUtil.buildLogMessage(description, params);
		return this;
	}
	
	/**
	 * Sets the timeout for the flow. When the specified
	 * amount of time is elapsed the flow execution will abort with an error.
	 * 
	 * @param milliseconds the timeout for this flow in milliseconds
	 * @return this builder instance for method chaining
	 */
	public function timeout (milliseconds:uint) : CommandFlowBuilder {
		setTimeout(milliseconds);
		return this;
	}
	
	/**
	 * Adds a value that can get passed to any command
	 * executed by the flow this builder creates.
	 * 
	 * @param value the value to pass to the command flow
	 * @return this builder instance for method chaining
	 */
	public function data (value:Object) : CommandFlowBuilder {
		addData(value);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command flow completes successfully.
	 * The result produced by the last command in the flow will get passed to the callback.
	 * 
	 * @param callback the callback to invoke when the command flow completes successfully
	 * @return this builder instance for method chaining
	 */
	public function lastResult (callback:Function) : CommandFlowBuilder {
		var f:Function = function (data:CommandData) : void {
			callback(data.getObject());
		};
		addResultCallback(f);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command flow completes successfully.
	 * An instance of <code>CommandResult</code> will get passed to the callback
	 * holding all results produced by the commands in the flow.
	 * 
	 * @param callback the callback to invoke when the command flow completes successfully
	 * @return this builder instance for method chaining
	 */
	public function allResults (callback:Function) : CommandFlowBuilder {
		addResultCallback(callback);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command flow produced an error.
	 * The cause of the error will get passed to the callback.
	 * 
	 * @param callback the callback to invoke when the command flow produced an error
	 * @return this builder instance for method chaining
	 */
	public function error (callback:Function) : CommandFlowBuilder {
		addErrorCallback(callback);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command flow gets cancelled.
	 * The callback should not expect any parameters.
	 * 
	 * @param callback the callback to invoke when the command flow gets cancelled
	 * @return this builder instance for method chaining
	 */
	public function cancel (callback:Function) : CommandFlowBuilder {
		addCancelCallback(callback);
		return this;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function build () : CommandProxy {
		var flow:CommandFlow = new DefaultCommandFlow(_description);
		var types:Map = new Map();
		var instances:Map = new Map();
		var targetMap:Map;
		for each (var com:CommandLinkBuilder in links) {
			targetMap = (com.target is Class) ? types : instances;
			targetMap.put(com.target, asCommand(com.target));
		}
		for each (var builder:CommandLinkBuilder in links) {
			targetMap = (builder.target is Class) ? types : instances;
			var command:Command = targetMap.get(builder.target) as Command;
			for each (var link:Object in builder.links) {
				if (link is CommandLink) {
					flow.addLink(command, link as CommandLink);
				}
				else {
					flow.addLink(command, LinkTargetBuilder(link).build(types, instances));
				}
			}
		}
		if (_defaultLink) flow.setDefaultLink(_defaultLink.link);

		setTarget(flow);
		return super.build();
	}
	
	
}
}
