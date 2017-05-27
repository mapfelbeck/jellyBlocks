package constants;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SoundAssets 
{
    #if !flash
    private static var soundType:String = ".ogg";
    private static var musicType:String = ".ogg";
    #else
    private static var soundType:String = ".wav";
    private static var musicType:String = ".mp3";
    #end
    
    //gameplay
    public static var PieceHit:String = "assets/audio/soundFX/gameplay/PieceHit" + soundType;
    public static var BlockPop:String = "assets/audio/soundFX/gameplay/BlockPop" + soundType;
    public static var PieceCreate:String = "assets/audio/soundFX/gameplay/PieceCreate" + soundType;
    public static var Unfreeze:String = "assets/audio/soundFX/gameplay/Unfreeze" + soundType;
    
    //ui
    public static var MenuAdvance:String = "assets/audio/soundFX/ui/MenuAdvance" + soundType;
    public static var MenuBack:String = "assets/audio/soundFX/ui/MenuBack" + soundType;
    public static var MenuBadSelect:String = "assets/audio/soundFX/ui/MenuBadSelect" + soundType;
    public static var MenuScroll:String = "assets/audio/soundFX/ui/MenuScroll" + soundType;
    public static var MenuSelect1:String = "assets/audio/soundFX/ui/MenuSelect1" + soundType;
    public static var MenuSelect2:String = "assets/audio/soundFX/ui/MenuSelect2" + soundType;
    public static var MenuSelect3:String = "assets/audio/soundFX/ui/MenuSelect3" + soundType;
    
    //music
    public static var MainTrack:String = "assets/audio/music/TechTalk" + musicType;
}