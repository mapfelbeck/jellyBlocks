package constants;

/**
 * ...
 * @author 
 */
class GameConstants
{
    public function new() 
    {
    }

    public static inline var offscreenRenderX:Int = -2000;
    public static inline var offscreenRenderY:Int = 0;
    
    //control forces
    public static inline var PushForceXCoefficient:Float = 1.25;
    public static inline var PushForceYCoefficient:Float = .75;
    public static inline var TorqueForceCoefficient:Float = 1.25;

    //if a controlled block is above this line when a new piece spawns, game over
    public static var GAME_WORLD_FAIL_HEIGHT: Int = -10;

    //How many unique colors are there
    public static inline var UniqueColors:Int = 7;
    //How many of the same color can be in a game piece
    public static var MaxSameColorPerPiece:Int = 2;
    public static inline var MATERIAL_GROUND:Int = UniqueColors;

    //how long a block inflates before popping
    public static inline var BlockCollideTime:Float = 1;
    //how long the block pulses from red (out of game area) or 
    //white(in game area) before the next plaock spawns
    public static inline var BlockSpawnWarningTime:Float = 2;
    //must wait at least this long between block spawns
    public static inline var ForcedSpawnCoolOff:Float = 2;
 
    public static inline var GamePadDeadZone:Float = 0.2;
}