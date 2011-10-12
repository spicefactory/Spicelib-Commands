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

import org.spicefactory.lib.command.group.CommandGroup;
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.hamcrest.core.isA;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.sameInstance;
import org.spicefactory.lib.command.builder.CommandGroupBuilder;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.events.CommandExecutorFailure;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.events.CommandTimeout;
import org.spicefactory.lib.command.impl.AsynchronousCommand;
import org.spicefactory.lib.command.impl.FullCommand;
import org.spicefactory.lib.command.impl.SynchronousCommand;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.command.util.CommandEventCounter;
	
/**
 * @author Jens Halm
 */
public class CommandGroupTest {
	
	
	[Test]
	public function emptySequentialComplete () : void {
		assertCompletion(Commands.asSequence());
	}
	
	[Test]
	public function emptyConcurrentComplete () : void {
		assertCompletion(Commands.inParallel());
	}
	
	[Test(async)]
	public function syncSequentialComplete () : void {
		assertCompletion(Commands.asSequence().add(new SynchronousCommand()).add(new SynchronousCommand()));
	}
	
	[Test(async)]
	public function syncConcurrentComplete () : void {
		assertCompletion(Commands.inParallel().add(new SynchronousCommand()).add(new SynchronousCommand()));
	}
	
	private function assertCompletion (builder:CommandGroupBuilder): void {
		var events: CommandEventCounter = new CommandEventCounter();
		addCallbacks(builder, events);
		var proxy: CommandProxy = builder.build();
		events.target = proxy;
		
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		proxy.execute();
		
		events.assertEvents(1);
		events.assertCallbacks(1);
	}
	
	[Test(async)]
	public function sequentialComplete () : void {
		var com1: AsynchronousCommand = new AsynchronousCommand();
		var com2: AsynchronousCommand = new AsynchronousCommand();
		assertAsyncCompletion(Commands.asSequence().add(com1).add(com2), com1, com2, false);
	}
	
	[Test(async)]
	public function concurrentComplete () : void {
		var com1: AsynchronousCommand = new AsynchronousCommand();
		var com2: AsynchronousCommand = new AsynchronousCommand();
		assertAsyncCompletion(Commands.inParallel().add(com1).add(com2), com1, com2, true);
	}
	
	private function assertAsyncCompletion (builder:CommandGroupBuilder, com1: AsynchronousCommand, com2: AsynchronousCommand, parallel: Boolean): void {
		var events: CommandEventCounter = new CommandEventCounter();
		addCallbacks(builder, events);
		var proxy: CommandProxy = builder.build();
		events.target = proxy;
		
		assertActive(com1, false);
		assertActive(com2, false);
		
		proxy.execute();
		
		assertActive(com1, true);
		assertActive(com2, parallel);
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		com1.forceCompletion();
		
		assertActive(com1, false);
		assertActive(com2, true);
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		com2.forceCompletion();
		
		assertActive(com1, false);
		assertActive(com2, false);
		events.assertEvents(1);
		events.assertCallbacks(1);
	}
	
	private function assertActive (com: AsyncCommand, active: Boolean): void {
		assertThat(com.active, equalTo(active));
	}
	
	private function assertSuspended (com: SuspendableCommand, suspended: Boolean): void {
		assertThat(com.suspended, equalTo(suspended));
	}
	
