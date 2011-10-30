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
 * Represents the data produced by commands, usually inside a group or flow.
 * 
 * @author Jens Halm
 */
public interface CommandData {
	
	/**
	 * Returns the result of the specified type
	 * if any command has produced a matching result.
	 * In case of multiple matches the last matching
	 * result that was added to this instance is returned.
	 * When no matching result was added this method returns null.
	 * 
	 * @param type the type of the result to return (if omitted all types are considered)
	 * @return the last result added to this instance with a matching type
	 */
 	function getObject (type:Class = null) : Object;
 	
 	/**
	 * Returns all results of the specified type.
	 * When no matching result was added this method returns an empty Array.
	 * When a flow or group contains nested flows or groups their result is
	 * represented by a separate <code>CommandData</code> instance.
	 * 
	 * @param type the type of the results to return (if omitted all types are included)
	 * @return an Array holding all matching results that were added to this instance
	 */
 	function getAllObjects (type:Class = null) : Array;
 	
 	
}
}
