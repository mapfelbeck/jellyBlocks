package;

/**
 * ...
 * @author 
 */
class GameConstants
{
    public function new() 
    {
    }
    public static var MATERIAL_GROUND:Int = UniqueColors;
    
    public static inline var settingsFile:String = "Balloon Blocks Settings";
    public static inline var highScoreFile:String = "Balloon Blocks High Scores";

    public static inline var MassPerPoint:Float = 1;

    public static inline var GravityConstant:Float = 9.8;

    //control forces
    public static inline var PushForceXCoefficient:Float = 1.25;
    public static inline var PushForceYCoefficient:Float = .75;
    public static inline var TorqueForceCoefficient:Float = 1.25;

    //inflate pressure for game blocks
    public static inline var GasPressure:Float = 250;

    //spring constants
    public static inline var ShapeSpringK:Float = 450;
    public static inline var ShapeSpringDamp:Float = 15;
    public static inline var EdgeSpringK:Float = 450;
    public static inline var EdgeSpringDamp:Float = 15;
    public static inline var InternalSpringK:Float = 450;
    public static inline var InternalSpringDamp:Float = 15;
    public static inline var AttachSpringK:Float = 450;
    public static inline var AttachSpringDamp:Float = 15;

    public static inline var MinVolume:Float = 0;
    public static inline var MaxVolume:Float = 100;

    //speed increase constants for speeding up gameplay as it progresses
    public static inline var CombosToMaxSpeed = 20;
    public static inline var MaxGravityIncrease:Float = 1.5;
    public static inline var MaxFrictionDecrease:Float = .4;

    //How many unique colors are there
    public static var UniqueColors:Int = 6;
    //How many of the same color can be in a game piece
    public static var MaxSameColorPerPiece:Int = 2;

    //how long a block inflates before popping
    public static inline var BlockCollideTime:Float = 1;
    //how long the block pulses from red (out of game area) or 
    //white(in game area) before the next plaock spawns
    public static inline var BlockSpawnWarningTime:Float = 2;
    //must wait at least this long between block spawns
    public static inline var ForcedSpawnCoolOff:Float = 2;

    public static inline var IntroDisplayTime:Float = 6;
    public static inline var IntroSkippable = true;
   
    public static inline var IntroTimesOut = true;
    public static inline var ExitDisplayTime:Float = 6;
    public static inline var ExitSkippable:Bool = true;
    public static inline var ExitTimesOut:Bool = true;
    
}