package;

import flixel.FlxGame;
import flixel.FlxState;

/**
 * ...
 * @author Michael Apfelbeck
 */
class JellyBlocksGame extends FlxGame 
{

    public function new(GameWidth:Int=0, GameHeight:Int=0, ?InitialState:Class<FlxState>, Zoom:Float=1, UpdateFramerate:Int=60, DrawFramerate:Int=60, SkipSplash:Bool=false, StartFullscreen:Bool=false) 
    {
        super(GameWidth, GameHeight, InitialState, Zoom, UpdateFramerate, DrawFramerate, SkipSplash, StartFullscreen);
		
    }
    
    override function update():Void 
    {
        super.update();
    }
}