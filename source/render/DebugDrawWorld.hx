package render;
import jellyPhysics.*;
import constants.GameConstants;
import jellyPhysics.World;
import jellyPhysics.math.*;
import openfl.display.*;
import openfl.events.*;
import openfl.text.TextField;
import render.DebugDrawBodyOption;
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
    
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:World;
    private var worldBounds:AABB;
    
    private var labels:Array<TextField>;
    
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
    
    public function new(sprite:Sprite, colorSource:IColorSource, physicsWorld:World, screenWorldTransform:ScreenWorldTransform) 
    {
        super(colorSource, screenWorldTransform);
        drawGlobalBodyDefault = new DebugDrawBodyOption(0, ColorOfGlobalBody, false);
        drawPhysicsBodyDefault = new DebugDrawBodyOption(0, ColorOfPhysicsBody, false);
    
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;

        if (DrawingLabels){
            createTextLabels(world.NumberBodies);
        }
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
            graphics.drawRect(transform.overscan, transform.overscan, backgroundSize.x, backgroundSize.y);
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
        graphics.lineStyle(0, ColorOfPointMasses);
        graphics.beginFill(ColorOfPointMasses, 1.0);
        
        for (i in 0...pointMasses.length){
            var vert:Vector2 = pointMasses[i].Position;
            graphics.drawRect((vert.x * transform.scale.x) + transform.offset.x - (SizeOfVert / 2), (vert.y * transform.scale.y) + transform.offset.y - (SizeOfVert / 2), SizeOfVert, SizeOfVert);
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
            graphics.moveTo((pmA.Position.x * transform.scale.x) + transform.offset.x, (pmA.Position.y * transform.scale.y) + transform.offset.y);
            graphics.lineTo((pmB.Position.x * transform.scale.x) + transform.offset.x, (pmB.Position.y * transform.scale.y) + transform.offset.y);
        }
    }
    
    function drawGlobalVerts(verts:Array<Vector2>) 
    {
        graphics.lineStyle(0, ColorOfGlobalVerts);
        graphics.beginFill(ColorOfGlobalVerts, 1.0);
        for (i in 0...verts.length){
            var vert:Vector2 = verts[i];
            graphics.drawRect((vert.x * transform.scale.x) + transform.offset.x - (SizeOfVert / 2), (vert.y * transform.scale.y) + transform.offset.y - (SizeOfVert / 2), SizeOfVert, SizeOfVert);
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
    
    function drawBody(shape:Array<Vector2>, opts:DebugDrawBodyOption) 
    {
        graphics.lineStyle(0, opts.Color);
        var start:Vector2 = shape[0];
        if (opts.IsSolid){
            graphics.beginFill(opts.Color, 1.0);
        }
        graphics.moveTo((start.x * transform.scale.x) + transform.offset.x , (start.y * transform.scale.y) + transform.offset.y );
        for (i in 0...shape.length){
            var next:Vector2;
            if (i == shape.length-1){
                next = shape[0];
            }else{
                next = shape[i+1];
            }
            graphics.lineTo((next.x * transform.scale.x) + transform.offset.x, (next.y * transform.scale.y) + transform.offset.y);
        }
        if (opts.IsSolid){
            graphics.endFill();
        }
    }
    
    function drawAABB(box:AABB) 
    {
        graphics.lineStyle(0, ColorOfAABB, 0.5);
                
        graphics.drawRect((box.UL.x * transform.scale.x) + transform.offset.x, (box.UL.y * transform.scale.y) + transform.offset.y, 
                                 box.Width * transform.scale.x, box.Height * transform.scale.y);
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
        this.SetMaterialDrawOptions(constants.GameConstants.MATERIAL_GROUND, BaseDrawWorld.COLOR_WHITE, false);
        for (i in 0...constants.GameConstants.UniqueColors){
            this.SetMaterialDrawOptions(i, colorSource.getColor(i), true);
        }
    }
}