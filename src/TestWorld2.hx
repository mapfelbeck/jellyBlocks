package;
import jellyPhysics.*;
import lime.math.Vector2;
import openfl.events.*;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorld2 extends TestWorldBase
{    
    public function new(inputPoll:InputPoll) 
    {
        super(inputPoll);
        Title = "Collision Test World";
        PromptText = "Create a bunch of bodies and add gravity to test collisions.";
    }    
    
    public override function addBodiesToWorld():Void
    {
        super.addBodiesToWorld();
        
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
        var shapeK:Float = 100;
        var shapeDamp:Float = 50;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 100.0;
        
        var springBodyXPositions:Array<Float> = [ -12, -8, -4, 0, 4, 8, 12];
        for (x in springBodyXPositions){
            var squareBody:SpringBody = new SpringBody(getSquareShape(2), mass, new Vector2( x, 6.8), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
            physicsWorld.AddBody(squareBody);
            squareBody = new SpringBody(getSquareShape(2), mass, new Vector2( x, 4.6), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
            physicsWorld.AddBody(squareBody);
        }

        var rotationAmount =  Math.PI / 3.8;
        var pressureBody:PressureBody = new PressureBody(getBigSquareShape(2), mass, new Vector2( 0, -7), Math.PI/4, new Vector2(1, 1), false,
                                            shapeK, shapeDamp, edgeK, edgeDamp, pressureAmount);
        pressureBody.Label = "PressureBody";
        physicsWorld.AddBody(pressureBody);
    } 
}