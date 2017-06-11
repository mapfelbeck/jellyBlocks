package screens;

import enums.PressType;
import flixel.FlxG;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIPopup;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author Michael Apfelbeck
 */
class GameOverMenu extends FlxUIPopup
{
    public function new() 
    {
        super();
    }
    
    override public function create(){
		_xml_id = "game_over_popup";
        _makeCursor = true;
        super.create();
        
        #if !mobile
        cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.GAMEPAD_DPAD | FlxUICursor.GAMEPAD_LEFT_STICK);
        cursor.visible = false;
        #end
    }
    
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		var str:String = "";
		
		switch (name)
		{
			case "click_button":
				if (params != null && params.length > 0)
				{
                    trace("click param: " + Std.string(params[0]));
					switch (Std.string(params[0]))
					{
                        case "restart":
                            castParent().getEvent("RELOAD", this, null);
                            close();
                        case "main_menu":
                            close();
                            FlxG.switchState(new MenuState());
					}
				}
		}
	}
}