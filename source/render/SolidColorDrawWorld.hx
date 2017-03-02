package render;
import blocks.GameBlock;
import blocks.FreezingGameBlock;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import jellyPhysics.*;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SolidColorDrawWorld extends BaseDrawWorld 
{
    private static var groundAssetPath:String =  "assets/images/gameArena.png";
    public var backgroundSize:Vector2;
    
    private var parentState:FlxState;
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:World;
    private var worldBounds:AABB;
    
	private var gameArenaSprite:FlxSprite;

    public var width:Int = 0;
    public var height:Int = 0;
    public var overscan:Int = 0;
    
    public var SizeOfVert:Float = 4;
    
    private var outlineColor:FlxColor = FlxColor.BLACK;
    //higher = darker, [0...1]
    private var outlineAlpha:Float = 0.25;
    
    public function new(sprite:Sprite, colorSource:IColorSource, parentState:FlxState, physicsWorld:World, width:Int, height:Int, overscan:Int) 
    {
        super(colorSource);
        
        this.parentState = parentState;
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;
        
        setupDrawParam();
        
        setRenderAndOffset(width, height, overscan);
    }

    public override function setGameGround(ground:GameGround):Void{
        super.setGameGround(ground);
		var h:Float = ground.Height;
		var w:Float = ground.Width;
		var b:Float = ground.Border;
		gameArenaSprite = new FlxSprite(0, 0, groundAssetPath);

		var center:Vector2 = new Vector2(0, 0);
		var borderSize:Vector2 = new Vector2(ground.Border, ground.Border);
		var centerAsScreen:Vector2 = new Vector2(center.x * scale.x + offset.x, center.y * scale.y + offset.y);
		var borderSizeAsScreen:Vector2 = new Vector2(borderSize.x * scale.x + offset.x, borderSize.y * scale.y + offset.y);
		var diff:Vector2 = VectorTools.Subtract(borderSizeAsScreen, centerAsScreen);
		diff.x *= 0.5;
		diff.y *= 0.5;
		var arenaWidth:Int = Std.int(diff.x * (2 * ground.Border + ground.Width));
		var arenaHeight:Int = Std.int(diff.y * (2 * ground.Border + ground.Height));

		gameArenaSprite.setGraphicSize(arenaWidth, arenaHeight);
		gameArenaSprite.updateHitbox();
		gameArenaSprite.x = Std.int((width - arenaWidth) / 2);
		gameArenaSprite.y = Std.int((height - arenaHeight) / 2);
		parentState.add(gameArenaSprite);
    }
    
    private var worldWidth:Float;
    private var worldHeight:Float;
    private function setRenderAndOffset(width:Int, height:Int, overscan:Int):Void{
        worldBounds = world.WorldBounds;
        worldWidth = worldBounds.LR.x - worldBounds.UL.x;
        worldHeight = worldBounds.LR.y - worldBounds.UL.y;
        this.overscan = overscan;
        this.width = width;
        this.height = height;
        backgroundSize = new Vector2(width - (2 * overscan), height - (2 * overscan));
        offset.x = width / 2;
        offset.y = height / 2;
        
        var hScale:Float = backgroundSize.x / worldWidth;
        var wScale:Float = backgroundSize.y / worldHeight;
        scale.x = Math.min(hScale, wScale);
        scale.y = Math.min(hScale, wScale);
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
            graphics.lineStyle(0, outlineColor, outlineAlpha);
        }else if (freezingBlock.Popping) {
            graphics.lineStyle(2, colorSource.getColor(freezingBlock.Material), 1.0);
        }else if (freezingBlock.IsControlled){
            graphics.lineStyle(0, outlineColor, outlineAlpha + 0.5);
        }else{
            graphics.lineStyle(0, outlineColor, outlineAlpha);
        }
        var shape:Array<Vector2> = new Array<Vector2>();
        for (i in 0...freezingBlock.PointMasses.length){
            shape.push(freezingBlock.PointMasses[i].Position);
        }
        
        var color:FlxColor = FlxColor.WHITE;
        if (freezingBlock.Material != GameConstants.MATERIAL_GROUND){
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
        graphics.moveTo(localToWorldX(start.x) , localToWorldY(start.y) );
        for (i in 1...shape.length){
            var next:Vector2 = shape[i];
            //graphics.lineTo((next.x * scale.x) + offset.x, (next.y * scale.y) + offset.y);
            graphics.lineTo(localToWorldX(next.x) , localToWorldY(next.y));
        }
        graphics.endFill();
    }
    
    private function localToWorldX(x:Float):Float{
        return Math.round((x * scale.x) + offset.x);
    }
    
    private function localToWorldY(y:Float):Float{
        return Math.round((y * scale.y) + offset.y);
    }
}