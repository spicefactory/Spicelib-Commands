package {

import org.spicefactory.lib.command.CommandDataTest;
import org.spicefactory.lib.command.CommandExecutionTest;
import org.spicefactory.lib.command.CommandFlowTest;
import org.spicefactory.lib.command.CommandGroupTest;
import org.spicefactory.lib.command.LightCommandTest;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class CommandSuite {

	public var execution:CommandExecutionTest;
	public var groups:CommandGroupTest;
	public var flows:CommandFlowTest;
	public var data:CommandDataTest;
	public var light:LightCommandTest;
	
}
}
