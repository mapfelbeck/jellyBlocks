package screenPlugins;

import blocks.GameBlock;
import events.EventAndAction;
import events.EventManager;
import events.Events;
import flixel.system.FlxAssets.FlxGraphicAsset;
import render.IColorSource;
import screens.BaseScreen;

/**
 * ...
 * @author Michael Apfelbeck
 */
private class CountAndTime{
    public var count:Int;
    public var time:Float;
    public function new(count:Int, time:Float){
        this.count = count;
        this.time = time;
    }
}
class ScorePlugin extends ScreenPluginBase 
{
    private var colors:IColorSource;
    private var lookupTable:Map<Int, CountAndTime> = new Map<Int, CountAndTime>();
    private static var popWaitTime:Float = 1.0;
    
    public function new(parent:BaseScreen, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        colors = colorSource;
    }
    
    override public function update(elapsed:Float){
        var removeList:List<Int> = new List<Int>();
        for (key in lookupTable.keys()){
            lookupTable[key].time -= elapsed;
            if (lookupTable[key].time <= 0){
                //trace("Popped " + lookupTable[key].count + " block of type " + key);
                removeList.add(key);
            }
        }
        for (materialToRemove in removeList){
            lookupTable.remove(materialToRemove);
        }
    }
    
    override function createEventSet():Void 
    {
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.BLOCK_POP, onBlockPop));
    }
    
    private function onBlockPop(sender:Dynamic, event:String, args:Array<Dynamic>):Void{
        //trace("Block popped");
        
        var block:GameBlock = Std.instance(sender, GameBlock);
        if (block != null){
            //trace("Block type was: " + block.Material);
            if (lookupTable.exists(block.Material)){
                lookupTable[block.Material].count++;
                lookupTable[block.Material].time = popWaitTime;
            }else{
                lookupTable.set(block.Material, new CountAndTime(1, popWaitTime));
            }
        }
    }
}