package builders;
import blocks.BlockConfig;
import blocks.GameBlock;
import builders.GameBlockBuilder;
import enums.BlockType;
import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class GameBlockBuilder
{
    var shape:ClosedShape;
    var type:BlockType;
    var mass:Float;
    var angle:Float;
    var position:Vector2;
    var scale:Vector2;
    var kinematic:Bool;
    var shapeK:Float;
    var shapeDamp:Float;
    var edgeK:Float;
    var edgeDamp:Float;
    var pressure:Float;
    var config:BlockConfig;
    
    public function new() 
    {
    }
    
    public function create():GameBlock{
        var finalBlock:GameBlock = null;
        switch(type){
            case BlockType.Normal:
                finalBlock = new GameBlock(shape, mass, position, angle, scale, kinematic, shapeK, shapeDamp, edgeK, edgeDamp, pressure, config);
            default:
        }
        return finalBlock;
    }
    
    public function setShape(polygonShape:ClosedShape):GameBlockBuilder
    {
        shape = polygonShape;
        return this;
    }
    
    public function setType(type:BlockType) :GameBlockBuilder
    {
        this.type = type;
        return this;
    }
    
    public function setMass(mass:Float) :GameBlockBuilder
    {
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
}