package render;
import jellyPhysics.*;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;
import openfl.text.TextField;
import render.DebugDrawBodyOption;

/**
 * ...
 * @author 
 */
class ReleaseDrawWorld extends BaseDrawWorld
{
    private static var groundAssetPath:String = "assets/images/gameArena.png";
    private static var groundAssetImage:FlxSprite;
    private var parentState:FlxState;
    public var drawLookup:Map<Int,render.DebugDrawBodyOption>;
    public var drawGlobalBodyDefault:render.DebugDrawBodyOption;
    public var drawPhysicsBodyDefault:render.DebugDrawBodyOption;
    public var backgroundSize:Vector2;
    
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:World;
    private var worldBounds:AABB;
    
    private var labels:Array<TextField>;
    
    public var offset:Vector2 = new Vector2(0, 0);
    public var scale:Vector2 = new Vector2(10.0, 10.0);
    public var width:Int = 0;
    public var height:Int = 0;
    public var overscan:Int = 0;
    
    public var ColorOfBounds:Int = render.BaseDrawWorld.COLOR_PURPLE;
    public var ColorOfText:Int = render.BaseDrawWorld.COLOR_GREY;
    public var ColorOfAABB:Int = render.BaseDrawWorld.COLOR_GREY;
    public var ColorOfBackground:Int = render.BaseDrawWorld.COLOR_BLACK;
    public var ColorOfGlobalVerts:Int = render.BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfGlobalBody:Int = render.BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfPhysicsBody:Int = render.BaseDrawWorld.COLOR_WHITE;
    public var ColorOfInternalSprings:Int = render.BaseDrawWorld.COLOR_RED;
    public var ColorOfPointMasses:Int = render.BaseDrawWorld.COLOR_BLUE;
    
    public var SizeOfVert:Float = 4;
    
    public var DrawingBackground:Bool = true;
    public var DrawingBounds:Bool = false;
    public var DrawingLabels:Bool = true;
    public var DrawingAABB:Bool = false;
    public var DrawingGlobalVerts:Bool = false;
    public var DrawingGlobalBody:Bool = false;
    public var DrawingPhysicsBody:Bool = true;
    public var DrawingInternalSprings:Bool = false;
    public var DrawingPointMasses:Bool = true;
    
