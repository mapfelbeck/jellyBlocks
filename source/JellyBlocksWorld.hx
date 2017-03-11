package;

import collider.QuadTreeCollider;
import constants.GameConstants;
import flixel.math.FlxRandom;
import gamepieces.GamePiece;
import jellyPhysics.AABB;
import jellyPhysics.Body;
import jellyPhysics.ColliderBase;
import jellyPhysics.MaterialMatrix;
import jellyPhysics.MaterialPair;
import jellyPhysics.World;
import jellyPhysics.math.Vector2;
import util.UtilClass;

/**
 * ...
 * @author 
 */
class JellyBlocksWorld extends World
{
    private static var pieceCounter:Int = 1;
    private var gamePieces:Array<GamePiece>;
    private var removeList:Array<GamePiece>;
    private var random:FlxRandom;

    public function new(worldMaterialCount:Int, worldMaterialPairs:MaterialMatrix, worldDefaultMaterialPair:MaterialPair, worldPenetrationThreshhold:Float, worldBounds:AABB) 
    {
        super(worldMaterialCount, worldMaterialPairs, worldDefaultMaterialPair, worldPenetrationThreshhold, worldBounds);
        gamePieces = new Array<GamePiece>();
        removeList = new Array<GamePiece>();
        random = new FlxRandom();
    }
    
    override public function getBodyCollider(penetrationThreshhold:Float):ColliderBase
    {
        //return new ArrayCollider(penetrationThreshhold);
        return new QuadTreeCollider(penetrationThreshhold);
    }
        
    private function GravityAccumulator(elapsed:Float){
        var gravity:Vector2 = new Vector2(0, 0.5 * constants.GameConstants.GravityConstant);

        for(i in 0...NumberBodies)
        {
            var body:Body = GetBody(i);
            if (!body.IsStatic){
                body.AddGlobalForce(body.DerivedPos, gravity);
            }
        }
    }
    
    override public function internalAccumulator(elapsed:Float):Void{
        super.internalAccumulator(elapsed);
        GravityAccumulator(elapsed);
        for (i in 0...gamePieces.length){
            gamePieces[i].GamePieceAccumulator(elapsed);
        }
    }
    
    override public function Update(elapsed:Float):Void{
        super.Update(elapsed);
        
        for (i in 0...gamePieces.length){
            gamePieces[i].Update(elapsed);
            if (gamePieces[i].Blocks.length == 0){
                removeList.push(gamePieces[i]);
            }
        }
        
        while (removeList.length > 0){
            var piece:GamePiece = removeList.pop();
            gamePieces.remove(piece);
        }
    }
    
    public function addGround(ground:GameGround) :Void
    {
        var groundBodies:Array<Body> = ground.Assemble();
        for (j in 0...groundBodies.length){
            AddBody(groundBodies[j]);
        }
    }
    
    public function addGamePiece(newGamePiece:GamePiece, controlled:Bool):Void
    {
        var colors:Array<Int> = null;
        if(controlled){
            colors = UtilClass.randomInts(newGamePiece.Blocks.length, constants.GameConstants.UniqueColors, constants.GameConstants.MaxSameColorPerPiece);
        }else{
            colors = UtilClass.randomInts(newGamePiece.Blocks.length, constants.GameConstants.UniqueColors, 1);
        }
        for (i in 0...newGamePiece.Blocks.length){
            newGamePiece.Blocks[i].Material = colors[i];
            AddBody(newGamePiece.Blocks[i]);
            newGamePiece.Blocks[i].GroupNumber = pieceCounter;
        }
        
        gamePieces.push(newGamePiece);
        pieceCounter++;
    }
    
    private static var colorCounter = 0;
    function linearPieceColors(count:Int, howManyColors:Int) 
    {
        var blockColors:Array<Int> = new Array<Int>();
        for (i in 0...count){
            blockColors.push(colorCounter + 1);
            colorCounter = (colorCounter + 1) % howManyColors;
        }
        return blockColors;
    }
}