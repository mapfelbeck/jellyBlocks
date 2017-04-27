package events;
import haxe.Constraints.Function;
/**
 * ...
 * @author Michael Apfelbeck
 */
typedef EventManagerCallback = Dynamic->String->Array<Dynamic>->Void;

class EventManager 
{
    private var func:EventManagerCallback;
    private static var instance:EventManager = new EventManager();
    private var callbackTable:Map<String,Array<EventManagerCallback>>;
    public function new(){
        callbackTable = new Map<String,Array<EventManagerCallback>>();
    }
    
    public static function Register(callback:EventManagerCallback, event:String):Void{
        if (callback == null || event == null){
            throw "Callback and event must be non-null to register for event.";
        }
        instance.Add(callback, event);
    }
    
    public static function UnRegister(callback:EventManagerCallback, event:String):Void{
        if (callback == null || event == null){
            throw "Callback and event must be non-null to un-register for event.";
        }
        instance.Remove(callback, event);
    }
    
    public static function Trigger(sender:Dynamic, event:String, ?params:Array<Dynamic>):Void{
        if (event == null){
            throw "Event non-null to trigger event.";
        }
        instance.ActivateEvent(sender, event, params);
    }
    
    private function Add(callback:EventManagerCallback, event:String):Void{
        var callbackArray:Array<EventManagerCallback> = callbackTable.get(event);
        if (callbackArray == null){
            callbackArray = new Array<EventManagerCallback>();
            callbackTable.set(event, callbackArray);
        }
        
        if (callbackArray.indexOf(callback) == -1){
            callbackArray.push(callback);
        }
    }
    
    private function Remove(callback:EventManagerCallback, event:String):Void{
        var callbackArray:Array<EventManagerCallback> = callbackTable.get(event);
        if (callbackArray != null){
            //var index:Int = callbackArray.indexOf(callback);
            //if (index != -1){
                callbackArray.remove(callback);
            //}
        }
    }
    
    private function ActivateEvent(sender:Dynamic, event:String, ?params:Array<Dynamic>):Void{
        var callbackArray:Array<EventManagerCallback> = callbackTable.get(event);
        if (callbackArray != null){
            var iter:Iterator<EventManagerCallback> = callbackArray.iterator();
            while (iter.hasNext()){
                iter.next()(sender, event, params);
            }
        }
    }
}