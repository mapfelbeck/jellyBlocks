package screenPlugins;

import events.EventAndAction;
import events.EventManager;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import screens.BaseScreen;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ScreenPluginBase extends FlxSprite 
{
    private var parent:FlxUIState;
    private var eventSet:Array<EventAndAction> = new Array<EventAndAction>();
    public function new(parent:BaseScreen, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(X, Y, SimpleGraphic);
        this.parent = parent;
        this.visible = false;
		createEventSet();
        registerEvents();
    }
    
    override public function destroy():Void 
    {
        super.destroy();
        for (i in 0...eventSet.length){
            EventManager.UnRegister(eventSet[i].action, eventSet[i].event);
        }
    }
    
    private function registerEvents():Void{
        for (i in 0...eventSet.length){
            EventManager.Register(eventSet[i].action, eventSet[i].event);
        }
    }
    
    public function createEventSet():Void{}
}