package plugins;

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
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);

        if (FlxG.sound.music == null) // don't restart the music if it's already playing
        {
            FlxG.sound.playMusic(SoundAssets.MainTrack, 1, true);
        }
    }
}