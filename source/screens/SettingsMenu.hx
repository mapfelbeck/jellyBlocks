package screens;

import enums.PressType;
import flixel.FlxG;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIPopup;
import flixel.addons.ui.FlxUISlider;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SettingsMenu extends FlxUIPopup 
{
    private var musicCheckbox:FlxUICheckBox;
    private var soundCheckbox:FlxUICheckBox;
    
    private var musicStepper:FlxUINumericStepper;
    private var soundStepper:FlxUINumericStepper;
    /*private var foo:Float = 0.4;
    public var Foo(get, set):Float;
    public function get_Foo(){
        trace("Foo get");
        return foo;
    }
    public function set_Foo(value:Float):Float{
        trace("Foo set");
        foo = value;
        return foo;
    }
    
    private var bar:Float = 0.6;
    public var Bar(get, set):Float;
    public function get_Bar(){
        trace("3");
        return bar;
    }
    public function set_Bar(value:Float):Float{
        trace("4");
        bar = value;
        return bar;
    }
    
    function onValueChange (newValue:Float)
    {
    	trace("new value: " + newValue);
    }*/

    /*public var MusicEnabled(get, set):Bool;
    public function get_MusicEnabled(){
        trace("MusicEnabled get");
        return GameSettings.MusicEnabled;
    }
    public function set_MusicEnabled(value:Bool):Bool{
        GameSettings.MusicEnabled = value;
        trace("MusicEnabled set");
        return GameSettings.MusicEnabled;
    }*/
    private var input:Input;
    public function new() 
    {
        super();
    }
    
    override public function create(){
		_xml_id = "settings_menu";
        _makeCursor = true;
        super.create();
        
        #if !mobile
        cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.GAMEPAD_DPAD | FlxUICursor.GAMEPAD_LEFT_STICK);
        cursor.visible = false;
        #end
        
        input = new Input();
        
        input.AddGamepadButtonInput(FlxGamepadInputID.B, closeBtn, PressType.Down);
        
        musicCheckbox = cast _ui.getAsset("music_enabled");
        if (musicCheckbox != null){
            musicCheckbox.checked = GameSettings.MusicEnabled;
        }
        
        musicStepper = cast _ui.getAsset("music_volume");
        if (musicStepper != null){
            musicStepper.value = GameSettings.MusicVolume;
        }
        
        soundCheckbox = cast _ui.getAsset("sfx_enabled");
        if (soundCheckbox != null){
            soundCheckbox.checked = GameSettings.SoundEffectsEnabled;
        }

        soundStepper = cast _ui.getAsset("sfx_volume");
        if (soundStepper != null){
            soundStepper.value = GameSettings.SoundEffectsVolume;
        }
    }
    
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{		
		switch (name)
		{
			case FlxUICheckBox.CLICK_EVENT:
                var check:FlxUICheckBox = cast sender;
                if (check.name == "music_enabled"){
                    GameSettings.MusicEnabled = check.checked;
                }else if (check.name == "sfx_enabled"){
                    GameSettings.SoundEffectsEnabled = check.checked;
                }
			case FlxUINumericStepper.CHANGE_EVENT:
                var stepper:FlxUINumericStepper = cast sender;
                var value:Float = stepper.value;
                if (stepper.name == "music_volume"){
                    GameSettings.MusicVolume = value;
                }else if (stepper.name == "sfx_volume"){
                    GameSettings.SoundEffectsVolume = value;
                }
			case "click_button":
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
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        input.Update(elapsed);
    }
    
    private function closeBtn(button:FlxGamepadInputID, type:PressType){
        close();
    }
    
}