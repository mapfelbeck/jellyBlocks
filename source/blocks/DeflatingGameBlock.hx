package blocks;

import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class DeflatingGameBlock extends DampingGameBlock
{
    public var Deflated(get, null):Bool;    
    function get_Deflated():Bool { return GasAmount <= 0; }

    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, gasPressure:Float, blockConfig:BlockConfig) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure, blockConfig);
		
    }
    override public function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);
        if (!popping && lifeTime > config.timeTillDamping && !IsAsleep)
        {
            GasAmount = Math.max(
                GasAmount - elapsed * GameConstants.GasPressure * config.deflateRate, 0);
        }
    }
}