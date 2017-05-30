package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import screenPlugins.SoundsEffectsPlugin;
import globalPlugins.MusicPlugin;

/**
 * ...
 * @author Michael Apfelbeck
 */
class JellyBlocksGame extends FlxGame 
{
    private var musicPlugin:MusicPlugin;
    //private var soundEffectsPlugin:SoundsEffectsPlugin;
    
    public function new(GameWidth:Int=0, GameHeight:Int=0, ?InitialState:Class<FlxState>, Zoom:Float=1, UpdateFramerate:Int=60, DrawFramerate:Int=60, SkipSplash:Bool=true, StartFullscreen:Bool=false) 
    {
        super(GameWidth, GameHeight, InitialState, Zoom, UpdateFramerate, DrawFramerate, SkipSplash, StartFullscreen);
		
        createPlugins();
    }
    
    private function createPlugins():Void{
        musicPlugin = new MusicPlugin();
        FlxG.plugins.add(musicPlugin);
        
        //soundEffectsPlugin = new SoundsEffectsPlugin();
        //FlxG.plugins.add(soundEffectsPlugin);
    }
    
    override function update():Void 
    {
        super.update();
    }
}