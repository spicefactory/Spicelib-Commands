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
import org.flexunit.async.Async;
import org.hamcrest.core.isA;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.isFalse;
import org.hamcrest.object.isTrue;
import org.hamcrest.object.notNullValue;
import org.hamcrest.object.nullValue;
import org.hamcrest.object.sameInstance;
import org.spicefactory.lib.command.builder.CommandProxyBuilder;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.events.CommandExecutorFailure;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.events.CommandTimeout;
import org.spicefactory.lib.command.impl.*;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.command.util.CommandEventCounter;
import org.spicefactory.lib.errors.IllegalStateError;

/**
 * @author Jens Halm
 */
public class LightCommandTest {


	private var events: CommandEventCounter;
	private var proxy: CommandProxy;
	
	
	[Before]
	public function setup (): void {
		events = new CommandEventCounter();
	}


	[Test]
	public function synchronousCommand (): void {
		var sync: SyncLightCommand = new SyncLightCommand();
		build(sync);
		assertInactive();
		proxy.execute();
		assertCompleted();
		assertThat(sync.executed, isTrue());
	}
	
	[Test]
	public function synchronousError (): void {
		var sync: SyncLightDataCommand = new SyncLightDataCommand(true);
		useBuilder(Commands.wrap(sync).data(new CommandModel("foo")));
		assertInactive();
		proxy.execute();
		assertThat(sync.model, notNullValue());
		assertError(IllegalStateError);
	}
	
	[Test]
	public function synchronousReturnValue (): void {
		var sync: SyncLightDataCommand = new SyncLightDataCommand();
		useBuilder(Commands.wrap(sync).data(new CommandModel("foo")));
		assertInactive();
		proxy.execute();
		assertThat(sync.model, notNullValue());
		assertResult("foo");
	}
	
	[Test]
	public function missingRequiredParameter (): void {
		var sync: SyncLightDataCommand = new SyncLightDataCommand(true);
		build(sync);
		assertInactive();
		proxy.execute();
		assertThat(sync.model, nullValue());
		assertError(IllegalStateError);
	}
	
	[Test]
	public function missingOptionalParameter (): void {
		var sync: SyncLightOptionalDataCommand = new SyncLightOptionalDataCommand();
		build(sync);
		assertInactive();
		proxy.execute();
		assertThat(sync.model, nullValue());
		assertCompleted();
	}
	
	[Test]
	public function optionalParameter (): void {
		var sync: SyncLightOptionalDataCommand = new SyncLightOptionalDataCommand();
		useBuilder(Commands.wrap(sync).data(new CommandModel("foo")));
		assertInactive();
		proxy.execute();
		assertThat(sync.model, notNullValue());
		assertResult("foo");
	}
	
	[Test]
	public function constructorInjection (): void {
		useBuilder(Commands
			.create(SyncLightConstructorInjectionCommand)
			.data(new CommandModel("foo"))
			.data("bar")
			);
		assertInactive();
		proxy.execute();
		assertResult("foo:bar");
	}
	
	[Test]
	public function constructorInjectionMissingOptional (): void {
		useBuilder(Commands
			.create(SyncLightConstructorInjectionCommand)
			.data(new CommandModel("foo"))
			);
		assertInactive();
		proxy.execute();
		assertResult("foo:");
	}
	
	[Test]
	public function constructorInjectionMissingRequired (): void {
		useBuilder(Commands
			.create(SyncLightConstructorInjectionCommand)
			);
		assertInactive();
		proxy.execute();
		assertError(IllegalStateError);
	}
	
	[Test]
	public function asynchronousCommand (): void {
		var async: AsyncLightCommand = new AsyncLightCommand();
		build(async);
		assertInactive();
		proxy.execute();
		assertActive();
		async.invokeCallback("foo");
		assertResult("foo");
	}

	[Test]
	public function cancellationOnTarget (): void {
		var async: CancellableLightCommand = new CancellableLightCommand();
		build(async);
		assertInactive();
		proxy.execute();
		assertActive();
		async.cancel();
		assertCancelled();
	}
	
	[Test]
	public function cancellationOnProxy (): void {
		build(new CancellableLightCommand());
		assertInactive();
		proxy.execute();
		assertActive();
		proxy.cancel();
		assertCancelled();
	}
	
	[Test(expects="org.spicefactory.lib.errors.IllegalStateError")]
	public function illegalCancellation (): void {
		var async: AsyncLightCommand = new AsyncLightCommand();
		build(async);
		assertInactive();
		proxy.execute();
		assertActive();
		proxy.cancel();
	}

	[Test]
	public function createCommand (): void {
		create(AsyncLightCommand);
		assertInactive();
		proxy.execute();
		assertActive();
		AsyncLightCommand.lastCreated.invokeCallback("foo");
		assertCompleted();
	}

	[Test(async)]
	public function timeout (): void {
		useBuilder(Commands.wrap(new AsyncLightCommand()).timeout(100));
		assertInactive();
		proxy.execute();
		assertActive();
		
		var errorHandler:Function = function (error: Object, data: Object = null): void {
			assertError(CommandTimeout);
		};
		Async.handleEvent(this, proxy, CommandResultEvent.ERROR, errorHandler, 500);
	}
	
	[Test]
	public function asynchronousError (): void {
		var async: AsyncLightCommand = new AsyncLightCommand();
		build(async);
		assertInactive();
		proxy.execute();
		assertActive();
		async.invokeCallback(new IllegalStateError());
		assertError(IllegalStateError);
	}


	private function build (com: Object): void {
		proxy = prepare(Commands.wrap(com)).build();
		events.target = proxy;
	}
	
	private function create (com: Class): void {
		proxy = prepare(Commands.create(com)).build();
		events.target = proxy;
	}
	
	private function useBuilder (builder: CommandProxyBuilder): void {
		proxy = prepare(builder).build();
		events.target = proxy;
	}
	
	private function prepare (builder: CommandProxyBuilder): CommandProxyBuilder {
		builder
			.result(events.resultCallback)
			.cancel(events.cancelCallback)
			.error(events.errorCallback);
		return builder;
	}
	
	private function assertInactive (): void {
		assertThat(proxy.active, isFalse());
		events.assertEvents(0);
		events.assertCallbacks(0);
	}
	
	private function assertActive (): void {
		assertThat(proxy.active, isTrue());
		events.assertEvents(0);
		events.assertCallbacks(0);
	}

	private function assertCompleted (): void {
		events.assertEvents(1);
		events.assertCallbacks(1);
	}
	
	private function assertResult (value: Object): void {
		assertCompleted();
		assertThat(events.getResult(), equalTo(value));
	}
	
	private function assertError (expectedCause: Class): void {
		events.assertEvents(0, 1);
		events.assertCallbacks(0, 1);
		assertThat(events.getError(), isA(CommandExecutorFailure));
		var failure:CommandExecutorFailure = CommandExecutorFailure(events.getError());
		assertThat(failure.cause, isA(expectedCause));
		assertThat(failure.executor, sameInstance(proxy));
		assertThat(failure.target, sameInstance(proxy.target));
	}
	
	private function assertCancelled (): void {
		events.assertEvents(0, 0, 1);
		events.assertCallbacks(0, 0, 1);
	}
	

	
}
}
