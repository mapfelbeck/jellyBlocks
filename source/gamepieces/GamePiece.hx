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
    private var attachSprings:Array<ExternalSpring>;
    private var isControlled:Bool;
    private var showColorPulse:Bool;
    private var pieceNumber:Int;
    private var hasEverCollided:Bool;
    private var collidedThisFrame:Bool;
    
    private var pushForceX:Float;
    private var pushForceY:Float;
    private var torqueForce:Float;
    
    private var inFailLocation:Bool;
    private var remainingLifeTime:Float;
    private var autoDampRate:Float;
    
    private var originalBlockCount:Int;
    private var inputScalar:Float;
    
    private var rotationLastFrame:Float;
    private var rotationSpeed:Float;
    
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
        var rotationThisFrame:Float = GamePieceRotation();

        if (rotationLastFrame == 999.0)
        {
            rotationLastFrame = rotationThisFrame;
        }
        rotationSpeed = (rotationThisFrame - rotationLastFrame) / elapsedTime;

        collidedThisFrame = false;
        for (i in 0...blocks.length)
        {
            var block = blocks[i];
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
                block[k].CollisionlessFrame();
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
        var Force:Vector2 = new Vector2(0, 0);

        for (i in 0...attachSprings.length)
        {
            Force = VectorTools.CalculateSpringForce(
                attatchSprings[i].bodyA.getPointMass(attatchSprings[i].pointMassA).Position, attatchSprings[i].bodyA.getPointMass(attatchSprings[i].pointMassA).Velocity,
                attatchSprings[i].bodyB.getPointMass(attatchSprings[i].pointMassB).Position, attatchSprings[i].bodyB.getPointMass(attatchSprings[i].pointMassB).Velocity,
                attatchSprings[i].springD, attatchSprings[i].springK, attatchSprings[i].damping);

            attatchSprings[i].bodyA.getPointMass(attatchSprings[i].pointMassA).Force += Force;
            attatchSprings[i].bodyB.getPointMass(attatchSprings[i].pointMassB).Force -= Force;
        }
    }
    
    public function ApplyForce(Vector2 force):Void
    {
        var position:Vector2;
        for (i in 0...blocks.length)
        {
            position = blocks[i].DerivedPos;
            blocks[i].AddGlobalForce(position, force);
        }
    }
    
    public function GamePieceCenter():Vector2
    {
        var center:Vector2 = new Vector2(0, 0);

        for(i in 0...blocks.length)
        {
            center = VectorTools.Add(center, blocks[i].DerivedPosition);
        }

        center = VectorTools.Multiply(center, 1.0 / blocks.Count);
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
    
    private function RemoveBlockFromGamePiece(body:Body):Void
    {
        var block:GameBlock = Std.instance(body, GameBlock);

        if (block!=null && blocks.indexOf(block) != -1)
        {
            RemoveSpringsAttachedTo(block);
        }
        blocks.remove(block);
    }

    private function RemoveSpringsAttachedTo(GameBlock block):Void
    {
        for (i in attachSprings.length...0)
        {
            if (attatchSprings[i].bodyA == block || attatchSprings[i].bodyB == block)
            {
                attachSprings.remove(attatchSprings[i]);
            }
        }
    }
}