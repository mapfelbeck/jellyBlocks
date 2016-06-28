package jellyPhysics.test;

import haxe.ds.Vector;
import haxe.unit.TestCase;
import jellyPhysics.AABB;
import jellyPhysics.World;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorld extends TestCase
{
    public function testCreate(){
        var closedShape:ClosedShape = new ClosedShape();

        closedShape.Begin();
        closedShape.AddVertex(new Vector2(0, 0));
        closedShape.AddVertex(new Vector2(4, 0));
        closedShape.AddVertex(new Vector2(4, 4));
        closedShape.AddVertex(new Vector2(0, 4));
        closedShape.Finish(true);

        var testBody1:Body = new Body(closedShape, 5, new Vector2(0, 0), 0, new Vector2(1, 1), false);
        var testBody2:Body = new Body(closedShape, 5, new Vector2(5, 5), 0, new Vector2(1, 1), false);
        
        var bounds:AABB = new AABB(new Vector2( -20, -20), new Vector2(20, 20));
        //var world:World = new World();
        
        assertTrue(true);
    }
}