package jellyPhysics;

import haxe.Constraints.Function;
import jellyPhysics.ClosedShape;
import jellyPhysics.PointOnEdge;
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
    public var IsAsleep:Bool;
    
    public var ObjectTag:Object;
    public var BodyNumber:Int;    
    public var GroupNumber:Int;
    
    public var DeleteThis:Bool;
    
    public var VelocityDamping:Float;
        
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2,
            angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool) 
    {
            BoundingBox = new AABB();
            DerivedPos = position;
            DerivedAngle = angleInRadians;
            LastAngle = DerivedAngle;
            Scale = bodyScale;
            Material = 0;
            IsStatic = Math.POSITIVE_INFINITY == massPerPoint;
            Kinematic = isKinematic;

            PointMasses = new Array<PointMass>();
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

        if (BaseShape.LocalVertices.length != PointMasses.length)
        {
            PointMasses = null;
            PointMasses = new Array<PointMass>();

            GlobalShape = BaseShape.transformVertices(DerivedPos, DerivedAngle, Scale);

            for (i in 0...BaseShape.LocalVertices.length)
            {
                PointMasses.push(new PointMass(0.0, GlobalShape[i]));
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
            for (i in 0...PointMasses.length)
            {
                var p:Vector2 = PointMasses[i].Position;
                BoundingBox.ExpandToInclude(p);
                
                if (!IsStatic)
                {
                    p.x += PointMasses[i].Velocity.x * elapsed;
                    p.y += PointMasses[i].Velocity.y * elapsed;
                    BoundingBox.ExpandToInclude(p);
                }
            }
        }
    }
    
    public function SetMassAll(mass:Float):Void
    {
        for (i in 0...PointMasses.length)
        {
            PointMasses[i].Mass = mass;
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
    
    // collision detection.  detect if a global point is inside this body.
    public function Contains(point:Vector2):Bool
    {
        // basic idea: draw a line from the point to a point known to be outside
        // the body.  count the number of lines in the polygon it intersects.  if 
        // that number is odd, we are inside.  if it's even, we are outside. in 
        // this implementation we will always use a line that moves off in the 
        // positive X direction from the point to simplify things.
        var endPt:Vector2 = new Vector2();
        endPt.x = BoundingBox.LR.x + 0.1;
        endPt.y = point.y;

        // line we are testing against goes from pt -> endPt.
        var inside:Bool = false;
        var edgeSt:Vector2 = PointMasses[0].Position;
        var edgeEnd:Vector2 = new Vector2();
        var c:Int = PointMasses.length;
        for (i in 0...c)
        {
            // the current edge is defined as the line from edgeSt -> edgeEnd.
            if (i < (c - 1))
                edgeEnd = PointMasses[i + 1].Position;
            else
                edgeEnd = PointMasses[0].Position;

            // perform check now...
            if (((edgeSt.y <= point.y) && (edgeEnd.y > point.y)) || ((edgeSt.y > point.y) && (edgeEnd.y <= point.y)))
            {
                // this line crosses the test line at some point... does it do so within our test range?
                var slope:Float = (edgeEnd.x - edgeSt.x) / (edgeEnd.y - edgeSt.y);
                var hitX:Float = edgeSt.x + ((point.y - edgeSt.y) * slope);

                if ((hitX >= point.x) && (hitX <= endPt.x))
                    inside = !inside;
            }
            edgeSt = edgeEnd;
        }

        return inside;
    }
    
    // given a global point, find the point on this body that is closest to the 
    // global point, and if it is an edge, information about the edge it resides on.
    /*public function GetClosestPoint(point:Vector2):Vector2
    {
        var hitPt:Vector2 = new Vector2(0, 0);
        var pointA:Int = -1;
        var pointB:Int = -1;
        var edgeD:Float = 0;
        var normal:Vector2 = new Vector2(0, 0);

        var closestD:Float = 1000.0;

        for (i in 0...PointMasses.length)
        {
            var tempHit:Vector2;
            var tempNorm:Vector2;
            var tempEdgeD:Float;

            var dist:Float = getClosestPointOnEdge(pt, i, out tempHit, out tempNorm, out tempEdgeD);
            if (dist < closestD)
            {
                closestD = dist;
                pointA = i;
                if (i < (pointMasses.Count - 1))
                    pointB = i + 1;
                else
                    pointB = 0;
                edgeD = tempEdgeD;
                normal = tempNorm;
                hitPt = tempHit;
            }
        }
        
        // return.
        return closestD;
    }*/
    
    // find the distance from a global point in space, to the closest point on a given edge of the body.
    /*public function GetClosestPointOnEdge(point:Vector2, edgeNum:Int):PointOnEdge
    {
        var hitPt:Vector2 = new Vector2(0, 0);
        var normal:Vector2 = new Vector2(0, 0);
        
        var edgeD:Float = 0.0;;
        var dist:Float = 0.0;
        
        var ptA:Vector2 = PointMasses[edgeNum];
        var ptB:Vector2 = null;
        
        if (edgeNum < ()){
            ptB = PointMasses[edgeNum + 1].Position;
        }else{
            ptB = PointMasses[0].Position;
        }
        
        var toP:Vector2 = new Vector2(pt.x - ptA.x, pt.y - ptA.y);
        var E:Vector2 = new Vector2(ptB.x - ptA.x, ptB.y - ptA.y);
        
        // get the length of the edge, and use that to normalize the vector.
        var edgeLength:Float = (float)Math.sqrt((E.x * E.x) + (E.y * E.y));
        if (edgeLength > 0.00001)
        {
            E.x /= edgeLength;
            E.y /= edgeLength;
        }
        
        //normal
        var n:Vector2 = VectorTools.GetPerpendicular(E);
        
        // calculate the distance!
        var x:Float = VectorTools.Dot(toP, E);

        if (x <= 0.0)
        {
            // x is outside the line segment, distance is from pt to ptA.
            //dist = (pt - ptA).Length();
            pt
            dist = VectorTools.Distance(point, ptA);
            hitPt = ptA;
            edgeD = 0;
            normal = n;
        }
        else if (x >= edgeLength)
        {
            // x is outside of the line segment, distance is from pt to ptB.
            //dist = (pt - ptB).Length();
            Vector2.Distance(ref point, ref ptB, out dist);
            hitPt = ptB;
            edgeD = 1f;
            normal = n;
        }
        else
        {
            // point lies somewhere on the line segment.
            Vector3 toP3 = new Vector3();
            toP3.X = toP.X;
            toP3.Y = toP.Y;

            Vector3 E3 = new Vector3();
            E3.X = E.X;
            E3.Y = E.Y;

            //dist = Math.Abs(Vector3.Cross(toP3, E3).Z);
            Vector3.Cross(ref toP3, ref E3, out E3);
            dist = Math.Abs(E3.Z);
            hitPt.X = ptA.X + (E.X * x);
            hitPt.Y = ptA.Y + (E.Y * x);
            edgeD = x / edgeLength;
            normal = n;
        }
    }*/
}