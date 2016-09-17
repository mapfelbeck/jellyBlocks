package;

import flixel.*;
import flixel.addons.display.FlxTiledSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKeyList;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import jellyPhysics.*;
import jellyPhysics.math.*;
import openfl.Assets;
import openfl.Lib;
import openfl.display.*;
import haxe.ds.Vector;

class PlayState extends FlxState
{
    var debugRender:DrawDebugWorld;
    var debugDrawSurface:Sprite;
    var flxDrawSurface:FlxSprite;
    var overscan:Int = 0;
    var WINDOW_WIDTH:Int;
    var WINDOW_HEIGHT:Int;

    var physicsWorld:World;
    private static var MATERIAL_GROUND:Int = 0;
    private static var MATERIAL_TYPE_YELLOW:Int = 1;
    private static var MATERIAL_TYPE_GREEN:Int = 2;
    private static var MATERIAL_BLOB:Int   = 3;
    
    private var blobBody:PressureBody;
    private var collideYellow:Bool = false;
    private var collideGreen:Bool = false;
    private var blockSprings:Array<ExtrernalSpring>;
    
    public var defaultMaterial:MaterialPair;
    
    private var input:Input;
	override public function create():Void
	{
        #if mobile
        WINDOW_WIDTH = Std.int(Lib.current.stage.width);
        WINDOW_HEIGHT = Std.int(Lib.current.stage.height);
        //WINDOW_WIDTH = Lib.application.window.width;
        //WINDOW_HEIGHT = Lib.application.window.height;
        #else
        WINDOW_WIDTH = Std.parseInt(haxe.macro.Compiler.getDefine("windowWidth"));
        WINDOW_HEIGHT = Std.parseInt(haxe.macro.Compiler.getDefine("windowHeight"));
        #end
        trace("Window width: " + WINDOW_WIDTH);
        trace("Window height: " + WINDOW_HEIGHT);
		super.create();
        
        input = new Input();
        input.AddInputCommand(FlxKey.LEFT, setBlobMovingLeft);
        input.AddInputCommand(FlxKey.RIGHT, setBlobMovingRight);
        
        defaultMaterial = new MaterialPair();
        defaultMaterial.Collide = true;
        defaultMaterial.Friction = 0.3;
        defaultMaterial.Elasticity = 0.8;
        
        blockSprings = new Array<ExtrernalSpring>();
        
        createWorld();
        addBodiesToWorld();
        
        //draw surface needs stage
        debugRender = new DrawDebugWorld(createDrawSurface(), physicsWorld, WINDOW_WIDTH, WINDOW_HEIGHT);
        setupDrawParam(debugRender);
	}
    
    private function createDrawSurface():Sprite
    {
        flxDrawSurface = new FlxSprite().makeGraphic(WINDOW_WIDTH, WINDOW_HEIGHT, FlxColor.TRANSPARENT);
        add(flxDrawSurface);
        
        overscan = 20;
        debugDrawSurface = new Sprite();
        debugDrawSurface.x = overscan;
        debugDrawSurface.y = overscan;
        
        debugDrawSurface.cacheAsBitmap = true;
        
        return debugDrawSurface;
    }
    
