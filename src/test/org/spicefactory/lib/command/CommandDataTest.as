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
import org.hamcrest.collection.arrayWithSize;
import org.hamcrest.core.isA;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.isFalse;
import org.hamcrest.object.isTrue;
import org.hamcrest.object.notNullValue;
import org.spicefactory.lib.command.builder.CommandGroupBuilder;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.data.CommandData;
import org.spicefactory.lib.command.impl.AsynchronousCommand;
import org.spicefactory.lib.command.impl.SyncLightDataCommand;
import org.spicefactory.lib.command.impl.SyncLightResultCommand;
import org.spicefactory.lib.command.model.CommandModel;
/**
 * @author Jens Halm
 */
public class CommandDataTest {
	
	
	[Test]
	public function singleCommand (): void {
		var async: AsynchronousCommand = new AsynchronousCommand();
		var result:Object;
		var resultHandler: Function = function (param: Object): void {
			result = param;
		};
		Commands.wrap(async).result(resultHandler).execute();
		async.forceCompletion("foo");
		assertThat(result, equalTo("foo"));
	}
	
	[Test]
	public function sequence (): void {
		group(Commands.asSequence());
	}
	
	[Test]
	public function parallel (): void {
		group(Commands.inParallel());
	}
	
	private function group (builder: CommandGroupBuilder, numResults: uint = 2): CommandData {
		var com1: AsynchronousCommand = new AsynchronousCommand();
		var com2: AsynchronousCommand = new AsynchronousCommand();
		var allResults:Object;
		var allResultsHandler: Function = function (param: Object): void {
			allResults = param;
		};
		var lastResult:Object;
		var lastResultHandler: Function = function (param: Object): void {
			lastResult = param;
		};
		builder.add(com1).add(com2).allResults(allResultsHandler).lastResult(lastResultHandler).execute();
		com1.forceCompletion("foo");
		com2.forceCompletion(7);
		assertThat(lastResult, equalTo(7));
		assertThat(allResults, isA(CommandData));
		var data: CommandData = CommandData(allResults);
		assertThat(data.getObject(String), equalTo("foo"));
		assertThat(data.getObject(Number), equalTo(7));
		assertThat(data.getAllObjects(), arrayWithSize(numResults));
		return data;
	}
	
	[Test]
	public function passThrough (): void {
		var data: CommandData = group(Commands.asSequence().data(new Date()), 3);
		assertThat(data.getObject(Date), notNullValue());
	}
	
	[Test]
	public function injection (): void {
		var model: CommandModel = new CommandModel("foo");
		var com1: AsynchronousCommand = new AsynchronousCommand();
		Commands.asSequence().add(com1).create(AsynchronousCommand).execute();
		
		assertThat(model.injected, isFalse());
		com1.forceCompletion(model);
		assertThat(model.injected, isTrue());
	}
	
	[Test]
	public function lightCommand (): void {
		var com1: SyncLightResultCommand = new SyncLightResultCommand(new CommandModel("foo"));
		var com2: SyncLightDataCommand = new SyncLightDataCommand();
		var allResults:Object;
		var allResultsHandler: Function = function (param: Object): void {
			allResults = param;
		};
		var lastResult:Object;
		var lastResultHandler: Function = function (param: Object): void {
			lastResult = param;
		};
		Commands.asSequence().add(com1).add(com2).allResults(allResultsHandler).lastResult(lastResultHandler).execute();
		assertThat(lastResult, equalTo("foo"));
		assertThat(allResults, isA(CommandData));
		var data: CommandData = CommandData(allResults);
		assertThat(data.getObject(String), equalTo("foo"));
		assertThat(data.getObject(CommandData), notNullValue());
		assertThat(data.getAllObjects(), arrayWithSize(2));
		
		assertThat(com1.executed, isTrue());
		assertThat(com2.model, notNullValue());
	}
	
	
}
}
