package render;
import blocks.GameBlock;
import blocks.FreezingGameBlock;
import constants.GameConstants;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import jellyPhysics.*;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;
import util.ScreenWorldTransform;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SolidColorDrawWorld extends BaseDrawWorld 
{
    private static var groundAssetPath:String =  "assets/images/gameArena.png";
    
    private var parentState:FlxState;
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:World;
    private var worldBounds:AABB;
    
	private var gameArenaSprite:FlxSprite;
        
    private var outlineColor:FlxColor = FlxColor.BLACK;
    //higher = darker, [0...1]
    private var outlineAlpha:Float = 0.5;
        
    public function new(sprite:Sprite, colorSource:IColorSource, parentState:FlxState, physicsWorld:World, screenWorldTransform:ScreenWorldTransform)
    {
        super(colorSource, screenWorldTransform);
        
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
		parentState.add(gameArenaSprite);
    }
    
    public override function Draw():Void
    {
        graphics.clear();
        graphics.lineStyle(0, outlineColor, outlineAlpha);
        
        for (i in 0...world.NumberBodies){
            var block:GameBlock = Std.instance(world.GetBody(i), GameBlock);
            
            if (block.IsStatic){
                continue;
            }
            
            drawBlock(block);
        }
    }
        
    function drawBlock(block:GameBlock) 
    {
        var freezingBlock:FreezingGameBlock = Std.instance(block, FreezingGameBlock);
        if (freezingBlock.IsFrozen) {
            graphics.lineStyle(0, outlineColor, outlineAlpha - 0.25);
        }else if (freezingBlock.Popping) {
            graphics.lineStyle(2, colorSource.getColor(freezingBlock.Material), 1.0);
        }else if (freezingBlock.IsControlled){
            graphics.lineStyle(3, outlineColor, outlineAlpha + 0.5);
        }else{
            graphics.lineStyle(0, outlineColor, outlineAlpha);
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