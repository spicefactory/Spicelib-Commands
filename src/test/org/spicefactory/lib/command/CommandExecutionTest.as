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
 
package org.spicefactory.lib.command {

import org.flexunit.assertThat;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.isFalse;
import org.hamcrest.object.isTrue;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.impl.AsynchronousCommand;
import org.spicefactory.lib.command.impl.SynchronousCommand;
import org.spicefactory.lib.command.util.CommandEventCounter;
	
	
/**
 * @author Jens Halm
 */
public class CommandExecutionTest {
	
	
	[Test]
	public function synchronousCommand () : void {
		var sync:SynchronousCommand = new SynchronousCommand();
		Commands.wrap(sync).execute();
		assertThat(sync.executions, equalTo(1));
	}
	
	[Test]
	public function asynchronousCommand () : void {
		var async:AsynchronousCommand = new AsynchronousCommand();
		var events: CommandEventCounter = new CommandEventCounter(async);
		
		assertThat(async.executions, equalTo(0));
		assertThat(async.completions, equalTo(0));
		assertThat(async.active, isFalse());
		events.assertEvents(0);
		
		Commands.wrap(async).execute();

		assertThat(async.executions, equalTo(1));
		assertThat(async.completions, equalTo(0));
		assertThat(async.errors, equalTo(0));
		assertThat(async.active, isTrue());
		events.assertEvents(0);

		async.forceCompletion();
				
		assertThat(async.executions, equalTo(1));
		assertThat(async.completions, equalTo(1));
		assertThat(async.errors, equalTo(0));
		assertThat(async.active, isFalse());
		events.assertEvents(1);
	}
	
	
}
}
