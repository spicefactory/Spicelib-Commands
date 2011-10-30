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
import org.spicefactory.lib.command.CommandResult;
	
/**
 * Event dispatched by commands when they finished executing.
 * This event also implements the <code>CommandResult</code> interface.
 * 
 * @author Jens Halm
 */
public class CommandResultEvent extends CommandEvent implements CommandResult {
	
	
	/**
	 * Constant for the type of event fired when a command completed successfully.
	 */
	public static const COMPLETE:String = "complete";

	/**
	 * Constant for the type of event fired when a command aborted with an error.
	 */
	public static const ERROR:String = "error";
	
	
    private var _result:Object;
    
    /**
     * Creates a new instance.
     * 
     * @param type the type of the event
     * @result the result produced by the command
     */
    function CommandResultEvent (type:String, result:Object) {
        super(type);
        _result = result;
    }
    
    /**
     * @inheritDoc
     */
    public function get value () : Object {
        return _result;
    }
    
    /**
     * @inheritDoc
     */
    public function get complete () : Boolean {
    	return (type == COMPLETE);
    }
    
    
}
	
}
