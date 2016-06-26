package src.jellyPhysics;
import haxe.Constraints.Function;

/**
 * ...
 * @author Michael Apfelbeck
 */
class MaterialPair
{
    public var Collide:Bool

    // Amount of "bounce" when collision occurs. value range [0,1]. 0 == no bounce, 1 == 100% bounce
    public var Elasticity:Float;

    // Amount of friction.  Value range [0,1].  0 == no friction, 1 == 100% friction, will stop on contact.
    public var Friction:Float;

    // Collision filter function.
    public var CollisionFilter:Function;
    public function new() 
    {
        
    }    
}