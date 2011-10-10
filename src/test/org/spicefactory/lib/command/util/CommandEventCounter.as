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

import org.flexunit.assertThat;
import org.hamcrest.object.equalTo;
import org.spicefactory.lib.command.AsyncCommand;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.events.CommandResultEvent;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class CommandEventCounter {


	private var _results: Array = new Array();
	private var _errors: Array = new Array();
	private var _events: Dictionary = new Dictionary();


	function CommandEventCounter (target: AsyncCommand) {
		target.addEventListener(CommandResultEvent.COMPLETE, handleResultEvent);
		target.addEventListener(CommandResultEvent.ERROR, handleResultEvent);
		target.addEventListener(CommandEvent.CANCEL, handleEvent);
		target.addEventListener(CommandEvent.SUSPEND, handleEvent);
		target.addEventListener(CommandEvent.RESUME, handleEvent);
	}

	private function handleResultEvent (event: CommandResultEvent): void {
		var target: Array = (event.type == CommandResultEvent.COMPLETE) ? _results : _errors;
		target.push(event.value);
		handleEvent(event);
	}
	
	private function handleEvent (event: CommandEvent): void {
		_events[event.type] ||= 0;
		_events[event.type]++;
	}
	
	public function assertEvents (complete: uint, error: uint = 0, cancel: uint = 0, suspend: uint = 0, resume: uint = 0): void {
		assertThat(eventCount(CommandResultEvent.COMPLETE), equalTo(complete));
		assertThat(eventCount(CommandResultEvent.ERROR), equalTo(error));
		assertThat(eventCount(CommandEvent.CANCEL), equalTo(cancel));
		assertThat(eventCount(CommandEvent.SUSPEND), equalTo(suspend));
		assertThat(eventCount(CommandEvent.RESUME), equalTo(resume));
	}
	
	private function eventCount (type: String): uint {
		return _events[type] || 0;
	}
	
	public function getResults (): Array {
		return _results;
	}
	
	public function getErrors (): Array {
		return _errors;
	}
	
	public function getResult (): Object {
		assertThat(eventCount(CommandResultEvent.COMPLETE), equalTo(1));
		return _results[0];
	}
	
	public function getError (): Object {
		assertThat(eventCount(CommandResultEvent.ERROR), equalTo(1));
		return _errors[0];
	}
	
}
}
