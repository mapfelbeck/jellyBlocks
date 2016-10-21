package builders;
import builders.ShapeBuilder;
import enums.PieceType;
import enums.*;
import gamepieces.GamePiece;
import blocks.GameBlock;
import patterns.*;
import constants.PhysicsDefaults;
import jellyPhysics.ClosedShape;
import jellyPhysics.ExternalSpring;
import jellyPhysics.PointMass;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;

class GamePieceBuilder
{
    var shapeBuilder:ShapeBuilder;
    var blockBuilder:GameBlockBuilder;
    var pieceType:PieceType = PieceType.Single;
    var tetrominoShape:TetrominoShape = TetrominoShape.Square;
    var triominoShape:TriominoShape = TriominoShape.Corner;
    var externalDamp:Float = PhysicsDefaults.ExternalSpringDamp;
    var externalK:Float = PhysicsDefaults.ExternalSpringK;
    var location:Vector2 = new Vector2(0, 0);
    
    public function new(){
    }
    
    public function setShapeBuilder(shapeBuilder:ShapeBuilder):GamePieceBuilder
    {
        this.blockBuilder.setShapeBuilder(shapeBuilder);
        return this;
    }
    
    public function getShapeBuilder():ShapeBuilder
    {
        return this.blockBuilder.getShapeBuilder();
    }
    
    public function setBlockBuilder(blockBuilder:GameBlockBuilder):GamePieceBuilder
    {
        this.blockBuilder = blockBuilder;
        return this;
    }
    
    public function getBlockBuilder():GameBlockBuilder
    {
        return this.blockBuilder;
    }
    
    public function setPieceType(type:PieceType):GamePieceBuilder
    {
        pieceType = type;
        return this;
    }
    
    public function setTetrominoShape(shape:TetrominoShape):GamePieceBuilder
    {
        tetrominoShape = shape;
        return this;
    }
    
    public function setTriominoShape(shape:TriominoShape):GamePieceBuilder
    {
        triominoShape = shape;
        return this;
    }
    
    public function setAttachSpringDamp(externalSpringDamp:Float):GamePieceBuilder
    {
        externalDamp = externalSpringDamp;
        return this;
    }
    
    public function setAttachSpringK(externalSpringK:Float):GamePieceBuilder
    {
        externalK = externalSpringK;
        return this;
    }
    
    public function setLocation(location:Vector2):GamePieceBuilder
    {
        this.location = location;
        return this;
    }
    
    public function create():GamePiece
    {
        switch(pieceType){
            case PieceType.Single:
                return buildPiece([new Vector2(0, 0)]);
            case PieceType.Tetromino:
                return buildPiece(TetrominoPatterns.getPattern(tetrominoShape));
            case PieceType.Triomino:
                return buildPiece(TriominoPatterns.getPattern(triominoShape));
            default:
                return null;
        }
    }
    
    private function buildPiece(blockPattern:Array<Vector2>) :GamePiece
    {
        var gamePiece:GamePiece;
        var shapeLocations:Array<Vector2> = new Array<Vector2>();
        var blocks:Array<GameBlock> = new Array<GameBlock>();
        //var shapes:Array<ClosedShape> = new Array<ClosedShape>();
        var springs:Array<ExternalSpring> = new Array<ExternalSpring>();
        
        for (i in 0...blockPattern.length){
            var offsetPattern:Vector2 = VectorTools.Multiply(blockPattern[i], 1.0);
            shapeLocations.push(offsetPattern.add(location));
        }
        
        for (i in 0...shapeLocations.length){
            blockBuilder.setPosition(shapeLocations[i]);
            var gameBlock:GameBlock = blockBuilder.create();
            blocks.push(gameBlock);
        }
        
        
        for (i in 0...blocks.length){
            for (j in i+1...blocks.length){
                AttachBlocks(blocks[i], blocks[j], springs);
            }
        }
        
        gamePiece = new GamePiece(blocks, springs, 9.8);
        gamePiece.AutoDampRate = 0.25;
        
        return gamePiece;
    }
    
    function AttachBlocks(BlockA:GameBlock, BlockB:GameBlock, springs:Array<ExternalSpring>) 
    {
        var numberPMA:Int = BlockA.PointMasses.length;
        var numberPMB:Int = BlockB.PointMasses.length;
        var pmA:PointMass;

        /*if the two block are greater than their size distant then they're
         * diagonal to each other and we don't want to connect them*/
        var blockACenter:Vector2 = BlockA.DerivedPos;
        var blockBCenter:Vector2 = BlockB.DerivedPos;
        
        if (VectorTools.Distance(blockACenter, blockBCenter) > 1.0 + .01)
        {
            return;
        }

        var spring:ExternalSpring;
        for (i in 0...numberPMA)
        {
            pmA = BlockA.PointMasses[i];
            for (j in 0...numberPMB)
            {
                var dist:Vector2 = VectorTools.Subtract(pmA.Position, BlockB.PointMasses[j].Position);
                var absolute:Float = dist.length();

                if (absolute < 0.001)
                {
                    spring = new ExternalSpring(BlockA, BlockB, i, j,
                        0, externalK, externalDamp);

                    springs.push(spring);
                }
            }
        }
    }
}