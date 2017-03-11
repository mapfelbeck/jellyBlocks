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
import util.UtilClass;
import constants.GameConstants;

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
    private static var backgroundAssetPath:String =  "assets/images/GUIElementBackground.png";
    private var overlay:FlxSprite;
    private var overlayAlpha:FlxSprite;
    private var fullBar:FlxSprite;
    private var background:FlxSprite;
    
    private var colorWheelSize:Int = 30;
    private var colorWheel:FlxSprite;
    private var colorWheelAlpha:FlxSprite;
    
    public function new(parent:FlxUIState, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.colorSource = colorSource;
        
		overlayAlpha = new FlxSprite(0, 0, alphaAssetPath);
        
		overlay = new FlxSprite(0, 0, emptyBarSpriteAssetPath);
        FlxSpriteUtil.alphaMaskFlxSprite(overlay, overlayAlpha, overlay);
        
        fullBar = new FlxSprite(0, 0, fullBarSpriteAssetPath);
        FlxSpriteUtil.alphaMaskFlxSprite(fullBar, overlayAlpha, fullBar);
        
        testBar = new FlxBar(50, 30, null, Std.int(overlay.width), Std.int(overlay.height), this, "accumulated", 0, accumulateThreshold, false);
        testBar.createImageBar(overlay.pixels, fullBar.pixels, FlxColor.TRANSPARENT, FlxColor.RED);
        parent.add(testBar);
        
        background = new FlxSprite(0, 0, backgroundAssetPath);
        var backgroundScale:Float = 40 / background.width;
        background.scale.set(backgroundScale, backgroundScale);
        background.updateHitbox();
        background.x = testBar.x + testBar.width;
        background.y = testBar.y;
        parent.add(background);
        
        colorWheel = makeColorWheel(new FlxSprite());
        colorWheel.x = background.x + 5;
        colorWheel.y = background.y + 5;
        parent.add(colorWheel);

        colorWheelAlpha = makeColorWheelApha();
    }
    
    function makeColorWheel(sprite:FlxSprite):FlxSprite{
        if (colorWheelAlpha == null){
            colorWheelAlpha = makeColorWheelApha();
        }
        sprite = makeColorWheelBase(sprite);

        FlxSpriteUtil.alphaMaskFlxSprite(sprite, colorWheelAlpha, sprite);
        
        return sprite;
    }
    
    function makeColorWheelApha():FlxSprite{
        var sprite:FlxSprite = new FlxSprite();
        sprite.makeGraphic(colorWheelSize, colorWheelSize, FlxColor.BLACK);
        
        var spriteAlpha:FlxSprite = new FlxSprite();
        spriteAlpha.makeGraphic(colorWheelSize, colorWheelSize, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawCircle(spriteAlpha, -1, -1, colorWheelSize / 2, FlxColor.BLACK);
        
        FlxSpriteUtil.alphaMaskFlxSprite(sprite, spriteAlpha, sprite);
        
        return sprite;
    }
    
    function makeColorWheelBase(sprite:FlxSprite) :FlxSprite
    {
        sprite.makeGraphic(colorWheelSize, colorWheelSize, FlxColor.WHITE);
        var colorIndexes:Array<Int> = UtilClass.randomInts(4, GameConstants.UniqueColors, 1);
        
        //FlxSpriteUtil.drawRect(sprite, 0, 0, 20, 20, FlxColor.WHITE);
        FlxSpriteUtil.beginDraw(colorSource.getColor(colorIndexes[0]));
        FlxSpriteUtil.flashGfx.moveTo(0, 0);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, 0);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(colorIndexes[1]));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize, 0);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, colorWheelSize);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(colorIndexes[2]));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize, colorWheelSize);
        FlxSpriteUtil.flashGfx.lineTo(0, colorWheelSize);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(colorIndexes[3]));
        FlxSpriteUtil.flashGfx.moveTo(0, colorWheelSize);
        FlxSpriteUtil.flashGfx.lineTo(0, 0);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.endDraw(sprite);
        
        return sprite;
    }
    
    private var spinning:Bool = false;
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        timeSincePop += elapsed;
        
        accumulated = Math.max(accumulated-(sublimationRate() * elapsed), 0.0);
        
        if (accumulated > accumulateThreshold){
            colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.10) % 1.0;
            EventManager.Trigger(this, Events.COLOR_ROTATE);
            accumulated -= accumulateThreshold;
            makeColorWheel(colorWheel);
            spinning = true;
        }
        
        if(spinning){
            colorWheel.angle+= elapsed * 1500;
            if (colorWheel.angle > 360){
                spinning = false;
                colorWheel.angle = 0;
            }
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