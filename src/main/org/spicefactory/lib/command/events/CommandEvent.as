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

package org.spicefactory.lib.command.events {

import flash.events.Event;
	
/**
 * Event dispatched by commands to signal state changes.
 * 
 * @author Jens Halm
 */
public class CommandEvent extends Event {
	
	
	/**
	 * Constant for the type of event fired when a command was cancelled.
	 */
	public static const CANCEL:String = "cancel";

	/**
	 * Constant for the type of event fired when a command was suspended.
	 */
	public static const SUSPEND:String = "suspend";
	
	/**
	 * Constant for the type of event fired when a command was resumed.
	 */
	public static const RESUME:String = "resume";
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type of the event
	 */
    function CommandEvent (type:String) {
        super(type);
    }
    
    /**
     * The command that dispatched the event.
     */
    public function get command () : Object {
    	return target;
    }
	
	
}
}
