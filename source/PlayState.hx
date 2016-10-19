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
    
    private var gamePiece:GamePiece;
    private var blockSprings:Array<ExternalSpring>;
    private var gamePieces:Array<GamePiece>;
    
    public var defaultMaterial:MaterialPair;
    
    private var pieceLeft:Bool = false;
    private var pieceRight:Bool = false;
    private var pieceUp:Bool = false;
    private var pieceDown:Bool = false;
    private var pieceCCW:Bool = false;
    private var pieceCW:Bool = false;
    
    private var random:FlxRandom;
    
    private var input:Input;
    
    private var colorCount:Int = 6;
    
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
        input.AddInputCommand(FlxKey.A, pushPieceLeft, PressType.Pressed);
        input.AddInputCommand(FlxKey.D, pushPieceRight, PressType.Pressed);
        input.AddInputCommand(FlxKey.W, pushPieceUp, PressType.Pressed);
        input.AddInputCommand(FlxKey.S, pushPieceDown, PressType.Pressed);
        input.AddInputCommand(FlxKey.LEFT, rotatePieceCCW, PressType.Pressed);
        input.AddInputCommand(FlxKey.RIGHT, rotatePieceCW, PressType.Pressed);
        input.AddInputCommand(FlxKey.PAGEUP, adjustColorUp, PressType.Down);
        input.AddInputCommand(FlxKey.PAGEDOWN, adjustColorDown, PressType.Down);
        input.AddInputCommand(FlxKey.SPACE, spawnPiece, PressType.Down);
        
        defaultMaterial = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.75;
        defaultMaterial.Elasticity = 0.8;
        
        random = new FlxRandom();
        
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
        var colors:Array<Int> = makeColors(.8, .9, colorCount);
        for (i in 1...colors.length + 1){
            render.SetMaterialDrawOptions(i, colors[i-1], true);
        }
    }
    
    private static var colorAdjust:Float = 0.0;
    private function makeColors(saturation:Float, value:Float, count:Int):Array<Int>
    {
        var iter:Float = 1.0 / count;
        var colors:Array<Int> = new Array<Int>();
        for (i in 0...count){
            colors.push(HSVtoRGB(((i * iter) + colorAdjust) % 1.0, saturation, value));
        }
        return colors;
    }
    
    private function HSVtoRGB(h:Float, s:Float, v:Float):Int{
        var r:Float = 0;
        var g:Float = 0;
        var b:Float = 0;
        
        var i:Int = Math.floor(h * 6);
        var f:Float = h * 6 - i;
        var p:Float = v * (1 - s);
        var q:Float = v * (1 - f * s);
        var t:Float = v * (1 - (1 - f) * s);
        
        switch(i % 6){
            case 0:
                r = v;
                g = t;
                b = p;
            case 1:
                r = q;
                g = v;
                b = p;
            case 2:
                r = p;
                g = v;
                b = t;
            case 3:
                r = p;
                g = q;
                b = v;
            case 4:
                r = t;
                g = p;
                b = v;
            case 5:
                r = v;
                g = p;
                b = q;
        }
        
        var rInt:Int = Std.int(r * 255.0);
        var gInt:Int = Std.int(g * 255.0);
        var bInt:Int = Std.int(b * 255.0);
        
        
        return (rInt << 16) + (gInt << 8) + (bInt);
    }
    
    public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, colorCount + 1);
        
        return materialMatrix;
    }
    
    private var removeList:Array<GamePiece> = new Array<GamePiece>();
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        input.Update(elapsed);
        
        physicsWorld.Update(elapsed);
        
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

        Draw();
        
        pieceCCW = false;
        pieceCW = false;
        pieceLeft = false;
        pieceRight = false;
        pieceUp = false;
        pieceDown = false;
    }
    
    private function pushPieceLeft():Void{
        pieceLeft = true;
    }
    
    private function pushPieceRight():Void{
        pieceRight = true;
    }
    
    private function pushPieceUp():Void{
        pieceUp = true;
    }
    
    private function pushPieceDown():Void{
        pieceDown = true;
    }
    
    private function rotatePieceCCW():Void{
        pieceCCW = true;
    }
    
    private function rotatePieceCW():Void{
        pieceCW = true;
    }
    
    private function adjustColorUp():Void{
        colorAdjust = (colorAdjust + 0.05) % 1.0;
        setupDrawParam(debugRender);
    }
    
    private function adjustColorDown():Void{
        colorAdjust = (colorAdjust + 0.95) % 1.0;
        setupDrawParam(debugRender);
    }
    
    private function spawnPiece():Void{
        if(null != pieceBuilder){
            addGamePiece(createGamePiece(pieceBuilder, new Vector2(0, 0)));
        }
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
    private var shapeBuilder:ShapeBuilder = null;
    private var blockBuilder:GameBlockBuilder = null;
    private var pieceBuilder:GamePieceBuilder = null;
    function addBodiesToWorld() 
    {
        //new up the builders
        shapeBuilder = new ShapeBuilder().type(ShapeType.Rectangle).size(1.0);
        blockBuilder = new GameBlockBuilder().setKinematic(true).setMass(Math.POSITIVE_INFINITY);
        pieceBuilder = new GamePieceBuilder().setBlockBuilder(blockBuilder).setShapeBuilder(shapeBuilder);

        //create static bodies for the container
        ground = new GameGround(2, 16, 20, new Vector2(0, 2), blockBuilder);
        var groundBodies:Array<Body> = ground.Assemble();
        for (i in 0...groundBodies.length){
            physicsWorld.AddBody(groundBodies[i]);
        }
        
        shapeBuilder = shapeBuilder.type(ShapeType.Square).size(1.0);
        blockBuilder = blockBuilder.setMass(PhysicsDefaults.Mass);
        blockBuilder = blockBuilder.setKinematic(false);
        blockBuilder = blockBuilder.setType(BlockType.Freeze);
        blockBuilder = blockBuilder.setShapeBuilder(shapeBuilder);
        pieceBuilder.setPieceType(PieceType.Tetromino).setTetrominoShape(TetrominoShape.Square);
        
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(0, 6)));
        /*addGamePiece(createGamePiece(pieceBuilder, new Vector2(-6, -4)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(-2, -4)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(2, -4)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(6, -4)));
        
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(-6, 0)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(-2, 0)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(2, 0)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(6, 0)));
        
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(-6, 4)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(-2, 4)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(2, 4)));
        addGamePiece(createGamePiece(pieceBuilder, new Vector2(6, 4)));*/
    }
    
    function createGamePiece(pieceBuilder:GamePieceBuilder, location:Vector2) :GamePiece
    {
        pieceBuilder = pieceBuilder.setLocation(location);
        return pieceBuilder.create();
    }
    
    private static var pieceCounter:Int = 1;
    //private static var colorCounter:Int = 0;
    function addGamePiece(newGamePiece:GamePiece) 
    {
        for (i in 0...newGamePiece.Blocks.length){
            //newGamePiece.Blocks[i].Material = (colorCounter % colorCount)+1;
            //colorCounter++;
            newGamePiece.Blocks[i].Material = random.int(1, colorCount);
            physicsWorld.AddBody(newGamePiece.Blocks[i]);
            newGamePiece.Blocks[i].GroupNumber = pieceCounter;
        }
        
        gamePieces.push(newGamePiece);
        pieceCounter++;
        gamePiece = newGamePiece;
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
        var gravity:Vector2 = new Vector2(0, 1.0 * 9.8);

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
        var pushAmount:Vector2 = new Vector2(0, 0);
        
        if (pieceCCW)
        {
            rotationAmount -= 1;
        }
        if (pieceCW)
        {
            rotationAmount += 1;
        }
        
        if (pieceLeft){
            pushAmount.x -= 4;
        }
        if (pieceRight){
            pushAmount.x += 4;
        }
        if (pieceUp){
            pushAmount.y -= 4;
        }
        if (pieceDown){
            pushAmount.y += 4;
        }
        if (pushAmount.x != 0 || pushAmount.y !=0){
            gamePiece.ApplyForce(pushAmount);
        }
        if (rotationAmount != 0 && Math.abs(gamePiece.GamePieceOmega()) < 6.0){
            gamePiece.ApplyTorque(rotationAmount);
        }
    }
}
