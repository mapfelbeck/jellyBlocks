package screenPlugins;

import flixel.addons.text.FlxTextField;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import screens.BaseScreen;
/**
 * ...
 * @author Michael Apfelbeck
 */
class FrameRatePlugin extends ScreenPluginBase 
{
    //how many samples/second
    private var samplesPerSecond:Int = 1;
    private var displayText:FlxTextField;
    public function new(parent:BaseScreen, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
		sampleRate = 1.0 / samplesPerSecond;

        then = get_now();
        
        displayText = new FlxTextField(0, 0, 40, "0", 16, false);
        displayText.color = new FlxColor(0xFFA0A0A0);
        parent.add(displayText);
    }
    
    private var sampleRate:Float = 1.0;
    private var count:Int = 0;
    private var then:Float = 0;
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        
        count++;
        
        var currentTime:Float = get_now();
        var delta:Float = currentTime-then;
        if (delta > sampleRate){
            var fps:Int = Std.int(count / sampleRate);
            displayText.text = Std.string(fps);
            //trace("fps: " + fps);
            count = 0;
            then = currentTime;
        }
    }
    
    var now (get, never) :Float;
    inline function get_now() :Float
    {
    #if (sys)
        return Sys.cpuTime();
    #elseif (flash || nme || openfl)
        return flash.Lib.getTimer() / 1000;
    #elseif lime
        return lime.system.System.getTimer() / 1000;
    #else
        return haxe.Timer.stamp();
    #end
    }
    
}