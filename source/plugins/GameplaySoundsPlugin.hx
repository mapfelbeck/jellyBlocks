package plugins;

import flixel.FlxG;
import constants.SoundAssets;
import events.Events;
import events.EventManager;
import flixel.system.FlxSound;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.macro.MacroStringTools;

/**
 * ...
 * @author Michael Apfelbeck
 */
class GameplaySoundsPlugin extends PluginBase 
{
    private var eventAssetTable:Map<String, String> =[
      Events.BLOCK_POP=>SoundAssets.BlockPop,
      Events.COLOR_ROTATE=>SoundAssets.Unfreeze,
      Events.PIECE_CREATE=>SoundAssets.PieceCreate,
      Events.PIECE_HIT=>SoundAssets.PieceHit,
    ];
    
    private var eventSoundTable:Map<String, FlxSound> = new Map<String, FlxSound>();
    
    public function new(parent:FlxUIState, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
		init();
    }
    
    private function init():Void{
        for (event in eventAssetTable.keys()){
            eventSoundTable.set(event, FlxG.sound.load(eventAssetTable[event]));
            EventManager.Register(playSoundEvent, event);
        }
    }
    
    function playSoundEvent(sender:Dynamic, event:String, params:Dynamic) :Void{
        eventSoundTable[event].play();
    }
}