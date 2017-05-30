package globalPlugins;

import flixel.FlxG;
import constants.SoundAssets;
import events.Events;
import events.EventManager;
import flixel.system.FlxSound;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import globalPlugins.GlobalPluginBase;
import haxe.macro.MacroStringTools;
import screenPlugins.ScreenPluginBase;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SoundsEffectsPlugin extends GlobalPluginBase 
{
    private var eventAssetTable:Map<String, String> =[
      Events.BLOCK_POP=>SoundAssets.BlockPop,
      Events.COLOR_ROTATE=>SoundAssets.Unfreeze,
      Events.PIECE_CREATE=>SoundAssets.PieceCreate,
      Events.PIECE_HIT=>SoundAssets.PieceHit,
    ];
    
    private var eventSoundTable:Map<String, FlxSound> = new Map<String, FlxSound>();
    
    public function new() 
    {
        super();
		init();
    }
    
    private function init():Void{
        for (event in eventAssetTable.keys()){
            eventSoundTable.set(event, FlxG.sound.load(eventAssetTable[event]));
            EventManager.Register(playSoundEvent, event);
        }
        //EventManager.Register(soundToggleCallback, Events.SOUND_ENABLED);
        //EventManager.Register(soundVolumeCallback, Events.SOUND_VOLUME);
    }
    
    function playSoundEvent(sender:Dynamic, event:String, params:Dynamic) :Void{
        if (GameSettings.SoundEffectsEnabled && eventSoundTable.exists(event)){
            eventSoundTable[event].volume = GameSettings.SoundEffectsVolume;
            eventSoundTable[event].play();
        }
    }
    
    /*function soundToggleCallback(sender:Dynamic, event:String, params:Array<Dynamic>):Void
    {
    }
    
    function soundVolumeCallback(sender:Dynamic, event:String, params:Array<Dynamic>):Void
    {
    }*/
}