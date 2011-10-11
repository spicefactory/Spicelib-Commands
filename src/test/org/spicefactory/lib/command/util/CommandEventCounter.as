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
import org.hamcrest.collection.arrayWithSize;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.sameInstance;
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
	
	private var _resultCallbacks: Array = new Array();
	private var _errorCallbacks: Array = new Array();
	private var _cancelCallbacks: uint = 0;


	function CommandEventCounter (target: AsyncCommand = null) {
		if (target) this.target = target;
	}
	
	public function set target (value: AsyncCommand): void {
		value.addEventListener(CommandResultEvent.COMPLETE, handleResultEvent);
		value.addEventListener(CommandResultEvent.ERROR, handleResultEvent);
		value.addEventListener(CommandEvent.CANCEL, handleEvent);
		value.addEventListener(CommandEvent.SUSPEND, handleEvent);
		value.addEventListener(CommandEvent.RESUME, handleEvent);
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
	
	public function assertCallbacks (complete: uint, error: uint = 0, cancel: uint = 0): void {
		assertThat(_resultCallbacks, arrayWithSize(complete));
		assertThat(_errorCallbacks, arrayWithSize(error));
		assertThat(_cancelCallbacks, equalTo(cancel));
	}
	
	public function resultCallback (result: Object = null): void {
		_resultCallbacks.push(result);
	}
	
	public function errorCallback (error: Object = null): void {
		_errorCallbacks.push(error);
	}
	
	public function cancelCallback (): void {
		_cancelCallbacks++;
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
		assertThat(_resultCallbacks, arrayWithSize(1));
		assertThat(_resultCallbacks[0], sameInstance(_results[0]));
		return _results[0];
	}
	
	public function getError (): Object {
		assertThat(eventCount(CommandResultEvent.ERROR), equalTo(1));
		assertThat(_errorCallbacks, arrayWithSize(1));
		assertThat(_errorCallbacks[0], sameInstance(_errors[0]));
		return _errors[0];
	}
	
	public function getErrorFromCallback (): Object {
		assertThat(_errorCallbacks, arrayWithSize(1));
		return _errorCallbacks[0];
	}
	
}
}
