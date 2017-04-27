package;

import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;

class MenuState extends FlxUIState
{
	override public function create():Void
	{
		super.create();
        add(new FlxText(0, 0, 0, "Menu State."));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        FlxG.switchState(new PlayState());
	}
    
	/*public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
        trace("MenuState.getEvent(" + name+")");
	}*/
}
