package plugins;

import events.*;
import enums.PressType;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

/**
 * ...
 * @author Michael Apfelbeck
 */
class GamePieceSpawnPlugin extends PluginBase 
{

    private var spawnTimer:Float = 0.0;
    private var spawnTimerMax:Float = 10.0;
    private var spawnTimerInc:Float = 0.0;
    //timer starts spawning pieces 3 seconds after game loads.
    private var timeTillFirstSpawn:Float = 3.0;
    //new piece spawned this many seconds after controlled piece hits something
    private var spawnAfterCollidionTime:Float = 2.5;
    //don't spaw pieces at less than this interval
    private var minLifeTime:Float = 3.0;
    //spawn pieces at at least this interval
    private var maxLifeTime:Float = 7.0;
    
    private var testBar:FlxBar;
    
    private var input:Input;
    
    public function new(parent:FlxUIState, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        
        testBar = new FlxBar(10, 10, null, 250, 15, this, "spawnTimer", 0, spawnTimerMax, true);
        testBar.createFilledBar(0xFF63460C, 0xFFE6AA2F, true, FlxColor.BLACK);
        parent.add(testBar);
        
        input = new Input();
        input.AddInputCommand(FlxKey.SPACE, spawnPiece, PressType.Down);
        
        spawnTimerInc = spawnTimerMax / timeTillFirstSpawn;
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        
        spawnTimer += spawnTimerInc * elapsed;
        if (spawnTimer > spawnTimerMax){
            spawnTimer = 0;
            spawnTimerInc = spawnTimerMax / maxLifeTime;
        }
    }
    
    private var spawnPieceFlag:Bool = false;
    private function spawnPiece():Void{
        spawnPieceFlag = true;
    }
    
}