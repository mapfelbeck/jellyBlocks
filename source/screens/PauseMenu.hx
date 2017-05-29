package screens;

import enums.PressType;
import flixel.FlxG;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIPopup;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author 
 */
class PauseMenu extends FlxUIPopup
{
    private var input:Input;
    public function new() 
    {
        super();
    }
    
    override public function create(){
		_xml_id = "pause_menu";
        _makeCursor = true;
        super.create();
        
        #if !mobile
        cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.GAMEPAD_DPAD | FlxUICursor.GAMEPAD_LEFT_STICK);
        cursor.visible = false;
        #end
        
        input = new Input();
        
        input.AddGamepadButtonInput(FlxGamepadInputID.B, closeBtn, PressType.Down);
    }
    
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
        //trace("PlayState.getEvent(" + name+")");
		var str:String = "";
		
		switch (name)
		{
			case "finish_load":
                trace("Popup loaded");
			case "click_button":
                trace("Button click.");
				if (params != null && params.length > 0)
				{
                    trace("click param: " + Std.string(params[0]));
					switch (Std.string(params[0]))
					{
                        case "close": 
                            close();
                        case "restart":
                            castParent().getEvent("RELOAD", this, null);
                            close();
                        case "main_menu":
                            close();
                            FlxG.switchState(new MenuState());
                        case "settings":
                            openSubState(new SettingsMenu());
					}
				}
		}
	}
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        input.Update(elapsed);
    }
    
    private function closeBtn(button:FlxGamepadInputID, type:PressType){
        close();
    }
}