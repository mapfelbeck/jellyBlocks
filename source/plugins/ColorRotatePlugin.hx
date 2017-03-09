package plugins;

import events.*;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
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
    
    private static var emptyBarSpriteAssetPath:String =  "assets/images/ChargeBarH_empty.png";
    private static var fullBarSpriteAssetPath:String =  "assets/images/ChargeBarH_full.png";
    private static var alphaAssetPath:String =  "assets/images/ChargeBarH_alpha.png";
    private var overlaySprite:FlxSprite;
    private var alphaSprite:FlxSprite;
    private var fullBarSprite:FlxSprite;
    
    public function new(parent:FlxUIState, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.colorSource = colorSource;
        
		alphaSprite = new FlxSprite(0, 0, alphaAssetPath);
        
		overlaySprite = new FlxSprite(10, 60, emptyBarSpriteAssetPath);
        FlxSpriteUtil.alphaMaskFlxSprite(overlaySprite, alphaSprite, overlaySprite);
        
        fullBarSprite = new FlxSprite(0, 0, fullBarSpriteAssetPath);
        FlxSpriteUtil.alphaMaskFlxSprite(fullBarSprite, alphaSprite, fullBarSprite);
        
        testBar = new FlxBar(10, 30, null, Std.int(overlaySprite.width), Std.int(overlaySprite.height), this, "accumulated", 0, accumulateThreshold, false);
        testBar.createImageBar(overlaySprite.pixels, fullBarSprite.pixels, FlxColor.TRANSPARENT, FlxColor.RED);
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