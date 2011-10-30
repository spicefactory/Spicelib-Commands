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
import org.spicefactory.lib.errors.IllegalArgumentError;
	
/**
 * Helper class to create basic link actions.
 * 
 * @author Jens Halm
 */
public class CommandLinks {
	
	
	/**
	 * Creates a link that causes successful flow completion.
	 * 
	 * @return a link that causes successful flow completion
	 */
	public static function toFlowEnd () : CommandLink {
		return new FlowEndLink();
	}
	
	/**
	 * Creates a link that causes the flow to abort with the specified error.
	 * 
	 * @param value the cause of the error
	 * @return a link that causes the flow to abort with the specified error
	 */
	public static function toFlowError (value:Object) : CommandLink {
		return new FlowErrorLink(value);
	}
	
	/**
	 * Creates a link that causes flow cancellation.
	 * 
	 * @return a link that causes flow cancellation
	 */
	public static function toFlowCancellation () : CommandLink {
		return new FlowCancellationLink();
	}
	
	
	private static var _defaultLink:CommandLink;
	
	
	public static function set defaultLink (value:CommandLink) : void {
		if (!value) throw IllegalArgumentError("defaultLink must not be null");
		_defaultLink = value;
	}
	
	/**
	 * Specifies the default link to use when a CommandFlow
	 * does not have an explicit default link.
	 */
	public static function  get defaultLink () : CommandLink {
		if (!_defaultLink) {
			_defaultLink = new DefaultLink();
		}
		return _defaultLink;
	}
	
	
}
}


import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.flow.CommandLink;
import org.spicefactory.lib.command.flow.CommandLinkProcessor;
import org.spicefactory.lib.command.flow.CommandLinks;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

class FlowEndLink implements CommandLink {

	public function link (result: CommandResult, processor: CommandLinkProcessor): void {
		processor.complete();
	}
	
}

class FlowErrorLink implements CommandLink {

	private var error: Object;
	
	function FlowErrorLink (error: Object) {
		this.error = error;
	}
	
	public function link (result: CommandResult, processor: CommandLinkProcessor): void {
		processor.error(error);
	}
	
}

class FlowCancellationLink implements CommandLink {

	public function link (result: CommandResult, processor: CommandLinkProcessor): void {
		processor.cancel();
	}
	
}

class DefaultLink implements CommandLink {

	private static const logger:Logger = LogContext.getLogger(CommandLinks);

	public function link (result: CommandResult, processor: CommandLinkProcessor): void {
		if (result.complete) {
			logger.error("No link processed result {0} in flow {1}", result.value, result.command);
			processor.error("No link processed result " + result.value);
		}
		else if (result.value) {
			processor.error(result.value);
		}
		else {
			processor.cancel();
		}
	}
	
}


