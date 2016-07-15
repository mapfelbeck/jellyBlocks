package;

import openfl.display.Sprite;
import jellyPhysics.*;
import lime.math.Vector2;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestWorldBase extends Sprite
{
    public var worldRender:DrawDebugWorld;

    public function new() 
    {
        super();
		
    }
    public function getSquareShape(size:Float):ClosedShape{
        var squareShape:ClosedShape = new ClosedShape();
        squareShape.Begin();
        squareShape.AddVertex(new Vector2(0, 0));
        squareShape.AddVertex(new Vector2(size, 0));
        squareShape.AddVertex(new Vector2(size, size));
        squareShape.AddVertex(new Vector2(0, size));
        squareShape.Finish(true);
        return squareShape;
    }
    
    public function getBigSquareShape(size:Float):ClosedShape{
        var bigSquareShape:ClosedShape = new ClosedShape();
        bigSquareShape.Begin();
        bigSquareShape.AddVertex(new Vector2(0, -size*2));
        bigSquareShape.AddVertex(new Vector2(2, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -2));
        bigSquareShape.AddVertex(new Vector2(size*2, 0));
        bigSquareShape.AddVertex(new Vector2(size, 0));
        bigSquareShape.AddVertex(new Vector2(0, 0));
        bigSquareShape.AddVertex(new Vector2(0, -size));
        bigSquareShape.Finish(true);
        return bigSquareShape;
    }
    
    //convert local coordinate on this sprite to world coordinate in the physics world
    public function localToWorld(local:Vector2):Vector2{
        var world:Vector2 = new Vector2(
                                    (local.x - worldRender.offset.x) / worldRender.scale.x,
                                    (local.y - worldRender.offset.y) / worldRender.scale.y);
        return world;
    }
    
    //convert physics world coordinate to local coordinate on this sprite
    public function worldToLocal(world:Vector2):Vector2{
        var local:Vector2 = new Vector2(
                                    (world.x * worldRender.scale.x)+worldRender.offset.x,
                                    (world.y * worldRender.scale.y) + worldRender.offset.y );
        return local;
    }
    
}