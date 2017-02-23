package;

import blocks.*;
import builders.GameBlockBuilder;
import builders.GamePieceBuilder;
import builders.ShapeBuilder;
import constants.PhysicsDefaults;
import enums.*;
import events.*;
import flash.events.*;
import flixel.*;
import flixel.addons.ui.FlxUIState;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRandom;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import gamepieces.GamePiece;
import jellyPhysics.*;
import jellyPhysics.math.*;
import openfl.display.*;
import plugins.BlockPopEffectPlugin;
import plugins.PluginBase;
import render.*;

class PlayState extends FlxUIState
{
    private static var settings:GameSettings = new GameSettings();
    
    var render:BaseDrawWorld;
    var debugDrawSurface:Sprite;
    var flxDrawSurface:FlxSprite;
    var overscan:Int = 10;
    var WINDOW_WIDTH:Int;
    var WINDOW_HEIGHT:Int;

    var physicsWorld:JellyBlocksWorld;
    
    private var gamePiece:GamePiece;
    
    public var defaultMaterial:MaterialPair;
	private var colorSource:IColorSource;
    
    private var leftButton:FlxButton;
    private var rightButton:FlxButton;
    private var cwButton:FlxButton;
    private var ccwButton:FlxButton;
    
    private var pieceLeft:Bool = false;
    private var pieceRight:Bool = false;
    private var pieceUp:Bool = false;
    private var pieceDown:Bool = false;
    private var pieceCCW:Bool = false;
    private var pieceCW:Bool = false;
    
    private var random:FlxRandom;
    
    private var input:Input;
    
    //timer starts spawning pieces 2 seconds after game loads.
    private var firstSpawnTimer:Float = 2.0;
    //new piece spawned this many seconds after controlled piece hits something
    private var spawnAfterCollidionTime:Float = 1.0;
    //don't spaw pieces at less than this interval
    private var minLifeTime:Float = 3.0;
    //spawn pieces at at least this interval
    private var maxLifeTime:Float = 7.0;
    
    private var plugins:List<PluginBase> = new List<PluginBase>();
    
	override public function create():Void
	{
		_xml_id = "play_state";
        persistentDraw = false;
        persistentUpdate = false;
        
        /*#if mobile
        WINDOW_WIDTH = Std.int(Lib.current.stage.width);
        WINDOW_HEIGHT = Std.int(Lib.current.stage.height);
        //WINDOW_WIDTH = Lib.application.window.width;
        //WINDOW_HEIGHT = Lib.application.window.height;
        #else*/
        WINDOW_WIDTH = Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
        WINDOW_HEIGHT = Std.parseInt(haxe.macro.Compiler.getDefine("windowHeight"));
        //#end
        
        //trace("Window width: " + WINDOW_WIDTH);
        //trace("Window height: " + WINDOW_HEIGHT);
		super.create();
        
        colorSource = new MultiColorSource(GameConstants.UniqueColors);
        
        /*
        //wrong in HTML5 and Flash
        var stageWidth:Int = Std.int(Lib.current.stage.width);
        var stageHeight:Int = Std.int(Lib.current.stage.height);
        trace("Window size going by stage: [" + stageWidth + ", " + stageHeight + "]");
        
        //right in HTML5 and Flash
        var appWidth:Int = Lib.application.window.width;
        var appHeight:Int = Lib.application.window.height;
        trace("Window size going by app window: [" + appWidth + ", " + appHeight + "]");
        */
        
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
        input.AddInputCommand(FlxKey.F, unfreeze, PressType.Down);

        defaultMaterial = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.75;
        defaultMaterial.Elasticity = 0.8;
        
        random = new FlxRandom();

        createWorld();
        addInitialBodiesToWorld();
        
        setupConfigForSpawingBlocks();
        
        #if (html5)
        render = setupSolidColorRender();
        #else
        render = setupTexturedRender();
        #end
        render.setGameGround(ground);
        
        #if (html5)
        var r:EReg = new EReg("Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini", "i");
        if (r.match(js.Browser.navigator.userAgent)){
            settings.showTouchControls = true;
        }
        #elseif  (mobile)
        settings.showTouchControls = true;
        #end
        
        if (settings.showTouchControls){
            addButtons();
        }
        
        loadPlugins();
	}
    
