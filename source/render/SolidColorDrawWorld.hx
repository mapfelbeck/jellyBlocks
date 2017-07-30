package render;
import blocks.FreezingGameBlock;
import blocks.GameBlock;
import constants.GameConstants;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import gamepieces.GamePiece;
import jellyPhysics.*;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;
import screenPlugins.GamePieceSpawnPlugin;
import screens.PlayState;
import util.ScreenWorldTransform;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SolidColorDrawWorld extends BaseDrawWorld 
{
    private static var groundAssetPath:String =  "assets/images/gameArena.png";
    
    private var parentState:PlayState;
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:JellyBlocksWorld;
    private var worldBounds:AABB;
    
	private var gameArenaSprite:FlxSprite;
    
    private var spawnPlugin: GamePieceSpawnPlugin;
    
    private static var outlineColor:FlxColor = FlxColor.BLACK;
    //higher = darker, [0...1]
    private static var outlineAlpha:Float = 0.5;
        
    private static var BORDER_NORMAL: Int = 1;
    private static var BORDER_FROZEN: Int = 1;
    private static var BORDER_POPPING: Int = 3;
    private static var BORDER_CONTROLLED: Int = 4;
    private static var BORDER_FLICKER: Int = 2;
    
    public function new(sprite:Sprite, colorSource:IColorSource, parentState:PlayState, physicsWorld:JellyBlocksWorld, screenWorldTransform:ScreenWorldTransform, spawnPlugin: GamePieceSpawnPlugin)
    {
        super(colorSource, screenWorldTransform);
        
        this.spawnPlugin = spawnPlugin;
        this.parentState = parentState;
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;
    }

    public override function setGameGround(ground:GameGround):Void{
        super.setGameGround(ground);
		var h:Float = ground.Height;
		var w:Float = ground.Width;
		var b:Float = ground.Border;
		gameArenaSprite = new FlxSprite(0, 0, groundAssetPath);

		var center:Vector2 = new Vector2(0, 0);
		var borderSize:Vector2 = new Vector2(ground.Border, ground.Border);
		var centerAsScreen:Vector2 = new Vector2(center.x * transform.scale.x + transform.offset.x, center.y * transform.scale.y + transform.offset.y);
		var borderSizeAsScreen:Vector2 = new Vector2(borderSize.x * transform.scale.x + transform.offset.x, borderSize.y * transform.scale.y + transform.offset.y);
		var diff:Vector2 = VectorTools.Subtract(borderSizeAsScreen, centerAsScreen);
		diff.x *= 0.5;
		diff.y *= 0.5;
		var arenaWidth:Int = Std.int(diff.x * (2 * ground.Border + ground.Width));
		var arenaHeight:Int = Std.int(diff.y * (2 * ground.Border + ground.Height));

		gameArenaSprite.setGraphicSize(arenaWidth, arenaHeight);
		gameArenaSprite.updateHitbox();
		gameArenaSprite.x = Std.int((transform.screenWidth - arenaWidth) / 2);
		gameArenaSprite.y = Std.int((transform.screenHeight - arenaHeight) / 2);
		parentState.renderGroup.add(gameArenaSprite);
    }
    
    public override function Draw():Void
    {
        graphics.clear();
        graphics.lineStyle(0, outlineColor, outlineAlpha);
        
        for (i in 0...world.GamePieces.length){
            var piece:GamePiece = world.GamePieces[i];
            var controlled:Bool = piece.IsControlled;
            //var yPos:Float = prevPiece.GamePieceCenter().y;
            //if (yPos <= GameConstants.GAME_WORLD_FAIL_HEIGHT){
            var aboveFailHeight:Bool = false;
            if (controlled){
                var yPos:Float = piece.GamePieceCenter().y;
                aboveFailHeight = (yPos <= GameConstants.GAME_WORLD_FAIL_HEIGHT);
            }
            for (j in 0...piece.Blocks.length){
                var block:GameBlock = piece.Blocks[j];
                drawBlock(block, controlled, aboveFailHeight);
            }
        }
    }
    
    function drawBlock(block:GameBlock, controlled:Bool, aboveFailHeight:Bool) 
    {
        var freezingBlock:FreezingGameBlock = Std.instance(block, FreezingGameBlock);
        if (freezingBlock.IsFrozen) {
            graphics.lineStyle(BORDER_FROZEN, outlineColor, outlineAlpha - 0.25);
        }else if (freezingBlock.Popping) {
            graphics.lineStyle(BORDER_POPPING, colorSource.getColor(freezingBlock.Material), 1.0);
        }else if (controlled){
            var controlledPieceColor:FlxColor = outlineColor;
            if (aboveFailHeight && lossOfControlWarn){
                controlledPieceColor = FlxColor.RED;
            }
            
            var controlledPieceBorder:Int = BORDER_CONTROLLED;
            if (warningFlickerOn){
                controlledPieceBorder = BORDER_FLICKER;
            }
            
            graphics.lineStyle(controlledPieceBorder, controlledPieceColor, outlineAlpha + 0.5);

        }else{
            graphics.lineStyle(BORDER_NORMAL, outlineColor, outlineAlpha);
        }
        var shape:Array<Vector2> = new Array<Vector2>();
        for (i in 0...freezingBlock.PointMasses.length){
            shape.push(freezingBlock.PointMasses[i].Position);
        }
        
        var color:FlxColor = FlxColor.WHITE;
        if (freezingBlock.Material != constants.GameConstants.MATERIAL_GROUND){
            color = colorSource.getColor(freezingBlock.Material);
        }
        
        var alpha:Float = 1.0;
        if (freezingBlock.Popping){
            alpha = 0.5;
        }
        
        drawBody(shape, color, alpha);
    }
    
    private static var TIME_TILL_WARN:Float = 5.5; //start flashing the controlled piece at this time to warn player will lose control
    private static var FLICKER_RATE_MAX:Float = 0.65;
    private static var FLICKER_RATE_MIN:Float = 0.15;
    private var warningFlickerOn:Bool = false;
    private var warningFlickerLength:Float = 0.0;
    private var lossOfControlWarn:Bool = false;
    
    override function update(elapsed: Float){
        if (spawnPlugin.TimeTillSpawn < TIME_TILL_WARN){
            lossOfControlWarn = true;
            warningFlickerLength += elapsed;
            var warningFlickerMax: Float = FlxMath.lerp(FLICKER_RATE_MIN, FLICKER_RATE_MAX, spawnPlugin.TimeTillSpawn / TIME_TILL_WARN);
            if (warningFlickerLength >= warningFlickerMax){
                warningFlickerOn = !warningFlickerOn;
                warningFlickerLength = 0;
            }
        } else {
            lossOfControlWarn = false;
            warningFlickerOn = false;
            warningFlickerLength = 0;
        }
    }
    
    function drawBody(shape:Array<Vector2>, color:FlxColor, alpha:Float) 
    {
        //graphics.lineStyle(0, opts.Color);
        //graphics.lineStyle(0, outlineColor);
        var start:Vector2 = shape[0];
        graphics.beginFill(color, alpha);
        //graphics.moveTo((start.x * scale.x) + offset.x , (start.y * scale.y) + offset.y );
        graphics.moveTo(transform.localToWorldX(start.x) , transform.localToWorldY(start.y) );
        for (i in 1...shape.length){
            var next:Vector2 = shape[i];
            //graphics.lineTo((next.x * scale.x) + offset.x, (next.y * scale.y) + offset.y);
            graphics.lineTo(transform.localToWorldX(next.x) , transform.localToWorldY(next.y));
        }
        graphics.endFill();
    }
}