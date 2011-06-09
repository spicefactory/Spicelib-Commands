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
import org.spicefactory.lib.command.CommandFactory;
	
/**
 * @author Jens Halm
 */
public class DefaultCommandFactory implements CommandFactory {


	private var type:Class;


	public function DefaultCommandFactory (type:Class) {
		this.type = type;
	}


	public function createCommand () : Command {
		// TODO - handle constructor injections
		return new type();
	}
	
	
}
}
