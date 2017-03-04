package blocks;

import constants.GameConstants;
import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class DeflatingGameBlock extends DampingGameBlock
{
    public var Deflated(get, null):Bool;    
    function get_Deflated():Bool { return deflates && GasAmount <= 0; }

    private var deflates:Bool;
    private var deflateRate:Float;
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, gasPressure:Float, blockConfig:BlockConfig) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure, blockConfig);
		deflates = config.deflates;
        deflateRate = config.deflateRate;
    }
    override public function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);
        if (deflates && !popping && lifeTime > timeTillDamping && !IsAsleep)
        {
            GasAmount = Math.max(
                GasAmount - elapsed * constants.GameConstants.GasPressure * deflateRate, 0);
        }
    }
}