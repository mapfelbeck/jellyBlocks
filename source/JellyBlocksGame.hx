package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.input.gamepad.lists.FlxGamepadButtonList;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;
import screenPlugins.SoundsEffectsPlugin;
import globalPlugins.MusicPlugin;
import util.Capabilities;
import flixel.math.FlxPoint;

/**
 * ...
 * @author Michael Apfelbeck
 */
class JellyBlocksGame extends FlxGame 
{
    private var musicPlugin:MusicPlugin;
    
    public function new(GameWidth:Int=0, GameHeight:Int=0, ?InitialState:Class<FlxState>, Zoom:Float=1, UpdateFramerate:Int=60, DrawFramerate:Int=60, SkipSplash:Bool=true, StartFullscreen:Bool=false) 
    {
        super(GameWidth, GameHeight, InitialState, Zoom, UpdateFramerate, DrawFramerate, SkipSplash, StartFullscreen);
		
        createPlugins();
    }
    
    private function createPlugins():Void{
        #if html5
        if (!Capabilities.IsSafari()){
            musicPlugin = new MusicPlugin();
            FlxG.plugins.add(musicPlugin);
        }
        #else
        musicPlugin = new MusicPlugin();
        FlxG.plugins.add(musicPlugin);
        #end
    }
    
    var prevMousePosition: FlxPoint = new FlxPoint(0, 0);
    override function update():Void 
    {
        super.update();
        
        var currMousePosition:FlxPoint = FlxG.mouse.getPosition();
        var keyPress:Int = FlxG.keys.firstPressed();
        var btnPress:Int = -1;
        if (FlxG.gamepads.lastActive != null) {
            btnPress = FlxG.gamepads.lastActive.firstPressedID();
        }
        if (!prevMousePosition.equals(currMousePosition)){
            //trace("mouse ON");
            FlxG.mouse.visible = true;
        } else if (didKeyboardInput() || didGamepadInput()) {
            //trace("mouse OFF");
            FlxG.mouse.visible = false;
        }
        //trace("key: " + key);
        prevMousePosition = currMousePosition;
    }
    
    private function didKeyboardInput(): Bool {
        return FlxG.keys.firstPressed() != -1;
    }
    
    var gamePadButtons: Array<FlxGamepadInputID> = [FlxGamepadInputID.A, FlxGamepadInputID.B, FlxGamepadInputID.X, FlxGamepadInputID.Y,
                                                    FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.RIGHT_SHOULDER, 
                                                    FlxGamepadInputID.LEFT_TRIGGER_BUTTON, FlxGamepadInputID.RIGHT_TRIGGER_BUTTON,
                                                    FlxGamepadInputID.LEFT_STICK_DIGITAL_UP, FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN,
                                                    FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT,
                                                    FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP, FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN,
                                                    FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT, FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT,
                                                    FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.DPAD_DOWN,
                                                    FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.DPAD_RIGHT];
                                                    
    private function didGamepadInput(): Bool {
        var btnPress:Int = -1;
        if (FlxG.gamepads.lastActive != null) {
            var gamepad: FlxGamepad = FlxG.gamepads.lastActive;
            for (button in gamePadButtons) {
                if (gamepad.checkStatus(button, FlxInputState.PRESSED)) {
                    return true;
                }
            }
        }
        
        return false;
    }
}