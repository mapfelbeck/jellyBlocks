package;

import flixel.*;
import builders.GameBlockBuilder;
import builders.GamePieceBuilder;
import builders.ShapeBuilder;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import jellyPhysics.*;
import gamepieces.GamePiece;
import jellyPhysics.math.*;
import openfl.Lib;
import openfl.display.*;
import blocks.*;
import enums.*;

class PlayState extends FlxState
{
    var debugRender:DrawDebugWorld;
    var debugDrawSurface:Sprite;
    var flxDrawSurface:FlxSprite;
    var overscan:Int = 0;
    var WINDOW_WIDTH:Int;
    var WINDOW_HEIGHT:Int;

    var physicsWorld:World;
    private static var MATERIAL_GROUND:Int = 0;
    private static var MATERIAL_TYPE_YELLOW:Int = 1;
    private static var MATERIAL_TYPE_GREEN:Int = 2;
    private static var MATERIAL_BLOB:Int   = 3;
    
    //private var blobBody:PressureBody;
    private var blobPiece:GamePiece;
    private var yellowPiece:GamePiece;
    private var greenPiece:GamePiece;
    private var collideYellow:Bool = false;
    private var collideGreen:Bool = false;
    private var blockSprings:Array<ExternalSpring>;
    private var gamePieces:Array<GamePiece>;
    
    public var defaultMaterial:MaterialPair;
    
    private var blobMoveLeft:Bool = false;
    private var blobMoveRight:Bool = false;
    
    private var input:Input;
	override public function create():Void
	{
        #if mobile
        WINDOW_WIDTH = Std.int(Lib.current.stage.width);
        WINDOW_HEIGHT = Std.int(Lib.current.stage.height);
        //WINDOW_WIDTH = Lib.application.window.width;
        //WINDOW_HEIGHT = Lib.application.window.height;
        #else
        WINDOW_WIDTH = Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
        WINDOW_HEIGHT = Std.parseInt(haxe.macro.Compiler.getDefine("windowHeight"));
        #end
        trace("Window width: " + WINDOW_WIDTH);
        trace("Window height: " + WINDOW_HEIGHT);
		super.create();
        
        input = new Input();
        input.AddInputCommand(FlxKey.LEFT, setBlobMovingLeft);
        input.AddInputCommand(FlxKey.RIGHT, setBlobMovingRight);
        
        defaultMaterial = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.3;
        defaultMaterial.Elasticity = 0.8;
        
        //blockSprings = new Array<ExternalSpring>();
        gamePieces = new Array<GamePiece>();
        
        createWorld();
        addBodiesToWorld();
        
        //draw surface needs stage
        debugRender = new DrawDebugWorld(createDrawSurface(), physicsWorld, WINDOW_WIDTH, WINDOW_HEIGHT);
        setupDrawParam(debugRender);
	}
    
    private function createDrawSurface():Sprite
    {
        flxDrawSurface = new FlxSprite().makeGraphic(WINDOW_WIDTH, WINDOW_HEIGHT, FlxColor.TRANSPARENT);
        add(flxDrawSurface);
        
        overscan = 20;
        debugDrawSurface = new Sprite();
        debugDrawSurface.x = overscan;
        debugDrawSurface.y = overscan;
        
        debugDrawSurface.cacheAsBitmap = true;
        
        return debugDrawSurface;
    }
    
