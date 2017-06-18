package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import screenPlugins.SoundsEffectsPlugin;
import globalPlugins.MusicPlugin;
import util.Capabilities;

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
    
    override function update():Void 
    {
        super.update();
    }
}