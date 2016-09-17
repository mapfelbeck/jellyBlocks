package;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import haxe.Constraints.Function;

/**
 * ...
 * @author ...
 */
class Input
{
    private var keys:Array<FlxKey>;
    private var actionMap:Map<FlxKey, Array<Function>>;
    public function new() 
    {
        keys = new Array<FlxKey>();
        actionMap = new Map<FlxKey, Array<Function>>();
    }
    
    public function Update(elapsed:Float) 
    {
        for (key in keys){
            if (FlxG.keys.anyJustPressed([key])){
                //trace("key " + key.toString + " is pressed");
                for (action in actionMap.get(key)){
                    action();
                }
            }/*else{
                trace("key " + key.toString + " is NOT pressed");
            }*/
        }
    }
    
    public function AddInputCommand(key:FlxKey, action:Function) 
    {
        var actionArray:Array<Function> = null;
        if (actionMap.exists(key)){
            actionArray = actionMap.get(key);
        }else{
            keys.push(key);
            actionArray = new Array<Function>();
            actionMap.set(key, actionArray);
        }
        
        actionArray.push(action);
    }
    
}