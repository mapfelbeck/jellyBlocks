package gamepieces;
import blocks.GameBlock;
import constants.GameConstants;
import events.EventManager;
import events.Events;
import jellyPhysics.Body;
import jellyPhysics.ExternalSpring;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;
import enums.TriominoShape;

/**
 * ...
 * @author 
 */
class GamePiece
{
    private var blocks:Array<GameBlock>;
    public var Blocks(get, set):Array<GameBlock>;
    function get_Blocks():Array<GameBlock>{return blocks;}    
    function set_Blocks(value:Array<GameBlock>):Array<GameBlock>{return blocks = value; }
    
    private var attachSprings:Array<ExternalSpring>;
    public var AttachSprings(get, set):Array<ExternalSpring>;
    function get_AttachSprings():Array<ExternalSpring>{return attachSprings;}    
    function set_AttachSprings(value:Array<ExternalSpring>):Array<ExternalSpring>{return attachSprings = value; }
    
    private var hasEverCollided:Bool;
    public var HasEverCollided(get, null):Bool;
    function get_HasEverCollided():Bool{
        return hasEverCollided;
    }
    
    public var IsControlled(get, set):Bool;
    private var isControlled:Bool = false;
    function get_IsControlled():Bool 
    {
        return isControlled;
    }
    
    function set_IsControlled(value:Bool):Bool 
    {
        for (i in 0...blocks.length){
            blocks[i].IsControlled = value;
        }
        return isControlled = value;
    }
    
    public var IsKinematic(get, set):Bool;
    private var isKinematic:Bool = false;
    function get_IsKinematic():Bool 
    {
        return isKinematic;
    }
    function set_IsKinematic(value:Bool):Bool 
    {
        for (i in 0...blocks.length){
            blocks[i].Kinematic = value;
        }
        return isKinematic = value;
    }
    
    public var Pressure(get, set):Float;
    private var pressure:Float = 0;
    function get_Pressure():Float 
    {
        if (blocks.length > 0){
            return blocks[0].GasAmount;
        }
        return 0;
    }
    function set_Pressure(value:Float):Float 
    {
        for (i in 0...blocks.length){
            blocks[i].GasAmount = value;
        }
        return pressure = value;
    }
    
    public var Scale(get, set):Vector2;
    private var scale:Vector2 = null;
    function get_Scale():Vector2 
    {
        return scale;
    }
    function set_Scale(value:Vector2):Vector2 
    {
        for (i in 0...blocks.length){
            blocks[i].Scale = value;
        }
        return scale = value;
    }
    
    private var id:Int;
    private var ID(get, null):Int;
    function get_ID():Int 
    {
        return id;
    }
    
    private var shape:TriominoShape;
    public var Shape(get, set):TriominoShape;
    function get_Shape():TriominoShape{
        return shape;
    }
    function set_Shape(value:TriominoShape):TriominoShape{
        return this.shape = value;
    }
    
    private var collidedThisFrame:Bool;
    
    private var pushForceX:Float;
    private var pushForceY:Float;
    private var torqueForce:Float;
    
    private var lifeTime:Float = 0;
    public var LifeTime(get, null):Float; 
    public function get_LifeTime():Float {return lifeTime;}
    
    private var originalBlockCount:Int;
    private var inputScalar:Float;
    
    private var rotationLastFrame:Float;
    private var rotationSpeed:Float = 0;
    public var RotationSpeed(get, null):Float;    
    public function get_RotationSpeed():Float{return rotationSpeed; }
   
    public var DerivedVelocity(get, null):Vector2;
    function get_DerivedVelocity():Vector2{
        var derived:Vector2 = new Vector2(0, 0);
        for (block in blocks){
            if (block.DerivedVel == null){
                continue;
            }
            derived.add(block.DerivedVel);
        }
        derived.x /= blocks.length;
        derived.y /= blocks.length;
        return derived;
    }
    
    public function new(theBlocks:Array<GameBlock>, theSprings:Array<ExternalSpring>,
            gravityScalar:Float, id:Int) 
    {
        this.id = id;
        blocks = theBlocks;
        originalBlockCount = blocks.length;
        attachSprings = theSprings;
        SetControlForces(gravityScalar);

        for(i in 0...blocks.length)
        {
            blocks[i].DeleteCallback = RemoveBlockFromGamePiece;
        }

        inputScalar = Math.sqrt(2.0);
        //unpossible
        rotationLastFrame = 999.0;
    }
    
    function SetControlForces(gravityScalar:Float) 
    {
        pushForceX = -gravityScalar * constants.GameConstants.PushForceXCoefficient;
        pushForceY = -gravityScalar * constants.GameConstants.PushForceYCoefficient;
        torqueForce = -gravityScalar * constants.GameConstants.TorqueForceCoefficient;
    }
    
