package jellyPhysics;
import lime.math.Rectangle;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class AABB
{
    public var UL:Vector2;
    public var LR:Vector2;
    
    public var X(default, UL.x):Float:
    public var Y(default, UL.y):Float;
    public var Height(default, LR.y - UL.y):Float;
    public var Width(default, LR.x - UL.x):Float;
    
    public var Size(default, new Vector2(LR.x - UL.x, LR.y - UL.y)):Vector2;
    
    public var Valid : Bool;
    
    public function new(?upperLeft:Vector2, ?lowerRight:Vector2) 
    {
        Set((null == upperLeft) ? new Vector2(0, 0) : upperLeft,
            (null == lowerRight) ? new Vector2(0, 0) : lowerRight);
    }
    
    public function Set(upperLeft:Vector2, lowerRight:Vector2):Void
    {
        UL = upperLeft;
        LR = lowerRight;

        if (UL.x == RL.x == 0 || UL.y==LR.y==0){
            Valid = false;
        }else
        {
            Valid = true;
        }
    }
    
    public function Clear():Void
    {
        UL.x = UL.y = RL.x = LR.y = 0;
        Valid = false;
    }
    
    public function ExpandToInclude(pt:Vector2):Void
    {
        if (Valid)
        {
            if (pt.x < UL.x)
            { 
                UL.x = pt.x; 
                
            }else if (pt.x > LR.x)
            {
                LR.x = pt.x;
            }

            if (pt.y < UL.y)
            {
                UL.y = pt.y;
            }else if (pt.y > LR.y)
            {
                LR.y = pt.y;                
            }
        }else
        {
            UL = new Vector2(pt.x, pt.y);
            LR = new Vector2(pt.x, pt.y);
            Valid = true;
        }
    }
    
    public function ContainsPoint(pt):Bool
    {
        if (!Valid)
        {
            return false;
        }
        
        return ((pt.x >= UL.x) && (pt.x <= LR.x) && (pt.y >= UL.y) && (pt.y <= LR.y));
    }
    
    public function ContainsAABB(box: AABB):Bool
    {
        return (UL.y <= box.UL.y && UL.x <= box.UL.x &&
                LR.y >= box.LR.y && LR.x >= box.LR.x);
    }

    public function ContainsX(x:Float):Bool
    {
        return (UL.x <= X && LR.x >= X);
    }

    public function ContainsY(float Y):Bool
    {
        return (UL.y <= Y && LR.y >= Y);
    }

    public function Intersects(box:AABB):Bool
    {
        return (((UL.x <= box.LR.x) && (LR.x >= box.UL.x)) &&
                ((UL.y <= box.LR.y) && (LR.y >= box.UL.y)));
    }

    public function Within(box:AABB, overlap:Float):Bool
    {
        return (((UL.x + overlap <= box.LR.x + overlap) && (LR.x + overlap >= box.UL.x + overlap)) &&
                ((UL.y + overlap <= box.LR.y + overlap) && (LR.y + overlap >= box.UL.y + overlap)));
    }
}