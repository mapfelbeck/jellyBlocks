package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
        trace("oh hai!");
		addChild(new FlxGame(0, 0, MenuState));
	}
}
