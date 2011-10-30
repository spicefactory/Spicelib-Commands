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
import org.spicefactory.lib.command.flow.CommandLink;
import org.spicefactory.lib.command.flow.DefaultCommandLink;
import org.spicefactory.lib.command.flow.LinkAction;
import org.spicefactory.lib.command.flow.LinkCondition;
import org.spicefactory.lib.errors.IllegalStateError;
	
/**
 * @author Jens Halm
 */
public class LinkTargetBuilder {
	
	
	private var linkBuilder:CommandLinkBuilder;
	private var condition:LinkCondition;
	private var action:LinkAction;
	
	
	/**
	 * @private
	 */
	function LinkTargetBuilder (linkBuilder:CommandLinkBuilder, condition:LinkCondition) {
		this.linkBuilder = linkBuilder;
		this.condition = condition;
	}
	
	
	/**
	 * Links to the specified command type as the next command to execute.
	 * 
	 * @param type the type of command to execute
	 * @return the link builder to specify further links for the same command
	 */
	public function toCommandType (type:Class) : CommandLinkBuilder {
		action = new ExecuteCommandTypeAction(type);
		return linkBuilder;
	}
	
	/**
	 * Links to the specified command instance as the next command to execute.
	 * 
	 * @param command the command instance to execute
	 * @return the link builder to specify further links for the same command
	 */
	public function toCommandInstance (command:Object) : CommandLinkBuilder {
		action = new ExecuteCommandInstanceAction(command);
		return linkBuilder;
	}
	
	/**
	 * Links to the end of the flow, meaning that the flow will signal successful completion.
	 * 
	 * @return the link builder to specify further links for the same command
	 */
	public function toFlowEnd () : CommandLinkBuilder {
		action = new FlowEndAction();
		return linkBuilder;
	}
	
	
	/**
	 * @private
	 */
	internal function build (types:Map, instances:Map) : CommandLink {
		if (!action) {
			throw IllegalStateError("No action has been specified for this link");
		}
		if (action is ResolvableAction) {
			ResolvableAction(action).resolve(types, instances);
		}
		return new DefaultCommandLink(condition, action);
	}
	
	
}
}

import org.spicefactory.lib.collection.Map;
import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.flow.CommandLinkProcessor;
import org.spicefactory.lib.command.flow.LinkAction;

interface ResolvableAction extends LinkAction {
	
	function resolve (types:Map, instances:Map) : void;
	
}

class FlowEndAction implements LinkAction {

	public function execute (processor:CommandLinkProcessor) : void {
		processor.complete();
	}
	
}

class ExecuteCommandTypeAction implements ResolvableAction {

	private var type:Class;
	private var command:Command;
	
	function ExecuteCommandTypeAction (type:Class) {
		this.type = type;
	}

	public function resolve (types:Map, instances:Map) : void {
		if (types.containsKey(type)) {
			command = types.get(type) as Command;
		}
		else {
			command = Commands.create(type).build();
		}
	}

	public function execute (processor:CommandLinkProcessor) : void {
		processor.execute(command);
	}
	
}

class ExecuteCommandInstanceAction implements ResolvableAction {

	private var instance:Object;
	private var command:Command;
	
	function ExecuteCommandInstanceAction (instance:Object) {
		this.instance = instance;
	}

	public function resolve (types:Map, instances:Map) : void {
		if (instances.containsKey(instance)) {
			command = instances.get(instance) as Command;
		}
		else {
			command = Commands.wrap(instance).build();
		}
	}

	public function execute (processor:CommandLinkProcessor) : void {
		processor.execute(command);
	}
	
}
