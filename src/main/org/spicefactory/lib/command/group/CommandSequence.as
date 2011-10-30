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
 
package org.spicefactory.lib.command.group {

import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.base.AbstractCommandExecutor;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
	

/**
 * A CommandGroup implementation that executes its child commands sequentially.
 * When the last child command has completed its operation this sequence will fire its
 * <code>COMPLETE</code> event. If the sequence gets cancelled or suspended the currently active child
 * command will also be cancelled or suspended in turn.
 * If a child command throws an <code>ERROR</code> event and the <code>skipErrors</code> property
 * of this sequence is set to false, then the sequence will fire an <code>ERROR</code> event
 * and will not execute its remaining child commands.
 * 
 * @author Jens Halm
 */	
public class CommandSequence extends AbstractCommandExecutor implements CommandGroup {
		
	
	private static var logger:Logger = LogContext.getLogger(CommandSequence);

	
	private var commands:Array = new Array();
	private var currentIndex:Number;


	/**
	 * Creates a new sequence.
	 * 
	 * @param description a description of this command sequence
	 * @param skipErrors if true an error in a command executed by this instance leads to commandComplete getting called,
	 * if false the executor will stop with an error result 
	 * @param skipCancelllations if true the cancelleation of a command executed by this instance leads 
	 * to commandComplete getting called, if false the executor will stop with an error result 
	 */	
	function CommandSequence (description:String = null, 
			skipErrors:Boolean = false, skipCancelllations:Boolean = false) {
		super(description, skipErrors, skipCancelllations);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addCommand (command:Command) : void {
		commands.push(command);
	}
	
	/**
	 * @private
	 */
	protected override function doExecute () : void {
		currentIndex = 0;
		nextCommand();
	}
	
	/**
	 * @private
	 */
	protected override function commandComplete (result:CommandResult) : void {
		currentIndex++;
		nextCommand();
	}
	
	private function nextCommand () : void {
		if (commands.length == currentIndex) {
			logger.info("Completed all commands in {0}", this);
			complete();
		} else {
			var com:Command = commands[currentIndex] as Command;
			logger.info("Executing next command {0} in sequence {1}", com, this);
			executeCommand(com);
		}
	}	
		
		
}
	
}