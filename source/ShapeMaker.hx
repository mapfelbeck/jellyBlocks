package;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;
import jellyPhysics.ClosedShape;
/**
 * ...
 * @author 
 */
class ShapeMaker
{
    public static function getPolygonShape(radius:Float, ?count:Int):ClosedShape{
        if (null == count){
            count = 12;
        }
        
        var polygonShape:ClosedShape = new ClosedShape();
        polygonShape.Begin();
        for (i in 0...count){
            var point:Vector2 = new Vector2();
            point.x =  Math.cos(2 * (Math.PI / count) * i) * radius;
            point.y = Math.sin(2 * (Math.PI / count) * i) * radius;
            polygonShape.AddVertex(point);
        }
        
        polygonShape.Finish(true);
        return polygonShape;
    }
    public static function getSquareShape(size:Float):ClosedShape{
        return getRectangleShape(size, size);
    }
    
    public static function getRectangleShape(width:Float, height:Float):ClosedShape{
        var squareShape:ClosedShape = new ClosedShape();
        squareShape.Begin();
        squareShape.AddVertex(new Vector2(0, 0));
        squareShape.AddVertex(new Vector2(width, 0));
        squareShape.AddVertex(new Vector2(width, height));
        squareShape.AddVertex(new Vector2(0, height));
        squareShape.Finish(true);
        return squareShape;
    }
    
    public static function getBigSquareShape(size:Float):ClosedShape{
        var bigSquareShape:ClosedShape = new ClosedShape();
        bigSquareShape.Begin();
        bigSquareShape.AddVertex(new Vector2(0, -size*2));
        bigSquareShape.AddVertex(new Vector2(size, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -size));
        bigSquareShape.AddVertex(new Vector2(size*2, 0));
        bigSquareShape.AddVertex(new Vector2(size, 0));
        bigSquareShape.AddVertex(new Vector2(0, 0));
        bigSquareShape.AddVertex(new Vector2(0, -size));
        bigSquareShape.Finish(true);
        return bigSquareShape;
    }
}