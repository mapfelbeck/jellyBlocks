package;
import jellyPhysics.Body;
import jellyPhysics.MaterialMatrix;
import jellyPhysics.SpringBody;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorld5 extends TestWorldBase
{
    private static var GROUND_BODY_MATERIAL:Int = 0;
    private static var SPRING_BODY_MATERIAL:Int = 1;
    public function new(inputPoll:InputPoll) 
    {
        super(inputPoll);
		Title = "Delete Body World";
        PromptText = "Click/Tap on a body to delete it.";
    }
    
    override public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, 2);
        
        return materialMatrix;
    }
    
    override public function setupDrawParam(render:DrawDebugWorld):Void 
    {
        super.setupDrawParam(render);
        render.DrawingPointMasses = false;
        render.SetDefaultBodyDrawOptions(DrawDebugWorld.COLOR_PURPLE, false);
        render.SetMaterialDrawOptions(GROUND_BODY_MATERIAL, DrawDebugWorld.COLOR_WHITE, false);
        render.SetMaterialDrawOptions(SPRING_BODY_MATERIAL, DrawDebugWorld.COLOR_PURPLE, false);
    }
    
    public override function addBodiesToWorld():Void
    {                
        var groundBody:Body = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(0, 9), 0, new Vector2(16, 1), false);
        groundBody.IsStatic = true;
        groundBody.Material = GROUND_BODY_MATERIAL;
        physicsWorld.AddBody(groundBody);
        
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 100;
        var shapeDamp:Float = 50;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        
        var springBodyXPositions:Array<Float> = [ -12, -9, -6, -3, 0, 3, 6, 9, 12];
        for (x in springBodyXPositions){
            var squareBody:SpringBody = new SpringBody(getSquareShape(2), mass, new Vector2( x, 6.8), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
            squareBody.Material = SPRING_BODY_MATERIAL;
            physicsWorld.AddBody(squareBody);
            squareBody = new SpringBody(getSquareShape(2), mass, new Vector2( x, 4.6), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
            squareBody.Material = SPRING_BODY_MATERIAL;
            physicsWorld.AddBody(squareBody);
        }
    }
    
}