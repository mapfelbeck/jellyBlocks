package;

import flixel.FlxG;
import flixel.addons.ui.FlxUIPopup;

/**
 * ...
 * @author 
 */
class PauseMenu extends FlxUIPopup
{

    public function new() 
    {
        super();
    }
    
    override public function create(){
		_xml_id = "pause_menu";
        super.create();
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
					}
				}
		}
	}
}