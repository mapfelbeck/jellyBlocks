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
    private var materialPairs:Array<Array<MaterialPair>>;
    
    private var bodyDamping:Float;
    
    private var collisionList:Array<BodyCollisionInfo>;
    
    private var penetrationThreshold:Float;
    
    public function new(worldMaterialCount:Int, 
                        worldMaterialPairs:Array<Array<MaterialPair>>,
                        worldDefaultMaterialPair:MaterialPair,
                        worldPenetrationThreshhold:Float,
                        worldBounds: AABB)
    {
        collider = new ArrayCollider(worldPenetrationThreshhold);
        
        collisionList = new Array<BodyCollisionInfo>();
        bodyCounter = 0;
        
        // initialize materials
        materialCount = worldMaterialCount;
        materialPairs = worldMaterialPairs;
        defaultMaterialPair = worldDefaultMaterialPair;
        
        SetWorldLimits(worldBounds);
        
        penetrationThreshold = worldPenetrationThreshhold;
    }
    
    public function SetWorldLimits(limits:AABB) : Void
    {
        worldLimits = limits;
    }
}