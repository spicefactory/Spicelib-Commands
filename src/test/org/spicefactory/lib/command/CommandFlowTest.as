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

import flash.geom.Rectangle;
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.hamcrest.core.isA;
import org.hamcrest.object.isTrue;
import org.hamcrest.object.sameInstance;
import org.spicefactory.lib.command.builder.CommandFlowBuilder;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.events.CommandFailure;
import org.spicefactory.lib.command.events.CommandResultEvent;
import org.spicefactory.lib.command.events.CommandTimeout;
import org.spicefactory.lib.command.flow.CommandLinkProcessor;
import org.spicefactory.lib.command.impl.AsyncLightFlowCommand;
import org.spicefactory.lib.command.impl.LightFlowCommand;
import org.spicefactory.lib.command.impl.SyncLightDataCommand;
import org.spicefactory.lib.command.model.CommandModel;
import org.spicefactory.lib.command.model.FlowModel;
import org.spicefactory.lib.command.proxy.CommandProxy;
import org.spicefactory.lib.command.util.CommandEventCounter;
import org.spicefactory.lib.errors.IllegalStateError;

/**
 * @author Jens Halm
 */
public class CommandFlowTest {
	

	private var events: CommandEventCounter;
	private var proxy: CommandProxy;
	
	private var model: FlowModel;
	
	
	[Before]
	public function setup (): void {
		events = new CommandEventCounter();
		model = new FlowModel();
	}
	
		
	[Test]
	public function linkResultValue (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: LightFlowCommand = new LightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultValue("xxx").toCommandInstance(com3)
			.linkResultValue("foo").toCommandInstance(com2);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function linkResultType (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", new Date());
		var com2: LightFlowCommand = new LightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultType(Date).toCommandInstance(com2)
			.linkResultValue("xxx").toCommandInstance(com3);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function linkResultProperty (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", new Rectangle(5, 5, 200, 120));
		var com2: LightFlowCommand = new LightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultProperty("width", 200).toCommandInstance(com2)
			.linkResultValue("xxx").toCommandInstance(com3);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function linkFunction (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: Command = Commands.wrap(new LightFlowCommand("bar", "bar")).build();
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		var f:Function = function (result:CommandResult, processor:CommandLinkProcessor) : void {
			if (result.value == "foo") processor.execute(com2);
		};
		flow.add(com1).linkFunction(f);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function customLink (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: Command = Commands.wrap(new LightFlowCommand("bar", "bar")).build();
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1).link(new CustomLink(com2));
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function linkToType (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model).data(new CommandModel("bar"));
		
		flow.add(com1)
			.linkResultValue("xxx").toCommandInstance(com3)
			.linkResultValue("foo").toCommandType(SyncLightDataCommand);
		flow.create(SyncLightDataCommand).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function emptyFlow (): void {
		useBuilder(Commands.asFlow().data(model));
		proxy.execute();
		assertCompleted();
		model.assertFlow();
	}
	
	[Test]
	public function asyncFlow (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: AsyncLightFlowCommand = new AsyncLightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultValue("xxx").toCommandInstance(com3)
			.linkResultValue("foo").toCommandInstance(com2);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertActive();
		model.assertFlow("foo", "bar");
		com2.complete();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function cancelFlowProxy (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: AsyncLightFlowCommand = new AsyncLightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultValue("xxx").toCommandInstance(com3)
			.linkResultValue("foo").toCommandInstance(com2);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertActive();
		model.assertFlow("foo", "bar");
		proxy.cancel();
		assertCancelled();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function cancelFlowTarget (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: AsyncLightFlowCommand = new AsyncLightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultValue("xxx").toCommandInstance(com3)
			.linkResultValue("foo").toCommandInstance(com2);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertActive();
		model.assertFlow("foo", "bar");
		com2.forceCancellation();
		assertCancelled();
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function flowError (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: AsyncLightFlowCommand = new AsyncLightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultValue("xxx").toCommandInstance(com3)
			.linkResultValue("foo").toCommandInstance(com2);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertActive();
		model.assertFlow("foo", "bar");
		com2.error();
		assertError(IllegalStateError);
		model.assertFlow("foo", "bar");
	}
	
	[Test(async)]
	public function flowTimeout (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", "foo");
		var com2: AsyncLightFlowCommand = new AsyncLightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultValue("xxx").toCommandInstance(com3)
			.linkResultValue("foo").toCommandInstance(com2);
		flow.add(com2).linkAllResults().toFlowEnd();
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow.timeout(100));
		proxy.execute();
		assertActive();
		model.assertFlow("foo", "bar");
		
		var errorHandler:Function = function (error: Object, data: Object = null): void {
			assertError(CommandTimeout);
		};
		Async.handleEvent(this, proxy, CommandResultEvent.ERROR, errorHandler, 500);
	}
	
	[Test]
	public function noLinkForCommand (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", new Rectangle(5, 5, 200, 120));
		var com2: LightFlowCommand = new LightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultProperty("width", 200).toCommandInstance(com2);
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertError(String);
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function noMatchingLinkForCommand (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", new Rectangle(5, 5, 200, 120));
		var com2: LightFlowCommand = new LightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultProperty("width", 200).toCommandInstance(com2);
		flow.add(com2)
			.linkResultValue("xxx").toCommandInstance(com3);
		flow.add(com3).linkAllResults().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertError(String);
		model.assertFlow("foo", "bar");
	}
	
	[Test]
	public function localDefaultLink (): void {
		var com1: LightFlowCommand = new LightFlowCommand("foo", new Rectangle(5, 5, 200, 120));
		var com2: LightFlowCommand = new LightFlowCommand("bar", "bar");
		var com3: LightFlowCommand = new LightFlowCommand("unused", "unused");
		var flow: CommandFlowBuilder = Commands.asFlow().data(model);
		
		flow.add(com1)
			.linkResultProperty("width", 200).toCommandInstance(com2);
		flow.add(com2)
			.linkResultValue("xxx").toCommandInstance(com3);
		flow.add(com3).linkAllResults().toFlowEnd();
		
		flow.defaultLink().toFlowEnd();
		
		useBuilder(flow);
		proxy.execute();
		assertCompleted();
		model.assertFlow("foo", "bar");
	}
	
	
	
	
	private function useBuilder (builder: CommandFlowBuilder): void {
		proxy = prepare(builder).build();
		events.target = proxy;
	}
	
	private function prepare (builder: CommandFlowBuilder): CommandFlowBuilder {
		builder
			.lastResult(events.resultCallback)
			.cancel(events.cancelCallback)
			.error(events.errorCallback);
		return builder;
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
	
	private function assertError (expectedCause: Class): void {
		events.assertEvents(0, 1);
		events.assertCallbacks(0, 1);
		assertThat(events.getError(), isA(CommandFailure));
		var failure:CommandFailure = CommandFailure(events.getError());
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

import org.spicefactory.lib.command.Command;
import org.spicefactory.lib.command.CommandResult;
import org.spicefactory.lib.command.flow.CommandLink;
import org.spicefactory.lib.command.flow.CommandLinkProcessor;

class CustomLink implements CommandLink {

	private var targetCommand:Command;

	function CustomLink (targetCommand: Command) {
		this.targetCommand = targetCommand;
	}
	
	public function link (result: CommandResult, processor: CommandLinkProcessor): void {
		if (result.value == "foo") processor.execute(targetCommand);
	}
	
}
