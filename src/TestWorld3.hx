package;
import jellyPhysics.*;
import lime.math.Vector2;
import openfl.display.Sprite;
import openfl.events.*;
import openfl.display.FPS;
import haxe.Timer;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorld3 extends Sprite
{
    private var drawSurface:Sprite;
    private var physicsWorld:World;
    private var worldRender:DrawDebugWorld;
    var lastTimeStamp:Float;
    
    public function new() 
    {
        super();
        trace("TestWorld3 created");
        if (this.stage != null){
            Init(null);
        }else{
            addEventListener(Event.ADDED_TO_STAGE, Init);
        }
    }
    
    private var overscan:Int = 0;
    private var backgroundHeight:Int;
    private var backgroundWidth:Int;
    private function Init(e:Event):Void
    {
        lastTimeStamp = Timer.stamp();
        
        removeEventListener(Event.ADDED_TO_STAGE, Init);
        addEventListener(Event.REMOVED_FROM_STAGE, Close);
        addEventListener(Event.ENTER_FRAME, OnEnterFrame);
        
        addChildAt(createDrawSurface(), 0);
        addChild(new FPS(0, 0, 0x808080));
        
        createWorld();
        addBodiesToWorld();
        
        worldRender = new DrawDebugWorld(drawSurface, physicsWorld);
    }
    
    private function createWorld()
    {
        var materialCount : Int = 1;
        var defaultMaterial:MaterialPair = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.3;
        defaultMaterial.Elasticity = 0.8;
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, materialCount);
        
        var bounds:AABB = new AABB(new Vector2( -20, -20), new Vector2( 20, 20));
        
        var penetrationThreshhold:Float = 1;
        
        physicsWorld = new World(materialCount, materialMatrix, defaultMaterial, penetrationThreshhold, bounds);
        physicsWorld.externalAccumulator = PhysicsAccumulator;
    }
    
    private function PhysicsAccumulator(elapsed:Float){
        var gravity:Vector2 = new Vector2(0, 9.8);
        gravity.y *= 0.5;

        for(i in 0...physicsWorld.NumberBodies)
        {
            var body:Body = physicsWorld.GetBody(i);
            if (!body.IsStatic){
                body.AddGlobalForce(body.DerivedPos, gravity);
            }
        }
    }
    
    private var squareShape:ClosedShape;
    private var bigSquareShape:ClosedShape;
    private var diamondShape:ClosedShape;
    private function addBodiesToWorld():Void
    {
        var groundShape:ClosedShape = new ClosedShape();

        groundShape.Begin();
        groundShape.AddVertex(new Vector2(0, 0));
        groundShape.AddVertex(new Vector2(35, 0));
        groundShape.AddVertex(new Vector2(35, 2));
        groundShape.AddVertex(new Vector2(0, 2));
        groundShape.Finish(true);
                
        var groundBody:Body = new Body(groundShape, Math.POSITIVE_INFINITY, new Vector2(0, 9), 0, new Vector2(1, 1), false);
        groundBody.IsStatic = true;
        physicsWorld.AddBody(groundBody);
        
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 450;
        var shapeDamp:Float = 15;
        var edgeK:Float = 450;
        var edgeDamp:Float = 15;
        var pressureAmount:Float = 250.0;
        var springBodyXPositions:Array<Float> = [ -12, -8, -4, 0, 4, 8, 12];
        for (x in springBodyXPositions){
            var squareBody:SpringBody = new SpringBody(getSquareShape(), mass, new Vector2( x, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
            //physicsWorld.AddBody(squareBody);
        }

        var rotationAmount =  Math.PI / 3.8;
        var pressureBody:PressureBody = new PressureBody(getDiamondShape(), 1, new Vector2( 0, -5), Math.PI/3.9, new Vector2(2, 2), false,
                                            shapeK/2, shapeDamp, edgeK, edgeDamp, -pressureAmount);
        pressureBody.Label = "PressureBody";
        physicsWorld.AddBody(pressureBody);
        /*var squareBody1:SpringBody = new SpringBody(squareShape, mass, new Vector2( 0, -4), Math.PI/4, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        var squareBody2:SpringBody = new SpringBody(squareShape, mass, new Vector2( 0, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        squareBody1.Label = "top";
        squareBody2.Label = "bottom";
        physicsWorld.AddBody(squareBody1);
        physicsWorld.AddBody(squareBody2);*/
        
    }
    private function getSquareShape():ClosedShape{
        if(squareShape == null){
            squareShape = new ClosedShape();
            squareShape.Begin();
            squareShape.AddVertex(new Vector2(0, 0));
            squareShape.AddVertex(new Vector2(2, 0));
            squareShape.AddVertex(new Vector2(2, 2));
            squareShape.AddVertex(new Vector2(0, 2));
            squareShape.Finish(true);
        }
        return squareShape;
    }
    
    private function getBigSquareShape():ClosedShape{
        if(bigSquareShape == null){
            bigSquareShape = new ClosedShape();
            bigSquareShape.Begin();
            bigSquareShape.AddVertex(new Vector2(0, -4));
            bigSquareShape.AddVertex(new Vector2(2, -4));
            bigSquareShape.AddVertex(new Vector2(4, -4));
            bigSquareShape.AddVertex(new Vector2(4, -2));
            bigSquareShape.AddVertex(new Vector2(4, 0));
            bigSquareShape.AddVertex(new Vector2(2, 0));
            bigSquareShape.AddVertex(new Vector2(0, 0));
            bigSquareShape.AddVertex(new Vector2(0, -2));
            bigSquareShape.Finish(true);
        }
        return bigSquareShape;
    }
    
    private function getDiamondShape():ClosedShape{
        if(diamondShape == null){
            diamondShape = new ClosedShape();
            diamondShape.Begin();
            diamondShape.AddVertex(new Vector2(0, -2.5));
            diamondShape.AddVertex(new Vector2(1.5, -1.5));
            diamondShape.AddVertex(new Vector2(2.5, 0));
            diamondShape.AddVertex(new Vector2(1.5, 1.5));
            diamondShape.AddVertex(new Vector2(0, 2.5));
            diamondShape.AddVertex(new Vector2(-1.5, 1.5));
            diamondShape.AddVertex(new Vector2(-2.5, 0));        
            diamondShape.AddVertex(new Vector2(-1.5, -1.5));
            diamondShape.Finish(true);
        }
        return diamondShape;
    }
    
    private function createDrawSurface():Sprite
    {
        overscan = 20;
        drawSurface = new Sprite();
        drawSurface.x = overscan;
        drawSurface.y = overscan;
        
        return drawSurface;
    }
    
    private function OnEnterFrame(e:Event)
    {
        var currTimeStamp:Float = Timer.stamp();
        var frameTime = currTimeStamp - lastTimeStamp;
        //trace("frame time: " + frameTime);
        lastTimeStamp = currTimeStamp;
        
        Update(frameTime);
        
        Draw();
    }
    
    private function Update(elapsed:Float):Void
    {
        physicsWorld.Update(elapsed);
    }
    
    private function Draw():Void
    {
        worldRender.Draw();
    }
    
    private function Close(e:Event):Void
    {
        removeEventListener(Event.REMOVED_FROM_STAGE, Close);
        removeEventListener(Event.ENTER_FRAME, Update);
    }
}