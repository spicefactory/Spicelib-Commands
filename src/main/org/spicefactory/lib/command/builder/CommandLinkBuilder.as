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

import org.spicefactory.lib.command.flow.LinkConditions;
import org.spicefactory.lib.command.flow.CommandLink;
import org.spicefactory.lib.command.flow.LinkCondition;
	
/**
 * Builder for specifying link conditions in a command flow.
 * 
 * @author Jens Halm
 */
public class CommandLinkBuilder {
	
	
	/**
	 * @private
	 */
	internal var target:Object;
	
	/**
	 * @private
	 */
	internal var links:Array = new Array();
	
	
	/**
	 * @private
	 */
	public function CommandLinkBuilder (target:Object) {
		this.target = target;
	}
	
	
	private function newTargetBuilder (condition:LinkCondition) : LinkTargetBuilder {
		var builder:LinkTargetBuilder = new LinkTargetBuilder(this, condition);
		links.push(builder);
		return builder;
	}
	
	/**
	 * Creates a link that only executes if the result produced by the 
	 * command in the flow is of the specified type.
	 * 
	 * @param type the type of result the command must produce for this link to have an effect
	 * @return a builder to specify the action to perform when the link condition is met
	 */
	public function linkResultType (type:Class) : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forResultType(type));
	}
	
	/**
	 * Creates a link that only executes if the result produced by the 
	 * command in the flow equals the specified value.
	 * 
	 * @param value the result the command must produce for this link to have an effect
	 * @return a builder to specify the action to perform when the link condition is met
	 */
	public function linkResultValue (value:Object) : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forResultValue(value));
	}
	
	/**
	 * Creates a link that only executes if the result produced by the 
	 * command in the flow has the specified property value.
	 * 
	 * @param name the name of the property
	 * @param value the value the property must have for this link to have an effect
	 * @return a builder to specify the action to perform when the link condition is met
	 */
	public function linkResultProperty (name:String, value:Object) : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forResultProperty(name, value));
	}
	
	/**
	 * Creates a link that executes for all types of results produced by the 
	 * command in the flow.
	 * 
	 * @return a builder to specify the action to perform
	 */
	public function linkAllResults () : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forAllResults());
	}
	
	/**
	 * Specifies a link function to invoke after the command finished executing.
	 * The signature of the funciton must be 
	 * <code>(result: CommandResult, processor: CommandLinkProcessor): void</code>.
	 * 
	 * @param link a link function to invoke after the command finished executing
	 */
	public function linkFunction (link:Function) : void {
		links.push(new LinkFunction(link));
	}
	
	/**
	 * Specifies a custom link to invoke after the command finished executing.
	 * 
	 * @param link a link to invoke after the command finished executing
	 */
	public function link (link:CommandLink) : void {
		links.push(link);
	}
	
	
}
}

import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.flow.CommandLink;
import org.spicefactory.lib.command.flow.CommandLinkProcessor;

class LinkFunction implements CommandLink {

	private var delegate:Function;
	
	function LinkFunction (delegate:Function) {
		this.delegate = delegate;
		
	}
	
	public function link (result:CommandResult, processor:CommandLinkProcessor) : void {
		delegate(result, processor);
	}
	
}