    private function loadPlugins():Void
    {
        var blockPopPlugin = new BlockPopEffectPlugin(this, colorSource);
        add(blockPopPlugin);
        plugins.add(blockPopPlugin);
    }
    
    function setupTexturedRender() : BaseDrawWorld
    {
        var render:BaseDrawWorld = new TexturedDrawWorld(createDrawSurface(), colorSource, this, physicsWorld, WINDOW_WIDTH, WINDOW_HEIGHT, overscan);
        return render;
    }
    
    function setupSolidColorRender() : BaseDrawWorld
    {
        var render:BaseDrawWorld = new SolidColorDrawWorld(createDrawSurface(), colorSource, this, physicsWorld, WINDOW_WIDTH, WINDOW_HEIGHT, overscan);
        return render;
    }
    
    function setupDebugRender() : BaseDrawWorld
    {
        var render:BaseDrawWorld = new DebugDrawWorld(createDrawSurface(), colorSource, physicsWorld, WINDOW_WIDTH, WINDOW_HEIGHT, overscan);
        return render;
    }

	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
        trace("PlayState.getEvent(" + name+")");
		var str:String = "";
		
		switch (name)
		{
			case "finish_load":
                trace("Loaded!");
			case "click_button":
                trace("Button click.");
				if (params != null && params.length > 0)
				{
                    trace("click param: " + Std.string(params[0]));
					switch (Std.string(params[0]))
					{
						//case "pause": FlxG.switchState(new PauseMenu());
                        case "pause": openSubState(new PauseMenu());
					}
				}
                case "RELOAD":
                    FlxG.resetState();
		}
	}
    
    /*override public function onResize(Width:Int, Height:Int):Void 
    {
        super.onResize(Width, Height);
        trace("resize event [" + Width + ", " + Height + "]");
    }*/
    
    function addButtons() 
    {
        //ratio of screen width
        var buttonSize:Float = 0.25;
        var spriteSize:Int = 80;
        var buttonTrans:Float = 0.8;
        var buttonScale:Float = (WINDOW_WIDTH * buttonSize) / spriteSize;
        
        var turnButtonVert:Float = 0.5;
        var dirButtonVert:Float = 0.8;
        var leftButtonHoriz:Float = 0.02;
        var rightButtonHoriz:Float = 0.8;
        
        leftButton = new FlxButton(buttonSize, buttonSize, null, null);
        leftButton.onDown.callback = OnLeftDown;
        leftButton.onUp.callback = OnLeftUp;
        leftButton.onOut.callback = OnLeftUp;
        leftButton.loadGraphic("assets/images/LeftSprite.png", true, spriteSize, spriteSize);
        leftButton.alpha = buttonTrans;
        leftButton.scale.set(buttonScale, buttonScale);
        leftButton.x = WINDOW_WIDTH * leftButtonHoriz;
        leftButton.y = WINDOW_HEIGHT * dirButtonVert;
        add(leftButton);
        
        rightButton = new FlxButton(buttonSize, buttonSize, null, null);
        rightButton.onDown.callback = OnRightDown;
        rightButton.onUp.callback = OnRightUp;
        rightButton.onOut.callback = OnRightUp;
        rightButton.loadGraphic("assets/images/RightSprite.png", true, spriteSize, spriteSize);
        rightButton.alpha = buttonTrans;
        rightButton.scale.set(buttonScale, buttonScale);
        rightButton.x = WINDOW_WIDTH * rightButtonHoriz;
        rightButton.y = WINDOW_HEIGHT * dirButtonVert;
        add(rightButton);
        
        ccwButton = new FlxButton(buttonSize, buttonSize, null, null);
        ccwButton.onDown.callback = OnCCWDown;
        ccwButton.onUp.callback = OnCCWUp;
        ccwButton.onOut.callback = OnCCWUp;
        ccwButton.loadGraphic("assets/images/RotateCCWSprite.png", true, spriteSize, spriteSize);
        ccwButton.alpha = buttonTrans;
        ccwButton.scale.set(buttonScale, buttonScale);
        ccwButton.x = WINDOW_WIDTH * leftButtonHoriz;
        ccwButton.y = WINDOW_HEIGHT * turnButtonVert;
        add(ccwButton);
        
        cwButton = new FlxButton(buttonSize, buttonSize, null, null);
        cwButton.onDown.callback = OnCWDown;
        cwButton.onUp.callback = OnCWUp;
        cwButton.onOut.callback = OnCWUp;
        cwButton.loadGraphic("assets/images/RotateCWSprite.png", true, spriteSize, spriteSize);
        cwButton.alpha = buttonTrans;
        cwButton.scale.set(buttonScale, buttonScale);
        cwButton.x = WINDOW_WIDTH * rightButtonHoriz;
        cwButton.y = WINDOW_HEIGHT * turnButtonVert;
        add(cwButton);
    }
    
    private var leftHeld:Bool = false;
    private var rightHeld:Bool = false;
    private var ccwHeld:Bool = false;
    private var cwHeld:Bool = false;
    function OnLeftDown() 
    {
        leftHeld = true;
    }
    function OnLeftUp() 
    {
        leftHeld = false;
    }
    function OnRightDown() 
    {
        rightHeld = true;
    }
    function OnRightUp() 
    {
        rightHeld = false;
    }
    function OnCWDown() 
    {
        cwHeld = true;
    }
    function OnCWUp() 
    {
        cwHeld = false;
    }
    function OnCCWDown() 
    {
        ccwHeld = true;
    }
    function OnCCWUp() 
    {
        ccwHeld = false;
    }
    
    private function createDrawSurface():Sprite
    {
        flxDrawSurface = new FlxSprite().makeGraphic(WINDOW_WIDTH, WINDOW_HEIGHT, FlxColor.TRANSPARENT);
        add(flxDrawSurface);
        
        debugDrawSurface = new Sprite();
        debugDrawSurface.x = 0;
        debugDrawSurface.y = 0;
        
        debugDrawSurface.cacheAsBitmap = true;
        
        return debugDrawSurface;
    }
    
    public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, GameConstants.UniqueColors + 1);
        
        return materialMatrix;
    }
    
    private var changeTimer:Float = 0;
    private var timerTickingDown:Bool = true;
    private var spawnPieceFlag:Bool = false;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        changeTimer = Math.max(0, changeTimer - elapsed);
        
        if (gamePiece != null && gamePiece.HasEverCollided){
            timerTickingDown = true;
        }
        
        if(timerTickingDown){
            firstSpawnTimer -= elapsed;
            if (firstSpawnTimer <= 0 && (gamePiece == null || gamePiece.LifeTime >= minLifeTime)){
                spawnPieceFlag = true;
            }
        }
        
        if (gamePiece != null && gamePiece.LifeTime >= maxLifeTime){
            spawnPieceFlag = true;
        }
        
        if (spawnPieceFlag && null != pieceBuilder){
            spawnPieceFlag = false;
            timerTickingDown = false;
            firstSpawnTimer = spawnAfterCollidionTime;
            addGamePiece(createGamePiece(pieceBuilder, new Vector2(0, -10)), true);
        }
        
        input.Update(elapsed);
        
        physicsWorld.Update(elapsed);
        
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
        colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.05) % 1.0;
        EventManager.Trigger(this, Events.COLOR_ROTATE);
    }
    
    private function adjustColorDown():Void{
        colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.95) % 1.0;
        EventManager.Trigger(this, Events.COLOR_ROTATE);
    }
    
    private function spawnPiece():Void{
        spawnPieceFlag = true;
    }
    
    private function unfreeze():Void{
        for (i in 0...physicsWorld.NumberBodies){
            var body:Body = physicsWorld.GetBody(i);
            if (!body.IsStatic){
                var freezingBlock:FreezingGameBlock = Std.instance(body, FreezingGameBlock);
                if (freezingBlock != null){
                    freezingBlock.UnFreezeFor(5.0);
                }
            }
        }
    }
    
    override public function draw():Void 
    {
        super.draw();
        
        render.Draw();
        
        var pixels:BitmapData = flxDrawSurface.pixels;
        pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
        pixels.draw(debugDrawSurface);
        flxDrawSurface.pixels = pixels;
    }
    
    function setupConfigForSpawingBlocks() 
    {
        var spawnConfig:BlockConfig = new BlockConfig();
        spawnConfig.timeTillDamping = 0.5;
        spawnConfig.dampingRate = 0.60;
        spawnConfig.dampingInc = 0.10;
        spawnConfig.dampingMax = 0.85;
        
        spawnConfig.deflates = true;
        spawnConfig.deflateRate = .25;
        spawnConfig.timeTillDeflate = 5;
        
        spawnConfig.timeTillFreeze = 2;
        spawnConfig.freezeWaitTimerLength = 0.5;
        spawnConfig.freezeDistortionThreshhold = 0.8;
        spawnConfig.freezeVelocityThreshhold = 0.08;
        
        blockBuilder = blockBuilder.setBlockConfig(spawnConfig).setPressure(PhysicsDefaults.SpawnedBlockPressure);
        pieceBuilder.setTriominoShape(TriominoShape.Random);
    }
    
    private var ground:GameGround;
    private var shapeBuilder:ShapeBuilder = null;
    private var blockBuilder:GameBlockBuilder = null;
    private var pieceBuilder:GamePieceBuilder = null;
    function addInitialBodiesToWorld() 
    {
        var initialConfig:BlockConfig = new BlockConfig();
        initialConfig.timeTillDamping = 0.5;
        initialConfig.dampingRate = 0.25;
        initialConfig.dampingInc = 0.15;
        initialConfig.dampingMax = 0.85;
        
        initialConfig.deflates = true;
        initialConfig.deflateRate = .25;
        initialConfig.timeTillDeflate = 5;
        
        initialConfig.timeTillFreeze = 2;
        initialConfig.freezeWaitTimerLength = 0.5;
        initialConfig.freezeDistortionThreshhold = 0.8;
        initialConfig.freezeVelocityThreshhold = 0.08;
        
        initialConfig.scale = 1.5;
        
        //new up the builders
        shapeBuilder = new ShapeBuilder().type(ShapeType.Rectangle).size(1.0);
        blockBuilder = new GameBlockBuilder().setKinematic(true).setMass(Math.POSITIVE_INFINITY).setPressure(PhysicsDefaults.InitialBlockPressure).setMaterial(GameConstants.MATERIAL_GROUND);
        pieceBuilder = new GamePieceBuilder().setBlockBuilder(blockBuilder).setShapeBuilder(shapeBuilder);

        //create static bodies for the container
        ground = new GameGround(2, 16, 20, /*new Vector2(0, 12),*/ blockBuilder);
        physicsWorld.addGround(ground);
        
        shapeBuilder = shapeBuilder.type(ShapeType.Square).size(1.0);
        blockBuilder = blockBuilder.setScale(new Vector2(initialConfig.scale, initialConfig.scale));
        blockBuilder = blockBuilder.setMass(PhysicsDefaults.Mass);
        blockBuilder = blockBuilder.setBlockConfig(initialConfig);
        blockBuilder = blockBuilder.setKinematic(false);
        blockBuilder = blockBuilder.setType(BlockType.Freeze);
        blockBuilder = blockBuilder.setShapeBuilder(shapeBuilder);
        pieceBuilder.setPieceType(PieceType.Triomino).setTriominoShape(TriominoShape.Corner);

        var rowCount:Int = 2;
        var colCount:Int = 3;
        
        var rowStart:Float = -2;
        var rowInc:Float = 2;
        
        var colStart:Float = -6;
        var colInc:Float = 3;
        var colOffset:Float = 0.5;
        
        var stressPhysics:Bool = false;
        if (stressPhysics){
            rowCount = 6;
            rowStart = -9;
        }
        
        for (j in 0...rowCount){
            //trace("j: " + j + ", j%2: " + (j % 2));
            var colBase:Float = colStart;
            if (j % 2 == 0){
                pieceBuilder.setRotation(Math.PI);
                colBase += colOffset;
            }else{
                pieceBuilder.setRotation(0);
            }
            var rowLoc:Float = rowStart + (rowInc * initialConfig.scale) * j;
            for (k in 0...colCount){
                var colLoc:Float = colBase+(colInc * initialConfig.scale) * k;
                addGamePiece(createGamePiece(pieceBuilder, new Vector2(colLoc, rowLoc)), false);
            }
        }
    }
    
    function createGamePiece(pieceBuilder:GamePieceBuilder, location:Vector2) :GamePiece
    {
        pieceBuilder = pieceBuilder.setLocation(location);
        return pieceBuilder.create();
    }
    
    function addGamePiece(newGamePiece:GamePiece, controlled:Bool) 
    {
        physicsWorld.addGamePiece(newGamePiece, controlled);
        
        if(controlled){
            gamePiece = newGamePiece;
        }
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
        
        var bounds:AABB = new AABB(new Vector2( -12, -14), new Vector2( 12, 14));
        
        var penetrationThreshhold:Float = 1.0;
        
        physicsWorld = new JellyBlocksWorld(matrix.Count, matrix, matrix.DefaultMaterial, penetrationThreshhold, bounds);
        physicsWorld.SetBodyDamping(0.4);
        physicsWorld.externalAccumulator = PhysicsAccumulator;
        physicsWorld.PhysicsIter = 2;
    }

    private function PhysicsAccumulator(elapsed:Float){
        MoveAccumulator(elapsed);
    }
    
    private function MoveAccumulator(elapsed:Float){
        if (gamePiece == null){
            return;
        }
        var rotationAmount:Float = 0;
        var pushAmount:Vector2 = new Vector2(0, 0);
        
        var rotateForce:Float = 2;
        var moveForce:Float = 16;
        
        if (pieceCCW || ccwHeld)
        {
            rotationAmount -= rotateForce;
        }
        if (pieceCW || cwHeld)
        {
            rotationAmount += rotateForce;
        }
        
        //If no player input then counteract the game pieces rotation
        //makes piece much easier to control. Length check is here so
        //the piece doesn't go wonky when one of the pieces pops.
        if (rotationAmount == 0 && gamePiece.Blocks.length == 3){
            rotationAmount = -clampValue(gamePiece.RotationSpeed, -1, 1);
        }

        if (pieceLeft || leftHeld){
            pushAmount.x -= moveForce;
        }
        if (pieceRight || rightHeld){
            pushAmount.x += moveForce;
        }
        if (pieceUp){
            pushAmount.y -= moveForce;
        }
        if (pieceDown){
            pushAmount.y += moveForce;
        }
        if (pushAmount.x != 0 || pushAmount.y !=0){
            gamePiece.ApplyForce(pushAmount);
        }
        if (rotationAmount != 0 && Math.abs(gamePiece.GamePieceOmega()) < 6.0){
            gamePiece.ApplyTorque(rotationAmount);
        }
    }
    
    function clampValue(value:Float, low:Float, high:Float) 
    {
        var result:Float = value;
        if (result < low){
            result = low;
        }else if (result > high){
            result = high;
        }
       return result; 
    }
}
