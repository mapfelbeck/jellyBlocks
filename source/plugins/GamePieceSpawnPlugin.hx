package plugins;

import builders.GamePieceBuilder;
import enums.*;
import events.*;
import openfl.display.*;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import gamepieces.GamePiece;
import jellyPhysics.math.Vector2;
import render.IColorSource;
import patterns.TriominoPatterns;

/**
 * ...
 * @author Michael Apfelbeck
 */
class GamePieceSpawnPlugin extends PluginBase 
{
    private var timeSinceSpawn:Float = 0;
    private var spawnTimer:Float = 0.0;
    private var spawnTimerMax:Float = 10.0;
    private var spawnTimerInc:Float = 0.0;
    //timer starts spawning pieces 3 seconds after game loads.
    private var timeTillFirstSpawn:Float = 3.0;
    //don't spaw pieces at less than this interval
    private var minLifeTime:Float = 4.0;
    //spawn pieces at at least this interval
    private var maxLifeTime:Float = 8.0;
    
    private var previewBar:FlxBar;
    
    private var input:Input;
    
    private var world:JellyBlocksWorld;
    private var builder:GamePieceBuilder;
        
    public var previewGamePiece:GamePiece = null;
    public var controlledGamePiece:GamePiece = null;
    
    private var previewBackgroundSize:Int = 70;
    
    private static var fullPreviewBarAssetPath:String =  "assets/images/previewBarFull.png";
    private static var emptyPreviewBarAssetPath:String =  "assets/images/previewBarEmpty.png";
    private static var backgroundAssetPath:String =  "assets/images/piecePreviewBackground.png";
    private var fullPreviewBar:FlxSprite;
    private var emptyPreviewBar:FlxSprite;
    private var previewBackground:FlxSprite;
    private var previewOverlay:FlxSprite;
    
    private var previewPos:Vector2 = new Vector2(-11, -15);
    private var spawnPos:Vector2 = new Vector2( -1, -10);
    
    private var colorSource:IColorSource;
    
    public function new(parent:FlxUIState, colorSource:IColorSource, world:JellyBlocksWorld,builder:GamePieceBuilder, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(parent, X, Y, SimpleGraphic);
        
        this.builder = builder;
        this.world = world;
        this.colorSource = colorSource;
        
        var WINDOW_WIDTH:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
        var WINDOW_HEIGHT:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowHeight"));
        var yPos:Int = Std.int(WINDOW_HEIGHT / 20);
        yPos -= 20;
        var xPos:Int = Std.int(WINDOW_WIDTH / 20);
        xPos -= 10;

        previewBackground = new FlxSprite(0, 0, backgroundAssetPath);
        var backgroundScale:Float = previewBackgroundSize / previewBackground.width;
        previewBackground.scale.set(backgroundScale, backgroundScale);
        previewBackground.updateHitbox();
        previewBackground.x = xPos;
        previewBackground.y = yPos;
        parent.add(previewBackground);
        previewOverlay = new FlxSprite(xPos, yPos);
        parent.add(previewOverlay);
        
        emptyPreviewBar = new FlxSprite(0, 0, emptyPreviewBarAssetPath);
        fullPreviewBar = new FlxSprite(0, 0, fullPreviewBarAssetPath);
        
        previewBar = new FlxBar(xPos, yPos+previewBackgroundSize, FlxBarFillDirection.TOP_TO_BOTTOM, Std.int(emptyPreviewBar.width), Std.int(emptyPreviewBar.height), this, "spawnTimer", 0, spawnTimerMax, true);
        previewBar.createImageBar(emptyPreviewBar.pixels, fullPreviewBar.pixels, FlxColor.TRANSPARENT, FlxColor.RED);
        parent.add(previewBar);
        
        input = new Input();
        input.AddKeyboardInput(FlxKey.SPACE, spawnPiece, PressType.Down);
        
        spawnTimerInc = spawnTimerMax / timeTillFirstSpawn;
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        input.Update(elapsed);
        
        if (previewGamePiece == null){
            previewGamePiece = createGamePiece(builder, spawnPos);
            previewOverlay.makeGraphic(previewBackgroundSize, previewBackgroundSize, FlxColor.MAGENTA);
            makePreviewOverlay();
        }
        
        timeSinceSpawn += elapsed;
        
        if (controlledGamePiece!= null && controlledGamePiece.HasEverCollided){
            spawnTimerInc = spawnTimerMax / minLifeTime;
        }
        
        spawnTimer += spawnTimerInc * elapsed;
        if (spawnTimer > spawnTimerMax){
            if (controlledGamePiece != null){
                controlledGamePiece.IsControlled = false;
            }
            controlledGamePiece = previewGamePiece;
            //trace("new game piece is: " + controlledGamePiece.Shape);
            addGamePiece(controlledGamePiece, true, false);
            previewGamePiece = createGamePiece(builder, spawnPos);
            makePreviewOverlay();
            spawnTimer = 0;
            spawnTimerInc = spawnTimerMax / maxLifeTime;
            timeSinceSpawn = 0.0;
        }
    }
    
