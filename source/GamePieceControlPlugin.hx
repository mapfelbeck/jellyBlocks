package;
import gamepieces.GamePiece;
import plugins.PluginBase;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author Michael Apfelbeck
 */
class GamePieceControlPlugin extends PluginBase 
{
    public var gamePiece:GamePiece = null;
    private var input:Input;
    
    public function new(parent:FlxUIState, input:Input, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.input = input;
    }
    
}