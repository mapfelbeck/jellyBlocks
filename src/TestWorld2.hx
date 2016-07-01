package;
import openfl.display.Sprite;
import openfl.events.*;
import haxe.Timer;
/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorld2 extends Sprite
{    
    public function new() 
    {
        super();
        trace("TestWorld2 created");
        if (this.stage != null){
            trace("immediate init");
            Init(null);
        }else{
            trace("waiting...");
            addEventListener(Event.ADDED_TO_STAGE, Init);
        }
    }
    
    private function Init(e:Event):Void
    {
        lastTimeStamp = Timer.stamp();
        removeEventListener(Event.ADDED_TO_STAGE, Init);
        addEventListener(Event.REMOVED_FROM_STAGE, Close);
        addEventListener(Event.ENTER_FRAME, Update);
    }
    
    private var lastTimeStamp:Float;
    private function Update(e:Event):Void
    {
        var currTimeStamp:Float = Timer.stamp();
        trace("frame time: " + (currTimeStamp - lastTimeStamp));
        lastTimeStamp = currTimeStamp;
    }
    
    private function Close(e:Event):Void
    {
        removeEventListener(Event.REMOVED_FROM_STAGE, Close);
        removeEventListener(Event.ENTER_FRAME, Update);
    }
}