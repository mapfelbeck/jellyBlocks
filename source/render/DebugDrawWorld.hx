package render;
import constants.GameConstants;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import jellyPhysics.*;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;
import render.DebugDrawBodyOption;
import screens.BaseScreen;
import util.ScreenWorldTransform;

/**
 * ...
 * @author Michael Apfelbeck
 */
class DebugDrawWorld extends BaseDrawWorld
{
    public var drawLookup:Map<Int,DebugDrawBodyOption> = new Map<Int,DebugDrawBodyOption>();
    public var drawGlobalBodyDefault:DebugDrawBodyOption;
    public var drawPhysicsBodyDefault:DebugDrawBodyOption;
    public var backgroundSize:Vector2;
    
    private var renderTarget:FlxSprite;
    private var world:World;
    private var worldBounds:AABB;
    
    private var labels:Array<FlxText>;
    
    public var ColorOfBounds:Int = BaseDrawWorld.COLOR_PURPLE;
    public var ColorOfText:Int = BaseDrawWorld.COLOR_GREY;
    public var ColorOfAABB:Int = BaseDrawWorld.COLOR_GREY;
    public var ColorOfBackground:Int = BaseDrawWorld.COLOR_BLACK;
    public var ColorOfGlobalVerts:Int = BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfGlobalBody:Int = BaseDrawWorld.COLOR_YELLOW;
    public var ColorOfPhysicsBody:Int = BaseDrawWorld.COLOR_WHITE;
    public var ColorOfInternalSprings:Int = BaseDrawWorld.COLOR_RED;
    public var ColorOfPointMasses:Int = BaseDrawWorld.COLOR_BLUE;
    
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
    
    private var parent:BaseScreen;
    
    public function new(parent:BaseScreen, sprite:FlxSprite, colorSource:IColorSource, physicsWorld:World, screenWorldTransform:ScreenWorldTransform) 
    {
        super(colorSource, screenWorldTransform);
        
        this.parent = parent;
        
        drawGlobalBodyDefault = new DebugDrawBodyOption(0, ColorOfGlobalBody, false);
        drawPhysicsBodyDefault = new DebugDrawBodyOption(0, ColorOfPhysicsBody, false);
    
        renderTarget = sprite;

        world = physicsWorld;

        if (DrawingLabels){
            createTextLabels(world.NumberBodies);
        }
    }
    
    function createTextLabels(count:Int) 
    {
        if(labels==null){
            labels = new Array<FlxText>();
        }
        
        while (labels.length > count){
            var label:FlxText = labels.pop();
            parent.remove(label);
            //renderTarget.removeChild(label);
            label = null;
        }
        
        while (labels.length < count){
            var label:FlxText = new FlxText();
            //label.mouseEnabled = false;
            parent.add(label);
            //renderTarget.addChild(label);
            labels.push(label);
        }
    }
    
