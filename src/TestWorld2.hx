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
 * 
 * Static body world
 */
class TestWorld2 extends Sprite
{
    private var drawSurface:Sprite;
    private var physicsWorld:World;
    private var worldRender:DrawDebugWorld;
    var lastTimeStamp:Float;
    
    public function new() 
    {
        super();
        trace("TestWorld2 created");
        if (this.stage != null){
            trace("immediate init");
            Init(null);
        }else{
            trace("waiting...");
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
        //backgroundWidth = this.stage.stageWidth - (2 * overscan);
        //backgroundHeight = this.stage.stageHeight - (2 * overscan);
        //worldRender.renderSize = new Vector2(backgroundWidth, backgroundHeight);
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
        
        var penetrationThreshhold:Float = 0.3;
        
        physicsWorld = new World(materialCount, materialMatrix, defaultMaterial, penetrationThreshhold, bounds);
    }
    
    private function addBodiesToWorld():Void
    {
        var squareShape:ClosedShape = new ClosedShape();

        squareShape.Begin();
        squareShape.AddVertex(new Vector2(0, 0));
        squareShape.AddVertex(new Vector2(4, 0));
        squareShape.AddVertex(new Vector2(4, 4));
        squareShape.AddVertex(new Vector2(0, 4));
        squareShape.Finish(true);
        
        var squareBody:Body = new Body(squareShape, 1, new Vector2(0, 0), 0, new Vector2(1, 1), false);
        
        physicsWorld.AddBody(squareBody);
        
        
        var triangleShape:ClosedShape = new ClosedShape();

        triangleShape.Begin();
        triangleShape.AddVertex(new Vector2(2, 0));
        triangleShape.AddVertex(new Vector2(4, 4));
        triangleShape.AddVertex(new Vector2(0, 4));
        triangleShape.Finish(true);
        
        var triangleBody:Body = new Body(triangleShape, 1, new Vector2(5, 5), 0, new Vector2(1, 1), false);
        
        physicsWorld.AddBody(triangleBody);
        
        var springBody:Body = new SpringBody(squareShape, 1, new Vector2( -6, -2), 1, new Vector2(1, 1), false,
                                            0.5, 0.5, 0.5, 0.5);
        physicsWorld.AddBody(springBody);
        
        var diamondShape:ClosedShape = new ClosedShape();

        diamondShape.Begin();
        diamondShape.AddVertex(new Vector2(0, 2.5));
        diamondShape.AddVertex(new Vector2(1.5, 1.5));
        diamondShape.AddVertex(new Vector2(2.5, 0));
        diamondShape.AddVertex(new Vector2(1.5, -1.5));
        diamondShape.AddVertex(new Vector2(0, -2.5));
        diamondShape.AddVertex(new Vector2(-1.5, -1.5));
        diamondShape.AddVertex(new Vector2(-2.5, 0));
        diamondShape.AddVertex(new Vector2(-1.5, 1.5));
        diamondShape.Finish(true);
        
        var pressureBody:Body = new PressureBody(diamondShape, 1, new Vector2( 6, -4), 0, new Vector2(1, 1), false,
                                            0.5, 0.5, 0.5, 0.5, 1);
        physicsWorld.AddBody(pressureBody);
        
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