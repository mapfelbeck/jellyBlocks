package jellyPhysics;
import haxe.Constraints.Function;
import jellyPhysics.*;
import lime.math.Vector2;

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
    
    private var BodyDamping:Float = .5;
    
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
        
        PhysicsIter = 4;
        
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
    
    public function AddBody(body:Body):Void
    {
        if (!collider.Contains(body)){
            body.VelocityDamping = BodyDamping;
            body.BodyNumber = bodyCounter;
            bodyCounter++;
            collider.Add(body);
        }
    }
    
    public function RemoveBody(body:Body):Void
    {
        if (collider.Contains(body)){
            collider.Remove(body);
            if (body.DeleteCallback != null){
                body.DeleteCallback(body);
            }
        }
    }
    
    public function GetBody(index:Int):Body
    {
        if (index < collider.Count){
            return collider.GetBody(index);
        }
        return null;
    }
    
    public function GetClosestPointMass(point:Vector2):BodyPointMassRef
    {
        var bodyID:Int = -1;
        var pmID:Int = -1;

        var closestD:Float = 1000.0;
        for (i in 0...collider.Count)
        {
            var dist:Float = 0.0;
            var pmRef:PointMassRef = collider.GetBody(i).GetClosestPointMass(point);
            if (pmRef.Distance < closestD)
            {
                closestD = pmRef.Distance;
                bodyID = i;
                pmID = pmRef.Index;
            }
        }
        
        if (bodyID == -1){
            return null;
        }
        
        return new BodyPointMassRef(bodyID, pmID);
    }
    
    public function GetBodyContaining(point:Vector2):Body
    {
        for (i in 0...collider.Count){
            if (collider.GetBody(i).Contains(point)){
                return collider.GetBody(i);
            }
        }
        return null;
    }
    
    public function Update(elapsed:Float)
    {
        var iterElapsed = elapsed / PhysicsIter;
        
        for (iter in 0...PhysicsIter){
            penetrationCount = 0;
            
            if (null != externalAccumulator){
                externalAccumulator(iterElapsed);
            }
            
            for (i in 0...collider.Count){
                if (collider.GetBody(i).DeleteThis){
                    RemoveBody(collider.GetBody(i));
                    //i--;
                }
            }
            
            AccumulateAndIntegrate(iterElapsed);
        }
    }

    private function AccumulateAndIntegrate(iterElapsed:Float):Void
    {
        AccumulateAndIntegrateForces(0, collider.Count, iterElapsed);
    }

    private function AccumulateAndIntegrateForces(start:Int, end:Int, elapsed:Float):Void
    {
        for (i in start...end)
        {
            var body = collider.GetBody(i);
            if (!body.IsStatic)
            {
                /*body.DerivePositionAndAngle(iterElapsed);
                body.AccumulateExternalForces(iterElapsed);
                body.AccumulateInternalForces(iterElapsed);
                body.Integrate(iterElapsed);
                body.UpdateAABB(iterElapsed, false);*/
            }
        }
    }
}