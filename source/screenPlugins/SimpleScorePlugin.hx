package screenPlugins;

import blocks.GameBlock;
import events.EventAndAction;
import events.EventManager;
import events.Events;
import flixel.addons.ui.FlxUIText;
import flixel.system.FlxAssets.FlxGraphicAsset;
import jellyPhysics.math.Vector2;
import render.IColorSource;
import screens.BaseScreen;

/**
 * ...
 * @author Michael Apfelbeck
 */
private class CountAndTime{
    public var count:Int;
    public var time:Float;
    public var pos:Vector2;
    public var material:Int;
    public var timeIndex:Float;
    public function new(count:Int, time:Float, pos:Vector2, material:Int, timeIndex:Float){
        this.count = count;
        this.time = time;
        this.pos = pos;
        this.material = material;
        this.timeIndex = timeIndex;
    }
}
class SimpleScorePlugin extends ScreenPluginBase 
{
    private var colors:IColorSource;
    private var lookupTable:Map<Int, CountAndTime> = new Map<Int, CountAndTime>();
    private static var popWaitTime:Float = 1.0;
    
    private var scoreNumber:Int = 0;
    private var scoreText:FlxUIText;
    
    private var gameTime:Float = 0;
    
    public function new(parent:BaseScreen, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        colors = colorSource;
        
        scoreText = cast parent.getAsset("score_number");
        updateScoreText();
    }
    
    //var drawCount:Int = 0;
    override public function update(elapsed:Float){
        gameTime += elapsed;
        var removeList:List<Int> = new List<Int>();
        for (key in lookupTable.keys()){
            lookupTable[key].time -= elapsed;
            if (lookupTable[key].time <= 0){
                //trace("Popped " + lookupTable[key].count + " block of type " + key);
                removeList.add(key);
                scoreNumber += Std.int(Math.pow(lookupTable[key].count, 2)) * 10;
                updateScoreText();
                EventManager.Trigger(this, Events.COMBO_SCORE, [key, lookupTable[key].count, lookupTable[key].pos]);
            }
        }
        for (materialToRemove in removeList){
            lookupTable.remove(materialToRemove);
        }
        
        /*drawCount++;
        if (drawCount >= 20) {
            drawCount = 0;
            var inFlight:Array<CountAndTime> = new Array<CountAndTime>();
            for (key in this.lookupTable.keys()){
                inFlight.push(lookupTable[key]);
            }
            if(inFlight.length > 0){
                inFlight.sort(this.compare);
                trace("in flight score:");
                for (scoreElement in inFlight){
                    trace(scoreElement.count + "X, material type: " + scoreElement.material);
                }
            }
        }*/
    }

    private function compare(a:CountAndTime, b:CountAndTime){
        if (a.timeIndex < b.timeIndex){
            return -1;
        } else if (a.timeIndex < b.timeIndex){
            return 1;
        }
        return 0;
    }
    override function createEventSet():Void 
    {
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.BLOCK_POP, onBlockPop));
    }
    
    private function updateScoreText():Void{
        scoreText.text = Std.string(scoreNumber);
    }
    
    private function onBlockPop(sender:Dynamic, event:String, args:Array<Dynamic>):Void{
        //trace("Block popped");
        
        var block:GameBlock = Std.instance(sender, GameBlock);
        if (block != null){
            //trace("Block type was: " + block.Material);
            if (lookupTable.exists(block.Material)){
                lookupTable[block.Material].count++;
                lookupTable[block.Material].time = popWaitTime;
                lookupTable[block.Material].pos.x *= (lookupTable[block.Material].count / (lookupTable[block.Material].count + 1));
                lookupTable[block.Material].pos.y *= (lookupTable[block.Material].count / (lookupTable[block.Material].count + 1));
                lookupTable[block.Material].pos.x += block.DerivedPos.x / (lookupTable[block.Material].count + 1);
                lookupTable[block.Material].pos.y += block.DerivedPos.y / (lookupTable[block.Material].count + 1);
            }else{
                lookupTable.set(block.Material, new CountAndTime(1, popWaitTime, block.DerivedPos, block.Material, this.gameTime));
            }
        }
    }
}