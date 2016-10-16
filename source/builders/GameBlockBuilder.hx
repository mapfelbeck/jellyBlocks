package builders;
import blocks.BlockConfig;
import blocks.*;
import builders.GameBlockBuilder;
import constants.PhysicsDefaults;
import enums.BlockType;
import haxe.Constraints.Function;
import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class GameBlockBuilder
{
    var shapeBuilder:ShapeBuilder;
    var material:Int = 0;
    var type:BlockType = BlockType.Normal;
    var mass:Float = PhysicsDefaults.Mass;
    var angle:Float = PhysicsDefaults.Angle;
    var position:Vector2 = new Vector2( 0, 0);
    var scale:Vector2 = new Vector2( 1, 1);
    var kinematic:Bool= false;
    var shapeK:Float = PhysicsDefaults.ShapeSpringK;
    var shapeDamp:Float= PhysicsDefaults.ShapeSpringDamp;
    var edgeK:Float= PhysicsDefaults.EdgeSpringK;
    var edgeDamp:Float= PhysicsDefaults.EdgeSpringDamp;
    var pressure:Float = PhysicsDefaults.Pressure;
    var label:String = null;
    var config:BlockConfig;
    var collisionCallback:Function;
    
    public function new() 
    {
        config = new BlockConfig();
        config.timeTillDamping = 0.5;
        config.dampingRate = 0.15;
        config.dampingMax = 0.98;
        
        config.deflateRate = .25;
        config.timeTillDeflate = 5;
        
        config.timeTillFreeze = 2;
        config.freezeWaitTimerLength = 0.5;
        config.freezeDistortionThreshhold = 0.8;
        config.freezeVelocityThreshhold = 0.08;
    }
    
    public function create():GameBlock{
        var finalBlock:GameBlock = null;
        switch(type){
            case BlockType.Normal:
                finalBlock = new GameBlock(shapeBuilder.create(), mass, position, angle, scale, kinematic, shapeK, shapeDamp, edgeK, edgeDamp, pressure, config);
            case BlockType.Damping:
                var dampingBlock:DampingGameBlock = null;
                dampingBlock = new DampingGameBlock(shapeBuilder.create(), mass, position, angle, scale, kinematic, shapeK, shapeDamp, edgeK, edgeDamp, pressure, config);
                finalBlock = dampingBlock;
            case BlockType.Deflating:
                var deflatingBlock:DeflatingGameBlock = null;
                deflatingBlock = new DeflatingGameBlock(shapeBuilder.create(), mass, position, angle, scale, kinematic, shapeK, shapeDamp, edgeK, edgeDamp, pressure, config);
                finalBlock = deflatingBlock;
            /*case BlockType.Freeze:
                var freezingBlock:FreezingGameBlock = null;
                freezingBlock = new FreezingGameBlock(shapeBuilder.create(), mass, position, angle, scale, kinematic, shapeK, shapeDamp, edgeK, edgeDamp, pressure, config);
                finalBlock = freezingBlock;*/
            default:
        }
        finalBlock.Material = material;
        //finalBlock.CollisionCallback = collisionCallback;
        if (label != null){
            finalBlock.Label = label;
        }
        return finalBlock;
    }
    
    public function setShapeBuilder(builder:ShapeBuilder):GameBlockBuilder
    {
        shapeBuilder = builder;
        return this;
    }
    
    public function getShapeBuilder():ShapeBuilder
    {
        return shapeBuilder;
    }
    
    public function setType(type:BlockType) :GameBlockBuilder
    {
        this.type = type;
        return this;
    }
    
    public function setMaterial(material:Int) :GameBlockBuilder
    {
        this.material = material;
        return this;
    }
    
    public function setMass(mass:Float) :GameBlockBuilder
    {
        if (mass == Math.POSITIVE_INFINITY){
            this.kinematic = true;
        }else{
            this.kinematic = false;
        }
        this.mass = mass;
        return this;
    }
    
    public function setPosition(vector2:Vector2) :GameBlockBuilder
    {
        this.position = vector2;
        return this;
    }
    
    public function setRotation(angleInRadians:Float) :GameBlockBuilder
    {
        this.angle = angleInRadians;
        return this;
    }
    
    public function setScale(scale:Vector2) :GameBlockBuilder
    {
        this.scale = scale;
        return this;
    }
    
    public function setKinematic(kinematic:Bool) :GameBlockBuilder
    {
        this.kinematic = kinematic;
        return this;
    }
    
    public function setShapeK(shapeK:Float) :GameBlockBuilder
    {
        this.shapeK = shapeK;
        return this;
    }
    
    public function setShapeDamp(shapeDamp:Float) :GameBlockBuilder
    {
        this.shapeDamp = shapeDamp;
        return this;
    }
    
    public function setEdgeK(edgeK:Float) :GameBlockBuilder
    {
        this.edgeK = edgeK;
        return this;
    }
    
    public function setEdgeDamp(edgeDamp:Float) :GameBlockBuilder
    {
        this.edgeDamp = edgeDamp;
        return this;
    }
    
    public function setPressure(pressureAmount:Float) :GameBlockBuilder
    {
        this.pressure = pressureAmount;
        return this;
    }
    
    public function setConfig(blockConfig:BlockConfig) :GameBlockBuilder
    {
        this.config = blockConfig;
        return this;
    }
    
    /*public function setCollisionCallback(callback:Function):GameBlockBuilder{
        this.collisionCallback = callback;
        return this;
    }*/
    
    public function setLabel(string:String):GameBlockBuilder
    {
        this.label = string;
        return this;
    }
}