    public function Update(elapsedTime:Float):Void
    {
        lifeTime += elapsedTime;
        var rotationThisFrame:Float = GamePieceRotation();

        if (rotationLastFrame == 999.0)
        {
            rotationLastFrame = rotationThisFrame;
        }
        rotationSpeed = (rotationThisFrame - rotationLastFrame) / elapsedTime;

        collidedThisFrame = false;
        for (i in 0...blocks.length)
        {
            var block:GameBlock = blocks[i];
            //has or has not?...
            if (block.HasEverCollided)
            {
                if (!hasEverCollided){
                    EventManager.Trigger(this, Events.PIECE_HIT, null);
                }
                hasEverCollided = true;
                for (j in 0...blocks.length)
                {
                    blocks[j].HasEverCollided = true;
                }
            }
            if (block.CollidedThisFrame)
            {
                collidedThisFrame = true;
            }
        }
        if (hasEverCollided && !collidedThisFrame)
        {
            //Console.WriteLine("collisionless frame");
            for(k in 0...blocks.length)
            {
                blocks[k].CollisionlessFrame();
            }
        }
        //FIXME: why is this here?
        else if(hasEverCollided)
        {
            for(i in 0...blocks.length)
            {
                blocks[i].CollidedThisFrame = false;
            }
            //Console.WriteLine("collision this frame, piece {0}",pieceNumber);
        }

        rotationLastFrame = rotationThisFrame;
    }
    
    public function GamePieceAccumulator(elapsedTime:Float):Void
    {
        var accumulatorForce:Vector2 = null;

        for (i in 0...attachSprings.length)
        {
            var spring:ExternalSpring = attachSprings[i];
            var a:Body = spring.BodyA;
            var pmA = a.PointMasses[spring.pointMassA];
            var b:Body = spring.BodyB;
            var pmB = b.PointMasses[spring.pointMassB];
            
            accumulatorForce = VectorTools.CalculateSpringForce(pmA.Position, pmA.Velocity, pmB.Position, pmB.Velocity, spring.springLen, spring.springK, spring.damping);

            pmA.Force.x += accumulatorForce.x;
            pmA.Force.y += accumulatorForce.y;
            pmB.Force.x -= accumulatorForce.x;
            pmB.Force.y -= accumulatorForce.y;
        }
    }
    
    public function ApplyForce(force:Vector2):Void
    {
        var position:Vector2;
        for (i in 0...blocks.length)
        {
            position = blocks[i].DerivedPos;
            blocks[i].AddGlobalForce(position, force);
        }
    }
    
    public function ApplyTorque(torqueAmount:Float) 
    {
        for (i in 0...blocks.length)
        {
            blocks[i].rotateAmount = torqueAmount;
            blocks[i].rotateForce = 9.8 * 1.25;
            blocks[i].rotateCenter = GamePieceCenter();
        }
    }
    
    public function GamePieceCenter():Vector2
    {
        var center:Vector2 = new Vector2(0, 0);

        for(i in 0...blocks.length)
        {
            center = VectorTools.Add(center, blocks[i].DerivedPos);
        }

        center = VectorTools.Multiply(center, 1.0 / blocks.length);
        return center;
    }
    
    public function GamePieceRotation():Float
    {
        var rotation:Float = 0;

        for (i in 0...blocks.length)
        {
            rotation += blocks[i].DerivedAngle;
        }

        rotation = rotation / blocks.length;
        return rotation;
    }
    
    public function Omega():Float
    {
        var omega:Float = 0;

        for (i in 0...blocks.length)
        {
            var derivedOmega:Float = blocks[i].DerivedOmega;
            #if (neko)
            if (derivedOmega == null){
                //clear up a Neko bug
                continue;
            }
            #end
            omega += derivedOmega;
        }

        omega = omega / blocks.length;
        return omega;
    }
    
    private function RemoveBlockFromGamePiece(body:Body):Void
    {
        var block:GameBlock = Std.instance(body, GameBlock);

        if (block!=null && blocks.indexOf(block) != -1)
        {
            RemoveSpringsAttachedTo(block);
        }
        blocks.remove(block);
    }

    private var deleteSpringList:Array<ExternalSpring> = new Array<ExternalSpring>();
    private function RemoveSpringsAttachedTo(block: GameBlock):Void
    {
        for (i in 0...attachSprings.length)
        {
            if (attachSprings[i].BodyA == block || attachSprings[i].BodyB == block)
            {
                deleteSpringList.push(attachSprings[i]);
            }
        }
        
        while (deleteSpringList.length > 0){
            var spring:ExternalSpring = deleteSpringList.pop();
            attachSprings.remove(spring);
        }
    }
}