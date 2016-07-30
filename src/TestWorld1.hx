package;
import haxe.Timer;
import jellyPhysics.*;
import lime.math.Vector2;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.*;
/**
 * ...
 * @author Michael Apfelbeck
 * 
 * Static body world
 */
class TestWorld1 extends TestWorldBase
{    
    public function new(inputPoll:InputPoll) 
    {
        super(inputPoll);
        Title = "Shape Test World";
        PromptText = "Creates basic shapes.";
        hasGravity = false;
        hasDefaultMouse = false;
    }
    
    public override function setupDrawParam(render:DrawDebugWorld):Void{
        render.DrawingAABB = true;
    }
    
    public override function addBodiesToWorld():Void
    {
        var mass:Float = 1.0;
        var shapeK:Float = 100;
        var shapeDamp:Float = 50;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 100.0;
        
        var squareBody:Body = new Body(getSquareShape(4), mass, new Vector2(0, 0), 0, new Vector2(1, 1), false);
        
        physicsWorld.AddBody(squareBody);
        
        
        var triangleShape:ClosedShape = new ClosedShape();

        triangleShape.Begin();
        triangleShape.AddVertex(new Vector2(2, 0));
        triangleShape.AddVertex(new Vector2(4, 4));
        triangleShape.AddVertex(new Vector2(0, 4));
        triangleShape.Finish(true);
        
        var triangleBody:Body = new Body(triangleShape, mass, new Vector2(5, 5), 0, new Vector2(1, 1), false);
        
        physicsWorld.AddBody(triangleBody);
        
        var springBody:Body = new SpringBody(getSquareShape(4), mass, new Vector2( -6, -2), 1, new Vector2(1, 1), false,
                                            shapeK, shapeDamp, edgeK, edgeDamp);
        physicsWorld.AddBody(springBody);
        
        var diamondShape:ClosedShape = new ClosedShape();

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
        
        var pressureBody:Body = new PressureBody(diamondShape, mass, new Vector2( 6, -4), 0, new Vector2(1, 1), false,
                                            shapeK, shapeDamp, edgeK, edgeDamp, pressureAmount);
        physicsWorld.AddBody(pressureBody);
        
    }
}