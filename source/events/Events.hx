package events;

/**
 * ...
 * @author Michael Apfelbeck
 */
class Events 
{
    public static var PIECE_CREATE = "PieceCreate";
    public static var PIECE_HIT = "PieceHit";
    public static var BLOCK_POP = "BlockPop";
    public static var COLOR_ROTATE = "ColorRotate";
    
    public static var SHOW_TOUCH_CONTROLS = "ShowTouchControls";
    
    public static var MUSIC_ENABLED:String = "MusicEnabled";
    public static var MUSIC_VOLUME:String = "MusicVolume";
    public static var SOUND_ENABLED:String = "MsoundEnabled";
    public static var SOUND_VOLUME:String = "SoundVolume";
    
    
    public function new() {}
    
}