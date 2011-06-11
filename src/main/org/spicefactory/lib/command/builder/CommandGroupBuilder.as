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

import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.group.CommandGroup;
import org.spicefactory.lib.command.group.CommandSequence;
import org.spicefactory.lib.command.group.ParallelCommands;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.logging.LogUtil;

import flash.system.ApplicationDomain;
	
/**
 * @author Jens Halm
 */
public class CommandGroupBuilder extends AbstractCommandBuilder {
	
	
	private var sequence:Boolean;
	private var commands:Array = new Array();
	
	private var _description:String;
	private var _skipErrors:Boolean;
	private var _skipCancellations:Boolean;
	
	
	function CommandGroupBuilder (sequence:Boolean) {
		this.sequence = sequence;
	}
	
	
	public function add (command:Object) : CommandGroupBuilder {
		commands.push(command);
		return this;
	}
	
	public function create (commandType:Class) : CommandGroupBuilder {
		add(commandType);
		return this;
	}
	
	public function domain (domain:ApplicationDomain) : CommandGroupBuilder {
		setDomain(domain);
		return this;
	}
	
	public function description (description:String, ...params) : CommandGroupBuilder {
		_description = LogUtil.buildLogMessage(description, params);
		return this;
	}
	
	public function timeout (milliseconds:uint) : CommandGroupBuilder {
		setTimeout(milliseconds);
		return this;
	}
	
	public function data (value:Object) : CommandGroupBuilder {
		addData(value);
		return this;
	}
	
	
	public function lastResult (callback:Function) : CommandGroupBuilder {
		var f:Function = function (data:CommandData) : void {
			callback(data.getObject());
		};
		addResultCallback(f);
		return this;
	}
	
	public function allResults (callback:Function) : CommandGroupBuilder {
		addResultCallback(callback);
		return this;
	}
	
	public function error (callback:Function) : CommandGroupBuilder {
		addErrorCallback(callback);
		return this;
	}
	
	public function cancel (callback:Function) : CommandGroupBuilder {
		addCancelCallback(callback);
		return this;
	}
	
	public function skipErrors () : CommandGroupBuilder {
		_skipErrors = true;
		return this;
	}
	
	public function skipCancellations () : CommandGroupBuilder {
		_skipCancellations = true;
		return this;
	}
	
	public override function build () : CommandProxy {
		var group:CommandGroup = (sequence)
				? new CommandSequence(_description, _skipErrors, _skipCancellations)
				: new ParallelCommands(_description, _skipErrors, _skipCancellations);
		for each (var command:Object in commands) {
			group.addCommand(asCommand(command));
		}
		setTarget(group);
		return super.build();
	}


}
}
