package;
import enums.PressType;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import haxe.Constraints.Function;

/**
 * ...
 * @author ...
 */

typedef KeyboardInputCallback = FlxKey->PressType->Void;
typedef GamepadInputCallback = Dynamic->String->Array<Dynamic>->Void;

class Input
{
    private var downKeys:Array<FlxKey>;
    private var pressedKeys:Array<FlxKey>;
    private var upKeys:Array<FlxKey>;
    private var actionDownMap:Map<FlxKey, Array<Function>>;
    private var actionPressedMap:Map<FlxKey, Array<Function>>;
    private var actionUpMap:Map<FlxKey, Array<Function>>;
    public function new() 
    {
        downKeys = new Array<FlxKey>();
        pressedKeys = new Array<FlxKey>();
        upKeys = new Array<FlxKey>();
        actionDownMap = new Map<FlxKey, Array<Function>>();
        actionPressedMap = new Map<FlxKey, Array<Function>>();
        actionUpMap = new Map<FlxKey, Array<Function>>();
    }
    
    public function Update(elapsed:Float) 
    {
        #if (html5 || neko || flash || windows)
        for (key in downKeys){
            if (FlxG.keys.anyJustPressed([key])){
                for (action in actionDownMap.get(key)){
                    action(key, PressType.Down);
                }
            }
        }
        for (key in pressedKeys){
            if (FlxG.keys.anyPressed([key])){
                for (action in actionPressedMap.get(key)){
                    action(key, PressType.Pressed);
                }
            }
        }
        for (key in upKeys){
            if (FlxG.keys.anyJustReleased([key])){
                for (action in actionUpMap.get(key)){
                    action(key, PressType.Up);
                }
            }
        }
        #end
    }
    
    public function AddInputCommand(key:FlxKey, action:KeyboardInputCallback, pressType:PressType) 
    {
        var keys:Array<FlxKey> = null;
        var actionMap:Map<FlxKey, Array<Function>> = null;
        switch(pressType){
            case PressType.Down:
                keys = downKeys;
                actionMap = actionDownMap;
            case PressType.Pressed:
                keys = pressedKeys;
                actionMap = actionPressedMap;
            case PressType.Up:
                keys = upKeys;
                actionMap = actionUpMap;
        }
        
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