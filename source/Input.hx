package;
import enums.PressType;
import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

/**
 * ...
 * @author ...
 */

typedef KeyboardInputCallback = FlxKey->PressType->Void;
typedef GamepadButtonCallback = FlxGamepadInputID->PressType->Void;
typedef GamepadAnalogCallback = FlxGamepadInputID->Float->Void;

class Input
{
    private var keyDownMap:Map<FlxKey, Array<KeyboardInputCallback>>;
    private var keyPressedMap:Map<FlxKey, Array<KeyboardInputCallback>>;
    private var keyUpMap:Map<FlxKey, Array<KeyboardInputCallback>>;
    
    private var analogMap:Map<FlxGamepadInputID, Array<GamepadAnalogCallback>>;
    
    private var buttonDownMap:Map<FlxGamepadInputID, Array<GamepadButtonCallback>>;
    private var buttonPressedMap:Map<FlxGamepadInputID, Array<GamepadButtonCallback>>;
    private var buttonUpMap:Map<FlxGamepadInputID, Array<GamepadButtonCallback>>;
    
    private var gamepad:FlxGamepad;
    
    public function new() 
    {
        keyDownMap = new Map<FlxKey, Array<KeyboardInputCallback>>();
        keyPressedMap = new Map<FlxKey, Array<KeyboardInputCallback>>();
        keyUpMap = new Map<FlxKey, Array<KeyboardInputCallback>>();

        analogMap = new Map<FlxGamepadInputID, Array<GamepadAnalogCallback>>();

        buttonDownMap = new Map<FlxGamepadInputID, Array<GamepadButtonCallback>>();
        buttonPressedMap = new Map<FlxGamepadInputID, Array<GamepadButtonCallback>>();
        buttonUpMap = new Map<FlxGamepadInputID, Array<GamepadButtonCallback>>();
    }
    
    public function Update(elapsed:Float) 
    {
        #if (html5 || neko || flash || windows)
        
        for (key in keyDownMap.keys()){
            if (FlxG.keys.checkStatus(key, FlxInputState.JUST_PRESSED)){
                for (action in keyDownMap.get(key)){
                    action(key, PressType.Down);
                }
            }
        }
        for (key in keyPressedMap.keys()){
            if (FlxG.keys.checkStatus(key, FlxInputState.PRESSED)){
                for (action in keyPressedMap.get(key)){
                    action(key, PressType.Pressed);
                }
            }
        }
        for (key in keyUpMap.keys()){
            if (FlxG.keys.checkStatus(key, FlxInputState.JUST_RELEASED)){
                for (action in keyUpMap.get(key)){
                    action(key, PressType.Up);
                }
            }
        }
        
        gamepad = FlxG.gamepads.lastActive;
		
		if (gamepad == null)
			return;
        
        for (button in buttonDownMap.keys()){
            if (gamepad.checkStatus(button, FlxInputState.JUST_PRESSED)){
                for (action in buttonDownMap.get(button)){
                    action(button, PressType.Down);
                }
            }
        }
        for (button in buttonPressedMap.keys()){
            if (gamepad.checkStatus(button, FlxInputState.PRESSED)){
                for (action in buttonPressedMap.get(button)){
                    action(button, PressType.Pressed);
                }
            }
        }
        for (button in buttonUpMap.keys()){
            if (gamepad.checkStatus(button, FlxInputState.JUST_RELEASED)){
                for (action in buttonUpMap.get(button)){
                    action(button, PressType.Up);
                }
            }
        }
        #end
    }
    
    public function AddKeyboardInput(key:FlxKey, action:KeyboardInputCallback, pressType:PressType) 
    {
        var actionMap:Map<FlxKey, Array<KeyboardInputCallback>> = null;
        switch(pressType){
            case PressType.Down:
                actionMap = keyDownMap;
            case PressType.Pressed:
                actionMap = keyPressedMap;
            case PressType.Up:
                actionMap = keyUpMap;
        }
        
        var actionArray:Array<KeyboardInputCallback> = null;
        if (actionMap.exists(key)){
            actionArray = actionMap.get(key);
        }else{
            actionArray = new Array<KeyboardInputCallback>();
            actionMap.set(key, actionArray);
        }
        
        actionArray.push(action);
    }
    
    public function AddGamepadButtonInput(button:FlxGamepadInputID, action:GamepadButtonCallback, pressType:PressType) 
    {
        var actionMap:Map<FlxGamepadInputID, Array<GamepadButtonCallback>> = null;
        switch(pressType){
            case PressType.Down:
                actionMap = buttonDownMap;
            case PressType.Pressed:
                actionMap = buttonPressedMap;
            case PressType.Up:
                actionMap = buttonUpMap;
        }
        
        var actionArray:Array<GamepadButtonCallback> = null;
        if (actionMap.exists(button)){
            actionArray = actionMap.get(button);
        }else{
            actionArray = new Array<GamepadButtonCallback>();
            actionMap.set(button, actionArray);
        }
        
        actionArray.push(action);
    }
}