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

import org.spicefactory.lib.command.events.CommandFailure;
import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.adapter.CommandAdapter;
import org.spicefactory.lib.command.base.AbstractSuspendableCommand;
import org.spicefactory.lib.command.base.DefaultCommandResult;
import org.spicefactory.lib.command.builder.CommandProxyBuilder;
import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.data.DefaultCommandData;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.lifecycle.CommandLifecycle;
import org.spicefactory.lib.command.lifecycle.DefaultCommandLifecycle;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.command.result.ResultProcessors;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.types.Void;

import flash.events.ErrorEvent;

	
/**
 * A CommandAdapter that for commands that adhere to the conventions of Spicelib's "Light Commands".
 * 
 * <p>Such a light command does not implement any of the Command interfaces. It has a required method
 * called <code>execute</code> that may expect data to be passed to it through its method parameters.
 * It supports an optional no-arg <code>cancel</code> method. For asynchronous operation it supports
 * a callback function that is either passed to the execute method or injected into a public property
 * called <code>callback</code>.</p>
 * 
 * @author Jens Halm
 */
public class LightCommandAdapter extends AbstractSuspendableCommand implements CommandAdapter {


	private var _target:Object;
	
	private var async:Boolean;
	private var callbackProperty:Property;
	private var executeMethod:Method;
	private var cancelMethod:Method;
	private var resultMethod:Method;
	private var errorMethod:Method;
	
	private var _lifecycle:CommandLifecycle;
	private var _data:DefaultCommandData;
	
	private var resultProcessor: CommandProxy;
	
	
	private static const errorTypes:Array = [Error, ErrorEvent];
	
	/**
	 * Adds a type of result that should be interpreted as an Error.
	 * 
	 * @param the type of result that should be interpreted as an Error
	 */
	public static function addErrorType (type:Class) : void {
		errorTypes.push(type);
	}
	
	/**
	 * Indicates whether the specified result value represents a known
	 * error type.
	 * 
	 * @param result the result instance to check
	 * @return true if the specified result value represents a known
	 * error type
	 */
	public static function isErrorType (result: Object): Boolean {
		for each (var errorType:Class in errorTypes) {
 			if (result is errorType) return true;
 		}
 		return false;
	}
 	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param target the target command instance
	 * @param executeMethod the method to invoke when the command gets executed
	 * @param callback the optional callback property to inject a callback function into
	 * @param cancelMethod the optional cancel method to invoke whent the command gets cancelled
	 * @param async flag indicating whether this command executes asynchronously
	 */
	function LightCommandAdapter (target:Object, executeMethod:Method, 
			callback:Property, cancelMethod:Method, resultMethod:Method, 
			errorMethod:Method, async:Boolean) {
		_target = target;
		this.callbackProperty = callback;
		this.executeMethod = executeMethod;
		this.cancelMethod = cancelMethod;
		this.resultMethod = resultMethod;
		this.errorMethod = errorMethod;
		this.async = async;
		_data = new DefaultCommandData();
	}


	/**
	 * @inheritDoc
	 */
	public function get target () : Object {
		return _target;
	}

	/**
	 * @inheritDoc
	 */
	public function get cancellable () : Boolean {
		return (resultProcessor) ? resultProcessor.cancellable : (cancelMethod != null);
	}

	/**
	 * @inheritDoc
	 */
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
	
	/**
	 * The lifecycle hook to use for the commands executed by this instance.
	 */
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
	
	/**
	 * @private
	 */
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
				if (executeMethod.returnType.getClass() != Void) {
					var result:Object = executeMethod.invoke(target, params);
					handleResult(result);
				}
				else {
					executeMethod.invoke(target, params);
					handleResult(null);
				}
			}
		}
		catch (e:Error) {
			afterCompletion(DefaultCommandResult.forError(target, e));
			error(e);
		}
	}
	
	private function getParameters () : Array {
		var params:Array = [];
		for each (var param:Parameter in executeMethod.parameters) {
			if (param.type.getClass() == Function) {
				params.push(callback);
				continue;
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
				break;
			}
		}
		return params;
	}
	
	private function callback (result:* = undefined) : void {
		if (!active) {
			throw new IllegalStateError("Callback invoked although command " + target + " is not active");
		}
		if (result === undefined) {
			handleCancellation();
		}
		else if (isErrorType(result)) {
			handleError(result);
		}
		else {
			handleResult(result);
		}
 	}
 	
 	private function handleResult (result: Object): void {
 		var builder:CommandProxyBuilder = (result) ? ResultProcessors.newProcessor(target, result) : null;
		if (builder) {
			processResult(builder);
		}
		else {
			handleCompletion(result);				
		}
 	}
 	
 	private function handleCompletion (result: Object): void {
 		result = invokeResultHandler(resultMethod, result);
 		if (isErrorType(result)) {
 			handleError(result);
 			return;
 		}
 		afterCompletion(DefaultCommandResult.forCompletion(target, result));
 		resultProcessor = null;
 		complete(result);
 	}
 	
 	private function handleError (cause: Object): void {
 		cause = invokeResultHandler(errorMethod, cause);
 		afterCompletion(DefaultCommandResult.forError(target, cause));
		resultProcessor = null;
		error(cause);
 	}
 	
 	private function invokeResultHandler (method: Method, value: Object): Object {
 		if (!method) return value;
 		var param:Object = getParam(method, value);
 		try {
 			if (method.returnType.getClass() == Void) {
 				method.invoke(target, [param]);
 				return value;
 			}
 			else {
 				return method.invoke(target, [param]);
 			}
 		}
 		catch (e: Error) {
 			return e;
 		}
 		return null; // unreachable, but mxmlc is stupid
 	}
 	
 	private function getParam (method: Method, value: Object): Object {
 		if (value is CommandFailure) {
 			if (!method.returnType.isType(CommandFailure)) {
 				return CommandFailure(value).rootCause;
 			}
 		}
 		return value;
 	}
 	
 	private function handleCancellation (): void {
 		// do not call cancel to bypass doCancel
		afterCompletion(DefaultCommandResult.forCancellation(target));
		resultProcessor = null;
 		dispatchEvent(new CommandEvent(CommandEvent.CANCEL));	
 	}
 	
 	private function processResult (builder: CommandProxyBuilder): void {
 		resultProcessor = builder
 			.domain(executeMethod.owner.applicationDomain)
 			.result(function (result: Object): void { 
 				handleCompletion(result); })
 			.error(function (cause: Object): void { 
 				handleError(cause); })
 			.cancel(function (): void { 
 				handleCancellation(); })
 			.execute();
 	}
 	
 	private function afterCompletion (cr: CommandResult): void {
 		lifecycle.afterCompletion(target, cr);
 	}
 	
	/**
	 * @private
	 */
	protected override function doCancel () : void {
		if (resultProcessor) 
		{
			resultProcessor.cancel();
			resultProcessor = null;
		}
		else {
			cancelMethod.invoke(target, []);
		}
		afterCompletion(DefaultCommandResult.forCancellation(this));
	}

	
}
}
