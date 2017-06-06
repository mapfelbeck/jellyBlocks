package render;
import flixel.FlxSprite;
import flixel.FlxState;
import jellyPhysics.*;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.Assets;
import openfl.display.*;
import openfl.events.*;
import openfl.text.TextField;
import render.BaseDrawWorld;
import render.DebugDrawBodyOption;
import util.UtilClass;
import util.ScreenWorldTransform;
import events.*;

/**
 * ...
 * @author 
 */
class TexturedDrawWorld extends BaseDrawWorld
{
    private static var groundAssetPath:String =  "assets/images/gameArena.png";
    private static var tileAssetPath:String =    "assets/images/tiled greyscale.png";
    private static var frostedAssetPath:String = "assets/images/frosted greyscale.png";
    
    private var parentState:FlxState;
    public var backgroundSize:Vector2;
    
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:World;
    private var worldBounds:AABB;
    
    private var labels:Array<TextField>;
    
    public var ColorOfBackground:Int = BaseDrawWorld.COLOR_BLACK;
    public var ColorOfGlobalVerts:Int = BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfGlobalBody:Int = BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfPhysicsBody:Int = BaseDrawWorld.COLOR_WHITE;
	
	private var gameArenaSprite:FlxSprite;
	private var gameTileSprite:NineSliceSprite;
	
	private var activeBodyCount:Int = -1;
	var vertices:Array<Float> = null;
	var indices:Array<Int> = null;
	var uvtData:Array<Float> = null;

    public function new(sprite:Sprite, colorSource:IColorSource, parentState:FlxState, physicsWorld:World, screenWorldTransform:ScreenWorldTransform) 
    {
        super(colorSource, screenWorldTransform);
    
        this.parentState = parentState;
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;
        
        setupDrawParam();
    }
    
    override public function createEventSet():Void{
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.COLOR_ROTATE, onColorRotate));
    }
    
    function onColorRotate(sender:Dynamic, event:String, params:Dynamic) 
    {
        buildTileTexture();
    }
    
    private function buildTileTexture():Void{
        if (gameTileSprite != null){
            Assets.cache.removeBitmapData(tileAssetPath);
            gameTileSprite.destroy();
            gameTileSprite = null;
        }
		gameTileSprite = new NineSliceSprite(0, 0, tileAssetPath, null, null, colorSource);
        #if (cpp || neko)
        gameTileSprite.useFramePixels = true;
        #end
        
        
    }

    public override function setGameGround(ground:GameGround):Void{
        super.setGameGround(ground);
		//trace("I see a game ground with width " +ground.Width + ", height " + ground.Height + " and border " + ground.Border + ".");
		var h:Float = ground.Height;
		var w:Float = ground.Width;
		var b:Float = ground.Border;
		gameArenaSprite = new FlxSprite(0, 0, groundAssetPath);
        //from old texture that had to be resized
		/*gameArenaSprite = new NineSliceSprite(0, 0, groundAssetPath, 
												[43,426,43,43,417,52], 
												[b, w, b, b, h, b]);*/

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
            //trace("New active body count: " + activeBodyCount);
            allocateDrawVectors();
        }
        graphics.clear();
        
        var bodyIndex:Int = 0;
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            if (body.IsStatic){
                continue;
            }
            
            var vertexIndex:Int = bodyIndex * vertexesPerBlock * elementsPerEntry;
            
            vertices[vertexIndex + 0] = body.PointMasses[0].Position.x * transform.scale.x + transform.offset.x;
            vertices[vertexIndex + 1] = body.PointMasses[0].Position.y * transform.scale.y + transform.offset.y;
            
            vertices[vertexIndex + 2] = body.PointMasses[1].Position.x * transform.scale.x + transform.offset.x;
            vertices[vertexIndex + 3] = body.PointMasses[1].Position.y * transform.scale.y + transform.offset.y;
            
            vertices[vertexIndex + 4] = body.PointMasses[2].Position.x * transform.scale.x + transform.offset.x;
            vertices[vertexIndex + 5] = body.PointMasses[2].Position.y * transform.scale.y + transform.offset.y;
            
            vertices[vertexIndex + 6] = body.PointMasses[3].Position.x * transform.scale.x + transform.offset.x;
            vertices[vertexIndex + 7] = body.PointMasses[3].Position.y * transform.scale.y + transform.offset.y;
            
            bodyIndex++;
        }
        
        graphics.beginBitmapFill(gameTileSprite.framePixels);
        graphics.drawTriangles(vertices, indices, uvtData);
        graphics.endFill();
    }
	
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
		vertices = UtilClass.arrayOfSize(activeBodyCount * vertexesPerBlock * elementsPerEntry);
        //indexes of all the triangles we draw, 3 vertexes per triangle * 2 triangles per block
		indices = UtilClass.arrayOfSize(activeBodyCount * indexesPerTriangle * trianglesPerBlock);
        //texture coordinates in [x1, y1,... xn, yn] format
        //each vertex has 1 texture coordinate
		uvtData = UtilClass.arrayOfSize(activeBodyCount * vertexesPerBlock * elementsPerEntry);
        
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
    
    public override function setupDrawParam():Void
    {
        super.setupDrawParam();
        
        buildTileTexture();
    }
}