package screens;

import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;

/**
 * ...
 * @author Michael Apfelbeck
 */
class BaseScreen extends FlxUIState 
{
	public function getAsset(key:String, recursive:Bool = true):IFlxUIWidget
	{
        return _ui.getAsset(key, recursive);
    }
}