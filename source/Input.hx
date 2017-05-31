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
typedef GamepadStickCallback = FlxGamepadInputID->Float->Float->Void;

class Input
{
    public var GamePadDeadZone(get, set):Float;
    public function get_GamePadDeadZone():Float{
        return gamePadDeadZone;
    }
    public function set_GamePadDeadZone(value:Float):Float{
        gamePadDeadZone = value;
        FlxG.gamepads.globalDeadZone = gamePadDeadZone;
        return gamePadDeadZone;
    }
    
    public var AnalogThreshhold(get, set):Float;
    public function get_AnalogThreshhold():Float{
        return analogThreshhold;
    }
    public function set_AnalogThreshhold(value:Float):Float{
        analogThreshhold = value;
        return analogThreshhold;
    }
    
    private var keyDownMap:Map<FlxKey, Array<KeyboardInputCallback>>;
    private var keyPressedMap:Map<FlxKey, Array<KeyboardInputCallback>>;
    private var keyUpMap:Map<FlxKey, Array<KeyboardInputCallback>>;
    
    private var analogMap:Map<FlxGamepadInputID, Array<GamepadAnalogCallback>>;
    
    private var stickMap:Map<FlxGamepadInputID, Array<GamepadStickCallback>>;
    
    private var buttonDownMap:Map<FlxGamepadInputID, Array<GamepadButtonCallback>>;
    private var buttonPressedMap:Map<FlxGamepadInputID, Array<GamepadButtonCallback>>;
    private var buttonUpMap:Map<FlxGamepadInputID, Array<GamepadButtonCallback>>;
    
    private var gamepad:FlxGamepad;
    
    private var analogThreshhold:Float = 0.2;
    private var gamePadDeadZone:Float = 0.01;
    
    public function new() 
    {
        FlxG.gamepads.globalDeadZone = gamePadDeadZone;
        
        keyDownMap = new Map<FlxKey, Array<KeyboardInputCallback>>();
        keyPressedMap = new Map<FlxKey, Array<KeyboardInputCallback>>();
        keyUpMap = new Map<FlxKey, Array<KeyboardInputCallback>>();

        analogMap = new Map<FlxGamepadInputID, Array<GamepadAnalogCallback>>();
        
        stickMap = new Map<FlxGamepadInputID, Array<GamepadStickCallback>>();

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
        for (button in analogMap.keys()){
            var analogValue:Float = gamepad.getAxis(button);
            if(analogValue >= analogThreshhold){
                for (action in analogMap.get(button)){
                    action(button, analogValue);
                }
            }
        }
        for (stick in stickMap.keys()){
            var xValue:Float = gamepad.getXAxis(stick);
            var yValue:Float = gamepad.getYAxis(stick);
            
            if(Math.abs(xValue) >= analogThreshhold || Math.abs(yValue) >= analogThreshhold){
                for (action in stickMap.get(stick)){
                    action(stick, xValue, yValue);
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
    
    public function AddGamepadAnalogInput(button:FlxGamepadInputID, action:GamepadAnalogCallback) 
    {   
        var actionArray:Array<GamepadAnalogCallback> = null;
        if (analogMap.exists(button)){
            actionArray = analogMap.get(button);
        }else{
            actionArray = new Array<GamepadAnalogCallback>();
            analogMap.set(button, actionArray);
        }
        
        actionArray.push(action);
    }
    
    public function AddGamepadStickInput(button:FlxGamepadInputID, action:GamepadStickCallback) 
    {   
        var actionArray:Array<GamepadStickCallback> = null;
        if (analogMap.exists(button)){
            actionArray = stickMap.get(button);
        }else{
            actionArray = new Array<GamepadStickCallback>();
            stickMap.set(button, actionArray);
        }
        
        actionArray.push(action);
    }
}