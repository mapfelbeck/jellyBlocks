package plugins;

import builders.GamePieceBuilder;
import enums.PressType;
import events.*;
import jellyPhysics.math.Vector2;
import flixel.addons.ui.FlxUIState;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import gamepieces.GamePiece;
import flixel.FlxSprite;

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
    private var minLifeTime:Float = 3.0;
    //spawn pieces at at least this interval
    private var maxLifeTime:Float = 7.0;
    
    private var previewBar:FlxBar;
    
    private var input:Input;
    
    private var world:JellyBlocksWorld;
    private var builder:GamePieceBuilder;
        
    public var gamePiece:GamePiece = null;
    
    private var previewBackgroundSize:Int = 60;
    
    private static var fullBarSpriteAssetPath:String =  "assets/images/previewBarFull.png";
    private static var emptyBarSpriteAssetPath:String =  "assets/images/previewBarEmpty.png";
    private static var backgroundAssetPath:String =  "assets/images/piecePreviewBackground.png";
    private var fullBar:FlxSprite;
    private var emptyBar:FlxSprite;
    private var background:FlxSprite;
    
    public function new(parent:FlxUIState, world:JellyBlocksWorld,builder:GamePieceBuilder, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(parent, X, Y, SimpleGraphic);
        
        this.builder = builder;
        this.world = world;
        
        var WINDOW_WIDTH:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
        var WINDOW_HEIGHT:Int = Std.parseInt(haxe.macro.Compiler.getDefine("windowHeight"));
        var yPos:Int = Std.int(WINDOW_HEIGHT / 20);
        yPos -= 10;
        var xPos:Int = Std.int(WINDOW_WIDTH / 20);
        xPos -= 10;

        background = new FlxSprite(0, 0, backgroundAssetPath);
        var backgroundScale:Float = previewBackgroundSize / background.width;
        background.scale.set(backgroundScale, backgroundScale);
        background.updateHitbox();
        background.y = yPos;
        background.x = xPos;
        parent.add(background);
        
        emptyBar = new FlxSprite(0, 0, emptyBarSpriteAssetPath);
        fullBar = new FlxSprite(0, 0, fullBarSpriteAssetPath);
        
        previewBar = new FlxBar(xPos, yPos+previewBackgroundSize, FlxBarFillDirection.TOP_TO_BOTTOM, Std.int(emptyBar.width), Std.int(emptyBar.height), this, "spawnTimer", 0, spawnTimerMax, true);
        previewBar.createImageBar(emptyBar.pixels, fullBar.pixels, FlxColor.TRANSPARENT, FlxColor.RED);
        parent.add(previewBar);
        
        input = new Input();
        input.AddInputCommand(FlxKey.SPACE, spawnPiece, PressType.Down);
        
        spawnTimerInc = spawnTimerMax / timeTillFirstSpawn;
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        input.Update(elapsed);
        
        timeSinceSpawn += elapsed;
        
        if (gamePiece!= null && gamePiece.HasEverCollided){
            spawnTimerInc = spawnTimerMax / minLifeTime;
        }
        
        spawnTimer += spawnTimerInc * elapsed;
        if (spawnTimer > spawnTimerMax){
            spawnTimer = 0;
            spawnTimerInc = spawnTimerMax / maxLifeTime;
            addGamePiece(createGamePiece(builder, new Vector2(-1, -10)), true);
            timeSinceSpawn = 0.0;
        }
    }
    
    public function createGamePiece(pieceBuilder:GamePieceBuilder, location:Vector2) :GamePiece
    {
        pieceBuilder = pieceBuilder.setLocation(location);
        return pieceBuilder.create();
    }
    
    public function addGamePiece(newGamePiece:GamePiece, controlled:Bool):Void
    {
        world.addGamePiece(newGamePiece, controlled);
        
        if (controlled){
            if(gamePiece != null){
                gamePiece.IsControlled = false;
            }
            newGamePiece.IsControlled = true;
            gamePiece = newGamePiece;
        }
    }
    
    private function spawnPiece():Void{
        if (timeSinceSpawn > minLifeTime){
            spawnTimer = spawnTimerMax;
        }
    }
    
}