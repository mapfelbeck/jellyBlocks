package;
import jellyPhysics.*;
import lime.math.Vector2;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorld5 extends TestWorldBase
{
    private static var MATERIAL_GROUND:Int = 0;
    private static var MATERIAL_TYPE_YELLOW:Int = 1;
    private static var MATERIAL_TYPE_GREEN:Int = 2;
    private static var MATERIAL_BLOB:Int   = 3;
    
    private var input:InputPoll;
    
    private var blobBody:PressureBody;
    
    public function new()
    {
        super();
        Title = "Collision Callback Test World";	
    }
    
    override function Init(e:Event):Void 
    {
        super.Init(e);
        //hasMouse = false;
        //setup mouse here
        input = new InputPoll(stage);
        //stage.addEventListener(KeyboardEvent.KEY_DOWN,reportKeyDown); 
        //stage.addEventListener(KeyboardEvent.KEY_UP,reportKeyUp); 
    }
    
    override public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, 4);
        
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_YELLOW, collisionFilterYellow);
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_GREEN, collisionFilterGreen);

        //materialMatrix.SetMaterialPairCollide(MATERIAL_BLOB, MATERIAL_TYPE_YELLOW, true);
        //materialMatrix.SetMaterialPairCollide(MATERIAL_BLOB, MATERIAL_TYPE_GREEN, true);
        
        return materialMatrix;
    }
    
    private var collideYellow:Bool = false;
    private var collideGreen:Bool = false;
    function collisionFilterYellow(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        collideYellow = true;
        return false;
    }
    
    function collisionFilterGreen(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        collideGreen = true;
        return false;
    }
    
    override function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);
        if (collideYellow){
            trace("yellow");
            collideYellow = false;
        }
        /*if (input.isDown(Keyboard.RIGHT)){
            trace("Right arrow key is down");
            //apply torque to blobBody
        }else{
            trace("Right arrow key is up");
        }*/
    }
    
    /*private function reportKeyUp(e:KeyboardEvent):Void 
    {
        trace("Key up: " + e.keyCode);
    }
    
    private function reportKeyDown(e:KeyboardEvent):Void 
    {
        trace("Key down: " + e.keyCode);
    }*/
    
    override public function setupDrawParam(render:DrawDebugWorld):Void 
    {
        super.setupDrawParam(render);
        render.DrawingGlobalBody = false;
        render.DrawingPointMasses = false;
        render.SetMaterialDrawOptions(MATERIAL_GROUND, DrawDebugWorld.COLOR_WHITE, false);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_YELLOW, DrawDebugWorld.COLOR_YELLOW, true);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_GREEN, DrawDebugWorld.COLOR_GREEN, true);
        render.SetMaterialDrawOptions(MATERIAL_BLOB, DrawDebugWorld.COLOR_RED, true);
    }
    
    override public function addBodiesToWorld():Void 
    {
        super.addBodiesToWorld();        
        
        var groundBody:Body = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(0, 9), 0, new Vector2(18, 1), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);
        
        groundBody = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(17, 6), 0, new Vector2(1, 2), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);
        
        groundBody = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(-17, 6), 0, new Vector2(1, 2), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);
        
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 200;
        var shapeDamp:Float = 100;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 100.0;
        
        var springBody:SpringBody = new SpringBody(getBigSquareShape(1), mass, new Vector2( -6, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        springBody.Material = MATERIAL_TYPE_YELLOW;
        physicsWorld.AddBody(springBody);
        
        springBody = new SpringBody(getBigSquareShape(1), mass, new Vector2( 6, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        springBody.Material = MATERIAL_TYPE_GREEN;
        physicsWorld.AddBody(springBody);
        
        blobBody = new PressureBody(getCircleShape(1, 16), mass, new Vector2( 0, 0), 0, new Vector2(1, 1), false, 0.2*shapeK, 5.0*shapeDamp, edgeK, edgeDamp, pressureAmount);
        blobBody.Label = "Blob";
        blobBody.Material = MATERIAL_BLOB;
        physicsWorld.AddBody(blobBody);        
    }
}