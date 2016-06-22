package jellyPhysics;

import haxe.Constraints.Function;
import jellyPhysics.ClosedShape;
import lime.math.Vector2;
import openfl.utils.Object;
//fixme
/**
 * ...
 * @author Michael Apfelbeck
 */
class Body
{
    public var UpdateDelegate:Function;
    public var DelateDelegate:Function;
    public var CollisionCallback:Function;
    public var DeleteCallback:Function;
    
    public var BaseShape: ClosedShape;
    public var GlobalShape:Array<Vector2>;
    
    public var PointMasses:Array<PointMass>;
    
    public var Scale:Vector2;
    
    public var DerivedPos:Vector2;
    public var DerivedVel:Vector2;
    public var DerivedAngle:Float;
    public var DerivedOmega:Float;
    
    public var LastAngle:Float;
    public var BoundingBox:AABB;

    public var Material:Int;
    public var IsStatic:Bool;
    public var Kinematic:Bool;
    
    public var ObjectTag;
    public var BodyNumber:Int;    
    public var GroupNumber:Int;
    
    public var DeleteThis:Bool;
    public var IsAsleep:Bool;
    public var IsStatic:Bool;
    public var IsKinamatic:Bool;
    
    public var VelocityDamping:Float;
        
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2,
            angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool) 
    {
            BoundingBox = new AABB();
            DerivedPos = position;
            DerivedAngle = angleInRadians;
            LastAngle = derivedAngle;
            Scale = bodyScale;
            Material = 0;
            IsStatic = Math.POSITIVE_INFINITY == massPerPoint;
            Kinematic = isKinematic;

            PointMasses = new List<PointMass>();
            SetShape(bodyShape);
            for (i in 0...PointMasses.length)
                PointMasses[i].Mass = massPerPoint;

            UpdateAABB(0, true);
    }
    
    // set the shape of this body to a new ClosedShape object.  This function 
    // will remove any existing PointMass objects, and replace them with new 
    // ones IF the new shape has a different vertex count than the previous one.
    // In this case the mass for each newly added point mass will be set zero.  
    // Otherwise the shape is just updated, not affecting the existing PointMasses.
    public function SetShape(shape:ClosedShape):Void
    {
        BaseShape = shape;

        if (BaseShape.Vertices.Count != pointMasses.Count)
        {
            PointMasses = null;
            PointMasses = new Array<PointMass>();
            GlobalShape = new Array<Vector2>();

            BaseShape.transformVertices(DerivedPos, DerivedAngle, Scale, GlobalShape);

            for (i 0...BaseShape.LocalVertices.length)
            {
                PointMasses.push(new PointMass(0.0f, GlobalShape[i]));
            }
        }
    }
    
    // update the AABB for this body, including padding for velocity given a timestep.
    // This function is called by the World object on Update(), so the user should not
    // need this in most cases.
    public function UpdateAABB(elapsed:Float, ?forceUpdate:Bool):Void
    {
        if (!IsStatic || forceUpdate)
        {
            BoundingBox.Clear();
            for (i 0...PointMasses.length)
            {
                var p:Vector2 = PointMasses[i];
                BoundingBox.ExpandToInclude(p);
                
                if (!IsStatic)
                {
                    p.x += PointMasses[i].Velocity.x * elapsed);
                    p.y += PointMasses[i].Velocity.y * elapsed);
                }
            }
        }
    }
    
    public function SetMassAll(mass:Float):Void
    {
        for (i in 0...PointMasses.length)
        {
            PointMasses[i] = mass;
        }
    }
    
    public function SetMassFromList(masses:Array<Float>)
    {
        if (PointMasses.length == masses.length)
        {
            for (i in 0...PointMasses.length)
            {
                PointMasses[i].Mass == masses[i];
            }
        }
    }
    
    public function SetPositionAngle(pos:Vector2, angleInRadian:Float, scale:Vector2):Void
    {
        GlobalShape = BaseShape.transformVertices(pos, angleInRadian, scale);
        
        for (i in 0...PointMasses.length)
        {
            PointMasses[i].Position = GlobalShape[i];
        }
        DerivedPos = pos;
        DerivedAngle = angleInRadian;
    }
    
    public function SetKinematicPosition(pos:Vector2):Void
    {
        DerivedPos = pos;
    }
    
    public function SetKinematicAngle(angleInRadian:Float):Void
    {
        DerivedAngle = angleInRadian;
    }
}