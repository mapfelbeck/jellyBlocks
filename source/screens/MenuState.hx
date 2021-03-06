package screens;

import constants.SoundAssets;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIText;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import screens.SettingsMenu;
import util.Capabilities;

class MenuState extends BaseScreen
{
	override public function create():Void
	{
		_xml_id = "menu_screen";
		_makeCursor = true;
		super.create();
        init();
        
	}
    
    private function init(){
        
        #if (html5)
        if (Capabilities.IsMobileBrowser()){
            FlxG.mouse.visible = false;
        }
        #end
        
        //cursor.loadGraphic("assets/gfx/ui/1px_trans.png");
        
        #if !mobile
        cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.GAMEPAD_DPAD | FlxUICursor.GAMEPAD_LEFT_STICK);
        cursor.visible = false;
        #end

        #if !flash
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
        #end
        
        var ui_play:FlxUIButton = cast _ui.getAsset("play_btn");
        if (ui_play != null){
            ui_play.onDown.sound = FlxG.sound.load(SoundAssets.MenuSelect1);
        }
        
        var buildText:FlxUIText = cast getAsset("version_text", false);
        var buildString:String = haxe.macro.Compiler.getDefine("BuildString");
        
        #if debug
        var buildType:String = "Debug";
        #else
        var buildType:String = "Release";
        #end
        if (buildText != null && buildString != null){
            buildText.text = StringTools.replace(buildString, "$buildType", buildType);
        }
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        /*if (FlxG.keys.justPressed.ENTER)
            FlxG.fullscreen = !FlxG.fullscreen;*/
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
                        case "play": FlxG.switchState(new screens.PlayState());
                        case "settings": openSubState(new SettingsMenu());
					}
				}
		}
	}
}
