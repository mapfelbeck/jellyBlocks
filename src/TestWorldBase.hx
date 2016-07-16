package;

import openfl.display.Sprite;
import jellyPhysics.*;
import lime.math.Vector2;
import openfl.events.*;
import openfl.display.FPS;
import haxe.Timer;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorldBase extends Sprite
{
    public var drawSurface:Sprite;
    public var physicsWorld:World;
    private var lastTimeStamp:Float;
    
    public var mouseActive:Bool = false;
    public var hasGravity:Bool = true;
    public var mouseDraggingOn:Bool = true;
    
    public var worldRender:DrawDebugWorld;
    
    public var mouseLocation:Vector2 = null;
    public var mouseBody:BodyPointMassRef = null;
    public var mouseCurrDistance:Float;
    
    public function new() 
    {
        super();
        trace("TestWorldBase created");
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
        addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
        addEventListener(MouseEvent.MOUSE_OUT, OnMouseUp);
        addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
        
        addChildAt(createDrawSurface(), 0);
        addChild(new FPS(0, 0, 0x808080));
        
        createWorld();
        addBodiesToWorld();
        
        worldRender = new DrawDebugWorld(drawSurface, physicsWorld);
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
        if (mouseActive){
            drawSurface.graphics.lineStyle(0, DrawDebugWorld.COLOR_GREEN, 1.0);
            
            var mouseLocal:Vector2 = worldToLocal(mouseLocation);
            drawSurface.graphics.moveTo(mouseLocal.x, mouseLocal.y);
            var body:Body = physicsWorld.GetBody(mouseBody.BodyID);
            var pointMass:PointMass = body.PointMasses[mouseBody.PointMassIndex];
            var location:Vector2 = worldToLocal(pointMass.Position);
            drawSurface.graphics.lineTo(location.x, location.y);
        }
    }
    
    private function Close(e:Event):Void
    {
        removeEventListener(Event.REMOVED_FROM_STAGE, Close);
        removeEventListener(Event.ENTER_FRAME, Update);
    }
        
    private function PhysicsAccumulator(elapsed:Float){
        if(hasGravity){
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
        
        if (mouseDraggingOn && mouseActive){
            var body:Body = physicsWorld.GetBody(mouseBody.BodyID);
            var pointMass:PointMass = body.PointMasses[mouseBody.PointMassIndex];
            var force:Vector2 = VectorTools.CalculateSpringForce(mouseLocation, new Vector2(0, 0), pointMass.Position, pointMass.Velocity, mouseBody.Distance, 250, 50);
            pointMass.Force.x -= force.x;
            pointMass.Force.y -= force.y;
        }
    }
    
    private function OnMouseMove(e:MouseEvent):Void 
    {
        if(mouseActive){
            mouseLocation = localToWorld(new Vector2(e.localX, e.localY));
        }        
    }
    
    private function OnMouseDown(e:MouseEvent):Void 
    {
        mouseLocation = localToWorld(new Vector2(e.localX, e.localY));
        mouseBody = physicsWorld.GetClosestPointMass(mouseLocation);
        mouseActive = true;
    }
    
    private function OnMouseUp(e:MouseEvent):Void 
    {
        mouseActive = false;
    }
    
    public function getSquareShape(size:Float):ClosedShape{
        var squareShape:ClosedShape = new ClosedShape();
        squareShape.Begin();
        squareShape.AddVertex(new Vector2(0, 0));
        squareShape.AddVertex(new Vector2(size, 0));
        squareShape.AddVertex(new Vector2(size, size));
        squareShape.AddVertex(new Vector2(0, size));
        squareShape.Finish(true);
        return squareShape;
    }
    
    public function getBigSquareShape(size:Float):ClosedShape{
        var bigSquareShape:ClosedShape = new ClosedShape();
        bigSquareShape.Begin();
        bigSquareShape.AddVertex(new Vector2(0, -size*2));
        bigSquareShape.AddVertex(new Vector2(2, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -2));
        bigSquareShape.AddVertex(new Vector2(size*2, 0));
        bigSquareShape.AddVertex(new Vector2(size, 0));
        bigSquareShape.AddVertex(new Vector2(0, 0));
        bigSquareShape.AddVertex(new Vector2(0, -size));
        bigSquareShape.Finish(true);
        return bigSquareShape;
    }
    
    //convert local coordinate on this sprite to world coordinate in the physics world
    public function localToWorld(local:Vector2):Vector2{
        var world:Vector2 = new Vector2(
                                    (local.x - worldRender.offset.x) / worldRender.scale.x,
                                    (local.y - worldRender.offset.y) / worldRender.scale.y);
        return world;
    }
    
    //convert physics world coordinate to local coordinate on this sprite
    public function worldToLocal(world:Vector2):Vector2{
        var local:Vector2 = new Vector2(
                                    (world.x * worldRender.scale.x)+worldRender.offset.x,
                                    (world.y * worldRender.scale.y) + worldRender.offset.y );
        return local;
    }
    
    private function createWorld()
    {
        var matrix:MaterialMatrix = getMaterialMatrix();
        
        var bounds:AABB = new AABB(new Vector2( -20, -20), new Vector2( 20, 20));
        
        var penetrationThreshhold:Float = 1.0;
        
        physicsWorld = new World(matrix.Count, matrix, matrix.DefaultMaterial, penetrationThreshhold, bounds);
        physicsWorld.externalAccumulator = PhysicsAccumulator;
    }
    
    public function getMaterialMatrix():MaterialMatrix{
        var materialCount : Int = 1;
        var defaultMaterial:MaterialPair = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.3;
        defaultMaterial.Elasticity = 0.8;
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, materialCount);
        
        return materialMatrix;
    }
    
    public function addBodiesToWorld():Void
    {
    }    
}