package;

import blocks.*;
import builders.GameBlockBuilder;
import builders.GamePieceBuilder;
import builders.ShapeBuilder;
import constants.GameConstants;
import constants.PhysicsDefaults;
import flixel.input.gamepad.FlxGamepadInputID;
import enums.*;
import events.*;
import flash.events.*;
import flixel.*;
import flixel.addons.ui.FlxUIState;
import flixel.input.keyboard.FlxKey;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import gamepieces.GamePiece;
import jellyPhysics.*;
import jellyPhysics.math.*;
import openfl.display.*;
import plugins.*;
import render.*;
import util.Capabilities;

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
        
    private var input:Input;
    
    private var spawnTimer:Float = 0.0;
    private var spawnTimerMax:Float = 10.0;
    private var spawnTimerInc:Float = 0.0;
    //timer starts spawning pieces 3 seconds after game loads.
    private var timeTillFirstSpawn:Float = 3.0;
    //new piece spawned this many seconds after controlled piece hits something
    private var spawnAfterCollidionTime:Float = 2.5;
    //don't spaw pieces at less than this interval
    private var minLifeTime:Float = 3.0;
    //spawn pieces at at least this interval
    private var maxLifeTime:Float = 7.0;
    
    private var plugins:List<PluginBase> = new List<PluginBase>();
    private var spawnPlugin:GamePieceSpawnPlugin;
    private var controlPlugin:GamePieceControlPlugin;

	override public function create():Void
	{
		_xml_id = "play_state";
        persistentDraw = true;
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
        
        colorSource = new MultiColorSource(constants.GameConstants.UniqueColors);
        
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
        
        input.AddKeyboardInput(FlxKey.PAGEUP, adjustColorUp, PressType.Down);
        input.AddKeyboardInput(FlxKey.PAGEDOWN, adjustColorDown, PressType.Down);
        input.AddKeyboardInput(FlxKey.F, unfreeze, PressType.Down);

        defaultMaterial = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.75;
        defaultMaterial.Elasticity = 0.8;
        
        createWorld();
        
        createPieceBuilder();
        
        loadPlugins();
        
        addInitialBodiesToWorld();
        
        setupConfigForSpawingBlocks();
        
        //#if (html5)
        render = setupSolidColorRender();
        //#else
        //render = setupTexturedRender();
        //#end
        render.setGameGround(ground);
        
        #if (html5)
        if (Capabilities.IsMobileBrowser()){
            settings.showTouchControls = true;
        }
        #elseif  (mobile)
        settings.showTouchControls = true;
        #end
        
        //if (settings.showTouchControls){
            addButtons();
        //}
        
        EventManager.Register(OnColorRotated, Events.COLOR_ROTATE);
	}
    
    private function loadPlugins():Void
    {
        var blockPopPlugin = new BlockPopEffectPlugin(this, colorSource);
        add(blockPopPlugin);
        plugins.add(blockPopPlugin);
        
        var colorRotatePlugin = new ColorRotatePlugin(this, colorSource);
        add(colorRotatePlugin);
        plugins.add(colorRotatePlugin);
        
        controlPlugin = new GamePieceControlPlugin(this, input);
        physicsWorld.externalAccumulator = controlPlugin.MoveAccumulator;
        add(controlPlugin);
        plugins.add(controlPlugin);
        
        spawnPlugin = new GamePieceSpawnPlugin(this, colorSource, physicsWorld, pieceBuilder);
        spawnPlugin.controlPlugin = controlPlugin;
        add(spawnPlugin);
        plugins.add(spawnPlugin);
        
        #if debug
        var fpsPlugin = new FrameRatePlugin(this);
        add(fpsPlugin);
        plugins.add(fpsPlugin);
        #end
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
		var str:String = "";
		
		switch (name)
		{
			case "finish_load":
			case "click_button":
                trace("Button click.");
				if (params != null && params.length > 0)
				{
					switch (Std.string(params[0]))
					{
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
        leftButton.loadGraphic("assets/images/LeftSprite.png", true, spriteSize, spriteSize);
        leftButton.alpha = buttonTrans;
        leftButton.scale.set(buttonScale, buttonScale);
        leftButton.x = WINDOW_WIDTH * leftButtonHoriz;
        leftButton.y = WINDOW_HEIGHT * dirButtonVert;
        controlPlugin.addLeftButton(leftButton);
        add(leftButton);
        
        rightButton = new FlxButton(buttonSize, buttonSize, null, null);
        rightButton.loadGraphic("assets/images/RightSprite.png", true, spriteSize, spriteSize);
        rightButton.alpha = buttonTrans;
        rightButton.scale.set(buttonScale, buttonScale);
        rightButton.x = WINDOW_WIDTH * rightButtonHoriz;
        rightButton.y = WINDOW_HEIGHT * dirButtonVert;
        controlPlugin.addRightButton(rightButton);
        add(rightButton);
        
        ccwButton = new FlxButton(buttonSize, buttonSize, null, null);
        ccwButton.loadGraphic("assets/images/RotateCCWSprite.png", true, spriteSize, spriteSize);
        ccwButton.alpha = buttonTrans;
        ccwButton.scale.set(buttonScale, buttonScale);
        ccwButton.x = WINDOW_WIDTH * leftButtonHoriz;
        ccwButton.y = WINDOW_HEIGHT * turnButtonVert;
        controlPlugin.addCCWButton(ccwButton);
        add(ccwButton);
        
        cwButton = new FlxButton(buttonSize, buttonSize, null, null);
        cwButton.loadGraphic("assets/images/RotateCWSprite.png", true, spriteSize, spriteSize);
        cwButton.alpha = buttonTrans;
        cwButton.scale.set(buttonScale, buttonScale);
        cwButton.x = WINDOW_WIDTH * rightButtonHoriz;
        cwButton.y = WINDOW_HEIGHT * turnButtonVert;
        controlPlugin.addCWButton(cwButton);
        add(cwButton);
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
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, constants.GameConstants.UniqueColors + 1);
        
        return materialMatrix;
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        input.Update(elapsed);
        
        physicsWorld.Update(elapsed);
    }
    
    private function OnColorRotated(sender:Dynamic, event:String, params:Dynamic){
        unfreeze(FlxKey.F, PressType.Down);
    }
    
    private function adjustColorUp(key: FlxKey, type:PressType):Void{
        colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.05) % 1.0;
        EventManager.Trigger(this, Events.COLOR_ROTATE);
    }
    
    private function adjustColorDown(key: FlxKey, type:PressType):Void{
        colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.95) % 1.0;
        EventManager.Trigger(this, Events.COLOR_ROTATE);
    }
    
    private function unfreeze(key: FlxKey, type:PressType):Void{
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
        /*spawnConfig.timeTillDamping = 0.5;
        spawnConfig.dampingRate = 0.60;
        spawnConfig.dampingInc = 0.10;
        spawnConfig.dampingMax = 0.85;*/
        
        spawnConfig.deflates = true;
        spawnConfig.deflateRate = .25;
        spawnConfig.timeTillDeflate = 5;
        
        spawnConfig.timeTillFreeze = 5;
        spawnConfig.freezeWaitTimerLength = 0.5;
        spawnConfig.freezeDistortionThreshhold = 0.8;
        spawnConfig.freezeVelocityThreshhold = 0.08;
        
        blockBuilder = blockBuilder.setBlockConfig(spawnConfig).setPressure(PhysicsDefaults.SpawnedBlockPressure);
        pieceBuilder.setTriominoBuildShape(TriominoShape.Random);
    }
        
    private var initialConfig:BlockConfig = null;
    private var ground:GameGround;
    private var shapeBuilder:ShapeBuilder = null;
    private var blockBuilder:GameBlockBuilder = null;
    private var pieceBuilder:GamePieceBuilder = null;
    private function createPieceBuilder():GamePieceBuilder{        
        initialConfig = new BlockConfig();
        /*initialConfig.timeTillDamping = 0.5;
        initialConfig.dampingRate = 0.25;
        initialConfig.dampingInc = 0.15;
        initialConfig.dampingMax = 0.85;*/
        
        initialConfig.deflates = true;
        initialConfig.deflateRate = .25;
        initialConfig.timeTillDeflate = 5;
        
        initialConfig.timeTillFreeze = 5;
        initialConfig.freezeWaitTimerLength = 0.5;
        initialConfig.freezeDistortionThreshhold = 0.8;
        initialConfig.freezeVelocityThreshhold = 0.08;
        
        initialConfig.scale = 1.5;
        
        //new up the builders
        shapeBuilder = new ShapeBuilder().type(ShapeType.Rectangle).size(1.0);
        blockBuilder = new GameBlockBuilder().setKinematic(true).setMass(Math.POSITIVE_INFINITY).setPressure(PhysicsDefaults.InitialBlockPressure).setMaterial(constants.GameConstants.MATERIAL_GROUND);
        pieceBuilder = new GamePieceBuilder().setBlockBuilder(blockBuilder).setShapeBuilder(shapeBuilder);
        return pieceBuilder;
    }
    
    function addInitialBodiesToWorld() 
    {
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
        pieceBuilder.setPieceType(PieceType.Triomino).setTriominoBuildShape(TriominoShape.Corner);

        var rowCount:Int = 2;
        var colCount:Int = 3;
        
        var rowStart:Float = 4;
        var rowInc:Float = 2;
        
        var bottomRowOffset:Float = -1.5;
        
        var colStart:Float = -5.2;
        var colInc:Float = 3.4;
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
                if (j % 2 == 1){
                    colLoc += bottomRowOffset;
                }
                spawnPlugin.addGamePiece(createGamePiece(pieceBuilder, new Vector2(colLoc, rowLoc)), false, false);
            }
        }
    }
    
    function createGamePiece(pieceBuilder:GamePieceBuilder, location:Vector2) :GamePiece
    {
        pieceBuilder = pieceBuilder.setLocation(location);
        return pieceBuilder.create();
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
        physicsWorld.SetBodyDamping(0.60);
        if(Capabilities.IsMobileBrowser()){
            physicsWorld.PhysicsIter = 2;
        }else{
            physicsWorld.PhysicsIter = 2;
        }
    }
    
    
}
