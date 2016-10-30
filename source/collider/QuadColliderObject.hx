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
    public function new(body:Body) 
    {
        var x = body.BoundingBox.X;
        var y = body.BoundingBox.Y;
        var h = body.BoundingBox.Width;
        var w = body.BoundingBox.Height;
        super(x,y,w,h);
        //super(body.BoundingBox.X, body.BoundingBox.Y, body.BoundingBox.Width, body.BoundingBox.Height);
        this.body = body;
    }   
}