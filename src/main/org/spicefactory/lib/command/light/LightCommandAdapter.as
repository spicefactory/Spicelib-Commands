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

import org.spicefactory.lib.command.adapter.CommandAdapter;
import org.spicefactory.lib.command.base.AbstractSuspendableCommand;
import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.data.DefaultCommandData;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.lifecycle.CommandLifecycle;
import org.spicefactory.lib.command.lifecycle.DefaultCommandLifecycle;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.types.Void;

import flash.events.ErrorEvent;

	
/**
 * @author Jens Halm
 */
public class LightCommandAdapter extends AbstractSuspendableCommand implements CommandAdapter {


	private var _target:Object;
	
	private var async:Boolean;
	private var callbackProperty:Property;
	private var executeMethod:Method;
	private var cancelMethod:Method;
	
	private var _lifecycle:CommandLifecycle;
	private var _data:DefaultCommandData;
	
	
	private static const errorTypes:Array = [Error, ErrorEvent];
	
	public static function addErrorType (type:Class) : void {
		errorTypes.push(type);
	}
 	
	
	function LightCommandAdapter (target:Object, executeMethod:Method, 
			callback:Property, cancelMethod:Method, async:Boolean) {
		_target = target;
		this.callbackProperty = callbackProperty;
		this.executeMethod = executeMethod;
		this.cancelMethod = cancelMethod;
		this.async = async;
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
	
	/**
	 * @inheritDoc
	 */
	public function prepare (lifecycle:CommandLifecycle, data:CommandData) : void {
		_lifecycle = lifecycle;
		_data = new DefaultCommandData(data);	
	}
	
	protected function get lifecycle () : CommandLifecycle {
		if (!_lifecycle) {
			_lifecycle = new DefaultCommandLifecycle();
		}
		return _lifecycle;
	}
    
    /**
     * The data associated with this executor.
     * Contains any results from previously executed commands or
     * data specified upfront.
     */
    protected function get data () : CommandData {
    	if (!_data) {
    		_data = new DefaultCommandData();
    	}
    	return _data;
    }
	
	protected override function doExecute () : void {
		_lifecycle.beforeExecution(target, new DefaultCommandData());
		if (callbackProperty) {
			callbackProperty.setValue(target, callback);
		}
		var params:Array = getParameters();
		try {
			if (async) {
				executeMethod.invoke(target, params);
			}
			else {
				if (executeMethod.returnType.getClass() != Void) {
					var result:Object = executeMethod.invoke(target, params);
					complete(result);
				}
				else {
					executeMethod.invoke(target, params);
					complete();
				}
				_lifecycle.afterCompletion(target);
			}
		}
		catch (e:Error) {
			error(e);
			_lifecycle.afterCompletion(target);
		}
	}
	
	private function getParameters () : Array {
		var params:Array = [];
		for each (var param:Parameter in executeMethod.parameters) {
			if (param.type.getClass() == Function) {
				params.push(callback);
			}
			var value:Object = _data.getObject(param.type.getClass());
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
	}
	
	private function callback (result:* = undefined) : void {
		if (!active) {
			throw new IllegalStateError("Callback invoked although command " + target + " is not active");
		}
		if (result === undefined) {
			// do not call cancel to bypass doCancel
			dispatchEvent(new CommandEvent(CommandEvent.CANCEL));	
		}
		else if (isError(result)) {
			error(result);
		}
		else {
			complete(result);
		}
		_lifecycle.afterCompletion(target);
 	}
 	
 	private function isError (result:Object) : Boolean {
 		for each (var type:Class in errorTypes) {
 			if (result is type) return true;
 		}
 		return false;
 	}
	
	/**
	 * @private
	 */
	protected override function doCancel () : void {
		cancelMethod.invoke(target, []);
		_lifecycle.afterCompletion(target);
	}

	
}
}
