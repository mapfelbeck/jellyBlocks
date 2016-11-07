package blocks;

import flixel.util.FlxColor;
import jellyPhysics.Body;
import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;
import jellyPhysics.PressureBody;

/**
 * ...
 * @author 
 */
class GameBlock extends PressureBody
{
    private var freezeable:Bool;
    public var Freezeable(get, set):Bool;
    public function get_Freezeable(){ return freezeable; }
    public function set_Freezeable(value:Bool){ return freezeable = value;}
    
    private var timeFrozen:Float;
    public  var TimeFrozen(get, set):Float;    
    public function get_TimeFrozen():Float { return timeFrozen; }    
    public function set_TimeFrozen(value:Float):Float { return timeFrozen = value;}

    private var poppable:Bool;
    public var Poppable(get, set):Bool;
    public function get_Poppable() { return poppable; }    
    public function set_Poppable(value:Bool) { return poppable = value;}
    
    private var popping:Bool;
    public var Popping(get, set):Bool;
    public function get_Popping(){ return popping;}
    public function set_Popping(value:Bool){ return popping = value;}
    
    private var hasEverCollided:Bool;
    public var HasEverCollided(get, set):Bool;
    public function get_HasEverCollided(){ return hasEverCollided;}
    public function set_HasEverCollided(value:Bool){ return hasEverCollided = value;}
    
    private var collidedThisFrame:Bool;
    public var CollidedThisFrame(get, set):Bool;
    public function get_CollidedThisFrame(){ return collidedThisFrame;}
    public function set_CollidedThisFrame(value:Bool){ return collidedThisFrame = value;}
    
    /*public var NormalColor:FlxColor = FlxColor.WHITE;
    private var blockColor:FlxColor;
    public var BlockColor(get, set):FlxColor;
    public function get_BlockColor(){
        return blockColor;
    }
    public function set_BlockColor(value:FlxColor){
        return blockColor = value;
    }*/
    
    private var config:BlockConfig;
    private var collideTime:Float = 0.0;

    public var moveForce:Vector2;
    public var rotateAmount:Float;
    public var rotateForce:Float;
    public var rotateCenter:Vector2;

    private var lifeTime:Float;

    //delete if the block falls below this treshhold
    private var deleteRange:Float;
    
    public var CollisionList:Array<GameBlock>;
        
    public function new(bodyShape:ClosedShape, massPerPoint:Float, position:Vector2, 
    angleInRadians:Float, bodyScale:Vector2, isKinematic:Bool, 
    bodyShapeSpringK:Float, bodyShapeSpringDamp:Float, edgeSpringK:Float, 
    edgeSpringDamp:Float, gasPressure:Float, blockConfig:BlockConfig) 
    {
        super(bodyShape, massPerPoint, position, angleInRadians, bodyScale, isKinematic, bodyShapeSpringK, bodyShapeSpringDamp, edgeSpringK, edgeSpringDamp, gasPressure);
    
        config = blockConfig;
        CollisionCallback = CollideWith;
        CollisionList = new Array<GameBlock>();
        moveForce = new Vector2(0, 0);
        rotateCenter = new Vector2(0, 0);
        rotateAmount = 0.0;
        lifeTime = 0.0;
        deleteRange = 80.0;
        timeFrozen = 0.0;
        poppable = true;
    }
    
    function CollideWith(otherBlock:Body):Void
    {
        if (GroupNumber != otherBlock.GroupNumber)
        {
            hasEverCollided = true;
        }

        if (GroupNumber != otherBlock.GroupNumber && !otherBlock.IsStatic ||
            hasEverCollided && !otherBlock.IsStatic)
        {
            collidedThisFrame = true;
        }
        
        if (Material == otherBlock.Material)
        {
            var other:GameBlock = Std.instance(otherBlock, GameBlock);
            if (CollisionList.indexOf(other) == -1)
            {
                CollisionList.push(other);
            }
        }
    }
    
    override public function ResetExternalForces():Void 
    {
        super.ResetExternalForces();
        moveForce.x = 0;
        moveForce.y = 0;
        rotateAmount = 0.0;
        rotateCenter.x = 0;
        rotateCenter.y = 0;
    }
    
    override public function Update(elapsed:Float):Void 
    {
        super.Update(elapsed);

        if (DerivedPos.y > deleteRange)
        {
            //delete because we're out of bounds
            DeleteThis = true;
        }

        if (hasEverCollided)
        {
            lifeTime += elapsed;
        }

        //if a block has collided with 2 or more others of it's color we know
        //that at least 3 of the same color are touching, so mark this block and
        //every block in it's collision list as collided so they inflate and pop
        if (CollisionList.length >= 2 && Poppable && !IsStatic)
        {
            popping = true;
            
            for (i in 0...CollisionList.length){
                CollisionList[i].Popping = true;
            }
            //EventManager.Trigger(this, "Inflate");
        }

        CollisionList = new Array<GameBlock>();

        if (popping)
        {
            collideTime += elapsed;
            GasAmount += elapsed * GameConstants.GasPressure;
            if (collideTime > GameConstants.BlockCollideTime)
            {
                DeleteThis = true;
            }
        }
    }
    
    public function CollisionlessFrame():Void{
        
    }
    
    override public function AccumulateExternalForces(elapsed:Float):Void 
    {
        super.AccumulateExternalForces(elapsed);
        
        if (!IsAsleep){
            var nCenter:Vector2 = null;
            var origin:Vector2 = null;
            var rotationForce:Vector2 = new Vector2(0, 0);

            for (i in 0...PointMasses.length){
                PointMasses[i].Force.add(moveForce);
                
                if (rotateAmount != 0){
                    
                    nCenter = VectorTools.Add(PointMasses[i].Position, rotateCenter);
                    origin = VectorTools.Subtract(PointMasses[i].Position, rotateCenter);
                    //trace("nCenter: (" + nCenter.x + ", " + nCenter.y + ")");
                    //trace("origin: (" + origin.x + ", " + origin.y + ")");

                    rotationForce.x =
                        origin.x * Math.cos(rotateAmount) - origin.y * Math.sin(rotateAmount);
                    rotationForce.y =
                        origin.x * Math.sin(rotateAmount) + origin.y * Math.cos(rotateAmount);
                    PointMasses[i].Force.add(VectorTools.Multiply(rotationForce, rotateForce));
                }
            }
        }
    }
}