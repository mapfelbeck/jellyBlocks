package screenPlugins;

import events.*;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUISprite;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import screens.BaseScreen;

/**
 * ...
 * @author Michael Apfelbeck
 */
class AccumulationPlugin extends ScreenPluginBase 
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
        
    private var chargeBar:FlxBar;
    
    private static var fullBarSpriteAssetPath:String =  "assets/images/chargeBarFull.png";
    private static var emptyBarSpriteAssetPath:String =  "assets/images/chargeBarEmpty.png";
    private var fullBar:FlxSprite;
    private var emptyBar:FlxSprite;
    private var barWidthRatio:Float = 5;
    
    private var background:FlxUISprite;
    
    public function new(parent:BaseScreen, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
                
        emptyBar = new FlxSprite(0, 0, emptyBarSpriteAssetPath);
        fullBar = new FlxSprite(0, 0, fullBarSpriteAssetPath);
        
        chargeBar = new FlxBar(0, 0, null, Std.int(emptyBar.width), Std.int(emptyBar.height), this, "Accumulated", 0, accumulateThreshold, false);
        chargeBar.createImageBar(emptyBar.pixels, fullBar.pixels, FlxColor.TRANSPARENT, FlxColor.RED);
        
        background = cast parent.getAsset("rotate_background");
        
        var chargeBarWidth:Int = cast(background.width * barWidthRatio);
        var heightToFinalRatio:Float = chargeBarWidth / emptyBar.width;
        var chargeBarHeight:Int = cast(emptyBar.height * heightToFinalRatio);
        chargeBar.setGraphicSize(chargeBarWidth, chargeBarHeight);
        chargeBar.updateHitbox();
        chargeBar.x = background.x - chargeBarWidth;
        chargeBar.y = background.y + (background.height-chargeBarHeight)/2;
        parent.add(chargeBar);
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        timeSincePop += elapsed;
        
        accumulated = Math.max(accumulated-(sublimationRate() * elapsed), 0.0);
        
        if (accumulated > accumulateThreshold){
            EventManager.Trigger(this, Events.ACCUMULATE_THRESHOLD);
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