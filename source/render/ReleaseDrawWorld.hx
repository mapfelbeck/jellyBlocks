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
    private static var groundAssetPath:String =  "assets/images/gameArena.png";
    private static var tileAssetPath:String =    "assets/images/tiled greyscale.png";
    private static var frostedAssetPath:String = "assets/images/frosted greyscale.png";
    
    private var parentState:FlxState;
    public var drawLookup:Map<Int,DebugDrawBodyOption>;
    public var drawPhysicsBodyDefault:DebugDrawBodyOption;
    public var backgroundSize:Vector2;
    
	private var colorSource:MultiColorSource;
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
	
	private var gameArenaSprite:NineSliceSprite;
	private var gameTileSprite:NineSliceSprite;
	
	private var activeBodyCount:Int = -1;
	var vertices:Vector<Float> = null;
	var indices:Vector<Int> = null;
	var uvtData:Vector<Float> = null;

    public function new(sprite:Sprite, parentState:FlxState, physicsWorld:World, width:Int, height:Int, overscan:Int) 
    {
        super();
        drawLookup = new Map<Int,render.DebugDrawBodyOption>();
        drawPhysicsBodyDefault = new render.DebugDrawBodyOption(0, ColorOfPhysicsBody, false);
    
        this.parentState = parentState;
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;
		
		colorSource = new MultiColorSource(GameConstants.UniqueColors);
        
        setupDrawParam();
        
        setRenderAndOffset(width, height, overscan);
    }

    public override function setGameGround(ground:GameGround){
        super.setGameGround(ground);
		//trace("I see a game ground with width " +ground.Width + ", height " + ground.Height + " and border " + ground.Border + ".");
		var h:Float = ground.Height;
		var w:Float = ground.Width;
		var b:Float = ground.Border;
		gameArenaSprite = new NineSliceSprite(0, 0, groundAssetPath, 
												[43,426,43,43,417,52], 
												[b, w, b, b, h, b]);
		gameTileSprite = new NineSliceSprite(0, 0, tileAssetPath, null, null, colorSource);

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
        //gameTileSprite.x = 0;
        //gameTileSprite.y = 0;
        //parentState.add(gameTileSprite);
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
        if (activeBodyCount != world.NumberBodies - ground.BodyCount)
        {
            activeBodyCount = world.NumberBodies - ground.BodyCount;
            trace("New active body count: " + activeBodyCount);
            allocateDrawVectors();
            
            var builtRed:Int = (255 << 24) + (255 << 16) + (0 << 8) + (0);
            var flxColorRed:Int = FlxColor.RED;
            trace("Red value: " + builtRed);
            trace("FlxColor.RED value: " + flxColorRed);
            
            /*for(i in 0...GameConstants.UniqueColors){
                var xOff:Float = uvXoffsetForMaterial(i);
                var yOff:Float = uvYoffsetForMaterial(i);
                trace("material " + i + " has offsets [" + xOff + "," + yOff + "]");
            }*/
        }
        graphics.clear();
        
		/*indices[0] = 0;
		indices[1] = 1;
		indices[2] = 3;
		indices[3] = 1;
		indices[4] = 2;
		indices[5] = 3;
		//texture co-ords
		uvtData[0] = 0;
		uvtData[1] = 0.33;
		
		uvtData[2] = 0.33;
		uvtData[3] = 0.33;
		
		uvtData[4] = 0.33;
		uvtData[5] = 0.66;
		
		uvtData[6] = 0;
		uvtData[7] = 0.66;*/
        var bodyIndex:Int = 0;
        //var upperLeft:Vector2 = new Vector2(0, 0);
        //var upperRight:Vector2 = new Vector2(0, 0);
        //var lowerRight:Vector2 = new Vector2(0, 0);
        //var lowerLeft:Vector2 = new Vector2(0, 0);
        //graphics.lineStyle(0, FlxColor.WHITE);
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            if (body.IsStatic){
                continue;
            }
            //drawPhysicsBody(body);
            var vertexIndex:Int = bodyIndex * vertexesPerBlock * elementsPerEntry;
            
            /*upperLeft.x = body.PointMasses[0].Position.x * scale.x + offset.x;
            upperLeft.y = body.PointMasses[0].Position.y * scale.y + offset.y;
            upperRight.x = body.PointMasses[1].Position.x * scale.x + offset.x;
            upperRight.y = body.PointMasses[1].Position.y * scale.y + offset.y;
            lowerRight.x = body.PointMasses[2].Position.x * scale.x + offset.x;
            lowerRight.y = body.PointMasses[2].Position.y * scale.y + offset.y;
            lowerLeft.x = body.PointMasses[3].Position.x * scale.x + offset.x;
            lowerLeft.y = body.PointMasses[3].Position.y * scale.y + offset.y;*/
            
            vertices[vertexIndex + 0] = body.PointMasses[0].Position.x * scale.x + offset.x;
            vertices[vertexIndex + 1] = body.PointMasses[0].Position.y * scale.y + offset.y;
            
            vertices[vertexIndex + 2] = body.PointMasses[1].Position.x * scale.x + offset.x;
            vertices[vertexIndex + 3] = body.PointMasses[1].Position.y * scale.y + offset.y;
            
            vertices[vertexIndex + 4] = body.PointMasses[2].Position.x * scale.x + offset.x;
            vertices[vertexIndex + 5] = body.PointMasses[2].Position.y * scale.y + offset.y;
            
            vertices[vertexIndex + 6] = body.PointMasses[3].Position.x * scale.x + offset.x;
            vertices[vertexIndex + 7] = body.PointMasses[3].Position.y * scale.y + offset.y;
            
            bodyIndex++;
        }
        
        graphics.beginBitmapFill(gameTileSprite.framePixels);
        graphics.drawTriangles(vertices, indices, uvtData);
        graphics.endFill();
    }
	
	//var vertices:Vector<Float> = null;
	//var indices:Vector<Int> = null;
	//var uvtData:Vector<Float> = null;
    private static var vertexesPerBlock:Int = 4;
    private static var elementsPerEntry:Int = 2;
    private static var indexesPerTriangle:Int = 3;
    private static var trianglesPerBlock:Int = 2;
    private static var oneThird:Float = 1.0 / 3.0;
	function allocateDrawVectors() 
	{
        
        //all the vertexes we're going to draw in [x1, y1,... xn, yn] format
        //4 vertexes per block * 2 floats per vertex
        //vertexes start at the upper left and move clockwise
        //vertex locations are set per frame
		vertices = new Vector<Float>(activeBodyCount * vertexesPerBlock * elementsPerEntry);
        //indexes of all the triangles we draw, 3 vertexes per triangle * 2 triangles per block
		indices = new Vector<Int>(activeBodyCount * indexesPerTriangle * trianglesPerBlock);
        //texture coordinates in [x1, y1,... xn, yn] format
        //each vertex has 1 texture coordinate
		uvtData = new Vector<Float>(activeBodyCount * vertexesPerBlock * elementsPerEntry);
        
        for (i in 0...activeBodyCount){
            var index:Int = i * indexesPerTriangle * trianglesPerBlock;
            var vertindex:Int = i * vertexesPerBlock;
            indices[index + 0] = vertindex + 0;
            indices[index + 1] = vertindex + 1;
            indices[index + 2] = vertindex + 2;
            indices[index + 3] = vertindex + 0;
            indices[index + 4] = vertindex + 2;
            indices[index + 5] = vertindex + 3;
        }
        
        var bodyIndex:Int = 0;
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            if (body.IsStatic){
                continue;
            }
            var uvXoffset:Float = uvXoffsetForMaterial(body.Material);
            var uvYoffset:Float = uvYoffsetForMaterial(body.Material);
            var uvIndex:Int = bodyIndex * vertexesPerBlock * elementsPerEntry;
            
            uvtData[uvIndex + 0] = uvXoffset;
            uvtData[uvIndex + 1] = uvYoffset;
            
            uvtData[uvIndex + 2] = uvXoffset + oneThird;
            uvtData[uvIndex + 3] = uvYoffset;
            
            uvtData[uvIndex + 4] = uvXoffset + oneThird;
            uvtData[uvIndex + 5] = uvYoffset + oneThird;
            
            uvtData[uvIndex + 6] = uvXoffset;
            uvtData[uvIndex + 7] = uvYoffset + oneThird;
            
            //trace("Body: " + body.BodyNumber + ", material: " + body.Material);
            bodyIndex++;
        }
    }
    
    function uvXoffsetForMaterial(material:Int):Float
    {
        var xIndex:Int = material % 3;
        return oneThird * xIndex;
	}
    
    function uvYoffsetForMaterial(material:Int):Float
    {
        var yIndex:Int = Math.floor(material / 3);
        return (1.0/3.0) * yIndex;
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
        //trace("line starts: " +((start.x * scale.x) + offset.x)+", " + ((start.y * scale.y) + offset.y));
        graphics.moveTo((start.x * scale.x) + offset.x , (start.y * scale.y) + offset.y );
        for (i in 0...shape.length){
            var next:Vector2;
            if (i == shape.length-1){
                next = shape[0];
            }else{
                next = shape[i+1];
            }
            //trace("line goes: " +((next.x * scale.x) + offset.x)+", " + ((next.y * scale.y) + offset.y));
            graphics.lineTo((next.x * scale.x) + offset.x, (next.y * scale.y) + offset.y);
        }
        if (opts.IsSolid){
            graphics.endFill();
        }
    }
	
	public override function rotateColorUp(){
		colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.05) % 1.0;
		setupDrawParam();

	}
    
    public override function rotateColorDown() 
    {
		colorSource.ColorAdjust = (colorSource.ColorAdjust + 0.95) % 1.0;
        setupDrawParam();
    }
    
    public override function setupDrawParam():Void
    {
        super.setupDrawParam();
        this.SetMaterialDrawOptions(GameConstants.MATERIAL_GROUND, BaseDrawWorld.COLOR_WHITE, false);
        var colors:Array<Int> = makeColors(.8, .9, GameConstants.UniqueColors);
        for (i in 0...colors.length+1){
            //this.SetMaterialDrawOptions(i, colors[i-1], true);
            this.SetMaterialDrawOptions(i, colorSource.getColor(i), true);
        }
    }
}