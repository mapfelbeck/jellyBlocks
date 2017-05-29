package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new JellyBlocksGame(0, 0, screens.MenuState));
	}
}
