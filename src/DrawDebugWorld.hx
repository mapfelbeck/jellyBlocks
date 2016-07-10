package;
import jellyPhysics.*;
import flash.display.Graphics;
import lime.math.Vector2;
import openfl.display.Sprite;
import jellyPhysics.World;

/**
 * ...
 * @author Michael Apfelbeck
 */
class DrawDebugWorld
{
    public var renderSize:Vector2;
    public var backgroundColor:Int;
    
    private var renderTarget:Sprite;
    private var graphics:Graphics;
    private var world:World;
    
    private var offset:Vector2 = new Vector2(0, 0);
    private var scale:Vector2 = new Vector2(20.0, 20.0);
    
    public static var COLOR_RED:Int = 0xFF0000;
    public static var COLOR_GREEN:Int = 0x00FF00;
    public static var COLOR_BLUE:Int = 0x0000FF;
    public static var COLOR_BLACK:Int = 0x000000;
    public static var COLOR_WHITE:Int = 0xFFFFFF;
    public static var COLOR_PURPLE:Int = 0xFF00FF;
    public static var COLOR_YELLOW:Int = 0xFFFF00;
    public static var COLOR_AQUA:Int = 0x00FFFF;
    
    public var ColorOfAABB:Int = COLOR_YELLOW;
    public var ColorOfBackground:Int = COLOR_BLACK;
    public var ColorOfGlobalVerts:Int = COLOR_YELLOW;
    public var ColorOfGlobalBody:Int = COLOR_YELLOW;
    public var ColorOfPhysicsBody:Int = COLOR_WHITE;
    public var ColorOfInternalSprings:Int = COLOR_RED;
    public var ColorOfPointMasses:Int = COLOR_BLUE;
    
    public var SizeOfVert:Float = 4;
    
    public var DrawingAABB:Bool = false;
    public var DrawingGlobalVerts:Bool = true;
    public var DrawingGlobalBody:Bool = true;
    public var DrawingPhysicsBody:Bool = true;
    public var DrawingInternalSprings:Bool = false;
    public var DrawingPointMasses:Bool = true;
    
    public function new(sprite:Sprite, physicsWorld:World) 
    {
        renderTarget = sprite;
        graphics = renderTarget.graphics;
        world = physicsWorld;
        backgroundColor = ColorOfBackground;
        
        renderSize = new Vector2(sprite.stage.stageWidth - (2 * sprite.x), sprite.stage.stageHeight - (2 * sprite.y));
        offset.x = renderSize.x / 2;
        offset.y = renderSize.y / 2;
    }
    
    public function Draw():Void
    {
        graphics.clear();
        graphics.beginFill(backgroundColor);
        graphics.drawRect(0, 0, renderSize.x, renderSize.y);
        graphics.endFill();
        
        //render.graphics.lineStyle(2, 0x708090);
        //render.graphics.drawRect(16, 16, 16, 16);
        //render.graphics.drawRect(0, 0, 64, 64);
        
        for (i in 0...world.NumberBodies){
            var body:Body = world.GetBody(i);
            DrawingAABB?drawAABB(body.BoundingBox):null;
            DrawingGlobalBody?drawGlobalBody(body.GlobalShape):null;
            DrawingPhysicsBody?drawPhysicsBody(body.PointMasses):null;
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
    
    function drawPhysicsBody(pointMasses:Array<PointMass>) 
    {
        graphics.lineStyle(0, ColorOfPhysicsBody);
        var point:Vector2 = pointMasses[0].Position;
        graphics.moveTo((point.x * scale.x) + offset.x, (point.y * scale.y) + offset.y);
        for (i in 0...pointMasses.length){
            var next:Vector2;
            if (i == pointMasses.length-1){
                next = pointMasses[0].Position;
            }else{
                next = pointMasses[i+1].Position;
            }
            graphics.lineTo((next.x * scale.x) + offset.x, (next.y * scale.y) + offset.y);            
        }
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
    
    function drawGlobalBody(shape:Array<Vector2>) 
    {
        graphics.lineStyle(0, ColorOfGlobalBody);
        var start:Vector2 = shape[0];
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
    }
    
    function drawAABB(box:AABB) 
    {
        graphics.lineStyle(0, ColorOfAABB, 0.5);
                
        graphics.drawRect((box.UL.x * scale.x) + offset.x, (box.UL.y * scale.y) + offset.y, 
                                 box.Width * scale.x, box.Height * scale.y);
    }
}