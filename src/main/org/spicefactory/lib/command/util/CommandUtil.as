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
 
package org.spicefactory.lib.command.util {

import org.spicefactory.lib.command.CancellableCommand;
import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.CommandExecutor;
import org.spicefactory.lib.command.SuspendableCommand;
	
/**
 * Utility methods for determining the capabilities of a target command.
 * 
 * @author Jens Halm
 */
public class CommandUtil {
	
	
	/**
	 * Determines whether the target command can be cancelled.
	 * 
	 * @param com the target command
	 * @return true if the target command can be cancelled
	 */
	public static function isCancellable (com:Command) : Boolean {
		if (com is CommandExecutor) {
			return CommandExecutor(com).cancellable;
		}
		else {
			return (com is CancellableCommand);
		}
	}
	
	/**
	 * Determines whether the target command can be suspended.
	 * 
	 * @param com the target command
	 * @return true if the target command can be suspended
	 */
	public static function isSuspendable (com:Command) : Boolean {
		if (com is CommandExecutor) {
			return CommandExecutor(com).suspendable;
		}
		else {
			return (com is SuspendableCommand);
		}
	}
	
	
}
}
