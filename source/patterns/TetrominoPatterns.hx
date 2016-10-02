package patterns;
import enums.TetrominoShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class TetrominoPatterns
{
    public static var square:Array<Vector2> = [new Vector2(0,0),new Vector2(1,0),new Vector2(1,1),new Vector2(0,1)];
    public static var l:Array<Vector2> = [new Vector2(0,0),new Vector2(0,1),new Vector2(0,2),new Vector2(1,2)];
    public static var reverseL:Array<Vector2> = [new Vector2(1,0),new Vector2(1,1),new Vector2(1,2),new Vector2(0,2)];
    public static var n:Array<Vector2> = [new Vector2(0,0),new Vector2(1,0),new Vector2(1,1),new Vector2(2,1)];
    public static var reverseN:Array<Vector2> = [new Vector2(0,1),new Vector2(1,1),new Vector2(1,0),new Vector2(2,0)];
    public static var t:Array<Vector2> = [new Vector2(0,0),new Vector2(1,0),new Vector2(2,0),new Vector2(1,1)];
    public static var line:Array<Vector2> = [new Vector2(0,0),new Vector2(1,0),new Vector2(2,0),new Vector2(3,0)];
    
    public static function getPattern(shape: TetrominoShape):Array<Vector2>{
        switch(shape){
            case TetrominoShape.L:
                return l;
            case TetrominoShape.ReverseL:
                return reverseL;
            case TetrominoShape.N:
                return n;
            case TetrominoShape.ReverseN:
                return reverseN;
            case TetrominoShape.Line:
                return line;
            case TetrominoShape.Square:
                return square;
            case TetrominoShape.T:
                return t;
        }
    }
}