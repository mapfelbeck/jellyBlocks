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
    private var collisions:Array<BodyCollisionInfo>;
    
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
    
    private static var collideCount:Int = 0;
    private function testTree():Void{
        collideCount = 0;
        var tree:FlxQuadTree;
        FlxQuadTree.divisions = 4;
        tree = FlxQuadTree.recycle(-1000, -1000, 2000, 2000);
        for (i in 0...50){
            var object:FlxObject = new FlxObject(-1000 + 10*i, 0/*-1000 + 10*i*/, 11, 11);
            object.ID = i;  
            tree.load(object, null, NotifyCallback, ProcessCallback);
        }    
        var collisions:Bool = tree.execute();
        trace("Collide count: " + collideCount);
    }
    
    private function testBigLittle():Void{
        collideCount = 0;
        var tree:FlxQuadTree;
        FlxQuadTree.divisions = 4;
        tree = FlxQuadTree.recycle(-1000, -1000, 2000, 2000);
        var bigObject:FlxObject = new FlxObject(-1000, 0, 2000, 20);
        bigObject.ID = 1;
        tree.load(bigObject, null, NotifyCallback, null);
        var littleObject:FlxObject = new FlxObject(0, 10, 20, 20);
        littleObject.ID = 2;
        tree.load(littleObject, null, NotifyCallback, null);
        var collisions:Bool = tree.execute();
        trace("Collide count: " + collideCount);
    }
    
    private function NotifyCallback(object1:FlxObject,object2:FlxObject):Void 
    {
        collideCount++;
        //trace("object " + object1.ID + " collided with object " + object2.ID);
    }
    
    private function ProcessCallback(object1:FlxObject,object2:FlxObject):Bool 
    {
        return true;
    }
    
    private function testTreeAABB():Void{
        var tree:FlxQuadTree;
        FlxQuadTree.divisions = 6;
        tree = FlxQuadTree.recycle( -21, -21, 42, 42);
        
        for (i in 0...bodies.length){
            var body:Body = bodies[i];
            if (!Math.isFinite(body.BoundingBox.X) || !Math.isFinite(body.BoundingBox.Y) || !Math.isFinite(body.BoundingBox.Width) || !Math.isFinite(body.BoundingBox.Height)){
                trace("wat??");
            }
            var x:Float = body.BoundingBox.X;
            var y:Float = body.BoundingBox.Y;
            var w:Float = body.BoundingBox.Width;
            var h:Float = body.BoundingBox.Height;

            //var treeObject = new FlxObject(x - w * 0.05, y - h * 0.05, w * 1.1, h * 1.1);
            var treeObject = new FlxObject(x, y, w, h);
            treeObject.ID = body.BodyNumber;
            tree.load(treeObject, null, NotifyCallback, ProcessCallback);
            //var treeObject = new QuadColliderObject(bodies[i]);
            //tree.load(treeObject, null, NotifyCallback2, ProcessCallback2);
        }
        var collisions:Bool = tree.execute();
        if (collisions){
            trace("Collide count: " + collideCount);
            collideCount = 0;
        }
        //trace("Saw collisions: " + collisions);
        tree.destroy();
        tree = null;
    }
    
    function testAABB() 
    {
        FlxQuadTree.divisions = 4;
        var intersectCount:Int = 0;
        var treeCount:Int = 0;
        for (i in 0...bodies.length){
            for (j in i+1...bodies.length){
                var bodyA:Body = bodies[i];
                var bodyB:Body = bodies[j];
                if ((!bodyA.IsStatic && !bodyB.IsStatic) && bodyA.BoundingBox.Intersects(bodyB.BoundingBox)){
                    var xA:Float = bodyA.BoundingBox.X;
                    var yA:Float = bodyA.BoundingBox.Y;
                    var wA:Float = bodyA.BoundingBox.Width;
                    var hA:Float = bodyA.BoundingBox.Height;
                    
                    var xB:Float = bodyB.BoundingBox.X;
                    var yB:Float = bodyB.BoundingBox.Y;
                    var wB:Float = bodyB.BoundingBox.Width;
                    var hB:Float = bodyB.BoundingBox.Height;
                    
                    var tree:FlxQuadTree;
                    tree = FlxQuadTree.recycle( -21, -21, 21, 21);
                    var treeObjectA = new FlxObject(xA, -yA, wA, hA);
                    treeObjectA.ID = bodyA.BodyNumber;
                    tree.load(treeObjectA, null, NotifyCallback, ProcessCallback);
                    var treeObjectB = new FlxObject(xB, -yB, wB, hB);
                    treeObjectB.ID = bodyB.BodyNumber;
                    tree.load(treeObjectB, null, NotifyCallback, ProcessCallback);
                    var collisions:Bool = tree.execute();
                    if (collisions){
                        //trace("Collide count: " + collideCount);
                        treeCount += collideCount;
                        collideCount = 0;
                    }
                    tree.destroy();
                    tree = null;
                    intersectCount++;
                }
            }
        }
        trace("Intersect count: " + intersectCount);
        trace("treeCount count: " + treeCount);
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
        var colliderObject1:QuadColliderObject = cast object1;
        var colliderObject2:QuadColliderObject = cast object2;
        var b1:Body = colliderObject1.body;
        var b2:Body = colliderObject2.body;
        
        var aCollide:Array<BodyCollisionInfo> = Body.BodyCollide(b1, b2, penetrationThreshold);
        collisions = collisions.concat(aCollide);
        var bCollide:Array<BodyCollisionInfo> = Body.BodyCollide(b2, b1, penetrationThreshold);
        collisions = collisions.concat(bCollide);
        //trace("object " + c1.body.Label + "("+c1.body.DerivedPos.x+","+c1.body.DerivedPos.y+") collided with object " + c2.body.Label+"("+c2.body.DerivedPos.x+","+c2.body.DerivedPos.y+")");
    }
    
    private function FilterCallback(object1:FlxObject,object2:FlxObject):Bool 
    {
        var colliderObject1:QuadColliderObject = cast object1;
        var colliderObject2:QuadColliderObject = cast object2;
        var body1:Body = colliderObject1.body;
        var body2:Body = colliderObject2.body;
        if ((body1.IsStatic && body2.IsStatic)||(body1.IsAsleep && body2.IsStatic)||(body1.IsStatic && body2.IsAsleep)){
            return false;
        }
        return body1.BoundingBox.Intersects(body2.BoundingBox);
    }
    
    public function BuildCollisions():Array<BodyCollisionInfo> 
    {
        collisions = new Array<BodyCollisionInfo>();
        var tree:FlxQuadTree;
        FlxQuadTree.divisions = 4;
        tree = FlxQuadTree.recycle( -21, -21, 42, 42);
        
        for (i in 0...bodies.length){
            var body:Body = bodies[i];
            var x:Float = body.BoundingBox.X;
            var y:Float = body.BoundingBox.Y;
            var w:Float = body.BoundingBox.Width;
            var h:Float = body.BoundingBox.Height;

            //var treeObject = new FlxObject(x - w * 0.05, y - h * 0.05, w * 1.1, h * 1.1);
            var treeObject = new QuadColliderObject(x - w * 0.05, y - h * 0.05, w * 1.1, h * 1.1,
                                                    body);
            treeObject.ID = body.BodyNumber;
            tree.load(treeObject, null, AddCollisionCallback, FilterCallback);
        }
        var collide:Bool = tree.execute();
        //trace("Saw collisions: " + collide);
        tree.destroy();
        tree = null;

        return collisions;
    }
    
    /*private static var count:Int = 0;
    public function BuildCollisions():Array<BodyCollisionInfo> 
    {
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
                collisions = collisions.concat(aCollide);
                var bCollide:Array<BodyCollisionInfo> = Body.BodyCollide(bodyB, bodyA, penetrationThreshold);
                collisions = collisions.concat(bCollide);
            }
        }
        return collisions;
    }*/
}