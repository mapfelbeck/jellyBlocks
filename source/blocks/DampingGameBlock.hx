package blocks;

import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class DampingGameBlock extends GameBlock
{
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, 
    angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, 
    bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, 
    edgeSpringDamp:Float, gasPressure:Float, blockConfig:BlockConfig) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure, blockConfig);
    }
    
    override public function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);
        if (lifeTime > config.timeTillDamping)
        {
            var dampingStep:Float = elapsed * config.dampingRate;
            VelocityDamping = Math.min(VelocityDamping + dampingStep, config.dampingMax);
        }
    }
}