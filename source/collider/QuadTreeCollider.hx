package collider;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.system.FlxQuadTree;
import jellyPhysics.AABB;
import jellyPhysics.BodyCollisionInfo;

import jellyPhysics.Body;
import jellyPhysics.ColliderBase;

/**
 * ...
 * @author 
 */
class QuadTreeCollider implements ColliderBase
{
    private var bodies:Array<Body>;
    
    private var penetrationThreshold:Float;    
    public var PenetrationThreshold(get, null):Float;
    function get_PenetrationThreshold():Float{
        return penetrationThreshold;
    }
    
    public var Count(get, null):Int;
    function get_Count():Int{
        return bodies.length;
    }
    
    public function new(penThreshold:Float) 
    {
        penetrationThreshold = penThreshold;
        bodies = new Array<Body>();
    }
    
    private function testTree():Void{
        var tree:FlxQuadTree;
        FlxQuadTree.divisions = 4;
        tree = FlxQuadTree.recycle(-10, -10, 1000, 1000);
        var group:FlxGroup = new FlxGroup();
        var object1:FlxObject = new FlxObject(0, 0, 40, 40);
        object1.ID = 1;
        var object2:FlxObject = new FlxObject(20, 20, 40, 40);
        object2.ID = 2;
        var object3:FlxObject = new FlxObject(60, 60, 40, 40);
        object3.ID = 3;
        var object4:FlxObject = new FlxObject(100, 100, 40, 40);
        object4.ID = 4;
        var object5:FlxObject = new FlxObject(10, 10, 60, 60);
        object5.ID = 5;
        tree.load(object1, null, NotifyCallback, ProcessCallback);
        tree.load(object2, null, NotifyCallback, ProcessCallback);
        tree.load(object3, null, NotifyCallback, ProcessCallback);
        tree.load(object4, null, NotifyCallback, ProcessCallback);
        tree.load(object5, null, NotifyCallback, ProcessCallback);      
        var collisions:Bool = tree.execute();
        trace("Saw collisions: " + collisions);
    }
    
    private function NotifyCallback(object1:FlxObject,object2:FlxObject):Void 
    {
        trace("object " + object1.ID + " collided with object " + object2.ID);
    }
    
    private function ProcessCallback(object1:FlxObject,object2:FlxObject):Bool 
    {
        return true;
    }
    
    private function testTreeNew():Void{
        var tree:FlxQuadTree;
        FlxQuadTree.divisions = 6;
        tree = FlxQuadTree.recycle( -21, -21, 21, 21);
        
        for (i in 0...bodies.length){
            var body:Body = bodies[i];
            var treeObject = new FlxObject(body.BoundingBox.X, body.BoundingBox.Y, body.BoundingBox.Width, body.BoundingBox.Height);
            tree.load(treeObject, null, NotifyCallback, ProcessCallback);
            //var treeObject = new QuadColliderObject(bodies[i]);
            //tree.load(treeObject, null, NotifyCallback2, ProcessCallback2);
        }
        var collisions:Bool = tree.execute();
        trace("Saw collisions: " + collisions);
        tree.destroy();
        tree = null;
    }
    
    private function NotifyCallback2(object1:FlxObject,object2:FlxObject):Void 
    {
        var c1:QuadColliderObject = cast object1;
        var c2:QuadColliderObject = cast object2;
        trace("object " + c1.body.Label + "("+c1.body.DerivedPos.x+","+c1.body.DerivedPos.y+") collided with object " + c2.body.Label+"("+c2.body.DerivedPos.x+","+c2.body.DerivedPos.y+")");
    }
    
    private function ProcessCallback2(object1:FlxObject,object2:FlxObject):Bool 
    {
        return true;
        /*var colliderObject1:QuadColliderObject = cast object1;
        var colliderObject2:QuadColliderObject = cast object2;
        var body1:Body = colliderObject1.body;
        var body2:Body = colliderObject2.body;
        return !((body1.IsStatic && body2.IsStatic) || (body1.IsAsleep && body2.IsStatic)||(body1.IsStatic && body2.IsAsleep));*/
    }
    
    public function GetBody(index:Int):Body 
    {
        if (index >= bodies.length){
            return null;
        }
        return bodies[index];
    }
    
    public function Add(body:Body):Void 
    {
        bodies.push(body);
    }
    
    public function Remove(body:Body):Void 
    {
        bodies.remove(body);
    }
    
