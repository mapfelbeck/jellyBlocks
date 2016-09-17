package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();
        trace("MenuState created.");
        add(new FlxText(0, 0, 0, "Menu State."));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        trace("Jumping straight to game state.");
        FlxG.switchState(new PlayState());
	}
}
