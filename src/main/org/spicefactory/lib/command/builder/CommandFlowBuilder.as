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

import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.CommandFlow;
import org.spicefactory.lib.command.CommandLink;
import org.spicefactory.lib.command.CommandProxy;
import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.flow.DefaultCommandFlow;
import org.spicefactory.lib.logging.LogUtil;
import org.spicefactory.lib.util.collection.Map;
	
/**
 * @author Jens Halm
 */
public class CommandFlowBuilder extends AbstractCommandBuilder {
	
	
	private var _description:String;
	private var links:Array = new Array();
	
	
	public function add (command:Object) : CommandLinkBuilder {
		var link:CommandLinkBuilder = new CommandLinkBuilder(command);
		links.push(link);
		return link;
	}
	
	public function create (commandType:Class) : CommandLinkBuilder {
		var link:CommandLinkBuilder = new CommandLinkBuilder(commandType);
		links.push(link);
		return link;
	}
	
	public function description (description:String, ...params) : CommandFlowBuilder {
		_description = LogUtil.buildLogMessage(description, params);
		return this;
	}
	
	public function timeout (milliseconds:uint) : CommandFlowBuilder {
		setTimeout(milliseconds);
		return this;
	}
	
	public function lastResult (callback:Function) : CommandFlowBuilder {
		var f:Function = function (data:CommandData) : void {
			callback(data.getObject());
		};
		addResultCallback(f);
		return this;
	}
	
	public function allResults (callback:Function) : CommandFlowBuilder {
		addResultCallback(callback);
		return this;
	}
	
	public function error (callback:Function) : CommandFlowBuilder {
		addErrorCallback(callback);
		return this;
	}
	
	public function cancel (callback:Function) : CommandFlowBuilder {
		addCancelCallback(callback);
		return this;
	}
	
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

		setTarget(flow);
		return super.build();
	}
	
	
}
}
