package builders;
import blocks.GameBlock;
import builders.ShapeBuilder;
import constants.PhysicsDefaults;
import enums.*;
import enums.PieceType;
import flixel.math.FlxRandom;
import gamepieces.GamePiece;
import jellyPhysics.ExternalSpring;
import jellyPhysics.PointMass;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;
import patterns.*;

class GamePieceBuilder
{
    var random:FlxRandom = new FlxRandom();
    var shapeBuilder:ShapeBuilder;
    var blockBuilder:GameBlockBuilder;
    var pieceType:PieceType = PieceType.Single;
    var tetrominoShape:TetrominoShape = TetrominoShape.Square;
    var triominoBuildShape:TriominoShape = TriominoShape.Corner;
    var triominoFinalShape:TriominoShape = TriominoShape.Corner;
    var externalDamp:Float = PhysicsDefaults.ExternalSpringDamp;
    var externalK:Float = PhysicsDefaults.ExternalSpringK;
    var location:Vector2 = new Vector2(0, 0);
    var rotation:Float = 0;
    var scale:Float = 1.0;
    
    var idCounter:Int = 0;
    
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
    
    public function setTriominoBuildShape(shape:TriominoShape):GamePieceBuilder
    {
        triominoBuildShape = shape;
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
    
    public function setScale(scale:Float):GamePieceBuilder
    {
        this.scale = scale;
        blockBuilder.setScale(new Vector2(scale, scale));
        return this;
    }
    
    public function setRotation(rotation:Float):GamePieceBuilder{
        this.rotation = rotation;
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
                if (triominoBuildShape == TriominoShape.Random){
                    var type:Int = random.int(0, 1);
                    var result:Array<Vector2>  = null;
                    if (type == 0){
                        triominoFinalShape = TriominoShape.Line;
                    }else{
                        triominoFinalShape = TriominoShape.Corner;
                    }
                }else{
                    triominoFinalShape = triominoBuildShape;
                }
                return buildPiece(TriominoPatterns.getPattern(triominoFinalShape));
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
        
        scale = blockBuilder.getScale().x;
        for (i in 0...blockPattern.length){
            var offsetPattern:Vector2 = VectorTools.Multiply(blockPattern[i], scale);
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
        
        gamePiece = new GamePiece(blocks, springs, 9.8, idCounter++);
        gamePiece.Shape = triominoFinalShape;
        if(rotation != 0){
            rotatePiece(gamePiece, rotation);
        }
        
        return gamePiece;
    }
    
    function rotatePiece(piece:GamePiece, rotationAmount:Float) 
    {
        var s:Float = Math.sin(rotationAmount);
        var c:Float = Math.cos(rotationAmount);
        var center:Vector2 = piece.GamePieceCenter();
        
        for (i in 0...piece.Blocks.length){
            for (j in 0...piece.Blocks[i].PointMasses.length){
                var p:Vector2 = piece.Blocks[i].PointMasses[j].Position;
                
                var xNew:Float = c * (p.x - center.x) - s * (p.y - center.y);
                var yNew:Float = s * (p.x - center.x) + c * (p.y - center.y);
                
                piece.Blocks[i].PointMasses[j].Position.x = xNew + center.x;
                piece.Blocks[i].PointMasses[j].Position.y = yNew + center.y;
            }
        }
    }
    
    private function AttachBlocks(BlockA:GameBlock, BlockB:GameBlock, springs:Array<ExternalSpring>) 
    {
        var numberPMA:Int = BlockA.PointMasses.length;
        var numberPMB:Int = BlockB.PointMasses.length;
        var pmA:PointMass;

        /*if the two block are greater than their size distant then they're
         * diagonal to each other and we don't want to connect them*/
        var blockACenter:Vector2 = BlockA.DerivedPos;
        var blockBCenter:Vector2 = BlockB.DerivedPos;
        
        if (VectorTools.Distance(blockACenter, blockBCenter) > scale + .01)
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

                if (absolute < 0.1)
                {
                    spring = new ExternalSpring(BlockA, BlockB, i, j,
                        0, externalK, externalDamp);

                    springs.push(spring);
                }
            }
        }
    }
}