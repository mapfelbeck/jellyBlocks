package collider;

import flixel.FlxObject;
import jellyPhysics.Body;

/**
 * ...
 * @author 
 */
class QuadColliderObject extends FlxObject
{
    public var body:Body;
    public function new(x:Float,y:Float,h:Float,w:Float,body:Body) 
    {        
        super(x, y, w, h);
        this.body = body;
    }   
}