package globalPlugins;

import events.EventManager;
import events.Events;
import flixel.FlxG;
import globalPlugins.GlobalPluginBase;
import constants.SoundAssets;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author Michael Apfelbeck
 */
class MusicPlugin extends GlobalPluginBase 
{
    public function new() 
    {
        super();
        
        init();
    }
    
    private function init():Void{
        EventManager.Register(musicToggleCallback, Events.MUSIC_ENABLED);
        EventManager.Register(musicVolumeCallback, Events.MUSIC_VOLUME);
    }
    
    function musicToggleCallback(sender:Dynamic, event:String, params:Array<Dynamic>):Void
    {
        var enabled:Bool = cast params[0];
        if (FlxG.sound.music != null && !enabled){
            stopMusic();
        }else if (enabled){
            startMusic();
        }
    }
    
    function musicVolumeCallback(sender:Dynamic, event:String, params:Array<Dynamic>):Void
    {
        var volume:Float = cast params[0];
        if (FlxG.sound.music != null){
            FlxG.sound.music.volume = volume;
        }
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);

        if (FlxG.sound.music == null && GameSettings.MusicEnabled) // don't restart the music if it's already playing
        {
            startMusic();
        }
    }
    
    private function startMusic():Void{
        FlxG.sound.playMusic(SoundAssets.MainTrack, GameSettings.MusicVolume, true);
    }
    
    private function stopMusic():Void{
        FlxG.sound.music.stop();
    }
}