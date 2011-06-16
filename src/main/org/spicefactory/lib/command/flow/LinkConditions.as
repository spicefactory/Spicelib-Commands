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
 * @author Jens Halm
 */
public class LinkConditions {
	
	
	public static function forResultType (type:Class) : LinkCondition {
		return new ResultTypeCondition(type);
	}
	
	public static function forResultValue (value:Object) : LinkCondition {
		return new ResultValueCondition(value);
	}
	
	public static function forResultProperty (name:String, value:Object) : LinkCondition {
		return new ResultPropertyCondition(name, value);
	}
	
	public static function forDefault () : LinkCondition {
		return new DefaultCondition();
	}
	
	
}
}


import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.flow.LinkCondition;

class DefaultCondition implements LinkCondition {

	public function matches (result:CommandResult) : Boolean {
		return true;
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