    public function new(sprite:Sprite, parentState:FlxState, physicsWorld:World, width:Int, height:Int, overscan:Int) 
    {
        super();
        drawLookup = new Map<Int,render.DebugDrawBodyOption>();
        drawGlobalBodyDefault = new render.DebugDrawBodyOption(0, ColorOfGlobalBody, false);
        drawPhysicsBodyDefault = new render.DebugDrawBodyOption(0, ColorOfPhysicsBody, false);
    
        this.parentState = parentState;
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;
        
        setupDrawParam();
        
        setRenderAndOffset(width, height, overscan);
        
        if (DrawingLabels){
            createTextLabels(world.NumberBodies);
        }
        
        groundAssetImage = new FlxSprite(50, 50, groundAssetPath);
        parentState.add(groundAssetImage);
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
        
        if(DrawingBackground){
            graphics.beginFill(ColorOfBackground);
            graphics.drawRect(overscan, overscan, backgroundSize.x, backgroundSize.y);
            graphics.endFill();
        }
        
        if(DrawingBounds){
            DrawPhysicsBounds();
        }
        
        if (DrawingLabels){
            if (labels.length != world.NumberBodies){
                createTextLabels(world.NumberBodies);
            }
        }
        
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            /*if (body.IsStatic){
                continue;
            }*/
            if (DrawingLabels){
                //graphics.lineStyle(0, ColorOfText);
                var labelText:TextField = labels[i];
                labelText.textColor = ColorOfText;
                var text:String = body.Label;
                if (text == null){text = "*"; }
                
                labelText.text = text;
                var location:Vector2 = worldToLocal(body.DerivedPos);
                labelText.x = location.x - (labelText.textWidth / 2);
                labelText.y = location.y - (labelText.textHeight /2 );
            }
            DrawingAABB?drawAABB(body.BoundingBox):null;
            DrawingGlobalBody?drawGlobalBody(body.GlobalShape):null;
            DrawingPhysicsBody?drawPhysicsBody(body):null;
            DrawingGlobalVerts?drawGlobalVerts(body.GlobalShape):null;
            DrawingPointMasses?drawPointMasses(body.PointMasses):null;
            if (Std.is(body, SpringBody)){
                var springBody:SpringBody = Std.instance(body, SpringBody);
                DrawingInternalSprings?drawInternalSprings(springBody):null;
            }
            if (Std.is(body, PressureBody)){
                var springBody:PressureBody = Std.instance(body, PressureBody);
                DrawingInternalSprings?drawInternalSprings(springBody):null;
            }
        }
    }
    
    private function worldToLocal(world:Vector2):Vector2{
        var local:Vector2 = new Vector2();
        local.x = (world.x * scale.x) + offset.x;
        local.y = (world.y * scale.y) + offset.y;
        return local;
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
    
    function drawPointMasses(pointMasses:Array<PointMass>) 
    {
        graphics.lineStyle(0, ColorOfPointMasses);
        graphics.beginFill(ColorOfPointMasses, 1.0);
        
        for (i in 0...pointMasses.length){
            var vert:Vector2 = pointMasses[i].Position;
            graphics.drawRect((vert.x * scale.x) + offset.x - (SizeOfVert / 2), (vert.y * scale.y) + offset.y - (SizeOfVert / 2), SizeOfVert, SizeOfVert);
        }
        graphics.endFill();
    }
    
    function drawInternalSprings(springBody:SpringBody) 
    {
        graphics.lineStyle(0, ColorOfInternalSprings);
        for (i in 0...springBody.Springs.length){
            var spring:InternalSpring = springBody.Springs[i];
            var pmA:PointMass = springBody.PointMasses[spring.pointMassA];
            var pmB:PointMass = springBody.PointMasses[spring.pointMassB];
            graphics.moveTo((pmA.Position.x * scale.x) + offset.x, (pmA.Position.y * scale.y) + offset.y);
            graphics.lineTo((pmB.Position.x * scale.x) + offset.x, (pmB.Position.y * scale.y) + offset.y);
        }
    }
    
    function drawGlobalVerts(verts:Array<Vector2>) 
    {
        graphics.lineStyle(0, ColorOfGlobalVerts);
        graphics.beginFill(ColorOfGlobalVerts, 1.0);
        for (i in 0...verts.length){
            var vert:Vector2 = verts[i];
            graphics.drawRect((vert.x * scale.x) + offset.x - (SizeOfVert / 2), (vert.y * scale.y) + offset.y - (SizeOfVert / 2), SizeOfVert, SizeOfVert);
        }
        graphics.endFill();
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
    
    function DrawPhysicsBounds() 
    {
        graphics.lineStyle(2, ColorOfBounds);
        //upper left and lower right
        //var ul:Vector2 = worldToLocal(new Vector2( -2, -2));
        //var lr:Vector2 = worldToLocal(new Vector2(2, 2));
        var ul:Vector2 = worldToLocal(worldBounds.UL);
        var lr:Vector2 = worldToLocal(worldBounds.LR);
        graphics.drawRect(ul.x, ul.y, lr.x - ul.x, lr.y - ul.y);
    }
    
    function drawGlobalBody(shape:Array<Vector2>) 
    {
        drawBody(shape, drawGlobalBodyDefault);
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
    
    function drawAABB(box:AABB) 
    {
        graphics.lineStyle(0, ColorOfAABB, 0.5);
                
        graphics.drawRect((box.UL.x * scale.x) + offset.x, (box.UL.y * scale.y) + offset.y, 
                                 box.Width * scale.x, box.Height * scale.y);
    }
    
    public override function setupDrawParam():Void
    {
        super.setupDrawParam();
        this.DrawingBackground = false;
        this.DrawingBounds = false;
        this.DrawingAABB = false;
        this.DrawingGlobalBody = false;
        this.DrawingPointMasses = false;
        this.DrawingLabels = false;
        this.SetMaterialDrawOptions(GameConstants.MATERIAL_GROUND, render.BaseDrawWorld.COLOR_WHITE, false);
        var colors:Array<Int> = makeColors(.8, .9, GameConstants.UniqueColors);
        for (i in 1...colors.length + 1){
            this.SetMaterialDrawOptions(i, colors[i-1], true);
        }
    }
}