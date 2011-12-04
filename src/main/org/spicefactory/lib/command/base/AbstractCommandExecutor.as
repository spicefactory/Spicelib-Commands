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

import org.spicefactory.lib.collection.List;
import org.spicefactory.lib.command.*;
import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.data.DefaultCommandData;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.events.CommandFailure;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.lifecycle.CommandLifecycle;
import org.spicefactory.lib.command.lifecycle.DefaultCommandLifecycle;
import org.spicefactory.lib.command.util.CommandUtil;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

import flash.system.ApplicationDomain;

/**
 * Abstract base class for all executor implementations.
 * It knows how to execute other commands and deal with their events.
 * Subclasses are expected to call the protected <code>executeCommand</code>
 * method to start a command and override the protected template method
 * <code>commandComplete</code> for dealing with the result.
 * 
 * @author Jens Halm
 */
public class AbstractCommandExecutor extends AbstractSuspendableCommand implements CommandExecutor {
		
		
	private static var logger:Logger = LogContext.getLogger(AbstractCommandExecutor);
	
	
	private var activeCommands:List = new List();
	
	private var _data:DefaultCommandData;
	private var values:Array = new Array();
	
	private var _domain:ApplicationDomain;
	private var _lifecycle:CommandLifecycle;
	
	private var processErrors:Boolean;
	private var processCancellations:Boolean;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param description a description of this command
	 * @param processErrors if true an error in a command executed by this instance leads to commandComplete getting called,
	 * if false the executor will stop with an error result 
	 * @param processCancellations if true the cancelleation of a command executed by this instance leads 
	 * to commandComplete getting called, if false the executor will stop with an error result 
	 */
	function AbstractCommandExecutor (description:String = null, 
			processErrors:Boolean = false, processCancellations:Boolean = false) {
		super(description);
		this.processErrors = processErrors;
		this.processCancellations = processCancellations;
	}

	/**
	 * @inheritDoc
	 */
	public function get cancellable () : Boolean {
		for each (var com:Command in activeCommands) {
			if (!CommandUtil.isCancellable(com)) return false;
		}
		return true;
	}

	/**
	 * @inheritDoc
	 */	
	public function get suspendable () : Boolean {
		for each (var com:Command in activeCommands) {
			if (!CommandUtil.isSuspendable(com)) return false;
		}
		return true;
	}
	
	/**
	 * Adds a value to this executor that can get passed to any command
	 * executed by this instance.
	 * 
	 * @param value the value to add to this executor
	 */
	public function addData (value:Object) : void {
		if (_data) {
			_data.addValue(value);
		}
		else {
			values.push(value);
		}
	}
	
	/**
	 * The domain to use in case reflection on the command classes
	 * this exeutor deals with is required.
	 */
	public function get domain (): ApplicationDomain {
		return _domain;
	}

