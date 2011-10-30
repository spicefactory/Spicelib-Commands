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
 * Represents a single link between two commands or a command and a flow action like
 * cancellation or completion.
 * 
 * @author Jens Halm
 */
public interface CommandLink {
	

	/**
	 * Invoked after a command in the flow finished executing.
	 * The implementation is supposed to invoke the corresponding
	 * action in the specified processor if the specified result
	 * matches its conditions. If not the implementation should not
	 * invoke anything on the processor in which case the next link
	 * for the same command (if available) will get invoked 
	 * (Chain of Responsiblity Pattern).
	 * 
	 * @param result the result the preceding command produced
	 * @param processor the processor that can be used to specify the next action the flow should perform
	 */
	function link (result:CommandResult, processor:CommandLinkProcessor) : void;
	
	
}
}
