package;
import flixel.system.FlxPreloader;
import util.Capabilities;

/**
 * ...
 * @author Michael Apfelbeck
 */
class JellyBlocksPreloader extends FlxPreloader
{
     public function new(MinDisplayTime:Float=0, ?AllowedURLs:Array<String>)
    {
        super(MinDisplayTime, AllowedURLs);
        
        #if (html5)
        if (Capabilities.IsSafari()){
            GameSettings.MusicEnabled = false;
            GameSettings.SoundEffectsEnabled = false;
        }
        #end
    }
}