package blocks;

/**
 * ...
 * @author 
 */
class BlockConfig
{
    public function new(){
    }
    
    //time before effect begins
    public var timeTillDamping:Float;
    //damping rate
    public var dampingRate:Float;
    //max physics damping
    public var dampingMax:Float;

    //does the block deflate
    public var deflates:Bool;
    //time until deflating begins
    public var timeTillDeflate:Float;
    //how much pressure does a deflating block loose per second
    public var deflateRate:Float;

    //time until freeze
    public var timeTillFreeze:Float;
    //how long to wait before attempts to freze the block
    public var freezeWaitTimerLength:Float;
    //don't freeze if the block is moving faster than this rate
    public var freezeVelocityThreshhold:Float;
    //don't freeze if the block is distroted by more than this
    public var freezeDistortionThreshhold:Float;
    
    public var scale:Float;
}