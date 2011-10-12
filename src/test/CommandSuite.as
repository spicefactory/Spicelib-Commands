package {

import org.spicefactory.lib.command.CommandDataTest;
import org.spicefactory.lib.command.CommandExecutionTest;
import org.spicefactory.lib.command.CommandGroupTest;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class CommandSuite {

	public var execution:CommandExecutionTest;
	public var groups:CommandGroupTest;
	public var data:CommandDataTest;
	
}
}
