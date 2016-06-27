package jellyPhysics;
import jellyPhysics.AABB;
import jellyPhysics.Body;
import jellyPhysics.BodyCollisionInfo;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ArrayCollider extends ColliderBase
{
    public function get_Count(){
        return bodies.length;
    }
    
    override public function GetBody(index:Int):Body 
    {
        if (index >= bodies.length){
            return null;
        }
        return bodies[index];
    }
    
    override function Add(body:Body):Void 
    {
        bodies.push(body);
    }
    
    override function Remove(body:Body):Void 
    {
        bodies.remove(body);
    }
    
    override function Contains(body:Body):Bool 
    {
        var index = bodies.indexOf(body);
        return -1 != index;
    }
    
    override function Clear():Void 
    {
        bodies = null;
        bodies = new Array<Body>();
    }
    
    override function BuildCollisions():Array<BodyCollisionInfo> 
    {
        var collisions:Array<BodyCollisionInfo> = new Array<BodyCollisionInfo>();
        
        for (i in 0...(bodies.length - 1)){
            for (j in (i + 1)...(bodies.length - 1)){
                var bodyA:Body = bodies[i];
                var bodyB:Body = bodies[j];
                
                var boxA:AABB = bodyA.BoundingBox;
                var boxB:AABB = bodyB.BoundingBox;
                
                if (boxA.Intersects(boxB)){
                    continue;
                }
                
                collisions.concat(Body.BodyCollide(bodyA, bodyB, PenetrationThreshold));
                collisions.concat(Body.BodyCollide(bodyB, bodyA, PenetrationThreshold));
            }
        }
        return collisions;
    }
    private var bodies:Array<Body>;
    public function new(penThreshold:Float) 
    {
        super(penThreshold);
        bodies = new Array<Body>();
    }
    
}