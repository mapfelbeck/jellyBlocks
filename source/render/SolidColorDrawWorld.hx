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
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxPoint;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SolidColorDrawWorld extends BaseDrawWorld 
{
    private static var groundAssetPath:String =  "assets/images/gameArena.png";
    
    private var parentState:PlayState;
    private var renderTarget:FlxSprite;
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
    private static var BORDER_FLICKER: Int = 1;
    
    public function new(sprite:FlxSprite, colorSource:IColorSource, parentState:PlayState, physicsWorld:JellyBlocksWorld, screenWorldTransform:ScreenWorldTransform, spawnPlugin: GamePieceSpawnPlugin)
    {
        super(colorSource, screenWorldTransform);
        
        this.spawnPlugin = spawnPlugin;
        this.parentState = parentState;
        renderTarget = sprite;
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
		gameArenaSprite.x = GameConstants.offscreenRenderX + Std.int((transform.screenWidth - arenaWidth) / 2);
		gameArenaSprite.y = GameConstants.offscreenRenderY + Std.int((transform.screenHeight - arenaHeight) / 2);
		parentState.renderGroup.add(gameArenaSprite);
    }
    
    public override function Draw():Void
    {
        FlxSpriteUtil.fill(renderTarget, FlxColor.TRANSPARENT);
        
        var outlineWithAlpha:FlxColor = outlineColor;
        outlineWithAlpha.alpha = Std.int(256 * outlineAlpha);
        FlxSpriteUtil.setLineStyle( { color: outlineColor, thickness: 0 });
        
        for (i in 0...world.GamePieces.length){
            var piece:GamePiece = world.GamePieces[i];
            var controlled:Bool = piece.IsControlled;

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
        var normalColor = outlineColor;
        normalColor.alpha = Std.int(256 * outlineAlpha);
        var style:LineStyle = { color: normalColor, thickness: BORDER_NORMAL };
            
        var freezingBlock:FreezingGameBlock = Std.instance(block, FreezingGameBlock);
        if (freezingBlock.IsFrozen) {
            var frozenWithAlpha:FlxColor = outlineColor;
            frozenWithAlpha.alpha = Std.int(256 * Math.max(outlineAlpha - 0.25, 0));
            style.color = frozenWithAlpha;
            style.thickness = BORDER_FROZEN;
        }else if (freezingBlock.Popping) {
            var poppingWithAlpha:FlxColor = colorSource.getColor(freezingBlock.Material);
            style.color = colorSource.getColor(freezingBlock.Material);
            style.thickness = BORDER_POPPING;
        }else if (controlled){
            var controlledPieceColor:FlxColor = outlineColor;
            if (aboveFailHeight && lossOfControlWarn){
                controlledPieceColor = FlxColor.RED;
            }
            controlledPieceColor.alpha = Std.int(256 * Math.min(outlineAlpha + 0.5, 1));
            
            var controlledPieceBorder:Int = BORDER_CONTROLLED;
            if (warningFlickerOn){
                controlledPieceBorder = BORDER_FLICKER;
            }
            
            style.color = controlledPieceColor;
            style.thickness = controlledPieceBorder;
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
        
        color.alpha = Std.int(256 * alpha);
        drawBody(shape, color, style);
    }
    
    private static var TIME_TILL_WARN:Float = 5.5; //start flashing the controlled piece at this time to warn player will lose control
    private static var FLICKER_RATE_MAX:Float = 0.6;
    private static var FLICKER_RATE_MIN:Float = 0.1;
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
    
    function drawBody(shape:Array<Vector2>, color:FlxColor, style:LineStyle) 
    {
        var transformedShape:Array<FlxPoint> = shape.map(function(v){
            return new FlxPoint(transform.localToWorldX(v.x) , transform.localToWorldY(v.y));
        });

        FlxSpriteUtil.drawPolygon(renderTarget, transformedShape, color, style);
    }
}