    public function Contains(body:Body):Bool 
    {
        var index = bodies.indexOf(body);
        return -1 != index;
    }
    
    public function Clear():Void 
    {
        bodies = null;
        bodies = new Array<Body>();
    }
    
    private function AddCollisionCallback(object1:FlxObject,object2:FlxObject):Void 
    {
        var b1:Body = bodies[object1.ID];
        var b2:Body = bodies[object2.ID];
        
        var aCollide:Array<BodyCollisionInfo> = Body.BodyCollide(b1, b2, penetrationThreshold);
        collisions = collisions.concat(aCollide);
        var bCollide:Array<BodyCollisionInfo> = Body.BodyCollide(b2, b1, penetrationThreshold);
        collisions = collisions.concat(bCollide);
        //trace("object " + c1.body.Label + "("+c1.body.DerivedPos.x+","+c1.body.DerivedPos.y+") collided with object " + c2.body.Label+"("+c2.body.DerivedPos.x+","+c2.body.DerivedPos.y+")");
    }
    
    private function FilterCallback(object1:FlxObject,object2:FlxObject):Bool 
    {
        return true;
        /*var colliderObject1:QuadColliderObject = cast object1;
        var colliderObject2:QuadColliderObject = cast object2;
        var body1:Body = colliderObject1.body;
        var body2:Body = colliderObject2.body;
        return !((body1.IsStatic && body2.IsStatic) || (body1.IsAsleep && body2.IsStatic)||(body1.IsStatic && body2.IsAsleep));*/
    }
    
    private var collisions:Array<BodyCollisionInfo>;
    public function BuildCollisions():Array<BodyCollisionInfo> 
    {
        collisions = new Array<BodyCollisionInfo>();
        var tree:FlxQuadTree;
        FlxQuadTree.divisions = 6;
        tree = FlxQuadTree.recycle( -21, -21, 21, 21);
        
        for (i in 0...bodies.length){
            var body:Body = bodies[i];
            FlxG.collide(
            var treeObject = new FlxObject(body.BoundingBox.X, body.BoundingBox.Y, body.BoundingBox.Width, body.BoundingBox.Height);
            treeObject.ID = body.BodyNumber;
            tree.load(treeObject, null, AddCollisionCallback, ProcessCallback);
            //var treeObject = new QuadColliderObject(bodies[i]);
            //tree.load(treeObject, null, NotifyCallback2, ProcessCallback2);
        }
        var collide:Bool = tree.execute();
        trace("Saw collisions: " + collide);
        tree.destroy();
        tree = null;
        
        return collisions;
    }
    
    public function BuildCollisions():Array<BodyCollisionInfo> 
    {
        //testTreeNew();
        var collisions:Array<BodyCollisionInfo> = new Array<BodyCollisionInfo>();
        
        for (i in 0...bodies.length){
            for (j in (i + 1)...bodies.length){
                var bodyA:Body = bodies[i];
                var bodyB:Body = bodies[j];
                
                var boxA:AABB = bodyA.BoundingBox;
                var boxB:AABB = bodyB.BoundingBox;
                
                if (!boxA.Intersects(boxB)){
                    continue;
                }
                
                var aCollide:Array<BodyCollisionInfo> = Body.BodyCollide(bodyA, bodyB, penetrationThreshold);
                for (i in 0...aCollide.length){
                    var info:BodyCollisionInfo = aCollide[i];
                    if (info == null || info.BodyA == null || info.BodyB == null || info.BodyAPointMass ==-1 || info.BodyBPointMassA ==-1 || info.BodyBPointMassB ==-1){
                        trace("what the hell broke?");
                    }
                }
                collisions = collisions.concat(aCollide);
                var bCollide:Array<BodyCollisionInfo> = Body.BodyCollide(bodyB, bodyA, penetrationThreshold);       
                for (i in 0...bCollide.length){
                    var info:BodyCollisionInfo = bCollide[i];
                    if (info == null || info.BodyA == null || info.BodyB == null || info.BodyAPointMass ==-1 || info.BodyBPointMassA ==-1 || info.BodyBPointMassB ==-1){
                        trace("what the hell broke?");
                    }
                }
                collisions = collisions.concat(bCollide);
                //collisions = collisions.concat(Body.BodyCollide(bodyA, bodyB, penetrationThreshold));
                //collisions = collisions.concat(Body.BodyCollide(bodyB, bodyA, penetrationThreshold));
            }
        }
        return collisions;
    }
}