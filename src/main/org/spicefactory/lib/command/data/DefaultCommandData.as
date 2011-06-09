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

import org.spicefactory.lib.command.data.CommandData;

/**
 * @author Jens Halm
 */
public class DefaultCommandData implements CommandData {


	private var data:Array = new Array();
	
	
	public function addValue (value:Object) : void {
		data.push(value);
	}


	public function getLastResult (type:Class = null) : Object {
		type ||= Object;
		for (var i:int = data.length - 1; i >= 0; i--) {
			if (data[i] is type) return data[i];
		}
		return null;
	}

	public function getAllResults (type:Class = null) : Array {
		if (!type) return data.concat();
		var results:Array = [];
		for each (var value:Object in data) {
			if (value is type) results.push(value);
		}
		return results;
	}
	
	
}
}
