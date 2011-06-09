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

package org.spicefactory.lib.command.util {

import flash.events.TimerEvent;
import org.spicefactory.lib.command.base.AbstractCancellableCommand;

import flash.utils.Timer;

/**
 * @author Jens Halm
 */
public class DelayCommand extends AbstractCancellableCommand {


	private var delay:uint;
	private var timer:Timer;


	function DelayCommand (delay:uint) {
		super("[DelayCommand(" + delay + " ms)]");
		this.delay = delay;
	}
	
	
	protected override function doExecute () : void {
		timer = new Timer(delay, 1);
		timer.addEventListener(TimerEvent.TIMER, timerComplete);
		timer.start();
	}
	
	private function timerComplete (event:TimerEvent) : void {
		timer = null;
		complete();
	}
	
	protected override function doCancel () : void {
		timer.reset();
		timer = null;
	}
	
	
}
}
