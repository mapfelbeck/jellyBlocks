package jellyPhysics;
import jellyPhysics.Body;
import jellyPhysics.BodyCollisionInfo;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ColliderBase
{    
    private var penetrationThreshold:Float;
    public var PenetrationThreshold(get, null):Float;
    public function get_PenetrationThreshold(){
        return penetrationThreshold;
    }
    
    public function Count():Int
    {
        throw "ColliderBase does not provide Count()";
        return -1;
    }
    
    public function GetBody(index:Int):Body
    {
        throw "ColliderBase does not provide GetBody()";
        return null;
    }
    
    public function new(penThreshold:Float)
    {
        this.penetrationThreshold = penThreshold;
    }
    
    function Add(body:Body):Void
    {
        throw "ColliderBase does not provide Add()";
    }
    function Remove(body:Body):Void
    {
        throw "ColliderBase does not provide Remove()";
    }
    function Contains(body:Body):Bool
    {
        throw "ColliderBase does not provide Contains()";
        return false;
    }
    function BuildCollisions():Array<BodyCollisionInfo>
    {
        throw "ColliderBase does not provide BuildCollisions()";
        return null;
    }
    function Clear():Void
    {
        throw "ColliderBase does not provide Clear()";
    }
}