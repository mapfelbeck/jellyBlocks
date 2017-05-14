package plugins;
import enums.PressType;
import gamepieces.GamePiece;
import plugins.PluginBase;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import jellyPhysics.math.Vector2;
/**
 * ...
 * @author Michael Apfelbeck
 */
class GamePieceControlPlugin extends PluginBase 
{
    public var controlled:GamePiece = null;
    
    private var input:Input;
    
    private var horizontalPush:Float = 0;
    private var verticalPush:Float = 0;
    private var rotatateAmount:Float = 0;
    
    public function new(parent:FlxUIState, input:Input, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.input = input;
        
        connectInput();
    }
    
    override public function update(elapsed:Float){
        horizontalPush = 0;
        verticalPush = 0;
        rotatateAmount = 0;
    }
    
    private function connectInput():Void{
        
        input.AddKeyboardInput(FlxKey.A, pushPieceLeft, PressType.Pressed);
        input.AddKeyboardInput(FlxKey.D, pushPieceRight, PressType.Pressed);
        input.AddKeyboardInput(FlxKey.W, pushPieceUp, PressType.Pressed);
        input.AddKeyboardInput(FlxKey.S, pushPieceDown, PressType.Pressed);
        input.AddKeyboardInput(FlxKey.Q, rotatePieceCCW, PressType.Pressed);
        input.AddKeyboardInput(FlxKey.E, rotatePieceCW, PressType.Pressed);
        input.AddKeyboardInput(FlxKey.LEFT, rotatePieceCCW, PressType.Pressed);
        input.AddKeyboardInput(FlxKey.RIGHT, rotatePieceCW, PressType.Pressed);
        
        /*
        input.AddGamepadButtonInput(FlxGamepadInputID.LEFT_TRIGGER, buttonCmd, PressType.Down);
        input.AddGamepadButtonInput(FlxGamepadInputID.LEFT_TRIGGER, buttonCmd, PressType.Pressed);
        input.AddGamepadButtonInput(FlxGamepadInputID.LEFT_TRIGGER, buttonCmd, PressType.Up);
                */
        input.AddGamepadStickInput(FlxGamepadInputID.LEFT_ANALOG_STICK, stickPush);
        input.AddGamepadStickInput(FlxGamepadInputID.RIGHT_ANALOG_STICK, stickRotate);
        
    }
    
    private function pushPieceLeft(key: FlxKey, type:PressType):Void{
        horizontalPush = -1.0;
    }
    
    private function pushPieceRight(key: FlxKey, type:PressType):Void{
        horizontalPush = 1.0;
    }
    
    private function pushPieceUp(key: FlxKey, type:PressType):Void{
        verticalPush = -1.0;
    }
    
    private function pushPieceDown(key: FlxKey, type:PressType):Void{
        verticalPush = 1.0;
    }
    
    private function rotatePieceCCW(key: FlxKey, type:PressType):Void{
        rotatateAmount = -1.0;
    }
    
    private function rotatePieceCW(key: FlxKey, type:PressType):Void{
        rotatateAmount = 1.0;
    }
    
    /*function buttonCmd(button:FlxGamepadInputID, type:PressType): Void
    {
        trace("Button " + button.toString() + " is " + type.getName());
    }
    
    function buttonAnalog(button:FlxGamepadInputID, value:Float): Void
    {
        trace("Button " + button.toString() + " is " + value);
    }
    
    function stickInput(stick:FlxGamepadInputID, xValue:Float, yValue:Float): Void
    {
        trace("Stick " + stick.toString() + " is (" + xValue+", " + yValue+")");
    }*/
    
    function stickPush(stick:FlxGamepadInputID, xValue:Float, yValue:Float): Void
    {
        horizontalPush = xValue;
        verticalPush = yValue;
    }
    
    function stickRotate(stick:FlxGamepadInputID, xValue:Float, yValue:Float): Void
    {
        rotatateAmount = xValue;
    }

    public function MoveAccumulator(elapsed:Float):Void{
        if (controlled == null){
            return;
        }
        
        var pushAmount:Vector2 = new Vector2(0, 0);
        
        var rotateForce:Float = 2;
        var moveForce:Float = 16;
        
        var rotationAmount:Float = rotatateAmount * rotateForce;
        
        //If no player input then counteract the game pieces rotation
        //makes piece much easier to control. Length check is here so
        //the piece doesn't go wonky when one of the pieces pops.
        if (rotationAmount == 0 && controlled.Blocks.length == 3){
            rotationAmount = -clampValue(controlled.RotationSpeed, -1, 1);
        }
        
        pushAmount.x = horizontalPush * moveForce;
        pushAmount.y = verticalPush * moveForce;

        if (pushAmount.x != 0 || pushAmount.y !=0){
            controlled.ApplyForce(pushAmount);
        }
        if (rotationAmount != 0 && Math.abs(controlled.Omega()) < 6.0){
            controlled.ApplyTorque(rotationAmount);
        }
    }
    
    function clampValue(value:Float, low:Float, high:Float) 
    {
        var result:Float = value;
        if (result < low){
            result = low;
        }else if (result > high){
            result = high;
        }
       return result; 
    }
}