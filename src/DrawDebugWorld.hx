package;
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
    
    private var renderTarget:Sprite;
    private var physicsWorld:World;
    
    public function new(sprite:Sprite, world:World) 
    {
        renderTarget = sprite;
        physicsWorld = world;
        backgroundColor = 0x000000;
        
        renderSize = new Vector2(sprite.stage.stageWidth - sprite.x, sprite.stage.stageHeight - sprite.y);
    }
    
    public function Draw():Void
    {
        renderTarget.graphics.clear();
        renderTarget.graphics.beginFill(backgroundColor);
        renderTarget.graphics.drawRect(0, 0, renderSize.x, renderSize.y);
        renderTarget.graphics.endFill();
    }
}