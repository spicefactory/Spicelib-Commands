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

package org.spicefactory.lib.command.flow {
	
/**
 * Helper class for creating common link condition types.
 * 
 * @author Jens Halm
 */
public class LinkConditions {
	
	
	/**
	 * Creates a condition for the specified result type.
	 * 
	 * @param type the result type that a command must produce for this condition to be met
	 * @return a condition instance for the specified result type
	 */
	public static function forResultType (type:Class) : LinkCondition {
		return new ResultTypeCondition(type);
	}
	
	/**
	 * Creates a condition for the specified result value.
	 * 
	 * @param value the result value that a command must produce for this condition to be met
	 * @return a condition instance for the specified result value
	 */
	public static function forResultValue (value:Object) : LinkCondition {
		return new ResultValueCondition(value);
	}
	
	/**
	 * Creates a condition for the specified result property value.
	 * 
	 * @param name the name of the property of the result
	 * @param value the property value that a command result must hold for this condition to be met
	 * @return a condition instance for the specified result result property value
	 */
	public static function forResultProperty (name:String, value:Object) : LinkCondition {
		return new ResultPropertyCondition(name, value);
	}
	
	/**
	 * Creates a condition that matches all results (except for cancellations and errors).
	 * 
	 * @return a condition instance for all results
	 */
	public static function forAllResults () : LinkCondition {
		return new DefaultCondition();
	}
	
	
}
}


import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.flow.LinkCondition;

class DefaultCondition implements LinkCondition {

	public function matches (result:CommandResult) : Boolean {
		return result.complete;
	}
	
}

class ResultTypeCondition implements LinkCondition {

	private var type:Class;
	
	function ResultTypeCondition (type:Class) {
		this.type = type;
	}
	
	public function matches (result:CommandResult) : Boolean {
		return result.complete && (result.value is type);
	}
	
}

class ResultValueCondition implements LinkCondition {

	private var value:*;
	
	function ResultValueCondition (value:*) {
		this.value = value;
	}
	
	public function matches (result:CommandResult) : Boolean {
		return result.complete && (result.value === value);
	}
	
}

class ResultPropertyCondition implements LinkCondition {

	private var name:String;
	private var value:*;
	
	function ResultPropertyCondition (name:String, value:*) {
		this.name = name;
		this.value = value;
	}
	
	public function matches (result:CommandResult) : Boolean {
		return result.complete 
			&& (result.value.hasOwnProperty(name) 
			&& result.value[name] === value);
	}
	
}

