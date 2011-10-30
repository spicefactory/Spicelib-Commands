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
 
package org.spicefactory.lib.command.base {

import org.spicefactory.lib.command.CancellableCommand;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;

	
/**
 * Abstract base implementation of the CancellableCommand interface. 
 * 
 * <p>A subclass of AbstractCancellableCommand is expected
 * to override the <code>doStart</code> method, do its work and then call <code>complete</code>
 * when the operation is done (or <code>error</code> when the command fails to complete successfully).
 * It is also expected to override the <code>doCancel</code> method to cancel the actual operation</p> 
 * 
 * @author Jens Halm
 */
public class AbstractCancellableCommand extends AbstractAsyncCommand implements CancellableCommand {
	
	
	private static var logger:Logger = LogContext.getLogger(AbstractCancellableCommand);
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param description a description of this command
	 */
	public function AbstractCancellableCommand (description:String = null) {
		super(description);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function cancel () : void {
		if (!active) {
			logger.error("Attempt to suspend inactive command '{0}'", this);
			return;
		}
		doCancel();
		dispatchEvent(new CommandEvent(CommandEvent.CANCEL));	
	}
	
	/**
	 * Invoked when this command gets cancelled. 
	 * Subclasses should override this method and cancel the actual operation
	 * this command performs.
	 */		
	protected function doCancel () : void {
		/* base implementation does nothing */
	}
	
	
}
}
