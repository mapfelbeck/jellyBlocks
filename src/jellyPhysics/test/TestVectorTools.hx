package jellyPhysics.test;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestVectorTools extends TestCase
{
    public function testIntersect() 
    {
        var ptA:Vector2 = new Vector2(0, 0);
        var ptB:Vector2 = new Vector2(5, 5);
        var ptC:Vector2 = new Vector2(0, 5);
        var ptD:Vector2 = new Vector2(5, 0);
        var intersect:Intersection = VectorTools.LineIntersect(ptA, ptB, ptC, ptD);
        
        assertEquals(2.5, intersect.HitPoint.x);
        assertEquals(2.5, intersect.HitPoint.y);
        assertEquals(0.5, intersect.IntersectAB);
        assertEquals(0.5, intersect.IntersectCD);
    }

    //these two lines never intersect
    public function testNoIntersect() 
    {
        var ptA:Vector2 = new Vector2(0, 0);
        var ptB:Vector2 = new Vector2(5, 5);
        var ptC:Vector2 = new Vector2(0, 5);
        var ptD:Vector2 = new Vector2(5, 10);
        var intersect:Intersection = VectorTools.LineIntersect(ptA, ptB, ptC, ptD);
        
        assertEquals(null, intersect);
    }

    //these lines intersect, but outside the deinfed range
    public function testNoIntersect2()
    {
        var ptA:Vector2 = new Vector2(0, 0);
        var ptB:Vector2 = new Vector2(5, 5);
        var ptC:Vector2 = new Vector2(0, 5);
        var ptD:Vector2 = new Vector2(5, 9);
        var intersect:Intersection = VectorTools.LineIntersect(ptA, ptB, ptC, ptD);
        
        assertEquals(null, intersect);
    }

    //these lines intersect, but outside the deinfed range
    public function testDistance()
    {
        var ptA:Vector2 = new Vector2(0, 0);
        var ptB:Vector2 = new Vector2(3, 4);
        var distance = VectorTools.Distance(ptA, ptB);
        
        assertEquals(5.0, distance);
    }
    
}