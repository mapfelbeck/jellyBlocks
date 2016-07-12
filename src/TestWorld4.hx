package;

import jellyPhysics.*;
import lime.math.Vector2;
import openfl.display.Sprite;
import openfl.events.*;
import openfl.display.FPS;
import haxe.Timer;
import openfl.geom.ColorTransform;
import haxe.Constraints.Function;
/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorld4 extends Sprite
{
    private static var MATERIAL_GROUND:Int = 0;
    private static var MATERIAL_TYPE_1:Int = 1;
    private static var MATERIAL_TYPE_2:Int = 2;
    
    private var drawSurface:Sprite;
    private var physicsWorld:World;
    private var worldRender:DrawDebugWorld;
    var lastTimeStamp:Float;
    
    private var squareShape:ClosedShape;
    private var bigSquareShape:ClosedShape;
    
    public function new() 
    {
        super();
        trace("TestWorld4 created");
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
        var materialCount:Int = 3;
        var defaultMaterial:MaterialPair = makeMaterial(true, 0.3, 0.8);
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial);
        materialMatrix.AddMaterial(makeMaterial(true, 0.3, 0.8));
        materialMatrix.AddMaterial(makeMaterial(true, 0.3, 0.8));
        materialMatrix.AddMaterial(makeMaterial(true, 0.3, 0.8));
        materialMatrix.SetMaterialPairCollide(MATERIAL_GROUND, MATERIAL_TYPE_1, true);
        materialMatrix.SetMaterialPairCollide(MATERIAL_GROUND, MATERIAL_TYPE_2, true);
        materialMatrix.SetMaterialPairCollide(MATERIAL_TYPE_1, MATERIAL_TYPE_2, false);
        
        var bounds:AABB = new AABB(new Vector2( -20, -20), new Vector2( 20, 20));
        
        var penetrationThreshhold:Float = 2;
        
        physicsWorld = new World(materialCount, materialMatrix, defaultMaterial, penetrationThreshhold, bounds);
        physicsWorld.externalAccumulator = PhysicsAccumulator;
    }
    
    private function makeMaterial(collide:Bool, friction:Float, elasticity:Float, ?filter:Function):MaterialPair{
        var material:MaterialPair = new MaterialPair();
        material.Collide = collide;
        material.Friction = friction;
        material.Elasticity = elasticity;
        material.CollisionFilter = filter;
        return material;
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
    
    private function addBodiesToWorld():Void
    {                
        var groundBody:Body = new Body(getSquareShape(), Math.POSITIVE_INFINITY, new Vector2(0, 9), 0, new Vector2(16, 1), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);
        
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 200;
        var shapeDamp:Float = 100;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 50.0;
             
        var type1PressureBody:PressureBody = new PressureBody(getBigSquareShape(), mass, new Vector2( -3, 6.25), 0, new Vector2(.5, .5), false, shapeK, shapeDamp, edgeK, edgeDamp, pressureAmount);
        type1PressureBody.Material = MATERIAL_TYPE_1;
        physicsWorld.AddBody(type1PressureBody);
        
        var type1SquareBody:SpringBody = new SpringBody(getSquareShape(), mass, new Vector2( -3, 4), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        type1SquareBody.Material = MATERIAL_TYPE_1;
        physicsWorld.AddBody(type1SquareBody); 
             
        var type2PressureBody:PressureBody = new PressureBody(getBigSquareShape(), mass, new Vector2( 3, 6.25), 0, new Vector2(.5, .5), false, shapeK, shapeDamp, edgeK, edgeDamp, pressureAmount);
        type2PressureBody.Material = MATERIAL_TYPE_2;
        physicsWorld.AddBody(type2PressureBody);
        
        var type2SquareBody:SpringBody = new SpringBody(getSquareShape(), mass, new Vector2( 3, 4), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        type2SquareBody.Material = MATERIAL_TYPE_2;
        physicsWorld.AddBody(type2SquareBody);
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