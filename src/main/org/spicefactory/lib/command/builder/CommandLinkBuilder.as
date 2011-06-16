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
	
	
	public function CommandLinkBuilder (target:Object) {
		this.target = target;
	}
	
	
	private function newTargetBuilder (condition:LinkCondition) : LinkTargetBuilder {
		var builder:LinkTargetBuilder = new LinkTargetBuilder(this, condition);
		links.push(builder);
		return builder;
	}
	
	public function linkResultType (type:Class) : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forResultType(type));
	}
	
	public function linkResultValue (value:Object) : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forResultValue(value));
	}
	
	public function linkResultProperty (name:String, value:Object) : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forResultProperty(name, value));
	}
	
	public function linkDefault () : LinkTargetBuilder {
		return newTargetBuilder(LinkConditions.forDefault());
	}
	
	public function linkFunction (link:Function) : void {
		links.push(new LinkFunction(link));
	}
	
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

