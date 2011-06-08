/*
 * Copyright 2007 the original author or authors.
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
import org.spicefactory.lib.command.CommandGroup;
import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.base.AbstractCommandExecutor;
	
/**
 * A CommandGroup implementation that executes its child commands concurrently.
 * If a group is started all the commands that were added to it will be started immediately.
 * If a command gets added to a running group, that command will be started immediately.
 * When all child commands have completed their operation this group will fire its
 * <code>COMPLETE</code> event. If a group gets cancelled or suspended all child
 * commands that are still running will also be cancelled or suspended in turn.
 * If a child command throws an <code>ERROR</code> event and the <code>ignoreChildErrors</code> property
 * of this group is set to false, then all child commands that are still running will be cancelled
 * and the group will fire an <code>ERROR</code> event.
 * 
 * @author Jens Halm
 */
public class ParallelCommands extends AbstractCommandExecutor implements CommandGroup {
	
		
	private var commands:Array = new Array();
	private var completed:uint = 0;
	
	
	/**
	 * Creates a new instance.
	 * 
	 */
	function ParallelCommands (description:String = null, 
			skipErrors:Boolean = false, skipCancelllations:Boolean = false) {
		super(description, skipErrors, skipCancelllations);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addCommand (command:Command) : void {
		commands.push(command);
		if (active) {
			executeCommand(command);
		}
	}

	/**
	 * @private
	 */	
	protected override function doExecute () : void {
		if (commands.isEmpty()) {
			complete();
			return;
		}
		completed = 0;
		for each (var com:Command in commands) {
			executeCommand(com);
		}
	}
	
	/**
	 * @private
	 */
	protected override function commandComplete (result:CommandResult) : void {
		if (++completed == commands.length) complete();
	}		
	
		
}
	
}