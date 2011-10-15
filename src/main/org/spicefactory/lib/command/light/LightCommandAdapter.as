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

import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.adapter.CommandAdapter;
import org.spicefactory.lib.command.base.AbstractSuspendableCommand;
import org.spicefactory.lib.command.base.DefaultCommandResult;
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
		_data = new DefaultCommandData();
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
		lifecycle.beforeExecution(target, data);
		if (callbackProperty) {
			callbackProperty.setValue(target, callback);
		}
		var params:Array = getParameters();
		try {
			if (async) {
				executeMethod.invoke(target, params);
			}
			else {
				var result:Object;
				if (executeMethod.returnType.getClass() != Void) {
					result = executeMethod.invoke(target, params);
					complete(result);
				}
				else {
					executeMethod.invoke(target, params);
					complete();
				}
				lifecycle.afterCompletion(target, DefaultCommandResult.forCompletion(target, result));
			}
		}
		catch (e:Error) {
			error(e);
			lifecycle.afterCompletion(target, DefaultCommandResult.forError(target, e));
		}
	}
	
	private function getParameters () : Array {
		var params:Array = [];
		for each (var param:Parameter in executeMethod.parameters) {
			if (param.type.getClass() == Function) {
				params.push(callback);
				break;
			}
			var value:Object = data.getObject(param.type.getClass());
			if (value) {
				params.push(value);
			}
			else if (param.required) {
				throw new IllegalStateError("No data available for required parameter of type " 
						+ param.type.name);
			}
			else {
				params.push(undefined);
			}
		}
		return params;
	}
	
	private function callback (result:* = undefined) : void {
		if (!active) {
			throw new IllegalStateError("Callback invoked although command " + target + " is not active");
		}
		var cr:CommandResult;
		if (result === undefined) {
			// do not call cancel to bypass doCancel
			cr = DefaultCommandResult.forCancellation(target);
			dispatchEvent(new CommandEvent(CommandEvent.CANCEL));	
		}
		else if (isError(result)) {
			cr = DefaultCommandResult.forError(target, result);
			error(result);
		}
		else {
			cr = DefaultCommandResult.forCompletion(target, result);
			complete(result);
		}
		lifecycle.afterCompletion(target, cr);
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
		lifecycle.afterCompletion(target, DefaultCommandResult.forCancellation(this));
	}

	
}
}
