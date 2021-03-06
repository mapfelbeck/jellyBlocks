package screenPlugins;

import events.EventAndAction;
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
import screens.BaseScreen;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SoundsEffectsPlugin extends ScreenPluginBase 
{
    private var eventAssetTable:Map<String, String> =[
      Events.BLOCK_POP=>SoundAssets.BlockPop,
      Events.COLOR_ROTATE=>SoundAssets.Unfreeze,
      Events.PIECE_CREATE=>SoundAssets.PieceCreate,
      Events.PIECE_HIT=>SoundAssets.PieceHit,
    ];
    
    private var eventSoundTable:Map<String, FlxSound> = new Map<String, FlxSound>();
    
    public function new(parent:BaseScreen) 
    {
        super(parent);
		init();
    }
    
    override public function createEventSet():Void{
        super.createEventSet();
        
        for (event in eventAssetTable.keys()){
            eventSoundTable.set(event, FlxG.sound.load(eventAssetTable[event]));
            eventSet.push(new EventAndAction(event, playSoundEvent));
        }
    }
    
    private function init():Void{
    }
    
    function playSoundEvent(sender:Dynamic, event:String, params:Dynamic) :Void{
        if (GameSettings.SoundEffectsEnabled && eventSoundTable.exists(event)){
            eventSoundTable[event].volume = GameSettings.SoundEffectsVolume;
            eventSoundTable[event].play();
        }
    }
}