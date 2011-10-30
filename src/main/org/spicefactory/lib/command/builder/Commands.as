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

import org.spicefactory.lib.command.util.DelayCommand;
import org.spicefactory.lib.command.util.DelegateCommand;

import flash.system.ApplicationDomain;
	
/**
 * Entry point for the builde DSL for configuring and creating new command instances.
 * This DSL exists mainly for convenience. Any command types built by this class
 * can also be created by using their respective target APIs. But using this DSL
 * usually leads to code that is more concise.
 * 
 * @author Jens Halm
 */
public class Commands {
	
	/**
	 * @private
	 */
	internal static var defaultDomain:ApplicationDomain;
	
	/**
	 * Specifies a domain to use for reflecting on command classes.
	 * This is a global default that will affect all subsequent commands
	 * built by this DSL.
	 * 
	 * @param domain the domain to use for reflecting on command classes
	 */
	public static function useDomain (domain:ApplicationDomain) : void {
		defaultDomain = domain;
	}
	
	/**
	 * Creates a builder for the specified command instance.
	 * 
	 * <p>Legal parameters are any instances that implement either
	 * <code>Command</code> or <code>CommandBuilder</code>, or any other type in case
	 * an adapter is registered that knows how to turn the type into a command.</p>
	 * 
	 * @return a new builder for the specified command instance
	 */
	public static function wrap (command:Object) : CommandProxyBuilder {
		return new CommandProxyBuilder(command);
	}
	
	/**
	 * Creates a builder for the specified command type.
	 * 
	 * The target type may either be a class that implements the <code>Command</code>
	 * interface itself or a type an adapter is registered for that knows how to turn
	 * the type into a command.
	 * 
	 * @return a new builder for the specified command type
	 */
	public static function create (commandType:Class) : CommandProxyBuilder {
		return new CommandProxyBuilder(commandType);
	}
	
	/**
	 * Creates a builder for simple delegate that invokes the specified function
	 * when the command gets executed.
	 * 
	 * @param commandFunction the function to invoke when the command gets executed
	 * @param params parameters to pass to the function
	 * 
	 * @return a new builder for the specified command function
	 */
	public static function delegate (commandFunction:Function, ...params) : CommandProxyBuilder {
		return new CommandProxyBuilder(new DelegateCommand(commandFunction, params));
	}
	
	/**
	 * Creates a builder that creates a command that simply waits the specified
	 * amount of time before completing.
	 * 
	 * @param milliseconds the time to wait in milliseconds before the command completion
	 * @param params parameters to pass to the function
	 * 
	 * @return a new builder for a command that waits the specified
	 * amount of time before completing
	 */
	public static function delay (milliseconds:uint) : CommandProxyBuilder {
		return new CommandProxyBuilder(new DelayCommand(milliseconds));
	}
	
	/**
	 * Creates a new builder for commands to be executed as a sequence.
	 * 
	 * @return a new builder for commands to be executed as a sequence
	 */
	public static function asSequence () : CommandGroupBuilder {
		return new CommandGroupBuilder(true);
	}
	
	/**
	 * Creates a new builder for commands to be executed in parallel.
	 * 
	 * @return a new builder for commands to be executed in parallel
	 */
	public static function inParallel () : CommandGroupBuilder {
		return new CommandGroupBuilder(false);
	}
	
	/**
	 * Creates a new builder for commands to be executed as a flow with
	 * decision points between individual commands.
	 * 
	 * @return a new builder for commands to be executed as a flow
	 */
	public static function asFlow () : CommandFlowBuilder {
		return new CommandFlowBuilder();
	}
	
	
}
}