    public override function Draw():Void
    {
        FlxSpriteUtil.fill(renderTarget, FlxColor.TRANSPARENT);
        
        if(DrawingBackground){
            FlxSpriteUtil.drawRect(renderTarget, 0, 0, backgroundSize.x, backgroundSize.y);
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
            if (DrawingLabels){
                var labelText:FlxText = labels[i];
                labelText.color = ColorOfText;
                var text:String = body.Label;
                if (text == null){text = "*"; }
                
                labelText.text = text;
                var location:Vector2 = worldToLocal(body.DerivedPos);
                labelText.x = location.x - (labelText.width / 2);
                labelText.y = location.y - (labelText.height /2 );
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
    
    public function SetDefaultBodyDrawOptions(color:Int, isSolid:Bool) 
    {
        drawPhysicsBodyDefault.Color = color;
        drawPhysicsBodyDefault.IsSolid = isSolid;
    }
    
    function drawPointMasses(pointMasses:Array<PointMass>) 
    {
        FlxSpriteUtil.setLineStyle( { color: ColorOfPointMasses, thickness: 0 });
        
        for (i in 0...pointMasses.length){
            var vert:Vector2 = pointMasses[i].Position;
            FlxSpriteUtil.drawRect(renderTarget,
                (vert.x * transform.scale.x) + transform.offset.x - (SizeOfVert / 2),
                (vert.y * transform.scale.y) + transform.offset.y - (SizeOfVert / 2),
                SizeOfVert,
                SizeOfVert,
                ColorOfPointMasses);
        }
    }
    
    function drawInternalSprings(springBody:SpringBody) 
    {
        FlxSpriteUtil.setLineStyle( { color: ColorOfInternalSprings, thickness: 0 });

        for (i in 0...springBody.Springs.length){
            var spring:InternalSpring = springBody.Springs[i];
            var pmA:PointMass = springBody.PointMasses[spring.pointMassA];
            var pmB:PointMass = springBody.PointMasses[spring.pointMassB];
            FlxSpriteUtil.drawLine(renderTarget,
                (pmA.Position.x * transform.scale.x) + transform.offset.x,
                (pmA.Position.y * transform.scale.y) + transform.offset.y,
                (pmB.Position.x * transform.scale.x) + transform.offset.x,
                (pmB.Position.y * transform.scale.y) + transform.offset.y);
        }
    }
    
    function drawGlobalVerts(verts:Array<Vector2>) 
    {
        FlxSpriteUtil.setLineStyle( { color: ColorOfGlobalVerts, thickness: 0 });

        for (i in 0...verts.length){
            var vert:Vector2 = verts[i];
            FlxSpriteUtil.drawRect(renderTarget,
                (vert.x * transform.scale.x) + transform.offset.x - (SizeOfVert / 2),
                (vert.y * transform.scale.y) + transform.offset.y - (SizeOfVert / 2),
                SizeOfVert,
                SizeOfVert,
                ColorOfGlobalVerts);
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
        var drawOpts:DebugDrawBodyOption;
        if (drawLookup.exists(body.Material)){
            drawOpts = drawLookup.get(body.Material);
        }else{
            drawOpts = drawPhysicsBodyDefault;
        }
        return drawOpts;
    }
    
    function DrawPhysicsBounds() 
    {
        FlxSpriteUtil.setLineStyle( { color: ColorOfBounds, thickness: 2 });

        var ul:Vector2 = worldToLocal(worldBounds.UL);
        var lr:Vector2 = worldToLocal(worldBounds.LR);
        FlxSpriteUtil.drawRect(renderTarget, 
            ul.x, 
            ul.y, 
            lr.x - ul.x, 
            lr.y - ul.y, 
            FlxColor.TRANSPARENT);
    }
    
    function drawGlobalBody(shape:Array<Vector2>) 
    {
        drawBody(shape, drawGlobalBodyDefault);
    }
    
    function drawBody(shape:Array<Vector2>, opts:DebugDrawBodyOption) 
    {
        FlxSpriteUtil.setLineStyle( { color: opts.Color, thickness: 1 });
        
        var fillColor = FlxColor.TRANSPARENT;
        var start:Vector2 = shape[0];
        if (opts.IsSolid){
            fillColor = opts.Color;
        }
        
        var transformedShape:Array<FlxPoint> = shape.map(function(v){
            return new FlxPoint((v.x * transform.scale.x) + transform.offset.x , (v.y * transform.scale.y) + transform.offset.y);
        });
        
        FlxSpriteUtil.drawPolygon(renderTarget, transformedShape, fillColor, {color:opts.Color});
    }
    
    function drawAABB(box:AABB) 
    {
        var color:FlxColor = ColorOfAABB;
        color.alpha = 128;
        FlxSpriteUtil.setLineStyle( { color: color, thickness: 0,  });

        FlxSpriteUtil.drawRect(renderTarget,
            (box.UL.x * transform.scale.x) + transform.offset.x, 
            (box.UL.y * transform.scale.y) + transform.offset.y, 
            box.Width * transform.scale.x, 
            box.Height * transform.scale.y,
            FlxColor.TRANSPARENT);
    }
    
    public override function setupDrawParam():Void
    {
        super.setupDrawParam();
        this.DrawingBackground = false;
        this.DrawingBounds = false;
        this.DrawingAABB = false;
        this.DrawingGlobalBody = false;
        this.DrawingPointMasses = false;
        this.DrawingLabels = true;
        this.SetMaterialDrawOptions(constants.GameConstants.MATERIAL_GROUND, FlxColor.WHITE, false);
        for (i in 0...constants.GameConstants.UniqueColors){
            this.SetMaterialDrawOptions(i, colorSource.getColor(i), true);
        }
    }
}