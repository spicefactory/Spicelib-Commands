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

import org.spicefactory.lib.command.events.CommandTimeout;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.flexunit.async.Async;
import org.flexunit.assertThat;
import org.hamcrest.core.isA;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.isFalse;
import org.hamcrest.object.isTrue;
import org.hamcrest.object.sameInstance;
import org.spicefactory.lib.command.builder.CommandProxyBuilder;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.events.CommandExecutorFailure;
import org.spicefactory.lib.command.impl.AsynchronousCommand;
import org.spicefactory.lib.command.impl.FullCommand;
import org.spicefactory.lib.command.impl.SynchronousCommand;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.command.util.CommandEventCounter;

/**
 * @author Jens Halm
 */
public class CommandExecutionTest {


	[Test]
	public function synchronousCommand (): void {
		var sync: SynchronousCommand = new SynchronousCommand();
		Commands.wrap(sync).execute();
		assertThat(sync.executions, equalTo(1));
	}

	[Test]
	public function asynchronousCommand (): void {
		var async: AsynchronousCommand = new AsynchronousCommand();
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

	[Test]
	public function cancellationOnTarget (): void {
		var com: FullCommand = new FullCommand();
		var targetEvents: CommandEventCounter = new CommandEventCounter(com);

		com.assertStatus(false, 0, 0);
		targetEvents.assertEvents(0);

		var proxy: AsyncCommand = Commands.wrap(com).execute();
		var proxyEvents: CommandEventCounter = new CommandEventCounter(proxy);

		com.assertStatus(true, 1, 0);
		targetEvents.assertEvents(0);
		proxyEvents.assertEvents(0);

		com.cancel();

		com.assertStatus(false, 1, 0, 0, 1);
		targetEvents.assertEvents(0, 0, 1);
		proxyEvents.assertEvents(0, 0, 1);
	}

	[Test]
	public function cancellationOnProxy (): void {
		var com: FullCommand = new FullCommand();
		var targetEvents: CommandEventCounter = new CommandEventCounter(com);

		com.assertStatus(false, 0, 0);
		targetEvents.assertEvents(0);

		var proxyEvents: CommandEventCounter = new CommandEventCounter();
		var proxy: CancellableCommand = execute(com, proxyEvents);

		com.assertStatus(true, 1, 0);
		targetEvents.assertEvents(0);
		proxyEvents.assertEvents(0);
		proxyEvents.assertCallbacks(0);

		proxy.cancel();

		com.assertStatus(false, 1, 0, 0, 1);
		targetEvents.assertEvents(0, 0, 1);
		proxyEvents.assertEvents(0, 0, 1);
		proxyEvents.assertCallbacks(0, 0, 1);
	}

	[Test]
	public function suspension (): void {
		var com: FullCommand = new FullCommand();
		var targetEvents: CommandEventCounter = new CommandEventCounter(com);

		com.assertStatus(false, 0, 0);
		targetEvents.assertEvents(0);

		var proxyEvents: CommandEventCounter = new CommandEventCounter();
		var proxy: SuspendableCommand = execute(com, proxyEvents);

		com.assertStatus(true, 1, 0);
		targetEvents.assertEvents(0);
		proxyEvents.assertEvents(0);
		proxyEvents.assertCallbacks(0);

		proxy.suspend();

		com.assertStatus(true, 1, 0, 0, 0, 1);
		targetEvents.assertEvents(0, 0, 0, 1);
		proxyEvents.assertEvents(0, 0, 0, 1);
		proxyEvents.assertCallbacks(0);

		proxy.resume();

		com.assertStatus(true, 1, 0, 0, 0, 1, 1);
		targetEvents.assertEvents(0, 0, 0, 1, 1);
		proxyEvents.assertEvents(0, 0, 0, 1, 1);
		proxyEvents.assertCallbacks(0);

		com.forceCompletion();

		com.assertStatus(false, 1, 1, 0, 0, 1, 1);
		targetEvents.assertEvents(1, 0, 0, 1, 1);
		proxyEvents.assertEvents(1, 0, 0, 1, 1);
		proxyEvents.assertCallbacks(1);
	}

	[Test]
	public function createCommand (): void {
		SynchronousCommand.resetTotalExecutions();
		Commands.create(SynchronousCommand).execute();
		assertThat(SynchronousCommand.totalExecutions, equalTo(1));
	}

	[Test]
	public function delegate (): void {
		var stringParam: String;
		var intParam: int;
		var delegate:Function = function (p1: String, p2: int): void {
			stringParam = p1;
			intParam = p2;
		};
		var proxyEvents: CommandEventCounter = new CommandEventCounter();
		var builder: CommandProxyBuilder = Commands.delegate(delegate, "foo", 7);
		addCallbacks(builder, proxyEvents);
		var proxy: CommandProxy = builder.execute();
		proxyEvents.target = proxy;
		
		proxyEvents.assertEvents(0); // due to timing we don't get the event for a synchronous command here
		proxyEvents.assertCallbacks(1);
		
		assertThat(stringParam, equalTo("foo"));
		assertThat(intParam, equalTo(7));
	}

	[Test(async)]
	public function delay (): void {
		var proxyEvents: CommandEventCounter = new CommandEventCounter();
		var builder: CommandProxyBuilder = Commands.delay(100);
		addCallbacks(builder, proxyEvents);
		var proxy: CommandProxy = builder.execute();
		proxyEvents.target = proxy;
		
		proxyEvents.assertEvents(0);
		proxyEvents.assertCallbacks(0);
		
		var resultHandler:Function = function (result: Object, data: Object = null): void {
			proxyEvents.assertEvents(1);
			proxyEvents.assertCallbacks(1);
		};
		
		Async.handleEvent(this, proxy, CommandResultEvent.COMPLETE, resultHandler, 500);
	}

	[Test(async)]
	public function timeout (): void {
		var proxyEvents: CommandEventCounter = new CommandEventCounter();
		var builder: CommandProxyBuilder = Commands.create(AsynchronousCommand).timeout(100);
		addCallbacks(builder, proxyEvents);
		var proxy: CommandProxy = builder.execute();
		proxyEvents.target = proxy;
		
		proxyEvents.assertEvents(0);
		proxyEvents.assertCallbacks(0);
		
		var errorHandler:Function = function (error: Object, data: Object = null): void {
			proxyEvents.assertEvents(0, 1);
			proxyEvents.assertCallbacks(0, 1);
			assertThat(proxyEvents.getError(), isA(CommandExecutorFailure));
			var failure:CommandExecutorFailure = CommandExecutorFailure(proxyEvents.getErrorFromCallback());
			assertThat(failure.cause, isA(CommandTimeout));
			assertThat(failure.executor, sameInstance(proxy));
			assertThat(failure.target, isA(AsynchronousCommand));
		};
		
		Async.handleEvent(this, proxy, CommandResultEvent.ERROR, errorHandler, 500);
	}

	[Test(expects="org.spicefactory.lib.errors.IllegalStateError")]
	public function illegalSuspension (): void {
		var async: AsynchronousCommand = new AsynchronousCommand();
		var proxy:CommandProxy = Commands.wrap(async).execute();
		proxy.suspend();
	}

	[Test]
	public function synchronousError (): void {
		var sync: SynchronousCommand = new SynchronousCommand(true);
		var proxyEvents: CommandEventCounter = new CommandEventCounter();
		var proxy:CommandProxy = execute(sync, proxyEvents);
		
		proxyEvents.assertEvents(0); // due to timing we don't get the event for a synchronous command here
		proxyEvents.assertCallbacks(0, 1);
		assertThat(proxyEvents.getErrorFromCallback(), isA(CommandExecutorFailure));
		var failure:CommandExecutorFailure = CommandExecutorFailure(proxyEvents.getErrorFromCallback());
		assertThat(failure.cause, isA(Error));
		assertThat(failure.executor, sameInstance(proxy));
		assertThat(failure.target, sameInstance(sync));
	}

	[Test]
	public function asynchronousError (): void {
		var async: AsynchronousCommand = new AsynchronousCommand();
		var proxyEvents: CommandEventCounter = new CommandEventCounter();
		var proxy:CommandProxy = execute(async, proxyEvents);
		
		proxyEvents.assertEvents(0);
		proxyEvents.assertCallbacks(0);
		
		async.forceError(new Date());
		
		proxyEvents.assertEvents(0, 1);
		proxyEvents.assertCallbacks(0, 1);
		
		assertThat(proxyEvents.getError(), isA(CommandExecutorFailure));
		var failure:CommandExecutorFailure = CommandExecutorFailure(proxyEvents.getErrorFromCallback());
		assertThat(failure.cause, isA(Date));
		assertThat(failure.executor, sameInstance(proxy));
		assertThat(failure.target, sameInstance(async));
	}

	private function execute (com: Command, eventCounter: CommandEventCounter): CommandProxy {
		var proxy:CommandProxy = Commands
			.wrap(com)
			.result(eventCounter.resultCallback)
			.cancel(eventCounter.cancelCallback)
			.error(eventCounter.errorCallback)
			.execute();
		eventCounter.target = proxy;
		return proxy;
	}
	
	private function addCallbacks (builder: CommandProxyBuilder, eventCounter: CommandEventCounter): void {
		builder
			.result(eventCounter.resultCallback)
			.cancel(eventCounter.cancelCallback)
			.error(eventCounter.errorCallback);
	}
	
	
}
}
