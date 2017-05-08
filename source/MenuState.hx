package;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.FlxUIState;
import flixel.graphics.FlxGraphic;

class MenuState extends FlxUIState
{
	override public function create():Void
	{
		_xml_id = "menu_screen";
		super.create();
        init();
	}
    
    private function init(){
        FlxTransitionableState.defaultTransIn = new TransitionData();
        FlxTransitionableState.defaultTransOut = new TransitionData();
        
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;
        
        FlxTransitionableState.defaultTransIn.tileData = { asset: diamond, width: 32, height: 32 };
        FlxTransitionableState.defaultTransOut.tileData = { asset: diamond, width: 32, height: 32 };
        
        FlxTransitionableState.defaultTransIn.duration = 0.25;
        FlxTransitionableState.defaultTransOut.duration = 0.25;

        FlxTransitionableState.defaultTransIn.color = FlxColor.GRAY;
        FlxTransitionableState.defaultTransOut.color = FlxColor.GRAY;

        transOut = FlxTransitionableState.defaultTransOut;
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
    
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		var str:String = "";
		
		switch (name)
		{
			case "finish_load":
			case "click_button":
				if (params != null && params.length > 0)
				{
					switch (Std.string(params[0]))
					{
                        case "play": FlxG.switchState(new PlayState());
					}
				}
		}
	}
}