	[Test(async)]
	public function sequentialCancellation () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertCancellation(Commands.asSequence().add(com1).add(com2), com1, com2, false);
	}
	
	[Test(async)]
	public function parallelCancellation () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertCancellation(Commands.inParallel().add(com1).add(com2), com1, com2, true);
	}
	
	private function assertCancellation (builder:CommandGroupBuilder, com1: FullCommand, com2: FullCommand, parallel: Boolean): void {
		var events: CommandEventCounter = new CommandEventCounter();
		addCallbacks(builder, events);
		var proxy: CommandProxy = builder.build();
		events.target = proxy;
		
		assertActive(com1, false);
		assertActive(com2, false);
		
		proxy.execute();
		
		assertActive(com1, true);
		assertActive(com2, parallel);
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		proxy.cancel();
		
		assertActive(com1, false);
		assertActive(com2, false);
		events.assertEvents(0, 0, 1);
		events.assertCallbacks(0, 0, 1);
	}
	
	[Test(async)]
	public function sequentialError () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertError(Commands.asSequence().add(com1).add(com2), com1, com2, false);
	}
	
	[Test(async)]
	public function parallelError () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertError(Commands.inParallel().add(com1).add(com2), com1, com2, true);
	}
	
	private function assertError (builder:CommandGroupBuilder, com1: FullCommand, com2: FullCommand, parallel: Boolean): void {
		var events: CommandEventCounter = new CommandEventCounter();
		addCallbacks(builder, events);
		var proxy: CommandProxy = builder.build();
		events.target = proxy;
		
		assertActive(com1, false);
		assertActive(com2, false);
		
		proxy.execute();
		
		assertActive(com1, true);
		assertActive(com2, parallel);
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		com1.forceError();
		
		assertActive(com1, false);
		assertActive(com2, false);
		events.assertEvents(0, 1);
		events.assertCallbacks(0, 1);
	}
	
	[Test(async)]
	public function sequentialSkippedError () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertSkippedError(Commands.asSequence().add(com1).add(com2).skipErrors(), com1, com2, false);
	}
	
	[Test(async)]
	public function parallelSkippedError () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertSkippedError(Commands.inParallel().add(com1).add(com2).skipErrors(), com1, com2, true);
	}
	
	private function assertSkippedError (builder:CommandGroupBuilder, com1: FullCommand, com2: FullCommand, parallel: Boolean): void {
		var events: CommandEventCounter = new CommandEventCounter();
		addCallbacks(builder, events);
		var proxy: CommandProxy = builder.build();
		events.target = proxy;
		
		assertActive(com1, false);
		assertActive(com2, false);
		
		proxy.execute();
		
		assertActive(com1, true);
		assertActive(com2, parallel);
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		com1.forceError();
		
		assertActive(com1, false);
		assertActive(com2, true);
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		com2.forceCompletion();
		
		assertActive(com1, false);
		assertActive(com2, false);
		events.assertEvents(1);
		events.assertCallbacks(1);
	}
	
	[Test(async)]
	public function sequentialSuspension () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertSuspension(Commands.asSequence().add(com1).add(com2), com1, com2, false);
	}
	
	[Test(async)]
	public function parallelSuspension () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertSuspension(Commands.inParallel().add(com1).add(com2), com1, com2, true);
	}
	
	private function assertSuspension (builder:CommandGroupBuilder, com1: FullCommand, com2: FullCommand, parallel: Boolean): void {
		var events: CommandEventCounter = new CommandEventCounter();
		addCallbacks(builder, events);
		var proxy: CommandProxy = builder.build();
		events.target = proxy;
		
		assertActive(com1, false);
		assertActive(com2, false);
		
		proxy.execute();
		
		assertActive(com1, true);
		assertActive(com2, parallel);
		assertSuspended(com1, false);
		assertSuspended(com2, false);
		events.assertEvents(0);
		events.assertCallbacks(0);
		
		proxy.suspend();
		
		assertActive(com1, true);
		assertActive(com2, parallel);
		assertSuspended(com1, true);
		assertSuspended(com2, parallel);
		events.assertEvents(0, 0, 0, 1);
		events.assertCallbacks(0);
		
		proxy.resume();
		
		assertActive(com1, true);
		assertActive(com2, parallel);
		assertSuspended(com1, false);
		assertSuspended(com2, false);
		events.assertEvents(0, 0, 0, 1, 1);
		events.assertCallbacks(0);
		
		com1.forceCompletion();
		com2.forceCompletion();
		
		assertActive(com1, false);
		assertActive(com2, false);
		assertSuspended(com1, false);
		assertSuspended(com2, false);
		events.assertEvents(1, 0, 0, 1, 1);
		events.assertCallbacks(1);
	}
	
	[Test(expects="org.spicefactory.lib.errors.IllegalStateError")]
	public function illegalSuspension (): void {
		var async: AsynchronousCommand = new AsynchronousCommand();
		var proxy:CommandProxy = Commands.asSequence().add(async).execute();
		proxy.suspend();
	}
	
	[Test(async)]
	public function sequentialTimeout () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertTimeout(Commands.asSequence().add(com1).add(com2).timeout(100), com1, com2, false);
	}
	
	[Test(async)]
	public function parallelTimeout () : void {
		var com1: FullCommand = new FullCommand();
		var com2: FullCommand = new FullCommand();
		assertTimeout(Commands.inParallel().add(com1).add(com2).timeout(100), com1, com2, true);
	}
	
	private function assertTimeout (builder:CommandGroupBuilder, com1: FullCommand, com2: FullCommand, parallel: Boolean): void {
		var events: CommandEventCounter = new CommandEventCounter();
		addCallbacks(builder, events);
		var proxy: CommandProxy = builder.execute();
		events.target = proxy;
		
		events.assertEvents(0);
		events.assertCallbacks(0);
		assertActive(com1, true);
		assertActive(com2, parallel);
		
		var errorHandler:Function = function (error: Object, data: Object = null): void {
			events.assertEvents(0, 1);
			events.assertCallbacks(0, 1);
			assertThat(events.getError(), isA(CommandExecutorFailure));
			var failure:CommandExecutorFailure = CommandExecutorFailure(events.getErrorFromCallback());
			assertThat(failure.cause, isA(CommandTimeout));
			assertThat(failure.executor, sameInstance(proxy));
			assertThat(failure.target, isA(CommandGroup));
		};
		
		Async.handleEvent(this, proxy, CommandResultEvent.ERROR, errorHandler, 500);
	}
	
	private function addCallbacks (builder: CommandGroupBuilder, eventCounter: CommandEventCounter): void {
		builder
			.allResults(eventCounter.resultCallback)
			.cancel(eventCounter.cancelCallback)
			.error(eventCounter.errorCallback);
	}
	
	
}
}
