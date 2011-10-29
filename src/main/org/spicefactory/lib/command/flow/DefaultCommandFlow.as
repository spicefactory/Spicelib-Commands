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

import org.spicefactory.lib.collection.List;
import org.spicefactory.lib.collection.MultiMap;
import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.base.AbstractCommandExecutor;
import org.spicefactory.lib.command.group.CommandSequence;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

/**
 * @author Jens Halm
 */
public class DefaultCommandFlow extends AbstractCommandExecutor implements CommandFlow {
	
	
	private static var logger:Logger = LogContext.getLogger(CommandSequence);
	
	
	private var firstCommand:Command;
	private var links:MultiMap = new MultiMap();
	private var defaultLink:CommandLink;
	
	
	/**
	 * Creates a new sequence.
	 * 
	 */	
	function DefaultCommandFlow (description:String = null) {
		super(description, true, true);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function addLink (command:Command, link:CommandLink) : void {
		if (active) {
			throw IllegalStateError("Flow " + this + " was already started");
		}
		if (!firstCommand) {
			firstCommand = command;
		}
		links.add(command, link);
	}
	
	/**
	 * @inheritDoc
	 */
	public function setDefaultLink (link:CommandLink) : void {
		defaultLink = link;
	}
	
	/**
	 * @private
	 */
	protected override function doExecute () : void {
		if (!firstCommand) {
			complete();
			return;
		}
		executeCommand(firstCommand);
	}
	
	/**
	 * @private
	 */
	protected override function commandComplete (result:CommandResult) : void {
		var mappedLinks:List = links.getAll(result.command);
		var processor:Processor = new Processor(executeCommand, complete, cancel, error);
		for each (var link:CommandLink in mappedLinks) {
			if (processLink(link, result, processor)) return;
		}
		var fallback:CommandLink = defaultLink || CommandLinks.defaultLink;
		if (!processLink(fallback, result, processor)) {
			logger.error("Default link did not process result in flow {1}", result.value, result.command);
			error("Default link did not process result " + result.value);
		}
	}
	
	private function processLink (link:CommandLink, result:CommandResult, processor:Processor) : Boolean {
		try {
			link.link(result, processor);
			if (processor.processed) {
				return true;
			}
		}
		catch (e:Error) {
			error(e);
			return true;
		}
		return false;
	}
		
	
}
}


import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.flow.CommandLinkProcessor;
import org.spicefactory.lib.errors.IllegalStateError;

class Processor implements CommandLinkProcessor {

	private var executeCallback:Function;
	private var completeCallback:Function;
	private var cancelCallback:Function;
	private var errorCallback:Function;
	
	public var processed:Boolean;
	
	function Processor (executeCallback:Function, completeCallback:Function, 
			cancelCallback:Function, errorCallback:Function) {
		this.executeCallback = executeCallback;
		this.completeCallback = completeCallback;
		this.cancelCallback = cancelCallback;
		this.errorCallback = errorCallback;		
	}

	public function execute (command:Command) : void {
		process();
		executeCallback(command);
	}

	public function complete () : void {
		process();
		completeCallback();
	}

	public function cancel () : void {
		process();
		cancelCallback();
	}

	public function error (cause:Object) : void {
		process();
		errorCallback(cause);
	}
	
	private function process () : void {
		if (processed) {
			throw new IllegalStateError("This CommandLinkProcessor has already completed");
		}
		processed = true;
	}

	
}

