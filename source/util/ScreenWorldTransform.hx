package util;
import jellyPhysics.AABB;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ScreenWorldTransform 
{
    public var scale:Vector2 = new Vector2(0, 0);
    public var offset:Vector2 = new Vector2(0, 0);
    
    public var bounds:AABB;
    public var overscan:Int;
    public var screenWidth:Int;
    public var screenHeight:Int;
    
    public function new(worldBounds:AABB, screenWidth:Int, screenHeight:Int, overscan:Int) 
    {
        bounds = worldBounds;
        this.overscan = overscan;
        this.screenWidth = screenWidth;
        this.screenHeight = screenHeight;
        setRenderAndOffset();
    }  
    
    /*private function worldToLocalX(x:Int):Float{
        var worldX:Float = x;
        return (worldX - offset.x) / scale.x;
    }
    
    private function worldToLocalY(y:Int):Float{
        var worldY:Float = y;
        return (worldY - offset.y) / scale.y;
    }*/
    
    public function localToWorldX(x:Float):Float{
        return Math.round((x * scale.x) + offset.x);
    }
    
    public function localToWorldY(y:Float):Float{
        return Math.round((y * scale.y) + offset.y);
    }
    
    private var worldWidth:Float;
    private var worldHeight:Float;
    private var backgroundSize:Vector2;
    private function setRenderAndOffset():Void{
        worldWidth = bounds.LR.x - bounds.UL.x;
        worldHeight = bounds.LR.y - bounds.UL.y;
        backgroundSize = new Vector2(screenWidth - (2 * overscan), screenHeight - (2 * overscan));
        offset.x = screenWidth / 2;
        offset.y = screenHeight / 2;
        
        var hScale:Float = backgroundSize.x / worldWidth;
        var wScale:Float = backgroundSize.y / worldHeight;
        scale.x = Math.min(hScale, wScale);
        scale.y = Math.min(hScale, wScale);
    }
    
}