    public function setupDrawParam(render:DrawDebugWorld):Void
    {
        render.DrawingAABB = false;
        render.DrawingGlobalBody = false;
        render.DrawingPointMasses = false;
        render.SetMaterialDrawOptions(MATERIAL_GROUND, DrawDebugWorld.COLOR_WHITE, false);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_YELLOW, DrawDebugWorld.COLOR_YELLOW, true);
        render.SetMaterialDrawOptions(MATERIAL_TYPE_GREEN, DrawDebugWorld.COLOR_GREEN, true);
        render.SetMaterialDrawOptions(MATERIAL_BLOB, DrawDebugWorld.COLOR_RED, true);
    }
        
    public function getMaterialMatrix():MaterialMatrix 
    {
        var materialMatrix:MaterialMatrix = new MaterialMatrix(defaultMaterial, 4);
        
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_YELLOW, collisionFilterYellow);
        materialMatrix.SetMaterialPairFilterCallback(MATERIAL_BLOB, MATERIAL_TYPE_GREEN, collisionFilterGreen);
        
        //default material friction is 0.3, pretty slippery
        //give the blob more friction, 0.75
        materialMatrix.SetMaterialPairData(MATERIAL_GROUND, MATERIAL_BLOB, 0.75, 0.8);
        
        return materialMatrix;
    }
    
    function collisionFilterYellow(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        collideYellow = true;
        return false;
    }
    
    function collisionFilterGreen(bodyA:Body, bodyApm:Int, bodyB:Body, bodyBpmA:Int, bodyBpmB:Int, hitPoint:Vector2, relDot:Float):Bool
    {
        return false;
    }
    
    function collisionCallbackGreen(otherBody:Body):Void{
        if(otherBody.Label == "Blob"){
            collideGreen = true;
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        input.Update(elapsed);
        
        physicsWorld.Update(elapsed);

        Draw();
        
        collideYellow = false;
        collideGreen = false;
    }
    
    private var blobMoveLeft:Bool = false;
    private var blobMoveRight:Bool = false;
    
    private function setBlobMovingLeft(){
        trace("left");
        blobMoveLeft = true;
    }
    private function setBlobMovingRight(){
        trace("right");
        blobMoveRight = true;
    }
    
    private function Draw():Void
    {
        debugRender.Draw();
        
        var pixels:BitmapData = flxDrawSurface.pixels;
        pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
        pixels.draw(debugDrawSurface);
        flxDrawSurface.pixels = pixels;
        flxDrawSurface.x = overscan;
        flxDrawSurface.y = overscan;
    }
    
    function addBodiesToWorld() 
    {
        var groundBody:Body = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(0, 9), 0, new Vector2(18, 1), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);
        
        groundBody = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(17, 6), 0, new Vector2(1, 2), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);
        
        groundBody = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(-17, 6), 0, new Vector2(1, 2), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);
        
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 200;
        var shapeDamp:Float = 100;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 50.0;
        
        blobBody = new PressureBody(getPolygonShape(1, 16), mass, new Vector2( 0, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp, pressureAmount);
        blobBody.Label = "Blob";
        blobBody.ShapeMatchingOn = false;
        blobBody.Material = MATERIAL_BLOB;
        physicsWorld.AddBody(blobBody);   
        
        var springBody:SpringBody = new SpringBody(getBigSquareShape(1), mass, new Vector2( -6, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        springBody.Material = MATERIAL_TYPE_YELLOW;
        physicsWorld.AddBody(springBody);
        
        //the green block is a composite of 4
        var greenBodyUL:SpringBody = new SpringBody(getSquareShape(1), mass, new Vector2( 6, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyUL.Material = MATERIAL_TYPE_GREEN;
        greenBodyUL.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyUL);
        
        var greenBodyUR:SpringBody = new SpringBody(getSquareShape(1), mass, new Vector2( 7, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyUR.Material = MATERIAL_TYPE_GREEN;
        greenBodyUR.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyUR);
        
        var greenBodyLR:SpringBody = new SpringBody(getSquareShape(1), mass, new Vector2( 7, 1), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyLR.Material = MATERIAL_TYPE_GREEN;
        greenBodyLR.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyLR);
        
        var greenBodyLL:SpringBody = new SpringBody(getSquareShape(1), mass, new Vector2( 6, 1), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyLL.Material = MATERIAL_TYPE_GREEN;
        greenBodyLL.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyLL);
        
        //connect those green blocks with springs
        var externalK:Float = 50.0;
        var externalDamp:Float = 20.0;
        var spring:ExtrernalSpring;
        spring = new ExtrernalSpring(greenBodyUL, greenBodyUR, 1, 0, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExtrernalSpring(greenBodyUL, greenBodyUR, 2, 3, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        
        spring = new ExtrernalSpring(greenBodyUR, greenBodyLR, 2, 1, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExtrernalSpring(greenBodyUR, greenBodyLR, 3, 0, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        
        spring = new ExtrernalSpring(greenBodyLR, greenBodyLL, 3, 2, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExtrernalSpring(greenBodyLR, greenBodyLL, 0, 1, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        
        spring = new ExtrernalSpring(greenBodyLL, greenBodyUL, 0, 3, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExtrernalSpring(greenBodyLL, greenBodyUL, 1, 2, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
    }
    
    public function getPolygonShape(radius:Float, ?count:Int):ClosedShape{
        if (null == count){
            count = 12;
        }
        
        var polygonShape:ClosedShape = new ClosedShape();
        polygonShape.Begin();
        for (i in 0...count){
            var point:Vector2 = new Vector2();
            point.x =  Math.cos(2 * (Math.PI / count) * i) * radius;
            point.y = Math.sin(2 * (Math.PI / count) * i) * radius;
            polygonShape.AddVertex(point);
        }
        
        polygonShape.Finish(true);
        return polygonShape;
    }
    public function getSquareShape(size:Float):ClosedShape{
        var squareShape:ClosedShape = new ClosedShape();
        squareShape.Begin();
        squareShape.AddVertex(new Vector2(0, 0));
        squareShape.AddVertex(new Vector2(size, 0));
        squareShape.AddVertex(new Vector2(size, size));
        squareShape.AddVertex(new Vector2(0, size));
        squareShape.Finish(true);
        return squareShape;
    }
    
    public function getBigSquareShape(size:Float):ClosedShape{
        var bigSquareShape:ClosedShape = new ClosedShape();
        bigSquareShape.Begin();
        bigSquareShape.AddVertex(new Vector2(0, -size*2));
        bigSquareShape.AddVertex(new Vector2(size, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -size*2));
        bigSquareShape.AddVertex(new Vector2(size*2, -size));
        bigSquareShape.AddVertex(new Vector2(size*2, 0));
        bigSquareShape.AddVertex(new Vector2(size, 0));
        bigSquareShape.AddVertex(new Vector2(0, 0));
        bigSquareShape.AddVertex(new Vector2(0, -size));
        bigSquareShape.Finish(true);
        return bigSquareShape;
    }
    
    private function createWorld()
    {
        var matrix:MaterialMatrix = getMaterialMatrix();
        
        var bounds:AABB = new AABB(new Vector2( -20, -20), new Vector2( 20, 20));
        
        var penetrationThreshhold:Float = 10.0;
        
        physicsWorld = new World(matrix.Count, matrix, matrix.DefaultMaterial, penetrationThreshhold, bounds);
        physicsWorld.externalAccumulator = PhysicsAccumulator;
    }
        
    private function PhysicsAccumulator(elapsed:Float){
        var gravity:Vector2 = new Vector2(0, 9.8);

        for(i in 0...physicsWorld.NumberBodies)
        {
            var body:Body = physicsWorld.GetBody(i);
            if (!body.IsStatic){
                body.AddGlobalForce(body.DerivedPos, gravity);
            }
        }
        
        for (i in 0...blockSprings.length)
        {
            var spring:ExtrernalSpring = blockSprings[i];
            var a:Body = spring.BodyA;
            var pmA = a.PointMasses[spring.pointMassA];
            var b:Body = spring.BodyB;
            var pmB = b.PointMasses[spring.pointMassB];
            
            var force = VectorTools.CalculateSpringForce(pmA.Position, pmA.Velocity, pmB.Position, pmB.Velocity, spring.springLen, spring.springK, spring.damping);
            /*if (force.x != 0){
                trace("wat?");
            }
            if (force.y != 0){
                trace("wat!");
            }*/
            pmA.Force.x += force.x;
            pmA.Force.y += force.y;
            pmB.Force.x -= force.x;
            pmB.Force.y -= force.y;
        }
    }
}
