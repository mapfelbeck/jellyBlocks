package gamepieces;
import blocks.GameBlock;
import jellyPhysics.Body;
import jellyPhysics.ExternalSpring;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;

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
    
    private var isControlled:Bool;
    private var showColorPulse:Bool;
    private var pieceNumber:Int;
    private var collidedThisFrame:Bool;
    
    private var pushForceX:Float;
    private var pushForceY:Float;
    private var torqueForce:Float;
    
    private var inFailLocation:Bool;
    private var lifeTime:Float = 0;
    public var LifeTime(get, null):Float; 
    public function get_LifeTime():Float {return lifeTime;}
    
    private var originalBlockCount:Int;
    private var inputScalar:Float;
    
    private var rotationLastFrame:Float;
    private var rotationSpeed:Float = 0;
    public var RotationSpeed(get, null):Float;    
    public function get_RotationSpeed():Float{return rotationSpeed;}
    
    public function new(theBlocks:Array<GameBlock>, theSprings:Array<ExternalSpring>,
            gravityScalar:Float) 
    {
        showColorPulse = true;
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
        pushForceX = -gravityScalar * GameConstants.PushForceXCoefficient;
        pushForceY = -gravityScalar * GameConstants.PushForceYCoefficient;
        torqueForce = -gravityScalar * GameConstants.TorqueForceCoefficient;
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
    
    public function GamePieceOmega():Float
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