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
import org.spicefactory.lib.command.CommandResult;
	
/**
 * Represents a condition of a CommandLink.
 * 
 * @author Jens Halm
 */
public interface LinkCondition {

	/**
	 * Determines whether the condition this instance represents
	 * is met based on the specified result of the preceding command
	 * in the flow.
	 * 
	 * @param result the result of the preceding command in the flow
	 * @return true if the condition is met and the associated link action should be performed
	 */	
	function matches (result:CommandResult) : Boolean;
	
}
}
