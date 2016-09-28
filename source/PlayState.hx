package;

import flixel.*;
import builders.GameBlockBuilder;
import builders.ShapeBuilder;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import jellyPhysics.*;
import jellyPhysics.math.*;
import openfl.Lib;
import openfl.display.*;
import blocks.*;
import enums.*;

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
    private var blockSprings:Array<ExternalSpring>;
    
    public var defaultMaterial:MaterialPair;
    
    private var blobMoveLeft:Bool = false;
    private var blobMoveRight:Bool = false;
    
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
        
        blockSprings = new Array<ExternalSpring>();
        
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
        blobMoveLeft = false;
        blobMoveRight = false;
    }
    
    private function setBlobMovingLeft(){
        blobMoveLeft = true;
    }
    
    private function setBlobMovingRight(){
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
    
    private var ground:GameGround;
    function addBodiesToWorld() 
    {
        ground = new GameGround(2, 16, 20, new Vector2(0, 2));
        var groundBodies:Array<Body> = ground.Assemble();
        for (i in 0...groundBodies.length){
            physicsWorld.AddBody(groundBodies[i]);
        }
        
        var mass:Float = 1.0;
        var angle:Float = 0.0;
        var shapeK:Float = 200;
        var shapeDamp:Float = 100;
        var edgeK:Float = 100;
        var edgeDamp:Float = 50;
        var pressureAmount:Float = 50.0;
        
        var shapeBuilder:ShapeBuilder = new ShapeBuilder().type(ShapeType.Polygon).size(1.0).facetCount(16);
        
        var blockBuilder = new GameBlockBuilder();
        blockBuilder = blockBuilder.setType(BlockType.Normal);
        blockBuilder = blockBuilder.setShape(shapeBuilder.create());
        blockBuilder = blockBuilder.setMass(mass);
        blockBuilder = blockBuilder.setPosition(new Vector2( 0, 0));
        blockBuilder = blockBuilder.setRotation(0.0);
        blockBuilder = blockBuilder.setScale(new Vector2( 1, 1));
        blockBuilder = blockBuilder.setKinematic(false);
        blockBuilder = blockBuilder.setShapeK(shapeK);
        blockBuilder = blockBuilder.setShapeDamp(shapeDamp);
        blockBuilder = blockBuilder.setEdgeK(edgeK);
        blockBuilder = blockBuilder.setEdgeDamp(edgeDamp);
        blockBuilder = blockBuilder.setPressure(pressureAmount);
        blockBuilder = blockBuilder.setConfig(new BlockConfig());
        blobBody = blockBuilder.create();
        blobBody.Label = "Blob";
        blobBody.ShapeMatchingOn = false;
        blobBody.Material = MATERIAL_BLOB;
        physicsWorld.AddBody(blobBody);
        
        shapeBuilder = shapeBuilder.type(ShapeType.Custom).size(1).vertexes(getBigSquareShape(1.0));
        var springBody:SpringBody = new SpringBody(shapeBuilder.create(), mass, new Vector2( -6, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        springBody.Material = MATERIAL_TYPE_YELLOW;
        physicsWorld.AddBody(springBody);
        
        shapeBuilder = shapeBuilder.type(ShapeType.Square);
        //the green block is a composite of 4
        var greenBodyUL:SpringBody = new SpringBody(shapeBuilder.create(), mass, new Vector2( 6, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyUL.Material = MATERIAL_TYPE_GREEN;
        greenBodyUL.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyUL);
        
        var greenBodyUR:SpringBody = new SpringBody(shapeBuilder.create(), mass, new Vector2( 7, 0), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyUR.Material = MATERIAL_TYPE_GREEN;
        greenBodyUR.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyUR);
        
        var greenBodyLR:SpringBody = new SpringBody(shapeBuilder.create(), mass, new Vector2( 7, 1), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyLR.Material = MATERIAL_TYPE_GREEN;
        greenBodyLR.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyLR);
        
        var greenBodyLL:SpringBody = new SpringBody(shapeBuilder.create(), mass, new Vector2( 6, 1), 0, new Vector2(1, 1), false, shapeK, shapeDamp, edgeK, edgeDamp);
        greenBodyLL.Material = MATERIAL_TYPE_GREEN;
        greenBodyLL.CollisionCallback = collisionCallbackGreen;
        physicsWorld.AddBody(greenBodyLL);
        
        //connect those green blocks with springs
        var externalK:Float = 50.0;
        var externalDamp:Float = 20.0;
        var spring:ExternalSpring;
        spring = new ExternalSpring(greenBodyUL, greenBodyUR, 1, 0, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExternalSpring(greenBodyUL, greenBodyUR, 2, 3, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        
        spring = new ExternalSpring(greenBodyUR, greenBodyLR, 2, 1, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExternalSpring(greenBodyUR, greenBodyLR, 3, 0, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        
        spring = new ExternalSpring(greenBodyLR, greenBodyLL, 3, 2, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExternalSpring(greenBodyLR, greenBodyLL, 0, 1, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        
        spring = new ExternalSpring(greenBodyLL, greenBodyUL, 0, 3, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
        spring = new ExternalSpring(greenBodyLL, greenBodyUL, 1, 2, 0.0, externalK, externalDamp);
        blockSprings.push(spring);
    }
    
    private function getBigSquareShape(size:Float):Array<Vector2>{
        var bigSquareShape:Array<Vector2> = new Array<Vector2>();
        bigSquareShape.push(new Vector2(0, -size*2));
        bigSquareShape.push(new Vector2(size, -size*2));
        bigSquareShape.push(new Vector2(size*2, -size*2));
        bigSquareShape.push(new Vector2(size*2, -size));
        bigSquareShape.push(new Vector2(size*2, 0));
        bigSquareShape.push(new Vector2(size, 0));
        bigSquareShape.push(new Vector2(0, 0));
        bigSquareShape.push(new Vector2(0, -size));
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
        GravityAccumulator(elapsed);
        MoveAccumulator(elapsed);
    }
        
    private function GravityAccumulator(elapsed:Float){
        var gravity:Vector2 = new Vector2(0, 0.5 * 9.8);

        for(i in 0...physicsWorld.NumberBodies)
        {
            var body:Body = physicsWorld.GetBody(i);
            if (!body.IsStatic){
                body.AddGlobalForce(body.DerivedPos, gravity);
            }
        }
        
        for (i in 0...blockSprings.length)
        {
            var spring:ExternalSpring = blockSprings[i];
            var a:Body = spring.BodyA;
            var pmA = a.PointMasses[spring.pointMassA];
            var b:Body = spring.BodyB;
            var pmB = b.PointMasses[spring.pointMassB];
            
            var force = VectorTools.CalculateSpringForce(pmA.Position, pmA.Velocity, pmB.Position, pmB.Velocity, spring.springLen, spring.springK, spring.damping);

            pmA.Force.x += force.x;
            pmA.Force.y += force.y;
            pmB.Force.x -= force.x;
            pmB.Force.y -= force.y;
        }
    }
        
    private function MoveAccumulator(elapsed:Float){
        
        var rotationAmount:Float = 0;
        
        if (blobMoveLeft)
        {
            rotationAmount += -1;
        }
        if (blobMoveRight)
        {
            rotationAmount += 1;
        }
        
        if (rotationAmount != 0 && Math.abs(blobBody.DerivedOmega) < 2.0){
            var blobCenter:Vector2 = blobBody.DerivedPos;
            for (i in 0...blobBody.PointMasses.length){
                var pmPosition:Vector2 = blobBody.PointMasses[i].Position;
                var origin:Vector2 = VectorTools.Subtract(pmPosition, blobCenter);
                var rotationForce:Vector2 = new Vector2(0, 0);
                var torqueForce:Float = 3;
                rotationForce.x = origin.x * Math.cos(rotationAmount) - origin.y * Math.sin(rotationAmount);
                rotationForce.y = origin.x * Math.sin(rotationAmount) + origin.y * Math.cos(rotationAmount);
                blobBody.PointMasses[i].Force.x += rotationForce.x * torqueForce;
                blobBody.PointMasses[i].Force.y += rotationForce.y * torqueForce;
            }
        }
    }
}
