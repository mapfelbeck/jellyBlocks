package patterns;
import enums.TriominoShape;
import flixel.math.FlxRandom;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author ...
 */
class TriominoPatterns
{
    public static var corner:Array<Vector2> = [new Vector2(0,0),new Vector2(0,1),new Vector2(1,1)];
    public static var line:Array<Vector2> = [new Vector2(0,0),new Vector2(1,0),new Vector2(2,0)];
    
    public static function getPattern(shape: TriominoShape):Array<Vector2>{
        switch(shape){
            case TriominoShape.Corner:
                return corner;
            case TriominoShape.Line:
                return line;
            case TriominoShape.Random:
                var random:FlxRandom = new FlxRandom();
                var type:Int = random.int(0, 1);
                var result:Array<Vector2>  = null;
                if (type == 0){
                    result = line;
                }else{
                    result = corner;
                }
                return result;
        }
    }
}