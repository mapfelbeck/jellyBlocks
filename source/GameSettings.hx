package;
import events.EventManager;
import events.Events;

/**
 * ...
 * @author Michael Apfelbeck
 */
class GameSettings 
{
    private static var showTouchControls:Bool = false;
    public static var ShowTouchControls(get, set):Bool;
    public static function get_ShowTouchControls():Bool{
        return showTouchControls;
    }
    public static function set_ShowTouchControls(value:Bool):Bool{
        showTouchControls = value;
        EventManager.Trigger(null, Events.SHOW_TOUCH_CONTROLS, [showTouchControls]);
        return showTouchControls;
    }
    
    private static var soundEffectsEnabled:Bool = true;
    public static var SoundEffectsEnabled(get, set):Bool;
    public static function get_SoundEffectsEnabled():Bool{
        return soundEffectsEnabled;
    }
    public static function set_SoundEffectsEnabled(value:Bool):Bool{
        soundEffectsEnabled = value;
        EventManager.Trigger(null, Events.SOUND_ENABLED, [soundEffectsEnabled]);
        return soundEffectsEnabled;
    }
    private static var soundEffectsVolume:Float = 0.35;
    public static var SoundEffectsVolume(get, set):Float;
    public static function get_SoundEffectsVolume():Float{
        return soundEffectsVolume;
    }
    public static function set_SoundEffectsVolume(value:Float):Float{
        soundEffectsVolume = value;
        EventManager.Trigger(null, Events.SOUND_VOLUME, [soundEffectsVolume]);
        return soundEffectsVolume;
    }
    
    private static var musicEnabled:Bool = true;
    public static var MusicEnabled(get, set):Bool;
    public static function get_MusicEnabled():Bool{
        return musicEnabled;
    }
    public static function set_MusicEnabled(value:Bool):Bool{
        musicEnabled = value;
        EventManager.Trigger(null, Events.MUSIC_ENABLED, [musicEnabled]);
        return musicEnabled;
    }
    private static var musicVolume:Float = 0.20;
    public static var MusicVolume(get, set):Float;
    public static function get_MusicVolume():Float{
        return musicVolume;
    }
    public static function set_MusicVolume(value:Float):Float{
        musicVolume = value;
        EventManager.Trigger(null, Events.MUSIC_VOLUME, [musicVolume]);
        return musicVolume;
    }
    
    public function new(){}
}