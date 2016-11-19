package blocks;

import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class DampingGameBlock extends GameBlock
{
    private var timeTillDamping:Float;
    private var dampingRate:Float;
    private var dampingMax:Float;
    private var dampingInc:Float;

    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, 
    angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, 
    bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, 
    edgeSpringDamp:Float, gasPressure:Float, blockConfig:BlockConfig) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure, blockConfig);
        dampingMax = config.dampingMax;
        dampingRate = config.dampingRate;
        timeTillDamping = config.timeTillDamping;
        dampingInc = config.dampingInc;
        VelocityDamping = dampingRate;
    }
    
    override public function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);
        if (lifeTime > timeTillDamping)
        {
            var dampingStep:Float = dampingInc * elapsed * dampingRate;
            VelocityDamping = Math.min(VelocityDamping + dampingStep, dampingMax);
        }else{
            VelocityDamping = dampingRate;
        }
    }
}