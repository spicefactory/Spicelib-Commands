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
 
package org.spicefactory.lib.command.base {

import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.AsyncCommand;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

import flash.events.EventDispatcher;

/**
 * Abstract base implementation of the AsyncCommand interface. 
 * 
 * <p>A subclass of AbstractAsyncCommand is expected
 * to override the <code>doStart</code> method, do its work and then call <code>complete</code>
 * when the operation is done (or <code>error</code> when the command fails to complete successfully).</p> 
 * 
 * @author Jens Halm
 */
public class AbstractAsyncCommand extends EventDispatcher implements AsyncCommand {
		

	private static var logger:Logger = LogContext.getLogger(AbstractAsyncCommand);


	private var _active : Boolean;
	
	private var description : String;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param description a description of this command
	 */
	public function AbstractAsyncCommand (description:String = null) {
		this.description = description || "[AsyncCommand]";
		addEventListener(CommandEvent.CANCEL, handleCancellation, false, 2); // higher prio, status must be reset before external listeners get invoked	 	
	}
	
	private function handleCancellation (event: CommandEvent) : void {
		_active = false;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get active () : Boolean {
		return _active;
	}
	
	/**
	 * Starts the execution of this command. If this command is member of a group or flow
	 * this method should not be called by application code.
	 */
	public function execute () : void {
		if (active) {
			logger.error("Attempt to execute command '{0}' which is already active", this);
			return;
		}
		_active = true;
		doExecute();
	}
	
	/**
	 * Signals that this command has completed. Subclasses should call this method
	 * when the asynchronous operation has completed.
	 */
	protected function complete (result:Object = null) : void {
		if (!active) {
			logger.error("Attempt to complete command '{0}' although it is not active", this);
			return;
		}
		_active = false;
		dispatchEvent(new CommandResultEvent(CommandResultEvent.COMPLETE, result));
	}
	
	/**
	 * Signals an error condition and cancels the command. Subclasses should call this method
	 * when the asynchronous operation cannot be successfully completed.
     * 
     * @param cause the cause of the error
	 */
	protected function error (cause:Object = null) : void {
		if (!active) {
			logger.error("Attempt to dispatch error event for command '{0}' although it is not active", this);
			return;
		}
		_active = false;
		dispatchEvent(new CommandResultEvent(CommandResultEvent.ERROR, cause));
	}
	
	/**
	 * Invoked when the command starts executing.
	 * Subclasses should override this method to start with the actual operation
	 * this command performs.
	 */
	protected function doExecute () : void {
		/* base implementation does nothing */
	}
	
	/**
	 * @private
	 */
	public override function toString () : String {
		return description;
	}	
		
		
}
}
