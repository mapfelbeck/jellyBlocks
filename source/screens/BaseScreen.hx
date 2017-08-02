package screens;

import events.EventAndAction;
import events.EventManager;
import events.Events;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.text.FlxText;
import haxe.xml.Fast;
import screenPlugins.ScreenPluginBase;

/**
 * ...
 * @author Michael Apfelbeck
 */
class BaseScreen extends FlxUIState 
{
    private var plugins:List<ScreenPluginBase> = new List<ScreenPluginBase>();
    private var eventSet:Array<EventAndAction> = new Array<EventAndAction>();
    
	public function getAsset(key:String, recursive:Bool = true):IFlxUIWidget
	{
        return _ui.getAsset(key, recursive);
    }
    
	public function getGroup(key:String, recursive:Bool = true):FlxUIGroup
	{
        return _ui.getGroup(key, recursive);
    }
    
	public function getDefinition(key:String, recursive:Bool = true):Fast
	{
        return _ui.getDefinition(key, recursive);
    }
    
	public function getMode(key:String, recursive:Bool = true):Fast
	{
        return _ui.getMode(key, recursive);
    }
    
	public function getFlxText(key:String, recursive:Bool = true):FlxText
	{
        return _ui.getFlxText(key, recursive);
    }
    
    private function registerEvent(action:EventManagerCallback, event:String):Void{
        var newEvent:EventAndAction = new EventAndAction(event, action);
        eventSet.push(newEvent);
        EventManager.Register(newEvent.action, newEvent.event);
    }
    
    override public function destroy():Void{
        super.destroy();
        for (plugin in plugins){
            remove(plugin);
        }
        
        for (event in eventSet){
            EventManager.UnRegister(event.action, event.event);
        }
    }
}