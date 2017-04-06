package events;
import events.EventManager.EventManagerCallback;
import haxe.Constraints.Function;

/**
 * ...
 * @author Michael Apfelbeck
 */
class EventAndAction 
{
    public var event:String;
    public var action:EventManagerCallback;
    public function new(event:String, action:EventManagerCallback) 
    {
        this.event = event;
        this.action = action;
    }
    
}