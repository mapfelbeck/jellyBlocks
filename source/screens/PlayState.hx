package screens;

import blocks.*;
import builders.*;
import constants.GameConstants;
import constants.PhysicsDefaults;
import enums.*;
import events.*;
import flash.events.*;
import flixel.*;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUISprite;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRandom;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import gamepieces.GamePiece;
import jellyPhysics.*;
import jellyPhysics.math.*;
import openfl.display.*;
import plugins.*;
import render.*;
import screenPlugins.*;
import util.Capabilities;
import util.ScreenWorldTransform;

class PlayState extends BaseScreen
{
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
    
    private var rotatePlugin:ColorRotatePlugin;
    private var spawnPlugin:GamePieceSpawnPlugin;
    private var controlPlugin:GamePieceControlPlugin;

    private var physicsPaused:Bool = false;
    
    private var drawGroup:FlxGroup = new FlxGroup();
    
    private var background:FlxUISprite;
    private var backgroundIndex:Int = 0;
    private var backgroundAssets:Array<String> = [
        "assets/gfx/ui/gameplay1.png",
        "assets/gfx/ui/gameplay2.png",
        "assets/gfx/ui/gameplay3.png",
        "assets/gfx/ui/gameplay4.png"
    ];
    
    //private static var failLineAssetPath:String =  "assets/images/line.png";
    
    private var screenWorldTransform:ScreenWorldTransform;
    
    public var mainCamera:FlxCamera;
    public var renderCamera:FlxCamera;
    
    public var pluginGroup:FlxGroup;
    public var renderGroup:FlxGroup;
    
    public var offscreenRenderX:Int = -2000;
    public var offscreenRenderY:Int = -2000;
    
	override public function create():Void
	{
		_xml_id = "play_state";
        persistentDraw = true;
        persistentUpdate = false;
        
        super.create();
        
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
        
        //trace("Std.int(Lib.current.stage.width): " + Std.int(Lib.current.stage.width));
        //trace("Lib.application.window.width: " + Lib.application.window.width);
        //trace("WINDOW_WIDTH: " + WINDOW_WIDTH);
        //trace("Std.parseInt(haxe.macro.Compiler.getDefine(\"windowWidth\")): " + Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
		
        
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
        input.GamePadDeadZone = GameConstants.GamePadDeadZone;
        
        input.AddGamepadButtonInput(FlxGamepadInputID.START, pauseBtn, PressType.Down);
        input.AddKeyboardInput(FlxKey.ESCAPE, pauseKey, PressType.Down);
        #if debug
        input.AddGamepadButtonInput(FlxGamepadInputID.LEFT_SHOULDER, unfreezeBtn, PressType.Down);
        input.AddGamepadButtonInput(FlxGamepadInputID.RIGHT_SHOULDER, scrambleColorsBtn, PressType.Down);
        input.AddKeyboardInput(FlxKey.PAGEUP, adjustColorUp, PressType.Down);
        input.AddKeyboardInput(FlxKey.PAGEDOWN, adjustColorDown, PressType.Down);
        input.AddKeyboardInput(FlxKey.F, unfreezeKey, PressType.Down);
        input.AddKeyboardInput(FlxKey.R, scrambleColorsKey, PressType.Down);
        input.AddKeyboardInput(FlxKey.P, pausePhysics, PressType.Down);
        input.AddKeyboardInput(FlxKey.G, gameOverKey, PressType.Down);
        
        input.AddKeyboardInput(FlxKey.Z, zoomOut, PressType.Down);
        input.AddKeyboardInput(FlxKey.X, zoomIn, PressType.Down);
        input.AddKeyboardInput(FlxKey.C, shake, PressType.Down);
        input.AddKeyboardInput(FlxKey.V, camUp, PressType.Down);
        input.AddKeyboardInput(FlxKey.B, camDown, PressType.Down);
        input.AddKeyboardInput(FlxKey.N, camLeft, PressType.Down);
        input.AddKeyboardInput(FlxKey.M, camRight, PressType.Down);
        #end

        defaultMaterial = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.75;
        defaultMaterial.Elasticity = 0.8;
        
        createWorld();
        
        screenWorldTransform = new ScreenWorldTransform(physicsWorld.WorldBounds, WINDOW_WIDTH, WINDOW_HEIGHT);
        
        createPieceBuilder();
        
        pluginGroup = new FlxGroup();
        add(pluginGroup);
        renderGroup = new FlxGroup();
        add(renderGroup);
        
        loadPlugins();
        //#if (html5)
        render = setupSolidColorRender();
        //#else
        //render = setupTexturedRender();
        //#end
        //render = setupDebugRender();
        
        addInitialBodiesToWorld();
        render.setGameGround(ground);
        
        setupConfigForSpawingBlocks();

        #if (html5)
        if (Capabilities.IsMobileBrowser()){
            GameSettings.ShowTouchControls = true;
        }
        #elseif  (mobile)
        GameSettings.ShowTouchControls = true;
        #end
        
        if (GameSettings.ShowTouchControls){
            addButtons();
        }
        
        background = cast _ui.getAsset("background");
        
        /*trace("FlxG.height: " + FlxG.height);
        trace("FlxG.width: " + FlxG.width);
        trace("WINDOW_HEIGHT: " + WINDOW_HEIGHT);
        trace("WINDOW_WIDTH: " + WINDOW_WIDTH);*/
        
        var renderOffset:Int = 50;
        //renderCamera = new FlxCamera(0,0, WINDOW_WIDTH, WINDOW_HEIGHT);
        renderCamera = new FlxCamera(Std.int(renderOffset/2), Std.int(renderOffset/2), Std.int(WINDOW_WIDTH-renderOffset), Std.int(WINDOW_HEIGHT-renderOffset));
        var bgColor:FlxColor = FlxColor.TRANSPARENT;
        //var bgColor:FlxColor = FlxColor.GRAY;
        //bgColor.alpha = 128;
        renderCamera.bgColor = bgColor;
        renderCamera.follow(flxDrawSurface, FlxCameraFollowStyle.NO_DEAD_ZONE);
        FlxG.cameras.add(renderCamera);
        
        registerEvent(OnColorRotated, Events.COLOR_ROTATE);
        registerEvent(OnNewGamePiece, Events.PIECE_CREATE);
	}
    