    public function setupDrawParam(render:DrawDebugWorld):Void
    {
        render.DrawingAABB = false;
        render.DrawingGlobalBody = false;
        render.DrawingPointMasses = false;
        render.SetMaterialDrawOptions(MATERIAL_GROUND, DrawDebugWorld.COLOR_WHITE, false);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_YELLOW, DrawDebugWorld.COLOR_YELLOW, true);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_GREEN, DrawDebugWorld.COLOR_GREEN, true);
        render.SetMaterialDrawOptions(MATERIAL_BLOB, DrawDebugWorld.COLOR_RED, true);
    }
        
    public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, 4);
        
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_YELLOW, collisionFilterYellow);
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_GREEN, collisionFilterGreen);
        
        //default material friction is 0.3, pretty slippery
        //give the blob more friction, 0.75
        materialMatrix.SetMaterialPairData(MATERIAL_GROUND, MATERIAL_BLOB, 0.75, 0.8);
        
        return materialMatrix;
    }
    
    function collisionFilterYellow(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        collideYellow = true;
        return false;
    }
    
    function collisionFilterGreen(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        return false;
    }
    
    function collisionCallbackGreen(otherBody:Body):Void{
        if(otherBody.Label == "Blob"){
            collideGreen = true;
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        input.Update(elapsed);
        
        physicsWorld.Update(elapsed);

        Draw();
        
        collideYellow = false;
        collideGreen = false;
        blobMoveLeft = false;
        blobMoveRight = false;
    }
    
    private function setBlobMovingLeft(){
        blobMoveLeft = true;
    }
    
    private function setBlobMovingRight(){
        blobMoveRight = true;
    }
    
    private function Draw():Void
    {
        debugRender.Draw();
        
        var pixels:BitmapData = flxDrawSurface.pixels;
        pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
        pixels.draw(debugDrawSurface);
        flxDrawSurface.pixels = pixels;
        flxDrawSurface.x = overscan;
        flxDrawSurface.y = overscan;
    }
    
    private var ground:GameGround;
    function addBodiesToWorld() 
    {
        //new up the builders
        var shapeBuilder:ShapeBuilder = new ShapeBuilder().type(ShapeType.Rectangle).size(1.0);
        var blockBuilder = new GameBlockBuilder().setKinematic(true).setMass(Math.POSITIVE_INFINITY);
        var pieceBuilder:GamePieceBuilder = new GamePieceBuilder().setBlockBuilder(blockBuilder).setShapeBuilder(shapeBuilder);
     
        //create static bodies for the container
        ground = new GameGround(2, 16, 20, new Vector2(0, 2), blockBuilder);
        var groundBodies:Array<Body> = ground.Assemble();
        for (i in 0...groundBodies.length){
            physicsWorld.AddBody(groundBodies[i]);
        }
        
        //build the big red blob
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 200;
        var shapeDamp:Float = 100;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 100.0;
        var externalK:Float = 50.0;
        var externalDamp:Float = 20.0;
        
        shapeBuilder = shapeBuilder.type(ShapeType.Polygon).size(1.0).facetCount(16);
        blockBuilder = blockBuilder.setPosition(new Vector2(0, 0));
        blockBuilder = blockBuilder.setKinematic(false);
        blockBuilder = blockBuilder.setType(BlockType.Normal);
        blockBuilder = blockBuilder.setShapeBuilder(shapeBuilder);
        blockBuilder = blockBuilder.setMass(mass);
        blockBuilder = blockBuilder.setShapeK(shapeK);
        blockBuilder = blockBuilder.setShapeDamp(shapeDamp);
        blockBuilder = blockBuilder.setEdgeK(edgeK);
        blockBuilder = blockBuilder.setEdgeDamp(edgeDamp);
        blockBuilder = blockBuilder.setPressure(pressureAmount);
        blockBuilder = blockBuilder.setConfig(new BlockConfig());
        blockBuilder = blockBuilder.setMaterial(MATERIAL_BLOB);
        blockBuilder = blockBuilder.setLabel("Blob");
        pieceBuilder.setPieceType(PieceType.Single);
        blobPiece = pieceBuilder.create();
        addGamePiece(blobPiece);
        
        //build the yellow custom block
        shapeBuilder = shapeBuilder.type(ShapeType.Custom).size(1).vertexes(getBigSquareShape(1.0));
        blockBuilder.setPressure(0).setPosition(new Vector2( -6, 0)).setLabel(null);
        blockBuilder = blockBuilder.setPressure(0).setMaterial(MATERIAL_TYPE_YELLOW);
        pieceBuilder.setLocation(new Vector2( -6, 0));
        yellowPiece = pieceBuilder.create();
        addGamePiece(yellowPiece);
        
        //var springBody:GameBlock = blockBuilder.create();
        //springBody.Material = MATERIAL_TYPE_YELLOW;
        //physicsWorld.AddBody(springBody);
        
        //build the green compound block
        shapeBuilder = shapeBuilder.type(ShapeType.Square);
        
        blockBuilder = blockBuilder.setType(BlockType.Normal).setMaterial(MATERIAL_TYPE_GREEN).setCollisionCallback(collisionCallbackGreen);
        shapeBuilder = shapeBuilder.type(ShapeType.Square);
        pieceBuilder = pieceBuilder.setPieceType(PieceType.Tetromino);
        pieceBuilder = pieceBuilder.setAttachSpringK(externalK);
        pieceBuilder = pieceBuilder.setAttachSpringDamp(externalDamp);
        pieceBuilder = pieceBuilder.setTetrominoShape(TetrominoShape.Square);
        pieceBuilder = pieceBuilder.setLocation(new Vector2(5.5, -3));
        
        greenPiece = pieceBuilder.create();        
        addGamePiece(greenPiece);
    }
    
    private static var pieceCounter:Int = 0;
    function addGamePiece(newGamePiece:GamePiece) 
    {
        for (i in 0...newGamePiece.Blocks.length){
            physicsWorld.AddBody(newGamePiece.Blocks[i]);
            newGamePiece.Blocks[i].GroupNumber = pieceCounter;
        }
        
        gamePieces.push(newGamePiece);
        pieceCounter++;
    }
    
    private function getBigSquareShape(size:Float):Array<Vector2>{
        var bigSquareShape:Array<Vector2> = new Array<Vector2>();
        bigSquareShape.push(new Vector2(0, -size*2));
        bigSquareShape.push(new Vector2(size, -size*2));
        bigSquareShape.push(new Vector2(size*2, -size*2));
        bigSquareShape.push(new Vector2(size*2, -size));
        bigSquareShape.push(new Vector2(size*2, 0));
        bigSquareShape.push(new Vector2(size, 0));
        bigSquareShape.push(new Vector2(0, 0));
        bigSquareShape.push(new Vector2(0, -size));
        return bigSquareShape;
    }
    
    private function createWorld()
    {
        var matrix:MaterialMatrix = getMaterialMatrix();
        
        var bounds:AABB = new AABB(new Vector2( -20, -20), new Vector2( 20, 20));
        
        var penetrationThreshhold:Float = 10.0;
        
        physicsWorld = new World(matrix.Count, matrix, matrix.DefaultMaterial, penetrationThreshhold, bounds);
        physicsWorld.externalAccumulator = PhysicsAccumulator;
    }
        
    private function PhysicsAccumulator(elapsed:Float){
        GravityAccumulator(elapsed);
        MoveAccumulator(elapsed);
        for (i in 0...gamePieces.length){
            gamePieces[i].GamePieceAccumulator(elapsed);
        }
    }
        
    private function GravityAccumulator(elapsed:Float){
        var gravity:Vector2 = new Vector2(0, 0.5 * 9.8);

        for(i in 0...physicsWorld.NumberBodies)
        {
            var body:Body = physicsWorld.GetBody(i);
            if (!body.IsStatic){
                body.AddGlobalForce(body.DerivedPos, gravity);
            }
        }
    }
        
    private function MoveAccumulator(elapsed:Float){
        
        var rotationAmount:Float = 0;
        
        if (blobMoveLeft)
        {
            rotationAmount += -8;
        }
        if (blobMoveRight)
        {
            rotationAmount += 8;
        }
        
        if (rotationAmount != 0 && Math.abs(blobPiece.GamePieceOmega()) < 6.0){
            greenPiece.ApplyTorque(rotationAmount);
        }
    }
}
