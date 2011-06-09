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

import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.CommandProxy;
import org.spicefactory.lib.command.adapter.CommandAdapters;
import org.spicefactory.lib.command.events.CommandEvent;
import org.spicefactory.lib.command.events.CommandResultEvent;
	
/**
 * @author Jens Halm
 */
public class AbstractCommandBuilder implements CommandBuilder {


	private var proxy:DefaultCommandProxy;


	protected function setTarget (target:Command) : void {
		proxy.target = target;
	}
	
	protected function setType (type:Class) : void {
		proxy.type = type;
	}
	
	protected function setTimeout (milliseconds:uint) : void {
		proxy.timeout = milliseconds;
	}
	
	protected function setDescription (description:String) : void {
		proxy.description = description;
	}
	
	protected function addResultCallback (callback:Function) : void {
		proxy.addEventListener(CommandResultEvent.COMPLETE, function (event:CommandResultEvent) : void {
			callback(event.value);
		});
	}
	
	protected function addErrorCallback (callback:Function) : void {
		proxy.addEventListener(CommandResultEvent.ERROR, function (event:CommandResultEvent) : void {
			callback(event.value);
		});
	}
	
	protected function addCancelCallback (callback:Function) : void {
		proxy.addEventListener(CommandEvent.CANCEL, function (event:CommandEvent) : void {
			callback();
		});
	}
	
	protected function asCommand (command:Object) : Command {
		if (command is Command) {
			return command as Command;
		}
		else if (command is CommandBuilder) {
			return CommandBuilder(command).build();
		}
		else {
			return CommandAdapters.createAdapter(command);
		}
		// TODO - handle ApplicationDomains
	}
	
	public function execute () : CommandProxy {
		var proxy:CommandProxy = build();
		proxy.execute();
		return proxy;
	}

	public function build () : CommandProxy {
		return proxy;
	}
	
	
}
}