    private function makePreviewOverlay(){
        
        var blockSize:Int = Std.int(previewBackgroundSize / 3.5);
        var blockPattern:Array<Vector2> = TriominoPatterns.getPattern(previewGamePiece.Shape);
        var overLaybitmap:Sprite = new Sprite();
        overLaybitmap.cacheAsBitmap = true;
        overLaybitmap.graphics.lineStyle(1, FlxColor.BLACK, 0.5);
        for (i in 0...previewGamePiece.Blocks.length){
            var blockPos:Vector2 = blockPattern[i];
            var xOff:Float = 0;
            var yOff:Float = 0;
            if (previewGamePiece.Shape == TriominoShape.Line){
                xOff = (previewBackgroundSize-(blockSize * 3)) / 2;
                yOff = (previewBackgroundSize-blockSize) / 2;
            }else if (previewGamePiece.Shape == TriominoShape.Corner){
                xOff = (previewBackgroundSize-(blockSize * 2)) / 2;
                yOff = (previewBackgroundSize-(blockSize * 2)) / 2;
            }
            overLaybitmap.graphics.beginFill(colorSource.getColor(previewGamePiece.Blocks[i].Material));
            overLaybitmap.graphics.moveTo(xOff+(blockPos.x * blockSize), yOff+(blockPos.y * blockSize));
            overLaybitmap.graphics.lineTo(xOff+((blockPos.x+1) * blockSize), yOff+(blockPos.y * blockSize));
            overLaybitmap.graphics.lineTo(xOff+((blockPos.x+1) * blockSize), yOff+((blockPos.y+1) * blockSize));
            overLaybitmap.graphics.lineTo(xOff+(blockPos.x * blockSize), yOff+((blockPos.y+1) * blockSize));
            overLaybitmap.graphics.endFill();
        }
        
        var pixels:BitmapData = previewOverlay.pixels;
        pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
        pixels.draw(overLaybitmap);
        previewOverlay.pixels = pixels;
    }
    
    public function createGamePiece(pieceBuilder:GamePieceBuilder, location:Vector2) :GamePiece
    {
        pieceBuilder = pieceBuilder.setLocation(location);
        return pieceBuilder.create();
    }
    
    public function addGamePiece(newGamePiece:GamePiece, controlled:Bool, kinematic:Bool):Void
    {
        world.addGamePiece(newGamePiece, controlled, kinematic);
        
        if (controlled){
            if(controlledGamePiece != null){
                controlledGamePiece.IsControlled = false;
            }
            newGamePiece.IsControlled = true;
        }
    }
    
    private function spawnPiece(key:FlxKey, type:PressType):Void{
        if (timeSinceSpawn > minLifeTime){
            spawnTimer = spawnTimerMax;
        }
    }
    
}