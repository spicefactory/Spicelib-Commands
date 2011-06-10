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

package org.spicefactory.lib.command.light {

import org.spicefactory.lib.command.CommandAdapter;
import org.spicefactory.lib.command.base.AbstractSuspendableCommand;
import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.data.DefaultCommandData;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.lifecycle.CommandLifecycle;
import org.spicefactory.lib.command.lifecycle.DefaultCommandLifecycle;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;

import flash.events.ErrorEvent;
	
/**
 * @author Jens Halm
 */
public class LightCommandAdapter extends AbstractSuspendableCommand implements CommandAdapter {


	private var _target:Object;
	
	private var executeMethod:Method;
	private var cancelMethod:Method;
	
	private var _lifecycle:CommandLifecycle;
	private var _data:CommandData; // TODO - obtain data from parent
	
	
	function LightCommandAdapter (target:Object, info:ClassInfo) {
		_target = target;
		executeMethod = info.getMethod("execute");
		cancelMethod = info.getMethod("cancel");
		if (cancelMethod.parameters.length > 0) {
			cancelMethod = null;
		}
	}


	public function get target () : Object {
		return _target;
	}

	public function get cancellable () : Boolean {
		return (cancelMethod != null);
	}

	public function get suspendable () : Boolean {
		return false;
	}
	
	protected override function doExecute () : void {
		_lifecycle.beforeExecution(target, new DefaultCommandData());
		var params:Array = [];
		var async:Boolean = false;
		for each (var param:Parameter in executeMethod.parameters) {
			if (param.type.getClass() == Function) {
				async = true;
				params.push(callback);
			}
			var value:Object = _data.getLastResult(param.type.getClass());
			if (value) {
				params.push(value);
			}
			else if (param.required) {
				throw new IllegalStateError("No data available for required constructor parameter of type " 
						+ param.type.name);
			}
			else {
				params.push(undefined);
			}
		}
		try {
			if (async) {
				executeMethod.invoke(target, params);
			}
			else {
				var result:Object = executeMethod.invoke(target, params); // TODO - check void return type
				complete(result);
				_lifecycle.afterCompletion(target);
			}
		}
		catch (e:Error) {
			error(e);
			_lifecycle.afterCompletion(target);
		}
	}
	
	private function callback (result:* = undefined) : void {
		if (!active) {
			throw new IllegalStateError("Callback invoked although command " + target + " is not active");
		}
		if (result === undefined) {
			// do not call cancel to bypass doCancel
			dispatchEvent(new CommandEvent(CommandEvent.CANCEL));	
		}
		else if (result is Error || result is ErrorEvent) {
			// TODO - add hook to extend this list of known error types
			error(result);
		}
		else {
			complete(result);
		}
		_lifecycle.afterCompletion(target);
 	}
	
	/**
	 * @private
	 */
	protected override function doCancel () : void {
		cancelMethod.invoke(target, []);
		_lifecycle.afterCompletion(target);
	}

	/**
	 * @inheritDoc
	 */	
	public function get lifecycle () : CommandLifecycle {
		if (!_lifecycle) {
			_lifecycle = new DefaultCommandLifecycle();
		}
		return _lifecycle;
	}
    
    public function set lifecycle (value:CommandLifecycle) : void {
    	_lifecycle = value;
    }

	
}
}