    private function loadPlugins():Void
    {
        var soundPlugin = new SoundsEffectsPlugin(this);
        pluginGroup.add(soundPlugin);
        plugins.add(soundPlugin);
        
        var accPlugin = new AccumulationPlugin(this);
        pluginGroup.add(accPlugin);
        plugins.add(accPlugin);
        
        var blockPopPlugin = new BlockPopEffectPlugin(this, colorSource, screenWorldTransform);
        pluginGroup.add(blockPopPlugin);
        plugins.add(blockPopPlugin);
        
        var comboPlugin = new ComboScoreEffectPlugin(this, colorSource, screenWorldTransform);
        pluginGroup.add(comboPlugin);
        plugins.add(comboPlugin);
        
        #if (mobile || html5)
        var scorePlugin:SimpleScorePlugin = new SimpleScorePlugin(this, colorSource);
        pluginGroup.add(scorePlugin);
        plugins.add(scorePlugin);
        #else
        var scorePlugin:AccumulateScorePlugin = new AccumulateScorePlugin(this, colorSource);
        pluginGroup.add(scorePlugin);
        plugins.add(scorePlugin);
        #end
        
        rotatePlugin = new ColorRotatePlugin(this, colorSource);
        pluginGroup.add(rotatePlugin);
        plugins.add(rotatePlugin);
        
        controlPlugin = new GamePieceControlPlugin(this, input);
        physicsWorld.externalAccumulator = controlPlugin.MoveAccumulator;
        pluginGroup.add(controlPlugin);
        plugins.add(controlPlugin);
        
        spawnPlugin = new GamePieceSpawnPlugin(this, colorSource, physicsWorld, pieceBuilder);
        spawnPlugin.controlPlugin = controlPlugin;
        pluginGroup.add(spawnPlugin);
        plugins.add(spawnPlugin);
        
        #if debug
        var fpsPlugin = new FrameRatePlugin(this);
        pluginGroup.add(fpsPlugin);
        plugins.add(fpsPlugin);
        #end
    }
    
    override function destroy():Void{
        super.destroy();
        render.destroy();
    }
    
    function setupTexturedRender() : BaseDrawWorld
    {
        var render:BaseDrawWorld = new TexturedDrawWorld(createDrawSurface(), colorSource, this, physicsWorld, screenWorldTransform);
        return render;
    }
    
    function setupSolidColorRender() : BaseDrawWorld
    {
        var render:BaseDrawWorld = new SolidColorDrawWorld(createDrawSurface(), colorSource, this, physicsWorld, screenWorldTransform, spawnPlugin);
        return render;
    }
    
