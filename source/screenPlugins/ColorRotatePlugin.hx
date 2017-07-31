package screenPlugins;

import events.*;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUISprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import render.IColorSource;
import screens.BaseScreen;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ColorRotatePlugin extends ScreenPluginBase 
{
    private var colorSource:IColorSource;

    //private var background:FlxUISprite;
    //private var backgroundSize:Int = 100;
    //private var colorWheelBackgroundRatio:Float = 0.8;
    //private var colorWheelSize:Int = 100;
    //private var colorWheel:FlxSprite;
    //private var colorWheelAlpha:FlxSprite;
    
    public function new(parent:BaseScreen, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        
        this.colorSource = colorSource;
        
        //ackground = cast parent.getAsset("rotate_background");
        
        //backgroundSize = Std.int(background.width);
        //colorWheelSize = Std.int(backgroundSize * colorWheelBackgroundRatio);
        
        //colorWheel = makeColorWheel(new FlxSprite());
        //colorWheel.y = background.y + (backgroundSize-colorWheelSize)/2;
        //parent.add(colorWheel);

        //colorWheelAlpha = makeColorWheelApha();
        
        //colorWheel.x = background.x + (backgroundSize-colorWheelSize)/2;
    }
    
    /*function makeColorWheel(sprite:FlxSprite):FlxSprite{
        if (colorWheelAlpha == null){
            colorWheelAlpha = makeColorWheelApha();
        }
        sprite = makeColorWheelBase(sprite);

        FlxSpriteUtil.alphaMaskFlxSprite(sprite, colorWheelAlpha, sprite);
        
        return sprite;
    }*/
    
    /*function makeColorWheelApha():FlxSprite{
        var sprite:FlxSprite = new FlxSprite();
        sprite.makeGraphic(colorWheelSize, colorWheelSize, FlxColor.BLACK);
        
        var spriteAlpha:FlxSprite = new FlxSprite();
        spriteAlpha.makeGraphic(colorWheelSize, colorWheelSize, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawCircle(spriteAlpha, -1, -1, colorWheelSize / 2, FlxColor.BLACK);
        
        FlxSpriteUtil.alphaMaskFlxSprite(sprite, spriteAlpha, sprite);
        
        return sprite;
    }*/
    
    /*function makeColorWheelBase(sprite:FlxSprite) :FlxSprite
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
    }*/
    
    private var spinning:Bool = false;
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
                
        /*if(spinning){
            colorWheel.angle+= elapsed * 1500;
            if (colorWheel.angle > 360){
                spinning = false;
                colorWheel.angle = 0;
            }
        }*/
    }
    
    override function createEventSet():Void 
    {
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.ACCUMULATE_THRESHOLD, OnThreshold));
    }
    
    private function OnThreshold(sender:Dynamic, event:String, params:Dynamic){
        colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.10) % 1.0;
        EventManager.Trigger(this, Events.COLOR_ROTATE);
        //makeColorWheel(colorWheel);
        //spinning = true;
    }
}