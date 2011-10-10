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

package org.spicefactory.lib.command.proxy {

import flash.events.TimerEvent;
import flash.utils.Timer;
import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.adapter.CommandAdapters;
import org.spicefactory.lib.command.base.AbstractCancellableCommand;
import org.spicefactory.lib.command.base.AbstractCommandExecutor;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.events.CommandTimeout;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;


	
/**
 * @author Jens Halm
 */
public class DefaultCommandProxy extends AbstractCommandExecutor implements CommandProxy {
	
	
	private static var logger:Logger = LogContext.getLogger(AbstractCancellableCommand);
	
	
	private var _target:Command;
	private var _type:Class;
	
	private var timer : Timer;
	private var _timeout:uint;
	
	private var proxyDescription:String;
	
	
	function DefaultCommandProxy () {
		addEventListener(CommandResultEvent.COMPLETE, commandInactive, false, 2);
		addEventListener(CommandResultEvent.ERROR, commandInactive, false, 2);
		addEventListener(CommandEvent.CANCEL, commandInactive, false, 2);
		addEventListener(CommandEvent.SUSPEND, commandInactive, false, 2);
		addEventListener(CommandEvent.RESUME, commandActive, false, 2);
	}
	
	
	public function get target () : Command {
		return _target;
	}
	
	public function set target (value:Command) : void {
		_target = value;
	}
	
	public function set type (value:Class) : void {
		_type = value;
	}
	
	public function set description (value:String) : void {
		proxyDescription = value;
	}
	
	/**
	 * The timeout in milliseconds. A value of 0 disables the timeout.
	 */
	public function get timeout ():uint {
		return _timeout;
	}

	public function set timeout (timeout:uint):void {
		_timeout = timeout;
	}
	
	/**
	 * @private
	 */
	protected override function doExecute () : void {
		if (!_target && !_type) {
			throw IllegalStateError("Either target or type property must be set");
		}
		if (!_target) {
			var target:Object = lifecycle.createInstance(_type, data);
			_target = (target is Command)
				? target as Command
				: CommandAdapters.createAdapter(target);
		}
		executeCommand(_target);
		startTimer();
	}
	
	private function commandInactive (event:CommandEvent) : void {
		cancelTimer();
	}
	
	private function commandActive (event:CommandEvent) : void {
		startTimer();
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
	public override function toString () : String {
		return (proxyDescription)
				? proxyDescription
				: (_target) 
					? (_target as Object).toString() 
					: "[Lazy CommandProxy]";
	}

	
}
}
