package blocks;

import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class DeflatingGameBlock extends DampingGameBlock
{

    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, gasPressure:Float) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure);
		
    }
    
}