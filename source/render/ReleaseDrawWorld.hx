package render;
import jellyPhysics.*;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;
import openfl.text.TextField;
import render.DebugDrawBodyOption;
import flixel.util.FlxColor;
import haxe.ds.Vector;
import openfl.Assets;
import render.BaseDrawWorld;

/**
 * ...
 * @author 
 */
class ReleaseDrawWorld extends BaseDrawWorld
{
    private static var groundAssetPath:String = "assets/images/gameArena.png";
    private static var tileAssetPath:String = "assets/images/tiled greyscale.png";
    private static var frostedAssetPath:String = "assets/images/frosted greyscale.png";
    
    private static var groundAssetImage:FlxSprite;
    private var parentState:FlxState;
    public var drawLookup:Map<Int,DebugDrawBodyOption>;
    public var drawPhysicsBodyDefault:DebugDrawBodyOption;
    public var backgroundSize:Vector2;
    
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:World;
    private var worldBounds:AABB;
    
    private var labels:Array<TextField>;
    
    public var width:Int = 0;
    public var height:Int = 0;
    public var overscan:Int = 0;
    
    public var ColorOfBackground:Int = BaseDrawWorld.COLOR_BLACK;
    public var ColorOfGlobalVerts:Int = BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfGlobalBody:Int = BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfPhysicsBody:Int = BaseDrawWorld.COLOR_WHITE;

    public function new(sprite:Sprite, parentState:FlxState, physicsWorld:World, width:Int, height:Int, overscan:Int) 
    {
        super();
        drawLookup = new Map<Int,render.DebugDrawBodyOption>();
        drawPhysicsBodyDefault = new render.DebugDrawBodyOption(0, ColorOfPhysicsBody, false);
    
        this.parentState = parentState;
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;
        
        setupDrawParam();
        
        setRenderAndOffset(width, height, overscan);
    }
    
    public override function setGameGround(ground:GameGround){
        super.setGameGround(ground);
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
    
    function createTextLabels(count:Int) 
    {
        if(labels==null){
            labels = new Array<TextField>();
        }
        
        while (labels.length > count){
            var label:TextField = labels.pop();
            renderTarget.removeChild(label);
            label = null;
        }
        
        while (labels.length < count){
            var label:TextField = new TextField();
            label.mouseEnabled = false;
            renderTarget.addChild(label);
            labels.push(label);
        }
    }
    
    public override function Draw():Void
    {
        graphics.clear();
        
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            /*if (body.IsStatic){
                continue;
            }*/
            drawPhysicsBody(body);
        }
    }
    
    public function SetMaterialDrawOptions(material:Int, color:Int, isSolid:Bool) 
    {
        if (drawLookup.exists(material)){
            drawLookup[material].Color = color;
            drawLookup[material].IsSolid = isSolid;
        }else{
            var newOption:render.DebugDrawBodyOption = new render.DebugDrawBodyOption(material, color, isSolid);
            drawLookup.set(material, newOption);
        }
    }
    
    public function SetDefaultBodyDrawOptions(color:Int, isSolid:Bool) 
    {
        drawPhysicsBodyDefault.Color = color;
        drawPhysicsBodyDefault.IsSolid = isSolid;
    }
    
    function drawPhysicsBody(body:Body) 
    {
        var shape:Array<Vector2> = new Array<Vector2>();
        for (i in 0...body.PointMasses.length){
            shape.push(body.PointMasses[i].Position);
        }
        
        drawBody(shape, getDrawOptions(body));
    }
    
    private function getDrawOptions(body:Body):render.DebugDrawBodyOption{
        var drawOpts:render.DebugDrawBodyOption;
        if (drawLookup.exists(body.Material)){
            drawOpts = drawLookup.get(body.Material);
        }else{
            drawOpts = drawPhysicsBodyDefault;
        }
        return drawOpts;
    }
    
    function drawBody(shape:Array<Vector2>, opts:render.DebugDrawBodyOption) 
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
        for (i in 1...colors.length + 1){
            this.SetMaterialDrawOptions(i, colors[i-1], true);
        }
    }
}