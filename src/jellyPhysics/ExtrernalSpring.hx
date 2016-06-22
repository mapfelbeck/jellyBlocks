package jellyPhysics;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ExtrernalSpring extends InternalSpring
{
    public var BodyA:Body;
    public var BodyB:Body;
    
    public function new(bodyA:Body,bodyB:Body, ?pmA:Int, ?pmB:Int, ?damp:Float, ?k:Float, ?d:Float) 
    {
        super(pmA, pmB, damp, k, d);
        BodyA = bodyA;
        BodyB = bodyB;
    }  
}