	public function set domain (domain: ApplicationDomain): void {
		_domain = domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function prepare (lifecycle:CommandLifecycle, data:CommandData) : void {
		_lifecycle = lifecycle;
		_data = new DefaultCommandData(data);
		addValues();
	}
	
	/**
	 * The lifecycle hook to use for the commands executed by this instance.
	 */
	protected function get lifecycle () : CommandLifecycle {
		if (!_lifecycle) {
			_lifecycle = createLifecycle();
		}
		return _lifecycle;
	}
	
	/**
	 * Creates a new instance of the lifecycle hook.
	 * Subclasses may override this method to provide specialized implementations.
	 * This method will only get invoked when the first command executed by this 
	 * instance gets started without the <code>prepare</code> method being invoked
	 * upfront. The <code>prepare</code> method allows to pass down <code>CommandLifecycle</code>
	 * instances from the environment (like parent executors), in which case this instance
	 * should not create its own lifecycle.
	 * 
	 * @return a new lifecycle instance to use when executing commands
	 */
	protected function createLifecycle () : CommandLifecycle {
		return new DefaultCommandLifecycle(domain);
	}
    
    /**
     * The data associated with this executor.
     * Contains any results from previously executed commands or
     * data specified upfront.
     */
    protected function get data () : CommandData {
    	if (!_data) {
    		var newData:CommandData = createData();
    		_data = (newData is DefaultCommandData) 
    			? newData as DefaultCommandData
    			: new DefaultCommandData(newData);
    		addValues();
    	}
    	return _data;
    }
    
    private function addValues () : void {
    	for each (var value:Object in values) {
			_data.addValue(value);
		}
		values = [];
    }
    
    /**
	 * Creates a new instance holding the data commands executed by this instance will produce.
	 * Subclasses may override this method to provide specialized implementations.
	 * This method will only get invoked when the first command executed by this 
	 * instance gets started without the <code>prepare</code> method being invoked
	 * upfront. The <code>prepare</code> method allows to pass down <code>CommandData</code>
	 * instances from the environment (like parent executors), in which case this instance
	 * should not use its own implementations.
	 * 
	 * @return a new instance to use for holding the data commands executed by this instance will produce
	 */
    protected function createData () : CommandData {
    	return new DefaultCommandData();
    }
    
	/**
	 * Executes the specified command.
	 * Upon completion the <code>commandComplete</code> method will get invoked
	 * which may be overridden by subclasses to deal with the result or decide
	 * on the next command to execute.
	 * 
	 * @param com the command to execute
	 */
	protected function executeCommand (com:Command) : void {
		if (activeCommands.contains(com)) return;
		
		activeCommands.add(com);

		if (com is AsyncCommand) {
			var async:AsyncCommand = com as AsyncCommand;
			addListeners(async);
			if (async.active) return;
		}
		
		if (com is CommandExecutor) {
			CommandExecutor(com).prepare(lifecycle, data);
		}
		
		try {
			lifecycle.beforeExecution(com, data);
			if (logger.isDebugEnabled()) logger.debug("Executing command {0}", com);
			com.execute();
		}
		catch (e:Error) {
			activeCommands.remove(com);
			commandError(com, e);
			return;
		}
		
		if (!(com is AsyncCommand)) {
			activeCommands.remove(com);
			var result:CommandResult = DefaultCommandResult.forCompletion(com, null);
			lifecycle.afterCompletion(com, result);
			commandComplete(result);
		}
	}
	
	private function addListeners (com:AsyncCommand) : void {
		com.addEventListener(CommandResultEvent.COMPLETE, commandCompleteHandler, false, -1);
		com.addEventListener(CommandResultEvent.ERROR, commandErrorHandler, false, -1);
		com.addEventListener(CommandEvent.CANCEL, commandCancelledHandler, false, -1);
	}
	
	private function removeListeners (com:AsyncCommand) : void {
		com.removeEventListener(CommandResultEvent.COMPLETE, commandCompleteHandler);
		com.removeEventListener(CommandResultEvent.ERROR, commandErrorHandler);
		com.removeEventListener(CommandEvent.CANCEL, commandCancelledHandler);
	}
	
	private function removeActiveCommand (com:AsyncCommand, result:CommandResult) : void {
		if (suspended) {
			throw new IllegalStateError("Child command " + com 
					+ " completed while executor was suspended");
		}
		removeListeners(com);
		activeCommands.remove(com);
		lifecycle.afterCompletion(com, result);
	}

	private function commandCompleteHandler (event:CommandResultEvent) : void {
		var com:AsyncCommand = event.target as AsyncCommand;
		removeActiveCommand(com, event);
		_data.addValue(event.value);
		commandComplete(event);
	}
	
	/**
	 * Invoked when a child command has completed its operation successfully.
	 * It may also get invoked when a child command has been cancelled 
	 * (in case <code>processCancellations</code> is set to true) and commands
	 * that failed (in case the <code>processErrors</code> is set to true).
	 * 
	 * @param result the result of the command
	 */
	protected function commandComplete (result:CommandResult) : void {
		/* default implementation does nothing */ 
	}
	
	private function commandErrorHandler (event:CommandResultEvent) : void {
		var com:AsyncCommand = event.target as AsyncCommand;
		removeActiveCommand(com, event);
		commandError(com, event.value);
	}
	
	private function commandError (com:Command, cause:Object) : void {
		if (processErrors) {
			commandComplete(DefaultCommandResult.forError(com, cause));
		} else {
			doCancel();
			error(new CommandFailure(this, com, cause));
		}
	}
	
	private function commandCancelledHandler (event:CommandEvent) : void {
		var com:AsyncCommand = event.target as AsyncCommand;
		var result:CommandResult = DefaultCommandResult.forCancellation(com);
		removeActiveCommand(com, result);
		if (processCancellations) {
			commandComplete(result);
		}
		else {
			cancel();
		}
	}
	
	/**
	 * @private
	 */
	protected override function complete (result:Object = null) : void {
		if (result === null) {
			result = data;
		}
 		super.complete(result);
	}

	/**
	 * @private
	 */
	public override function suspend () : void {
		if (!suspendable) throw new IllegalStateError("Command '" + this + "' cannot be suspended");
 		super.suspend();
	}
	
	/**
	 * @private
	 */	
	public override function cancel () : void {
		if (!cancellable) throw new IllegalStateError("Command '" + this + "' cannot be cancelled");
		super.cancel();
	}
	
	/**
	 * @private
	 */
	protected override function doSuspend () : void {
		for each (var com:SuspendableCommand in activeCommands) {
			if (!com.suspended) com.suspend();
		}
	}
	
	/**
	 * @private
	 */
	protected override function doResume () : void {
		for each (var com:SuspendableCommand in activeCommands) {
			if (com.suspended) com.resume();
		}
	}
	
	/**
	 * @private
	 */
	protected override function doCancel () : void {
		for each (var com:AsyncCommand in activeCommands) {
			removeListeners(AsyncCommand(com));
			if (CommandUtil.isCancellable(com)) {
				CancellableCommand(com).cancel();
			}
		}
		activeCommands.removeAll();
	}

		
}
	
}