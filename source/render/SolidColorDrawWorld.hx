package render;
import jellyPhysics.*;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;
import openfl.text.TextField;
import render.DebugDrawBodyOption;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SolidColorDrawWorld extends BaseDrawWorld 
{
    private static var groundAssetPath:String =  "assets/images/gameArena.png";
    public var drawLookup:Map<Int,DebugDrawBodyOption>;
    public var drawBodyDefault:DebugDrawBodyOption;
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
    
    public function new(sprite:Sprite, parentState:FlxState, physicsWorld:World, width:Int, height:Int, overscan:Int) 
    {
        super();
        drawLookup = new Map<Int,DebugDrawBodyOption>();
        drawBodyDefault = new DebugDrawBodyOption(0, FlxColor.WHITE, true);
    
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
        
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            if (body.IsStatic){
                continue;
            }
            
            drawPhysicsBody(body);
        }
    }
    
    public function SetMaterialDrawOptions(material:Int, color:Int, isSolid:Bool) 
    {
        if (drawLookup.exists(material)){
            drawLookup[material].Color = color;
            drawLookup[material].IsSolid = isSolid;
        }else{
            var newOption:DebugDrawBodyOption = new DebugDrawBodyOption(material, color, isSolid);
            drawLookup.set(material, newOption);
        }
    }
        
    function drawPhysicsBody(body:Body) 
    {
        var shape:Array<Vector2> = new Array<Vector2>();
        for (i in 0...body.PointMasses.length){
            shape.push(body.PointMasses[i].Position);
        }
        
        drawBody(shape, getDrawOptions(body));
    }
    
    private function getDrawOptions(body:Body):DebugDrawBodyOption{
        var drawOpts:DebugDrawBodyOption = null;
        if (drawLookup.exists(body.Material)){
            drawOpts = drawLookup.get(body.Material);
        }else{
            drawOpts = drawBodyDefault;
        }
        return drawOpts;
    }
    
    function drawBody(shape:Array<Vector2>, opts:DebugDrawBodyOption) 
    {
        graphics.lineStyle(0, opts.Color);
        var start:Vector2 = shape[0];
        if (opts.IsSolid){
            graphics.beginFill(opts.Color, 1.0);
        }
        graphics.moveTo((start.x * scale.x) + offset.x , (start.y * scale.y) + offset.y );
        for (i in 0...shape.length){
            var next:Vector2;
            if (i == shape.length-1){
                next = shape[0];
            }else{
                next = shape[i+1];
            }
            graphics.lineTo((next.x * scale.x) + offset.x, (next.y * scale.y) + offset.y);
        }
        if (opts.IsSolid){
            graphics.endFill();
        }
    }
    
    public override function setupDrawParam():Void
    {
        super.setupDrawParam();
        this.SetMaterialDrawOptions(GameConstants.MATERIAL_GROUND, BaseDrawWorld.COLOR_WHITE, false);
        var colors:Array<Int> = makeColors(.8, .9, GameConstants.UniqueColors);
        for (i in 0...colors.length){
            this.SetMaterialDrawOptions(i, colors[i], true);
        }
    }
}