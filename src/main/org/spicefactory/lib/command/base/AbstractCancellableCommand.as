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

import org.spicefactory.lib.command.CancellableCommand;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.events.CommandTimeout;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

import flash.events.TimerEvent;
import flash.utils.Timer;

	
/**
 * @author Jens Halm
 */
public class AbstractCancellableCommand extends AbstractAsyncCommand implements CancellableCommand {
	
	
	private static var logger:Logger = LogContext.getLogger(AbstractCancellableCommand);
	
	
	private var _timeout : uint;
	private var timer : Timer;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param description a description of this command for logging purposes
	 * @param timeout the timeout for this Task in milliseconds or 0 for disabling the timeout
	 */
	public function AbstractCancellableCommand (description:String = null, timeout:uint = 0) {
		super(description);
		_timeout = timeout;
		addEventListener(CommandResultEvent.COMPLETE, commandInactive, false, 2);
		addEventListener(CommandResultEvent.ERROR, commandInactive, false, 2);
		addEventListener(CommandEvent.SUSPEND, commandInactive, false, 2);
		addEventListener(CommandEvent.RESUME, commandActive, false, 2);
	}
	
	private function commandInactive (event:CommandResultEvent) : void {
		cancelTimer();
	}
	
	private function commandActive (event:CommandResultEvent) : void {
		startTimer();
	}
	
	/**
	 * The timeout in milliseconds. A value of 0 disables the timeout.
	 */
	public function get timeout () : uint {
		return _timeout;
	}
	
	private function startTimer () : void {
		cancelTimer();
		if (timeout > 0) {
			timer = new Timer(_timeout, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimeout);
			timer.start();
		}
	}		
	
	private function cancelTimer () : void {
		if (timer != null) {
			timer.reset();
			timer = null;
		}
	}
		
	private function onTimeout (evt:TimerEvent) : void {
		if (active) {
			doCancel();
			error(new CommandTimeout(timeout));
		} else {
			logger.error("Internal error: timeout in command '{0}' although it is not active", this);
		}
		timer = null;
	}
	
	/**
	 * @private
	 */
	public override function execute () : void {
		super.execute();
		startTimer();
	}
	
	/**
	 * Cancels this command. If the command is not currently active,
	 * invoking this method has no effect.
	 */
	public function cancel () : void {
		if (!active) {
			logger.error("Attempt to suspend inactive command '{0}'", this);
			return;
		}
		cancelTimer();
		doCancel();
		dispatchEvent(new CommandEvent(CommandEvent.CANCEL));	
	}
	
	/**
	 * Invoked when this command gets cancelled, either due to an explicit invocation of the
	 * cancel method or in case a timeout occurred. 
	 * Subclasses should override this method and cancel the actual operation
	 * this command performs.
	 */		
	protected function doCancel () : void {
		/* base implementation does nothing */
	}
	
	
}
}
