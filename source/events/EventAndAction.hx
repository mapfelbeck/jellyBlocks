package events;
import haxe.Constraints.Function;

/**
 * ...
 * @author Michael Apfelbeck
 */
class EventAndAction 
{
    public var event:String;
    public var action:Function;
    public function new(event:String, action:Function) 
    {
        this.event = event;
        this.action = action;
    }
    
}