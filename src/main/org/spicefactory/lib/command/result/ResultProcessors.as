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
 
package org.spicefactory.lib.command.result {

import org.spicefactory.lib.command.builder.CommandProxyBuilder;
import org.spicefactory.lib.command.builder.Commands;

import flash.utils.Dictionary;
	
/**
 * Central registry for all available result processors.
 * A processor must be registered before executing a command
 * that produces a result that should be handled by the processor.
 * 
 * <p>A result processor is a command itself and can be built
 * with any of the available command implementation styles, including
 * light commands. The result itself may get passed to the execute
 * method the same way as data from preceding commands can get passed
 * to a regular command.</p>
 * 
 * @author Jens Halm
 */
public class ResultProcessors {
	
	
	private static var byCommandType: Dictionary = new Dictionary();
	private static var byResultType: Dictionary = new Dictionary();
	
	
	/**
	 * Returns the result processor registration for the specified
	 * command type. Such a processor processes all results produced
	 * by commands of this type (or any subtype), no matter what the
	 * type of the actual result is.
	 * 
	 * @param type the type of the command
	 * @return the registration for the result processor
	 */
	public static function forCommandType (type: Class): ResultProcessor {
		if (!byCommandType[type]) {
			byCommandType[type] = new ResultProcessor(type);
		}
		return byCommandType[type];
	}
	
	/**
	 * Returns the result processor registration for the specified
	 * result type. Such a processor processes all results of this type 
	 * (or any subtype), no matter what the type of the command that 
	 * produced the result.
	 * 
	 * @param type the type of the result
	 * @return the registration for the result processor
	 */
	public static function forResultType (type: Class): ResultProcessor {
		if (!byResultType[type]) {
			byResultType[type] = new ResultProcessor(type);
		}
		return byResultType[type];
	}
	
	/**
	 * Returns a new processor for the specified command and result
	 * or null if no matching processor was registered.
	 * 
	 * @param command the command that produced the result
	 * @param result the result value
	 * @return a new processor for the specified command and result
	 * or null if no matching processor was registered
	 */
	public static function newProcessor (command: Object, result: Object): CommandProxyBuilder {
		var processor: Object = createProcessor(command, result);
		if (!processor) return null;
		return Commands.wrap(processor).data(result);
	}
	
	private static function createProcessor (command: Object, result: Object): Object {
		var processor: ResultProcessor;
		for each (processor in byResultType) {
			if (processor.supports(result)) {
				return processor.newInstance();
			}
		}
		for each (processor in byCommandType) {
			if (processor.supports(command)) {
				return processor.newInstance();
			}
		}
		return null;
	}
	
	
}
}
