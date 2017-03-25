package blocks;

import constants.GameConstants;
import jellyPhysics.ClosedShape;
import jellyPhysics.PointMass;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;

/**
 * ...
 * @author 
 */
class FreezingGameBlock extends DeflatingGameBlock
{
    private var FreezeWaitTimer:Float;
    
    public var IsFrozen(get, null):Bool;
    public function get_IsFrozen(){
        return GetPointMass(0).Mass == Math.POSITIVE_INFINITY;
    }
    
    private var freezeVelocityThreshhold:Float;
    private var timeTillFreeze:Float;
    private var freezeWaitTimerLength:Float;
    private var freezeDistortionThreshhold:Float;
    
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, gasPressure:Float, blockConfig:BlockConfig) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure, blockConfig);
		Freezeable = true;
        FreezeWaitTimer = 0.0;
        freezeVelocityThreshhold = config.freezeVelocityThreshhold;
        timeTillFreeze = config.timeTillFreeze;
        freezeWaitTimerLength = config.freezeWaitTimerLength;
        freezeDistortionThreshhold = config.freezeDistortionThreshhold;
    }
    
    override public function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);

        if (!popping && Deflated && !IsAsleep && lifeTime > timeTillFreeze && Freezeable)
        {
            FreezeWaitTimer += elapsed;
            if (FreezeWaitTimer > freezeWaitTimerLength)
            {
                if (!IsFrozen && CanFreeze())
                {
                    FreezeBlock();
                }
                else
                {
                    FreezeWaitTimer = 0;
                }
            }
        }
        else if (popping && IsFrozen)
        {
            UnFreezeBlock();
        }
        if (IsAsleep)
        {
            timeFrozen += elapsed;
        }
    }

    private function UnFreezeBlock():Bool
    {
        if (!IsAsleep) { return false; }

        timeFrozen = 0;
        IsAsleep = false;
        for (i in 0...PointMasses.length)
        {
            var mass:PointMass = PointMasses[i];
            mass.Mass = constants.GameConstants.MassPerPoint;
            mass.Force = new Vector2(0, 0);
            mass.Velocity = new Vector2(0, 0);
        }
        return true;
    }

    private function FreezeBlock():Void
    {
        IsAsleep = true;
        for (i in 0...PointMasses.length)
        {
            var mass:PointMass = PointMasses[i];

            ///Sub-Pixel Distance Hack
            ///In the freeze game type it's possile for pieces of the
            ///same color to lock in place less than a pixel away,
            ///looking like they're touching when in the physcics sim
            ///they aren't, leading to match-3 combos that look good
            ///but are invalid, this hack moves the pointmasses out a tiny
            ///bit when they lock, largly eliminating the problem
            var pointMassDirectionFromDerived:Vector2;
            pointMassDirectionFromDerived = VectorTools.Subtract(mass.Position, DerivedPos);
            pointMassDirectionFromDerived.normalize();

            mass.Position=VectorTools.Add(mass.Position, VectorTools.Multiply( pointMassDirectionFromDerived, .05));
            ///End Hack

            mass.Mass = Math.POSITIVE_INFINITY;
        }
    }

    private function CanFreeze():Bool
    {
        var result:Bool = true;
        //cant't freeze if the block isn't touching anything
        if(!CollidedThisFrame || Kinematic){
            result = false;
        }
        //can't freeze if the block is moving too fast
        else if (DerivedVel.lengthSquared() > freezeVelocityThreshhold)
        {
            result = false;
        }
        else
        {
            // this checks to see how distorted the block is, if the block is too
            // smashed out of shape we wait and freeze it later
            // this keeps blocks from freezing in ugly, twisted shapes
            var accumulatedDistortion:Float = 0;
            var distortion:Vector2 = new Vector2(0, 0);
            for (i in 0...PointMasses.length)
            {
                distortion = VectorTools.Subtract( PointMasses[i].Position, GlobalShape[i]);
                accumulatedDistortion += distortion.length();
            }
            if (accumulatedDistortion >= freezeDistortionThreshhold)
            {
                result = false;
            }
        }
        return result;
    }

    override public function CollisionlessFrame()
    {
        super.CollisionlessFrame();

        if (IsFrozen)
        {
            if (UnFreezeBlock())
            {
                FreezeWaitTimer -= freezeWaitTimerLength;
            }
        }
    }

    public function UnFreezeFor(seconds:Float):Void
    {
        UnFreezeBlock();
        FreezeWaitTimer -= seconds;
    }

    override public function ResetExternalForces():Void
    {
        super.ResetExternalForces();
        //CollidedThisFrame = false;
    }
}