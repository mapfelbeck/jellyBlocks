package blocks;

import constants.PhysicsDefaults;
import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class DeflatingGameBlock extends GameBlock
{
    public var Deflated(get, null):Bool;    
    function get_Deflated():Bool { return deflates && GasAmount <= 0; }

    private var deflates:Bool;
    private var deflateRate:Float;
    
    private var minPressure:Float = PhysicsDefaults.DeflatedBlockPressure;
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, gasPressure:Float, blockConfig:BlockConfig) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure, blockConfig);
		deflates = config.deflates;
        deflateRate = config.deflateRate;
    }
    override public function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);
        if (deflates && !popping && lifeTime > 0.5 && !IsAsleep)
        {
            GasAmount = Math.max(
                GasAmount - elapsed * PhysicsDefaults.PoppingBlockPressure * deflateRate, minPressure);
        }
    }
}