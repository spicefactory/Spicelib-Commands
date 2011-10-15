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
package org.spicefactory.lib.command.data {


/**
 * @author Jens Halm
 */
public class DefaultCommandData implements CommandData {


	private var data:Array = new Array();
	private var parent:CommandData;
	
	private var inProgress:Boolean;
	
	
	function DefaultCommandData (parent:CommandData = null) {
		this.parent = parent; 
	}
	
	public function addValue (value:Object) : void {
		data.push(value);
	}
	
	public function getObject (type:Class = null) : Object {
		if (inProgress) return null;
		type ||= Object;
		inProgress = true;
		try {
			for (var i:int = data.length - 1; i >= 0; i--) {
				if (data[i] is type) {
					return data[i];
				}
				else if (data[i] is CommandData) {
					var result:Object = CommandData(data[i]).getObject(type);
					if (result) return result;
				}
			}
			return (parent) ? parent.getObject(type) : null; 
		}
		finally {
			inProgress = false;
		}
		return null;
	}

	public function getAllObjects (type:Class = null) : Array {
		if (inProgress) return [];
		type ||= Object;
		inProgress = true;
		var results:Array = [];
		try {
			for each (var value:Object in data) {
				if (value is CommandData) {
					results = results.concat(CommandData(value).getAllObjects(type));
				}
				else if (value is type) {
					results.push(value);
				}
			}
			if (parent) {
				results = results.concat(parent.getAllObjects(type));
			}
		} 
		finally {
			inProgress = false;
		}
		return results;
	}
	
	
}
}
