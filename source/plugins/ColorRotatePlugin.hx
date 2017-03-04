package plugins;

import events.*;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import render.IColorSource;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ColorRotatePlugin extends PluginBase 
{
    private var accumulated:Float = 0.0;
    private var timeSincePop:Float = 0.0;
    
    //how much to accumulate before colors stuff shift
    private static var accumulateThreshold:Float = 6.0;
    //amount per block pop
    private static var popAccumulate:Float = 1.0;
    //amount per second
    private static var popSublimateMin:Float = 1.0 / 5.0;
    private static var popSublimateMax:Float = 1.0 / 1.0;
    private static var sublimateTimeToMin:Float = 2.0;
    
    private var colorSource:IColorSource;
    
    private var testBar:FlxBar;
    
    public function new(parent:FlxUIState, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.colorSource = colorSource;
        
        testBar = new FlxBar(10, 30, null, 250, 15, this, "accumulated", 0, accumulateThreshold, true);
        testBar.createFilledBar(0xFF63460C, 0xFFE6AA2F, true, FlxColor.BLACK);
        parent.add(testBar);
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        timeSincePop += elapsed;
        
        accumulated = Math.max(accumulated-(sublimationRate() * elapsed), 0.0);
        
        if (accumulated > accumulateThreshold){
            colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.10) % 1.0;
            EventManager.Trigger(this, Events.COLOR_ROTATE);
            accumulated -= accumulateThreshold;
        }
    }
    
    override function createEventSet():Void 
    {
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.BLOCK_POP, OnPop));
    }
    
    private function OnPop(sender:Dynamic, event:String, params:Dynamic){
        accumulated += popAccumulate;
        timeSincePop = 0.0;
    }
    
    private function sublimationRate():Float{
        if (timeSincePop > sublimateTimeToMin){
            return popSublimateMin;
        }
        return FlxMath.lerp(popSublimateMin, popSublimateMax, 1 - (timeSincePop / sublimateTimeToMin));
    }
}