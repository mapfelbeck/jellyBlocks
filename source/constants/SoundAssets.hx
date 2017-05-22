package constants;

/**
 * ...
 * @author Michael Apfelbeck
 */
class SoundAssets 
{
    #if !flash
    private static var ext:String = ".ogg";
    #else
    private static var ext:String = ".wav";
    #end
    
    //gameplay
    public static var PieceHit:String = "assets/audio/soundFX/gameplay/PieceHit" + ext;
    public static var BlockPop:String = "assets/audio/soundFX/gameplay/BlockPop" + ext;
    public static var PieceCreate:String = "assets/audio/soundFX/gameplay/PieceCreate" + ext;
    public static var Unfreeze:String = "assets/audio/soundFX/gameplay/Unfreeze" + ext;
    
    //ui
    public static var MenuAdvance:String = "assets/audio/soundFX/ui/MenuAdvance" + ext;
    public static var MenuBack:String = "assets/audio/soundFX/ui/MenuBack" + ext;
    public static var MenuBadSelect:String = "assets/audio/soundFX/ui/MenuBadSelect" + ext;
    public static var MenuScroll:String = "assets/audio/soundFX/ui/MenuScroll" + ext;
    public static var MenuSelect1:String = "assets/audio/soundFX/ui/MenuSelect1" + ext;
    public static var MenuSelect2:String = "assets/audio/soundFX/ui/MenuSelect2" + ext;
    public static var MenuSelect3:String = "assets/audio/soundFX/ui/MenuSelect3" + ext;
}