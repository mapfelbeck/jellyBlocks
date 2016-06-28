package jellyPhysics;

import haxe.Constraints.Function;
import jellyPhysics.ClosedShape;
import jellyPhysics.PointOnEdge;
import lime.math.Vector2;
import lime.math.Vector4;
import openfl.utils.Object;
import jellyPhysics.PointMassRef;

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
    public function GetClosestPoint(point:Vector2):PointOnEdge
    {
        //var hitPt:Vector2 = new Vector2(0, 0);
        //var pointA:Int = -1;
        //var pointB:Int = -1;
        //var edgeD:Float = 0;
        var normal:Vector2 = new Vector2(0, 0);

        var closestD:Float = 1000.0;

        var closestPoint:PointOnEdge = null;
        
        for (i in 0...PointMasses.length)
        {
            //var tempHit:Vector2;
            //var tempNorm:Vector2;
            //var tempEdgeD:Float;

            var pointOnEdge:PointOnEdge = GetClosestPointOnEdge(point, i);
            if (pointOnEdge.Distance < closestD)
            {
                closestD = pointOnEdge.Distance;
                closestPoint = pointOnEdge;
                //pointA = i;
                /*if (i < (pointMasses.Count - 1))
                    pointB = i + 1;
                else
                    pointB = 0;*/
                //edgeD = pointOnEdge.EdgeDistance;
                //normal = pointOnEdge.Normal;
                //hitPt = pointOnEdge.Point;
            }
        }
        
        return closestPoint;
    }
    
    // find the distance from a global point in space, to the closest point on a given edge of the body.
    public function GetClosestPointOnEdge(point:Vector2, edgeNum:Int):PointOnEdge
    {
        var hitPt:Vector2 = new Vector2(0, 0);
        var normal:Vector2 = new Vector2(0, 0);
        
        var edgeD:Float = 0.0;
        var dist:Float = 0.0;
        
        var ptA:Vector2 = PointMasses[edgeNum].Position;
        var ptB:Vector2 = null;
        
        if (edgeNum < (PointMasses.length - 1)){
            ptB = PointMasses[edgeNum + 1].Position;
        }else{
            ptB = PointMasses[0].Position;
        }
        
        var toP:Vector2 = new Vector2(point.x - ptA.x, point.y - ptA.y);
        var E:Vector2 = new Vector2(ptB.x - ptA.x, ptB.y - ptA.y);
        
        // get the length of the edge, and use that to normalize the vector.
        var edgeLength:Float = Math.sqrt((E.x * E.x) + (E.y * E.y));
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
            dist = VectorTools.Distance(point, ptA);
            hitPt = ptA;
            edgeD = 0;
            normal = n;
        }
        else if (x >= edgeLength)
        {
            // x is outside of the line segment, distance is from pt to ptB.
            //dist = (pt - ptB).Length();
            dist = VectorTools.Distance(point, ptB);
            hitPt = ptB;
            edgeD = 1;
            normal = n;
        }
        else
        {
            // point lies somewhere on the line segment.
            var toP4:Vector4 = VectorTools.Vec4FromVec2(toP);

            var E4:Vector4 = VectorTools.Vec4FromVec2(E);

            //dist = Math.Abs(Vector3.Cross(toP3, E3).Z);
            E4 = toP4.crossProduct(E4);

            dist = Math.abs(E4.z);
            hitPt.x = ptA.x + (E.x * x);
            hitPt.y = ptA.y + (E.y * x);
            edgeD = x / edgeLength;
            normal = n;
        }
        
        return new PointOnEdge(edgeNum, dist, hitPt, normal, edgeD);
    }
    
    // find the distance from a global point in space to the closest point 
    // on a given edge of the body. The distance parameter in the return structure
    //is the square of the distance
    public function GetClosestPointOnEdgeSquared(point:Vector2, edgeNum:Int):PointOnEdge
    {
        var hitPt:Vector2 = new Vector2(0, 0);
        var normal:Vector2 = new Vector2(0, 0);
        
        var edgeD:Float = 0.0;
        var dist:Float = 0.0;
        
        var ptA:Vector2 = PointMasses[edgeNum].Position;
        var ptB:Vector2 = null;
        
        if (edgeNum < (PointMasses.length - 1)){
            ptB = PointMasses[edgeNum + 1].Position;
        }else{
            ptB = PointMasses[0].Position;
        }
        
        var toP:Vector2 = new Vector2(point.x - ptA.x, point.y - ptA.y);
        var E:Vector2 = new Vector2(ptB.x - ptA.x, ptB.y - ptA.y);
        
        // get the length of the edge, and use that to normalize the vector.
        var edgeLength:Float = Math.sqrt((E.x * E.x) + (E.y * E.y));
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
            dist = VectorTools.DistanceSquared(point, ptA);
            hitPt = ptA;
            edgeD = 0;
            normal = n;
        }
        else if (x >= edgeLength)
        {
            // x is outside of the line segment, distance is from pt to ptB.
            //dist = (pt - ptB).Length();
            dist = VectorTools.DistanceSquared(point, ptB);
            hitPt = ptB;
            edgeD = 1;
            normal = n;
        }
        else
        {
            // point lies somewhere on the line segment.
            var toP4:Vector4 = VectorTools.Vec4FromVec2(toP);

            var E4:Vector4 = VectorTools.Vec4FromVec2(E);

            //dist = Math.Abs(Vector3.Cross(toP3, E3).Z);
            E4 = toP4.crossProduct(E4);

            dist = E4.z * E4.z;
            hitPt.x = ptA.x + (E.x * x);
            hitPt.y = ptA.y + (E.y * x);
            edgeD = x / edgeLength;
            normal = n;
        }
        
        return new PointOnEdge(edgeNum, dist, hitPt, normal, edgeD);
    }
    
    // Given a global point, find the closest PointMass in this body.
    public function GetClosestPointMass(point:Vector2):PointMassRef
    {
        var closestSquared:Float = 100000.0;
        var closestIndex:Int = -1;
        
        for (i in 0...PointMasses.length)
        {
            var diff:Vector2 = VectorTools.Subtract(point, PointMasses[i].Position);
            var tempDist:Float = VectorTools.LengthSquared(diff);
            if (tempDist < closestSquared)
            {
                closestSquared = tempDist;
                closestIndex = i;
            }
        }
        return new PointMassRef(closestIndex, Math.sqrt(closestSquared));
    }
    
    // Add a global force on this body.
    // point: location of the force in global space
    // force: direction and intensity of the force in global space
    public function AddGlobalForce(point:Vector2, force:Vector2):Void
    {
        var R:Vector2 = VectorTools.Subtract(DerivedPos, point);
        
        var Rv4:Vector4 = VectorTools.Vec4FromVec2(R);
        var forcev4:Vector4 = VectorTools.Vec4FromVec2(force);        
        var torqueF:Float = Rv4.crossProduct(forcev4).z;
        
        for (i in 0...PointMasses.length)
        {
            var toPoint:Vector2 = VectorTools.Subtract(PointMasses[i].Position, DerivedPos);
            var torque:Vector2 = VectorTools.RotateVector(toPoint, -Math.PI / 2.0);
            PointMasses[i].Force = VectorTools.Add(PointMasses[i].Force, VectorTools.Multiply(torque, torqueF));
            PointMasses[i].Force = VectorTools.Add(PointMasses[i].Force, force);
        }
    }
    
    // Derive the global position and angle of this body, based on the average of all the points.
    // This updates the DerivedPosision, DerivedAngle, and DerivedVelocity properties.
    // This is called by the World object each Update(), so usually a user does not need to call this.
    // Instead access the DerivedPosition, DerivedAngle, DerivedVelocity, and DerivedOmega properties.    
    /*public function DerivePositionAndAngle(float elaspsed):Void
    {
        // no need it this is a static body, or kinematically controlled.
        if (IsStatic || Kinematic || IsAsleep){
            return;
        }

        // find the geometric center.
        var center:Vector2 = new Vector2(0, 0);

        var vel:Vector2 = new Vector2(0, 0);

        for (i in 0...pointMasses.Count)
        {
            center.x += PointMasses[i].Position.x;
            center.y += PointMasses[i].Position.y;

            vel.x += PointMasses[i].Velocity.x;
            vel.y += PointMasses[i].Velocity.y;
        }

        center.x /= PointMasses.Count;
        center.y /= PointMasses.Count;

        vel.X /= PointMasses.Count;
        vel.Y /= PointMasses.Count;

        DerivedPos = center;
        DerivedVel = vel;

        // find the average angle of all of the masses.
        var angle:Float = 0;
        var originalSign:Int = 1;
        var originalAngle:Float = 0;
        for (i in 0...PointMasses.Count)
        {
            var baseNorm:Vector2 = new Vector2(BaseShape.LocalVertices[i].x, BaseShape.LocalVertices[i].y);
            baseNorm.normalize(1.0);

            Vector2 curNorm = new Vector2();
            curNorm.X = pointMasses[i].Position.X - derivedPos.X;
            curNorm.Y = pointMasses[i].Position.Y - derivedPos.Y;
            Vector2.Normalize(ref curNorm, out curNorm);

            float dot;
            Vector2.Dot(ref baseNorm, ref curNorm, out dot);
            if (dot > 1.0f) { dot = 1.0f; }
            if (dot < -1.0f) { dot = -1.0f; }

            float thisAngle = (float)Math.Acos(dot);
            if (!VectorTools.isCCW(ref baseNorm, ref curNorm)) { thisAngle = -thisAngle; }

            if (i == 0)
            {
                originalSign = (thisAngle >= 0.0f) ? 1 : -1;
                originalAngle = thisAngle;
            }
            else
            {
                float diff = (thisAngle - originalAngle);
                int thisSign = (thisAngle >= 0.0f) ? 1 : -1;

                if ((Math.Abs(diff) > Math.PI) && (thisSign != originalSign))
                {
                    thisAngle = (thisSign == -1) ? ((float)Math.PI + ((float)Math.PI + thisAngle)) : (((float)Math.PI - thisAngle) - (float)Math.PI);
                }
            }

            angle += thisAngle;
        }

        angle /= pointMasses.Count;
        derivedAngle = angle;

        // now calculate the derived Omega, based on change in angle over time.
        float angleChange = (derivedAngle - lastAngle);
        if (Math.Abs(angleChange) >= Math.PI)
        {
            if (angleChange < 0f)
                angleChange = angleChange + (float)(Math.PI * 2);
            else
                angleChange = angleChange - (float)(Math.PI * 2);
        }

        derivedOmega = angleChange / elaspsed;

        lastAngle = derivedAngle;
    }*/
        
    public static function BodyCollide(bodyA:Body, bodyB:Body, penThreshhold:Float):Array<BodyCollisionInfo>
    {
        if (null == bodyA || null == bodyB){
            trace("BodyCollide given at least one null arg.");
            return null;
        }
        
        var infoList:Array<BodyCollisionInfo> = new Array<BodyCollisionInfo>();
        var bApmCount:Int = bodyA.PointMasses.length;
        var bBpmCount:Int = bodyB.PointMasses.length;

        var boxB:AABB = bodyB.BoundingBox;
        
        // check all PointMasses on bodyA for collision against bodyB.
        // if there is a collision, return detailed info.
        var infoAway:BodyCollisionInfo = new BodyCollisionInfo();
        var infoSame:BodyCollisionInfo = new BodyCollisionInfo();
        var BodyCollisionInfoAwayCreated:Bool = false;
        var BodyCollisionInfoSameCreated:Bool = false;
        
        for (i in 0...bApmCount)
        {
            BodyCollisionInfoAwayCreated = false;
            BodyCollisionInfoSameCreated = false;
            
            var pt = bodyA.PointMasses[i].Position;

            // early out - if this point is outside the bounding box for bodyB, skip it!
            if (!boxB.ContainsPoint(pt))
                continue;

            // early out - if this point is not inside bodyB, skip it!
            if (!bodyB.Contains(pt))
                continue;
        
        
            var prevPt:Int = (i > 0) ? i - 1 : bApmCount - 1;
            var nextPt:Int = (i < bApmCount - 1) ? i + 1 : 0;

            var prev:Vector2 = bodyA.PointMasses[prevPt].Position;
            var next:Vector2 = bodyA.PointMasses[nextPt].Position;

            // now get the normal for this point. (NOT A UNIT VECTOR)
            var fromPrev:Vector2 = VectorTools.Subtract(pt, prev);

            var toNext:Vector2 = VectorTools.Subtract(next, pt);

            var ptNorm:Vector2 = VectorTools.Add(fromPrev, toNext);
            ptNorm = VectorTools.GetPerpendicular(ptNorm);

            // this point is inside the other body.  now check if the edges 
            // on either side intersect with and edges on bodyB.          
            var closestAway:Float = 100000.0;
            var closestSame:Float = 100000.0;
            
            infoAway.Clear();
            infoAway.BodyA = bodyA;
            infoAway.BodyAPointMass = i;
            infoAway.BodyB = bodyB;
            
            infoSame.Clear();
            infoAway.BodyA = bodyA;
            infoAway.BodyAPointMass = i;
            infoAway.BodyB = bodyB;
            
            var found:Bool = false;
            
            var b1:Int;
            var b2:Int;
            for (j in 0...bBpmCount)
            {
                var hitPt:Vector2 = null;
                var norm:Vector2;
                var edgeD:Float = -1.0;

                b1 = j;

                if (j < bBpmCount - 1)
                    b2 = j + 1;
                else
                    b2 = 0;

                /*
                // quick test of distance to each point on the edge, if both are greater than current mins, we can skip!
                // FIXME: figure out why this optimization fails in some cases
                var pt1:Vector2 = bB.PointMasses[b1].Position;
                var pt2:Vector2 = bB.PointMasses[b2].Position;

                var distToA:Float = ((pt1.X - pt.X) * (pt1.X - pt.X)) + ((pt1.Y - pt.Y) * (pt1.Y - pt.Y));
                var distToB:Float = ((pt2.X - pt.X) * (pt2.X - pt.X)) + ((pt2.Y - pt.Y) * (pt2.Y - pt.Y));

                
                if ((distToA > closestAway) && (distToA > closestSame) && (distToB > closestAway) && (distToB > closestSame))
                {
                    continue;
                }*/

                // test against this edge.
                var bBPoint =  bodyB.GetClosestPointOnEdgeSquared(pt, j);
                var dist:Float = bBPoint.Distance;
                norm = bBPoint.Normal;
                edgeD = bBPoint.EdgeDistance;
                hitPt = bBPoint.Point;
                
                // only perform the check if the normal for this edge is facing AWAY from the point normal.
                var dot:Float = VectorTools.Dot(ptNorm, norm);

                if (dot <= 0.0)
                {
                    if (dist < closestAway)
                    {
                        closestAway = dist;
                        infoAway.BodyBPointMassA = b1;
                        infoAway.BodyBPointMassB = b2;
                        infoAway.EdgeD = edgeD;
                        infoAway.HitPoint = hitPt;
                        infoAway.Normal = norm;
                        infoAway.Penetration = dist;
                        found = true;
                        BodyCollisionInfoAwayCreated = true;
                    }
                }
                else
                {
                    if (dist < closestSame)
                    {
                        closestSame = dist;
                        infoSame.BodyBPointMassA = b1;
                        infoSame.BodyBPointMassB = b2;
                        infoSame.EdgeD = edgeD;
                        infoSame.HitPoint = hitPt;
                        infoSame.Normal = norm;
                        infoSame.Penetration = dist;
                        BodyCollisionInfoSameCreated = true;
                    }
                }
            }
            
            // we've checked all edges on BodyB.  add the collision info to the stack.
            if ((found) && (closestAway > penThreshhold) && (closestSame < closestAway) &&
                BodyCollisionInfoSameCreated)
            {
                infoSame.Penetration = Math.sqrt(infoSame.Penetration);
                infoList.push(infoSame);
            }
            else if (BodyCollisionInfoAwayCreated)
            {
                infoAway.Penetration = Math.sqrt(infoAway.Penetration);
                infoList.push(infoAway);
            }
        }
        
        return infoList;
    }
}