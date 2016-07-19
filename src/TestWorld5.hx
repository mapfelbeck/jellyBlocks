package;
import jellyPhysics.Body;
import jellyPhysics.ClosedShape;
import jellyPhysics.PressureBody;
import jellyPhysics.SpringBody;
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
        stage.addEventListener(KeyboardEvent.KEY_DOWN,reportKeyDown); 
        stage.addEventListener(KeyboardEvent.KEY_UP,reportKeyUp); 
    }
    
    private function reportKeyUp(e:KeyboardEvent):Void 
    {
        trace("Key up: " + e.keyCode);
    }
    
    private function reportKeyDown(e:KeyboardEvent):Void 
    {
        trace("Key down: " + e.keyCode);        
    }
    
    override public function setupDrawParam(render:DrawDebugWorld):Void 
    {
        super.setupDrawParam(render);
        render.DrawingGlobalBody = false;
    }
    
    override public function addBodiesToWorld():Void 
    {
        super.addBodiesToWorld();        
        
        var groundBody:Body = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(0, 9), 0, new Vector2(16, 1), false);
        groundBody.IsStatic = true;
        physicsWorld.AddBody(groundBody);
        
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 200;
        var shapeDamp:Float = 100;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 100.0;
        
        var springBody:SpringBody = new SpringBody(getBigSquareShape(3), mass, new Vector2( -6, 0), 0, new Vector2(.5, .5), false, shapeK, shapeDamp, edgeK, edgeDamp);
        springBody.Label = "SpringBody";
        physicsWorld.AddBody(springBody);
        
        var pressureBody:PressureBody = new PressureBody(getCircleShape(2, 16), mass, new Vector2( 6, 0), 0, new Vector2(.5, .5), false, 0.2*shapeK, 5.0*shapeDamp, edgeK, edgeDamp, pressureAmount);
        pressureBody.Label = "PressureBody";
        physicsWorld.AddBody(pressureBody);        
    }
}