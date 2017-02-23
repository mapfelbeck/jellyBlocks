package plugins;

import events.*;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import render.IColorSource;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ColorRotatePlugin extends PluginBase 
{
    private var accumulated:Float = 0.0;
    
    private static var accumulateThreshold:Float = 1.5;
    //amount per block pop
    private static var popAccumulate:Float = 1.0 / 3.0;
    //amount per second
    private static var popSublimate:Float = 1.0 / 3.0;
    
    private var colorSource:IColorSource;
    
    public function new(parent:FlxUIState, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.colorSource = colorSource;
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        
        accumulated = Math.max(accumulated-(popSublimate * elapsed), 0.0);
        
        if (accumulated > accumulateThreshold){
            colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.10) % 1.0;
            EventManager.Trigger(this, Events.COLOR_ROTATE);
            accumulated = 0;
        }
    }
    
    override function createEventSet():Void 
    {
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.BLOCK_POP, OnPop));
    }
    
    private function OnPop(sender:Dynamic, event:String, params:Dynamic){
        accumulated+= popAccumulate;
    }
}