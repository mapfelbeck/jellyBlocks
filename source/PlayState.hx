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
import flixel.math.FlxRandom;
import constants.PhysicsDefaults;

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
    private static var MATERIAL_TYPE_RED:Int   = 3;
    private static var MATERIAL_TYPE_BLUE:Int   = 4;
    
    private var redPiece:GamePiece;
    private var yellowPiece:GamePiece;
    private var greenPiece:GamePiece;
    private var collideYellow:Bool = false;
    private var collideGreen:Bool = false;
    private var blockSprings:Array<ExternalSpring>;
    private var gamePieces:Array<GamePiece>;
    
    public var defaultMaterial:MaterialPair;
    
    private var pieceLeft:Bool = false;
    private var pieceRight:Bool = false;
    private var pieceCCW:Bool = false;
    private var pieceCW:Bool = false;
    
    private var random:FlxRandom;
    
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
        input.AddInputCommand(FlxKey.A, pushPieceLeft);
        input.AddInputCommand(FlxKey.D, pushPieceRight);
        input.AddInputCommand(FlxKey.LEFT, rotatePieceCCW);
        input.AddInputCommand(FlxKey.RIGHT, rotatePieceCW);
        
        defaultMaterial = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.3;
        defaultMaterial.Elasticity = 0.8;
        
        random = new FlxRandom();
        
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
        render.SetMaterialDrawOptions(MATERIAL_TYPE_RED, DrawDebugWorld.COLOR_RED, true);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_BLUE, DrawDebugWorld.COLOR_BLUE, true);
    }
        
    public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, 5);
        
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_TYPE_RED, MATERIAL_TYPE_YELLOW, collisionFilterYellow);
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_TYPE_RED, MATERIAL_TYPE_GREEN, collisionFilterGreen);
        
        //default material friction is 0.3, pretty slippery
        //give the blob more friction, 0.75
        materialMatrix.SetMaterialPairData(MATERIAL_GROUND, MATERIAL_TYPE_RED, 0.75, 0.8);
        
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
        pieceCCW = false;
        pieceCW = false;
        pieceLeft = false;
        pieceRight = false;
    }
    
    private function pushPieceLeft():Void{
        pieceLeft = true;
    }
    
    private function pushPieceRight():Void{
        pieceRight = true;
    }
    
    private function rotatePieceCCW(){
        pieceCCW = true;
    }
    
    private function rotatePieceCW(){
        pieceCW = true;
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
        
        //build the game pieces
        /*var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 450;
        var shapeDamp:Float = 15;
        var edgeK:Float = 450;
        var edgeDamp:Float = 15;
        var pressureAmount:Float = 250.0;
        var externalK:Float = 450.0;
        var externalDamp:Float = 15.0;*/
        
        shapeBuilder = shapeBuilder.type(ShapeType.Square).size(1.0);
        blockBuilder = blockBuilder.setPosition(new Vector2(0, 0));
        blockBuilder = blockBuilder.setMass(PhysicsDefaults.Mass);
        blockBuilder = blockBuilder.setKinematic(false);
        blockBuilder = blockBuilder.setType(BlockType.Normal);
        blockBuilder = blockBuilder.setShapeBuilder(shapeBuilder);
        blockBuilder = blockBuilder.setConfig(new BlockConfig());
        //blockBuilder = blockBuilder.setLabel("Lychee");
        blockBuilder = blockBuilder.setMaterial(MATERIAL_TYPE_RED);
        pieceBuilder.setPieceType(PieceType.Tetromino).setTetrominoShape(TetrominoShape.Square);
        redPiece = pieceBuilder.create();
        addGamePiece(redPiece);
        
        //build the yellow custom block
        blockBuilder.setPressure(0).setPosition(new Vector2( -6, 0)).setLabel(null);
        blockBuilder = blockBuilder.setMaterial(MATERIAL_TYPE_YELLOW);
        pieceBuilder.setLocation(new Vector2( -6, 0));
        yellowPiece = pieceBuilder.create();
        addGamePiece(yellowPiece);
        
        //build the green compound block
        shapeBuilder = shapeBuilder.type(ShapeType.Square);
        
        blockBuilder = blockBuilder.setType(BlockType.Normal).setMaterial(MATERIAL_TYPE_GREEN).setCollisionCallback(collisionCallbackGreen);
        shapeBuilder = shapeBuilder.type(ShapeType.Square);
        pieceBuilder = pieceBuilder.setPieceType(PieceType.Tetromino);
        //pieceBuilder = pieceBuilder.setAttachSpringK(externalK);
        //pieceBuilder = pieceBuilder.setAttachSpringDamp(externalDamp);
        pieceBuilder = pieceBuilder.setTetrominoShape(TetrominoShape.Square);
        pieceBuilder = pieceBuilder.setLocation(new Vector2(5.5, -3));
        
        greenPiece = pieceBuilder.create();        
        addGamePiece(greenPiece);
    }
    
    private static var pieceCounter:Int = 0;
    function addGamePiece(newGamePiece:GamePiece) 
    {
        for (i in 0...newGamePiece.Blocks.length){
            newGamePiece.Blocks[i].Material = random.int(1, 4);
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
        physicsWorld.SetBodyDamping(0.4);
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
        var pushAmount:Float = 0;
        
        if (pieceCCW)
        {
            rotationAmount += -8;
        }
        if (pieceCW)
        {
            rotationAmount += 8;
        }
        
        if (pieceLeft){
            pushAmount -= 4;
        }
        if (pieceRight){
            pushAmount += 4;
        }
        if (pushAmount != 0){
            greenPiece.ApplyForce(new Vector2(pushAmount, 0));
        }
        if (rotationAmount != 0 && Math.abs(redPiece.GamePieceOmega()) < 6.0){
            greenPiece.ApplyTorque(rotationAmount);
        }
    }
}
