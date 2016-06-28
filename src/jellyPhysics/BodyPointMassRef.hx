package jellyPhysics;

/**
 * ...
 * @author Michael Apfelbeck
 */
class BodyPointMassRef
{
    public var BodyID:Int;
    public var PointMassIndex:Int;
    public function new(bodyId:Int, pointMassIndex:Int) 
    {
        BodyID = bodyId;
        PointMassIndex = pointMassIndex;
    }
    
}