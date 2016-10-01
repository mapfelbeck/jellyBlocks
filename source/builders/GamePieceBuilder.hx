package builders;
import builders.ShapeBuilder;
import enums.PieceType;
import gamepieces.GamePiece;
import jellyPhysics.math.Vector2;

class GamePieceBuilder
{
    var shapeBuilder:ShapeBuilder;
    var blockBuilder:GameBlockBuilder;
    var pieceType:PieceType;
    var pieceShape:EnumValue;
    
    public function new(){
        
    }
    
    public function setShapeBuilder(shapeBuilder:ShapeBuilder):GamePieceBuilder
    {
        this.shapeBuilder = shapeBuilder;
        return this;
    }
    
    public function setBlockBuilder(blockBuilder:GameBlockBuilder):GamePieceBuilder
    {
        this.blockBuilder = blockBuilder;
        return this;
    }
    
    public function setPieceType(type:PieceType):GamePieceBuilder
    {
        pieceType = type;
        return this;
    }
    
    public function setPieceShape(shape:EnumValue):GamePieceBuilder
    {
        pieceShape = shape;
        return this;
    }
}