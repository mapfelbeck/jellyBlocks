package;
import jellyPhysics.*;
import lime.math.Vector2;
import openfl.display.Sprite;
import jellyPhysics.World;

/**
 * ...
 * @author Michael Apfelbeck
 */
class DrawDebugWorld
{
    public var renderSize:Vector2;
    public var backgroundColor:Int;
    
    private var render:Sprite;
    private var world:World;
    
    private var offset:Vector2 = new Vector2(0, 0);
    private var scale:Vector2 = new Vector2(20.0, 20.0);
    
    public function new(sprite:Sprite, physicsWorld:World) 
    {
        render = sprite;
        world = physicsWorld;
        backgroundColor = 0x000000;
        
        renderSize = new Vector2(sprite.stage.stageWidth - (2 * sprite.x), sprite.stage.stageHeight - (2 * sprite.y));
        offset.x = renderSize.x / 2;
        offset.y = renderSize.y / 2;
    }
    
    public function Draw():Void
    {
        render.graphics.clear();
        render.graphics.beginFill(backgroundColor);
        render.graphics.drawRect(0, 0, renderSize.x, renderSize.y);
        render.graphics.endFill();
        
        render.graphics.lineStyle(2, 0x708090);
        render.graphics.drawRect(16, 16, 16, 16);
        render.graphics.drawRect(0, 0, 64, 64);
        
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            drawAABB(body.BoundingBox);
            drawBodyShape(body.GlobalShape);
        }
    }
    
    function drawBodyShape(shape:Array<Vector2>) 
    {
        render.graphics.lineStyle(2, 0x0000FF);
        var vertSz:Float = 4;
        for (i in 0...shape.length){
            var vert:Vector2 = shape[i];
            render.graphics.drawRect((vert.x * scale.x) + offset.x - (vertSz / 2), (vert.y * scale.y) + offset.y - (vertSz / 2), vertSz, vertSz);
        }
    }
    
    function drawAABB(box:AABB) 
    {
        render.graphics.lineStyle(0, 0xFFFFFF);
                
        render.graphics.drawRect((box.UL.x * scale.x) + offset.x, (box.UL.y * scale.y) + offset.y, 
                                 box.Width * scale.x, box.Height * scale.y);
    }
}