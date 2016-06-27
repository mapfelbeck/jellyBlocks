package jellyPhysics;
import haxe.Constraints.Function;
import jellyPhysics.AABB;
import jellyPhysics.BodyCollisionInfo;

/**
 * ...
 * @author Michael Apfelbeck
 */
class World
{
    private var materialCount:Int;
    public var MaterialCount(get, null):Int;
    public function get_MaterialCount(){
        return materialCount;
    }
    
    public var NumberBodies(get, null):Int;
    public function get_NumberBodies(){
        return collider.Count;
    }
    private var collider:ColliderBase;
    
    public var PhysicsIter:Int;
    
    public var externalAccumulator:Function;
    
    private var worldLimits:AABB;
    //used to give each body added to the physics world a unique id
    private var bodyCounter:Int;
    private var penetrationCount:Int;
    
    private var defaultMaterialPair:MaterialPair;
    private var materialPairs:Map<MaterialPair, MaterialPair>;
    
    private var bodyDamping:Float;
    
    private var collisionList:Array<BodyCollisionInfo>;
    
    public function new(worldMaterialCount:Int, 
                        worldMaterialPairs:Map<MaterialPair, MaterialPair>,
                        worldDefaultMaterialPair:MaterialPair,
                        worldPenetrationThreshhold:Float,
                        worldBounds: AABB)
    {
        collider = new ArrayCollider(.05);
    }
}