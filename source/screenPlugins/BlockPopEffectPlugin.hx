package screenPlugins;

import blocks.GameBlock;
import events.EventAndAction;
import events.Events;
import flash.events.*;
import flixel.*;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import particles.PopEffect;
import render.IColorSource;
import screens.BaseScreen;
import util.Capabilities;
import util.ScreenWorldTransform;
/**
 * ...
 * @author Michael Apfelbeck
 */
class BlockPopEffectPlugin extends ScreenPluginBase 
{
    private var emitter:FlxEmitter;
    
    private var poolSize:Int = 200;
    private var rand:FlxRandom = new FlxRandom();
    private var particleSizes:Array<Int> = [6, 7, 7, 8, 9, 10, 12];
    private var emitterColor:Int = 0;
    
    private var effectQueue:List<PopEffect> = new List<PopEffect>();
    
    private var colorSource:IColorSource;
    private var transform:ScreenWorldTransform;

    public function new(parent:BaseScreen, colorSource:IColorSource, screenWorldTransform:ScreenWorldTransform, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
    {
        super(parent, X, Y, SimpleGraphic);
        this.colorSource = colorSource;
        this.transform = screenWorldTransform;
        emitter = new FlxEmitter(FlxG.width / 2 , FlxG.height / 2, poolSize);
        loadParticles();
		parent.add(emitter);
        emitter.color.set(colorSource.getColor(emitterColor));
        emitter.launchMode = FlxEmitterMode.CIRCLE;
        emitter.speed.set(50, 100);
        emitter.lifespan.set(1.0, 3.0);
        
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
        eventSet.push(new EventAndAction(Events.BLOCK_POP, OnPop));
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        
        var effect = effectQueue.pop();
        if (effect != null){
            emitter.color.set(effect.color);
            emitter.x = effect.position.x;
            emitter.y = effect.position.y;
            emitter.start(true, 0.01, effect.count);
        }
    }

    private function loadParticles():Void{
        for (i in 0...poolSize){
        	var p = new FlxParticle();
            var size:Int = particleSizes[rand.int(0, particleSizes.length-1)];
            p.makeGraphic(size, size, FlxColor.TRANSPARENT, true);
            FlxSpriteUtil.drawCircle(p, -1, -1, -1, FlxColor.WHITE);
        	p.exists = false;
        	emitter.add(p);
        }
    }
    
    private function OnPop(sender:Dynamic, event:String, params:Dynamic){
        //trace("Block pop effect: Block popped.");
        
        var block:GameBlock = Std.instance(sender, GameBlock);
        if (block != null){
            var screenX:Int = cast transform.localToWorldX(block.DerivedPos.x);
            var screenY:Int = cast transform.localToWorldY(block.DerivedPos.y);
            effectQueue.add(new PopEffect(new FlxPoint(screenX, screenY), colorSource.getColor(block.Material)));
        }
    }
}