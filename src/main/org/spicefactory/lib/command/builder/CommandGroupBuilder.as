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
 * A builder DSL for creating CommandGroup instances.
 * 
 * @author Jens Halm
 */
public class CommandGroupBuilder extends AbstractCommandBuilder {
	
	
	private var sequence:Boolean;
	private var commands:Array = new Array();
	
	private var _description:String;
	private var _skipErrors:Boolean;
	private var _skipCancellations:Boolean;
	
	
	/**
	 * @private
	 */
	function CommandGroupBuilder (sequence:Boolean) {
		this.sequence = sequence;
	}
	
	/**
	 * Adds a new command instance to this group.
	 * 
	 * @param command the command to add to this group
	 * @return this builder instance for method chaining
	 */
	public function add (command:Object) : CommandGroupBuilder {
		commands.push(command);
		return this;
	}
	
	/**
	 * Adds a new command type to this group.
	 * 
	 * @param command the command type to add to this group
	 * @return this builder instance for method chaining
	 */
	public function create (commandType:Class) : CommandGroupBuilder {
		add(commandType);
		return this;
	}
	
	/**
	 * The domain to use for reflecting on command classes.
	 * 
	 * @param domain the domain to use for reflecting on command classes
	 * @return this builder instance for method chaining
	 */
	public function domain (domain:ApplicationDomain) : CommandGroupBuilder {
		setDomain(domain);
		return this;
	}
	
	/**
	 * A description of the command group produced by this builder.
	 * 
	 * @param description a description of the command group produced by this builder
	 * @param params parameters to insert into the description in case in contains placeholders (like {0})
	 * @return this builder instance for method chaining
	 */
	public function description (description:String, ...params) : CommandGroupBuilder {
		_description = LogUtil.buildLogMessage(description, params);
		return this;
	}
	
	/**
	 * Sets the timeout for the group. When the specified
	 * amount of time is elapsed the group execution will abort with an error.
	 * 
	 * @param milliseconds the timeout for this group in milliseconds
	 * @return this builder instance for method chaining
	 */
	public function timeout (milliseconds:uint) : CommandGroupBuilder {
		setTimeout(milliseconds);
		return this;
	}
	
	/**
	 * Adds a value that can get passed to any command
	 * executed by the group this builder creates.
	 * 
	 * @param value the value to pass to the command group
	 * @return this builder instance for method chaining
	 */
	public function data (value:Object) : CommandGroupBuilder {
		addData(value);
		return this;
	}
	
	
	/**
	 * Adds a callback to invoke when the command group completes successfully.
	 * The result produced by the last command in the group will get passed to the callback.
	 * It is not recommended to use this callback in case of parallel execution as the
	 * type of result passed to the callback might be different for each execution.
	 * 
	 * @param callback the callback to invoke when the command group completes successfully
	 * @return this builder instance for method chaining
	 */
	public function lastResult (callback:Function) : CommandGroupBuilder {
		var f:Function = function (data:CommandData) : void {
			callback(data.getObject());
		};
		addResultCallback(f);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command group completes successfully.
	 * An instance of <code>CommandResult</code> will get passed to the callback
	 * holding all results produced by the commands in the group.
	 * 
	 * @param callback the callback to invoke when the command group completes successfully
	 * @return this builder instance for method chaining
	 */
	public function allResults (callback:Function) : CommandGroupBuilder {
		addResultCallback(callback);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command group produced an error.
	 * The cause of the error will get passed to the callback.
	 * 
	 * @param callback the callback to invoke when the command group produced an error
	 * @return this builder instance for method chaining
	 */
	public function error (callback:Function) : CommandGroupBuilder {
		addErrorCallback(callback);
		return this;
	}
	
	/**
	 * Adds a callback to invoke when the command group gets cancelled.
	 * The callback should not expect any parameters.
	 * 
	 * @param callback the callback to invoke when the command group gets cancelled
	 * @return this builder instance for method chaining
	 */
	public function cancel (callback:Function) : CommandGroupBuilder {
		addCancelCallback(callback);
		return this;
	}
	
	/**
	 * Instructs the group to ignore errors produced by any of its commands
	 * and treat them the same way as successful completion. Without invoking
	 * this method the group will abort with an error when any one command it executes produces
	 * an error.
	 * 
	 * @return this builder instance for method chaining
	 */
	public function skipErrors () : CommandGroupBuilder {
		_skipErrors = true;
		return this;
	}
	
	/**
	 * Instructs the group to ignore cancellations of any of its commands
	 * and treat them the same way as successful completion. Without invoking
	 * this method the entire group will get cancelled when any one command it executes gets
	 * cancelled.
	 * 
	 * @return this builder instance for method chaining
	 */
	public function skipCancellations () : CommandGroupBuilder {
		_skipCancellations = true;
		return this;
	}
	
	/**
	 * @inheritDoc
	 */
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
