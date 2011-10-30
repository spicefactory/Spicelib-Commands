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

package org.spicefactory.lib.command.builder {

import org.spicefactory.lib.command.flow.CommandLink;
import org.spicefactory.lib.command.flow.CommandLinks;
	
/**
 * Builder for specifying the default action for a flow
 * when a command result does not have any matching links.
 * 
 * @author Jens Halm
 */
public class DefaultLinkBuilder {
	
	
	private var flowBuilder: CommandFlowBuilder;
	internal var link: CommandLink;
	
	
	/**
	 * @private
	 */
	function DefaultLinkBuilder (flowBuilder: CommandFlowBuilder) {
		this.flowBuilder = flowBuilder;
	}
	
	
	/**
	 * Sets an error with the specified value as the default 
	 * action when a command result does not have any matching links.
	 * 
	 * @value the value of the error
	 * @return the flow builder for further configuration
	 */
	public function toFlowError (value: Object): CommandFlowBuilder {
		link = CommandLinks.toFlowError(value);
		return flowBuilder;
	}
	
	/**
	 * Sets flow cancellation as the default 
	 * action when a command result does not have any matching links.
	 * 
	 * @return the flow builder for further configuration
	 */
	public function toFlowCancellation (): CommandFlowBuilder {
		link = CommandLinks.toFlowCancellation();
		return flowBuilder;
	}
	
	/**
	 * Sets successful flow completion as the default 
	 * action when a command result does not have any matching links.
	 * 
	 * @return the flow builder for further configuration
	 */
	public function toFlowEnd (): CommandFlowBuilder {
		link = CommandLinks.toFlowEnd();
		return flowBuilder;
	}
	
	
	
}
}