package jellyPhysics;
import lime.math.Vector2;

/**
 * Represents a point on the edge of a Body
 * @author Michael Apfelbeck
 */
class PointOnEdge
{
    // Edge number on the body, 1 = edge between points 1 and 2, 2 between 2 and 3...
    var EdgeNum:Int;
    // Point on edge in global space
    var Point:Vector2;
    // Normal on Edge in global space
    var Normal:Vector2;
    // Normalized distance between start and end point
    var EdgeDistance:Float;
    
    public function new(edgeNum:Int, point:Vector2, normal:Vector2, edgeDistance:Float) 
    {
        EdgeNum = edgeNum;
        Point = point;
        Normal = normal;
        EdgeDistance = edgeDistance;
    }
    
}