    function setupDebugRender() : BaseDrawWorld
    {
        var render:BaseDrawWorld = new DebugDrawWorld(createDrawSurface(), colorSource, physicsWorld, screenWorldTransform);
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
                        case "pause": pauseMenu();
                    }
                }
            case "RELOAD":
                FlxG.resetState();
        }
    }
    
    private function pauseMenu():Void{
        openSubState(new PauseMenu());
    }
    
    private function gameOver():Void{
        openSubState(new GameOverMenu());
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
        //flxDrawSurface = new FlxSprite(0,0).makeGraphic(WINDOW_WIDTH, WINDOW_HEIGHT, FlxColor.TRANSPARENT);
        flxDrawSurface = new FlxSprite(offscreenRenderX,offscreenRenderY).makeGraphic(WINDOW_WIDTH, WINDOW_HEIGHT, FlxColor.TRANSPARENT);
        renderGroup.add(flxDrawSurface);
        
        debugDrawSurface = new Sprite();
        
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
        
        render.update(elapsed);
        
        if(!physicsPaused){
            physicsWorld.Update(elapsed);
        }
        
        #if (debug && !mobile)
        if (FlxG.mouse.justPressed){
            //trace("mouse click: ("+FlxG.mouse.screenX+", "+FlxG.mouse.screenY+")");
            var localX:Float = worldToLocalX(FlxG.mouse.screenX);
            var localY:Float = worldToLocalY(FlxG.mouse.screenY);
            //trace("as world coordinate:: (" + localX + ", " + localY + ")");
            var underCursor:Body = physicsWorld.GetBodyContaining(new Vector2(localX, localY));
            if (underCursor != null){
                trace("********************");
                trace("clicked body id: " + underCursor.BodyNumber);
                var instersectResult:String = "";
                var aabbBodies:List<Body> = physicsWorld.BodiesThatIntersectAABB(underCursor);
                if (aabbBodies.length > 0){
                    for (body in aabbBodies){
                        instersectResult = instersectResult + body.BodyNumber + " ";
                    }
                    trace("AABBs that intersect " + underCursor.BodyNumber + ": " + instersectResult);
                }
                var otherBodies:List<Body> = physicsWorld.BodiesThatIntersect(underCursor);
                if (otherBodies.length > 0){
                    instersectResult = "";
                    for (body in otherBodies){
                        instersectResult = instersectResult + body.BodyNumber + " ";
                    }
                    trace("Bodies that intersect " + underCursor.BodyNumber + ": " + instersectResult);
                }
            }
        }
        #end
        
        clearColliding();
    }
    public var off:Vector2 = new Vector2(225, 300);
    public var sc:Vector2 = new Vector2(17.916666666666668, 17.916666666666668);       
    private function localToWorldX(x:Float):Int{
        return Std.int((x * sc.x) + off.x);
    }
    
    private function localToWorldY(y:Float):Int{
        return Std.int((y * sc.y) + off.y);
    }    
    private function worldToLocalX(x:Int):Float{
        var worldX:Float = x;
        return (worldX - off.x) / sc.x;
    }
    
    private function worldToLocalY(y:Int):Float{
        var worldY:Float = y;
        return (worldY - off.y) / sc.y;
    }
    
    private function OnColorRotated(sender:Dynamic, event:String, params:Array<Dynamic>):Void{
        unfreezeKey(FlxKey.F, PressType.Down);
        
        if (background != null){
            backgroundIndex = (backgroundIndex + 1) % backgroundAssets.length;
            background.loadGraphic(backgroundAssets[backgroundIndex]);
            
            var scaleRatio:Float = FlxG.height / background.height;
            background.scale.set(scaleRatio, scaleRatio);
            background.updateHitbox();
        }
    }
    
    private function OnNewGamePiece(sender:Dynamic, event:String, params:Array<Dynamic>):Void{
        if (params == null || params.length < 2){
            return;
        }
        var prevPiece:GamePiece = cast params[0];
        var currPiece:GamePiece = cast params[1];
        
        if (prevPiece != null){
            var yPos:Float = prevPiece.GamePieceCenter().y;
            if (yPos <= GameConstants.GAME_WORLD_FAIL_HEIGHT){
                gameOver();
            }
        }
    }
    
    private function adjustColorUp(key: FlxKey, type:PressType):Void{
        colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.05) % 1.0;
        EventManager.Trigger(this, Events.COLOR_ROTATE);
    }
    
    private function adjustColorDown(key: FlxKey, type:PressType):Void{
        colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.95) % 1.0;
        EventManager.Trigger(this, Events.COLOR_ROTATE);
    }
    
    private function unfreezeKey(key: FlxKey, type:PressType):Void{
        unfreeze();
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
    
    private function unfreezeBtn(button: FlxGamepadInputID, type:PressType):Void{
        unfreezeKey(FlxKey.F, PressType.Pressed);
    }
    
    private function scrambleColorsBtn(button: FlxGamepadInputID, type:PressType):Void{
        scrambleColors();
    }
    
    private function scrambleColorsKey(key:FlxKey, type:PressType):Void{
        scrambleColors();
    }
    
    private function pauseBtn(button: FlxGamepadInputID, type:PressType):Void{
        pauseMenu();
    }
    
    private function pauseKey(key:FlxKey, type:PressType):Void{
        pauseMenu();
    }
    
    private function zoomOut(key:FlxKey, type:PressType):Void{
        trace("zoom render camera out.");
        this.renderGroup.camera.zoom = this.renderGroup.camera.zoom * 0.95;
    }
    
    private function zoomIn(key:FlxKey, type:PressType):Void{
        trace("zoom render camera in.");
        this.renderGroup.camera.zoom = this.renderGroup.camera.zoom * 1.05;
    }
    
    private function shake(key:FlxKey, type:PressType):Void{
        trace("shaking camera.");
        this.renderCamera.shake(0.01, 0.05);
    }
    
    private function camUp(key:FlxKey, type:PressType):Void{
        this.renderCamera.y -= 5;
        trace("camera up, y: " + this.renderCamera.y);
    }
    
    private function camDown(key:FlxKey, type:PressType):Void{
        this.renderCamera.y += 5;
        trace("camera down, y: " + this.renderCamera.y);
    }
    
    private function camLeft(key:FlxKey, type:PressType):Void{
        this.renderCamera.x -= 5;
        trace("camera up, x: " + this.renderCamera.x);
    }
    
    private function camRight(key:FlxKey, type:PressType):Void{
        this.renderCamera.x += 5;
        trace("camera down, x: " + this.renderCamera.x);
    }
    
    private function pausePhysics(key:FlxKey, type:PressType):Void{
        physicsPaused = !physicsPaused;
    }
    
    private function gameOverKey(key:FlxKey, type:PressType):Void{
        gameOver();
    }
    
    private function scrambleColors():Void{
        trace("scrambling colors...");
        var random:FlxRandom = new FlxRandom();
        for (i in 0...physicsWorld.NumberBodies){
            var body:Body = physicsWorld.GetBody(i);
            if (!body.IsStatic){
                body.Material = random.int(0, GameConstants.UniqueColors - 1);
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
        blockBuilder = new GameBlockBuilder().setKinematic(true).setMass(Math.POSITIVE_INFINITY)
                            .setPressure(PhysicsDefaults.InitialBlockPressure)
                            .setMaterial(constants.GameConstants.MATERIAL_GROUND)
                            .setSameMaterialCallback(sameMaterialCallback);
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
                physicsWorld.addGamePiece(createGamePiece(pieceBuilder, new Vector2(colLoc, rowLoc)), false, false);
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
    
    private function clearColliding():Void{
        for (list in collidingBlocks){
            if (list.length > 2){
                for (block in list){
                    var freezingBlock = Std.instance(block, FreezingGameBlock);
                    if (freezingBlock != null){
                        
                    }
                    block.Popping = true;
                }
            }
            list = null;
        }
        collidingBlocks = new Array<Array<GameBlock>>();
    }
    private var collidingBlocks:Array<Array<GameBlock>> = new Array<Array<GameBlock>>();
    private function sameMaterialCallback(block1:GameBlock, block2:GameBlock):Void{
        if (block1.IsStatic || block2.IsStatic){
            return;
        }
        
        var added:Bool = false;
        for (list in collidingBlocks){
            var block1Index:Int = list.indexOf(block1);
            var block2Index:Int = list.indexOf(block2);
            if (block1Index == -1 && block2Index == -1){
                continue;
            }else{
                if (block1Index == -1){
                    list.push(block1);
                }
                if (block2Index == -1){
                    list.push(block2);
                }
                added = true;
            }
        }
        
        if(!added){
            var newList:Array<GameBlock> = [block1, block2];
            collidingBlocks.push(newList);
        }
    }
}
