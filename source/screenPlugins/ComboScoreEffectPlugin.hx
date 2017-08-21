package screenPlugins;

import events.EventAndAction;
import events.Events;
import flash.events.*;
import flixel.*;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.TextEmitter;
import flixel.effects.particles.TextParticle;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import jellyPhysics.math.Vector2;
import particles.ComboEffect;
import render.IColorSource;
import screens.BaseScreen;
import util.Capabilities;
import util.ScreenWorldTransform;
import constants.GameConstants;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ComboScoreEffectPlugin extends ScreenPluginBase 
{
    private var emitter:TextEmitter;
    
    private var poolSize:Int = 25;
    private var emitterColor:Int = 0;
    
    private var effectQueue:List<ComboEffect> = new List<ComboEffect>();
    
    private var colorSource:IColorSource;
    private var transform:ScreenWorldTransform;
    
    public function new(parent:BaseScreen, colorSource:IColorSource, screenWorldTransform:ScreenWorldTransform, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.colorSource = colorSource;
        this.transform = screenWorldTransform;
        emitter = new TextEmitter(FlxG.width / 2 , FlxG.height / 2, poolSize);
        //emitter.Font = "SF Cartoonist Hand Bold";
        loadParticles();
		parent.add(emitter);
        emitter.color.set(colorSource.getColor(emitterColor));
        emitter.launchMode = FlxEmitterMode.CIRCLE;
        emitter.speed.set(140, 180);
        emitter.lifespan.set(1.5, 2.5);
        emitter.launchAngle.set(-145, -35);

        #if (windows || android)
        emitter.alpha.set(1, 1, 0, 0);
        #else
        if(Capabilities.IsMobileBrowser()){
            emitter.alpha.set(1, 1, 1, 1);
        }else{
            //fade out causes perf problems :(
            //emitter.alpha.set(1, 1, 0, 0);
            emitter.alpha.set(1, 1, 1, 1);
        }
        #end
    }
    
    override function createEventSet():Void 
    {
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.COMBO_SCORE, OnScore));
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        
        var effect:ComboEffect = effectQueue.pop();
        if (effect != null){
            emitter.color.set(effect.color);
            emitter.Text = effect.text;
            emitter.x = effect.position.x;
            emitter.y = effect.position.y;
            emitter.start(true, 0.01, effect.count);
        }
    }
    
    private function OnScore(sender:Dynamic, event:String, params:Array<Dynamic>){
        //trace("Block pop effect: Block popped.");
        var color:Int = cast params[0];
        var count:Int = cast params[1];
        var pos:Vector2 = cast params[2];
        
        var screenX:Int = cast transform.localToWorldX(pos.x);
        var screenY:Int = cast transform.localToWorldY(pos.y);
        effectQueue.add(new ComboEffect(new FlxPoint(screenX+GameConstants.offscreenRenderX, screenY+GameConstants.offscreenRenderY), colorSource.getColor(color), count+"X"));
    }

    private function loadParticles():Void{
        for (i in 0...poolSize){
        	var p = new TextParticle("*", 32, true);
            p.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.GRAY, 1, 0);
            p.text = "Hi!";
        	emitter.add(p);
        }
    }
    
}