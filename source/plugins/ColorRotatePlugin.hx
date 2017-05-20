package plugins;

import events.*;
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
    public var Accumulated(get, null):Float;
    public function get_Accumulated(){
        return accumulated;
    }
    
    private var accumulated:Float = 0.0;
    private var timeSincePop:Float = 0.0;
    
    //how much to accumulate before colors stuff shift
    private static var accumulateThreshold:Float = 6.5;
    //amount per block pop
    private static var popAccumulate:Float = 1.0;
    //amount per second
    private static var popSublimateMin:Float = 1.0 / 5.0;
    private static var popSublimateMax:Float = 1.0 / 1.0;
    private static var sublimateTimeToMin:Float = 2.0;
    
    private var colorSource:IColorSource;
    
    private var chargeBar:FlxBar;
    
    private static var fullBarSpriteAssetPath:String =  "assets/images/chargeBarFull.png";
    private static var emptyBarSpriteAssetPath:String =  "assets/images/chargeBarEmpty.png";
    private static var backgroundAssetPath:String =  "assets/images/chargeBarBackground.png";
    private var fullBar:FlxSprite;
    private var emptyBar:FlxSprite;
    private var background:FlxSprite;
    
    private var colorWheelBackgroundSize:Int = 40;
    private var colorWheelSize:Int = 30;
    private var colorWheel:FlxSprite;
    private var colorWheelAlpha:FlxSprite;
    
    public function new(parent:FlxUIState, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        
        var WINDOW_WIDTH:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
        var WINDOW_HEIGHT:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowHeight"));
        var yPos:Int = Std.int(WINDOW_HEIGHT / 20);
        
        this.colorSource = colorSource;
        
        emptyBar = new FlxSprite(0, 0, emptyBarSpriteAssetPath);
        fullBar = new FlxSprite(0, 0, fullBarSpriteAssetPath);
        
        chargeBar = new FlxBar(0, yPos, null, Std.int(emptyBar.width), Std.int(emptyBar.height), this, "Accumulated", 0, accumulateThreshold, false);
        chargeBar.createImageBar(emptyBar.pixels, fullBar.pixels, FlxColor.TRANSPARENT, FlxColor.RED);
        parent.add(chargeBar);
        
        background = new FlxSprite(0, 0, backgroundAssetPath);
        var backgroundScale:Float = colorWheelBackgroundSize / background.width;
        background.scale.set(backgroundScale, backgroundScale);
        background.updateHitbox();
        background.y = yPos;
        parent.add(background);
        
        colorWheel = makeColorWheel(new FlxSprite());
        colorWheel.y = yPos + (colorWheelBackgroundSize-colorWheelSize)/2;
        parent.add(colorWheel);

        colorWheelAlpha = makeColorWheelApha();
        
        var xPos:Int = Std.int((WINDOW_WIDTH - (chargeBar.width + colorWheelBackgroundSize)) / 2);
        chargeBar.x = xPos;
        background.x = xPos + chargeBar.width;
        colorWheel.x = xPos + chargeBar.width+(colorWheelBackgroundSize-colorWheelSize)/2;
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
        //I had to do trig to figure this out :(
        //correct for color count = 6
        var magicRatio:Float = 0.21133;
        var sideLength:Float = colorWheelSize * magicRatio;
        sprite.makeGraphic(colorWheelSize, colorWheelSize, FlxColor.WHITE);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(0));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, 0);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, 0);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, sideLength);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(1));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, sideLength);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, colorWheelSize - sideLength);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(2));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, colorWheelSize - sideLength);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize, colorWheelSize);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, colorWheelSize);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(3));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, colorWheelSize);
        FlxSpriteUtil.flashGfx.lineTo(0, colorWheelSize);
        FlxSpriteUtil.flashGfx.lineTo(0, colorWheelSize - sideLength);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(4));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.flashGfx.lineTo(0, colorWheelSize - sideLength);
        FlxSpriteUtil.flashGfx.lineTo(0, sideLength);
        FlxSpriteUtil.endDraw(sprite);
        
        FlxSpriteUtil.beginDraw(colorSource.getColor(5));
        FlxSpriteUtil.flashGfx.moveTo(colorWheelSize/2, colorWheelSize/2);
        FlxSpriteUtil.flashGfx.lineTo(0, sideLength);
        FlxSpriteUtil.flashGfx.lineTo(0, 0);
        FlxSpriteUtil.flashGfx.lineTo(colorWheelSize/2, 0);
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