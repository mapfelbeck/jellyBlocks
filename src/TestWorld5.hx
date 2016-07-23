package;
import jellyPhysics.*;
import lime.math.Vector2;
import openfl.events.*;
import openfl.text.*;
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
        
    private var blobBody:PressureBody;
    
    private var collideYellow:Bool = false;
    private var collideGreen:Bool = false;
    
    private var yellowText:TextField;
    private var greenText:TextField;
    
    public function new()
    {
        super();
        Title = "Collision Callback Test World";	
    }
    
    override function Init(e:Event):Void 
    {
        super.Init(e);
        setupCollisionTextFields();
        
        //hasMouse = false turns off the default mouse controls, this should probably
        //be handled in a better way
        hasMouse = false;
        addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDownEvent);
        addEventListener(MouseEvent.MOUSE_UP, OnMouseUpEvent);
        addEventListener(MouseEvent.MOUSE_OUT, OnMouseUpEvent);
        addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMoveEvent);
    }
    
    private var mousePressed:Bool = false;
    private var mouseWorldPos:Vector2;
    private function OnMouseDownEvent(e:MouseEvent):Void 
    {
        mousePressed = true;
        mouseWorldPos = localToWorld(new Vector2(e.localX, e.localY));
    }
    
    private function OnMouseUpEvent(e:MouseEvent):Void 
    {
        mousePressed = false;
    }
    
    private function OnMouseMoveEvent(e:MouseEvent):Void 
    {
        mouseWorldPos = localToWorld(new Vector2(e.localX, e.localY));
    }
    
    override public function setupDrawParam(render:DrawDebugWorld):Void 
    {
        super.setupDrawParam(render);
        render.DrawingAABB = false;
        render.DrawingGlobalBody = false;
        render.DrawingPointMasses = false;
        render.SetMaterialDrawOptions(MATERIAL_GROUND, DrawDebugWorld.COLOR_WHITE, false);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_YELLOW, DrawDebugWorld.COLOR_YELLOW, true);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_GREEN, DrawDebugWorld.COLOR_GREEN, true);
        render.SetMaterialDrawOptions(MATERIAL_BLOB, DrawDebugWorld.COLOR_RED, true);
    }
    
    override public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, 4);
        
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_YELLOW, collisionFilterYellow);
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_GREEN, collisionFilterGreen);
        
        //default material friction is 0.3, pretty slippery
        //give the blob more friction, 0.75
        materialMatrix.SetMaterialPairData(MATERIAL_GROUND, MATERIAL_BLOB, 0.75, 0.8);
        
        return materialMatrix;
    }
    
    function collisionFilterYellow(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        collideYellow = true;
        return false;
    }
    
    function collisionFilterGreen(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        return false;
    }
    
    function collisionCallbackGreen(otherBody:Body):Void{
        if(otherBody.Label == "Blob"){
            collideGreen = true;
        }
    }
    
    private function setText(textField:TextField, text:String, color:Int){
        textField.text = text;
        textField.setTextFormat(new TextFormat(null, null, color));
    }
    
    override function PhysicsAccumulator(elapsed:Float) 
    {
        super.PhysicsAccumulator(elapsed);        
        
        var rotationAmount:Float = 0;
        
        if(mousePressed){
            if (mouseWorldPos.x < blobBody.DerivedPos.x)
            {
                rotationAmount = -1;
            }
            else if (mouseWorldPos.x > blobBody.DerivedPos.x)
            {
                rotationAmount = 1;
            }
            
            if (rotationAmount != 0 && Math.abs(blobBody.DerivedOmega) < 1.0){
                var blobCenter:Vector2 = blobBody.DerivedPos;
                for (i in 0...blobBody.PointMasses.length){
                    var pmPosition:Vector2 = blobBody.PointMasses[i].Position;
                    var origin:Vector2 = VectorTools.Subtract(pmPosition, blobCenter);
                    var rotationForce:Vector2 = new Vector2(0, 0);
                    var torqueForce:Float = 3;
                    rotationForce.x = origin.x * Math.cos(rotationAmount) - origin.y * Math.sin(rotationAmount);
                    rotationForce.y = origin.x * Math.sin(rotationAmount) + origin.y * Math.cos(rotationAmount);
                    blobBody.PointMasses[i].Force.x += rotationForce.x * torqueForce;
                    blobBody.PointMasses[i].Force.y += rotationForce.y * torqueForce;
                }
            }        
        }
        //keyboard controls
        if (input.isDown(Keyboard.LEFT) && !input.isDown(Keyboard.RIGHT))
        {
            rotationAmount = -1;
        }
        else if (!input.isDown(Keyboard.LEFT) && input.isDown(Keyboard.RIGHT))
        {
            rotationAmount = 1;
        }
        
        if (rotationAmount != 0 && Math.abs(blobBody.DerivedOmega) < 3.0){
            var blobCenter:Vector2 = blobBody.DerivedPos;
            for (i in 0...blobBody.PointMasses.length){
                var pmPosition:Vector2 = blobBody.PointMasses[i].Position;
                var origin:Vector2 = VectorTools.Subtract(pmPosition, blobCenter);
                var rotationForce:Vector2 = new Vector2(0, 0);
                var torqueForce:Float = 3;
                rotationForce.x = origin.x * Math.cos(rotationAmount) - origin.y * Math.sin(rotationAmount);
                rotationForce.y = origin.x * Math.sin(rotationAmount) + origin.y * Math.cos(rotationAmount);
                blobBody.PointMasses[i].Force.x += rotationForce.x * torqueForce;
                blobBody.PointMasses[i].Force.y += rotationForce.y * torqueForce;
            }
        }
    }
    override function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);
        if (collideYellow){
            setText(yellowText, "The blob is touching the yellow square.", DrawDebugWorld.COLOR_YELLOW);
        }else{
            setText(yellowText, "The blob is not touching the yellow square.", DrawDebugWorld.COLOR_YELLOW);
        }
        if (collideGreen){
            setText(greenText, "The blob is touching the green square.", DrawDebugWorld.COLOR_GREEN);
        }else{
            setText(greenText, "The blob is not touching the green square.", DrawDebugWorld.COLOR_GREEN);
        }
        collideYellow = false;
        collideGreen = false;
    }
    
    function setupCollisionTextFields():Void 
    {
        yellowText = new TextField();
        yellowText.text = "*";
        yellowText.setTextFormat(new TextFormat(null, null, DrawDebugWorld.COLOR_YELLOW));
        yellowText.autoSize = TextFieldAutoSize.LEFT;
        yellowText.mouseEnabled = false;
        drawSurface.addChild(yellowText);
        
        greenText = new TextField();
        greenText.text = "*";
        greenText.setTextFormat(new TextFormat(null, null, DrawDebugWorld.COLOR_GREEN));
        greenText.autoSize = TextFieldAutoSize.LEFT;
        greenText.y += overscan;
        greenText.mouseEnabled = false;
        drawSurface.addChild(greenText);
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
        springBody.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(springBody);
        
        blobBody = new PressureBody(getPolygonShape(1, 16), mass, new Vector2( 0, 0), 0, new Vector2(1, 1), false, 0.2*shapeK, 5.0*shapeDamp, edgeK, edgeDamp, pressureAmount);
        blobBody.Label = "Blob";
        blobBody.Material = MATERIAL_BLOB;
        physicsWorld.AddBody(blobBody);        
    }
}