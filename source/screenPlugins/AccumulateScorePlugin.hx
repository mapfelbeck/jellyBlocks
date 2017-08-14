package screenPlugins;

import blocks.GameBlock;
import events.EventAndAction;
import events.EventManager;
import events.Events;
import flixel.addons.ui.FlxUIText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import jellyPhysics.math.Vector2;
import render.IColorSource;
import screens.BaseScreen;
import flixel.util.FlxColor;
import flixel.text.FlxText;
/**
 * ...
 * @author Michael Apfelbeck
 */
private class CountAndTime
{
    public var count:Int;
    public var time:Float;
    public var pos:Vector2;
    public var material:Int;
    public var timeIndex:Float;
    public function new(count:Int, time:Float, pos:Vector2, material:Int, timeIndex:Float)
    {
        this.count = count;
        this.time = time;
        this.pos = pos;
        this.material = material;
        this.timeIndex = timeIndex;
    }
}
private class ScoreAndColor
{
    public var score:Int;
    public var color:FlxColor;
    public function new(score:Int, color:FlxColor)
    {
        this.score = score;
        this.color = color;
    }
}
class AccumulateScorePlugin extends ScreenPluginBase
{
    private static var POOL_SIZE:Int = 10;
    private static var LABEL_OFFSET:Int = 40;
    private static var SCORE_ACC_RATE:Int = 150;
    private var textLabelPool:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>(POOL_SIZE);

    private var finishedScoreLabels:Array<FlxText> = new Array<FlxText>();
    private var accumulatingScoreLabels:Array<FlxText> = new Array<FlxText>();

    private var colors:IColorSource;
    private var lookupTable:Map<Int, CountAndTime> = new Map<Int, CountAndTime>();
    private static var popWaitTime:Float = 1.0;

    private var scoreNumber:Int = 0;
    private var scoreLabel:FlxUIText;
    private var scoreText:FlxUIText;

    private var gameTime:Float = 0;

    private var scoreLabels:Array<FlxText> = new Array<FlxText>();
    private var scoreItems: Array<ScoreAndColor> = new Array<ScoreAndColor>();
    private var accumulateLabels:Array<FlxText> = new Array<FlxText>();
    private var accumulateItems: Array<CountAndTime> = new Array<CountAndTime>();

    public function new(parent:BaseScreen, colorSource:IColorSource, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(parent, X, Y, SimpleGraphic);
        colors = colorSource;

        scoreLabel = cast parent.getAsset("score_label");
        scoreText = cast parent.getAsset("score_number");
        updateScoreText();

        for (i in 0...POOL_SIZE)
        {
            var label = new FlxText(0, 0, 150, "****", 28, true);
            label.font = "SF Cartoonist Hand Bold";
            label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.GRAY, 1, 0);
            textLabelPool.add(label);
        }
    }

    private function countToScore(count:Int):Int
    {
        return Std.int(Math.pow(count, 2)) * 10;
    }
    
    override public function update(elapsed:Float)
    {
        gameTime += elapsed;

        if (this.scoreItems.length > 0)
        {
            var accAmount:Int = Std.int(SCORE_ACC_RATE * elapsed);
            var item:ScoreAndColor = this.scoreItems[0];
            scoreNumber += Std.int(Math.min(accAmount, item.score));
            updateScoreText();
            item.score -= accAmount;
            if (item.score <= 0)
            {
                this.scoreItems.shift();
            }
        }

        var removeList:List<Int> = new List<Int>();
        var removed:Bool = false;
        for (key in lookupTable.keys())
        {
            lookupTable[key].time -= elapsed;
            if (lookupTable[key].time <= 0)
            {
                //trace("Popped " + lookupTable[key].count + " block of type " + key);
                removeList.add(key);
                this.scoreItems.push(new ScoreAndColor(countToScore(lookupTable[key].count), colors.getColor(lookupTable[key].material) ));
                EventManager.Trigger(this, Events.COMBO_SCORE, [key, lookupTable[key].count, lookupTable[key].pos]);
            }
        }
        for (materialToRemove in removeList)
        {
            removed = true;
            lookupTable.remove(materialToRemove);
        }
        if (removed){
            rebuildAccumulateItems();
        }

        var prevText:FlxText = this.scoreLabel;
        var scoreUpdated:Bool = updateScoreLabels();
        if (scoreUpdated)
        {
            for (i in 0...scoreLabels.length)
            {
                var label:FlxText = scoreLabels[i];
                label.x = this.scoreLabel.x + LABEL_OFFSET;
                label.y = prevText.y + prevText.height;
                prevText = label;
            }
        }
        var accumulateUpdated:Bool = updateAccumulateLabels();

        if (scoreUpdated || accumulateUpdated)
        {
            for (i in 0...accumulateLabels.length)
            {
                var label:FlxText = accumulateLabels[i];
                label.x = this.scoreLabel.x + LABEL_OFFSET;
                label.y = prevText.y + prevText.height;
                prevText = label;
            }
        }
    }

    private function compare(a:CountAndTime, b:CountAndTime)
    {
        if (a.timeIndex < b.timeIndex)
        {
            return -1;
        }
        else if (a.timeIndex < b.timeIndex)
        {
            return 1;
        }
        return 0;
    }
    override function createEventSet():Void
    {
        super.createEventSet();
        eventSet.push(new EventAndAction(Events.BLOCK_POP, onBlockPop));
    }

    private function updateScoreText():Void
    {
        scoreText.text = Std.string(scoreNumber);
    }

    private function onBlockPop(sender:Dynamic, event:String, args:Array<Dynamic>):Void
    {
        //trace("Block popped");

        var block:GameBlock = Std.instance(sender, GameBlock);
        if (block != null)
        {
            //trace("Block type was: " + block.Material);
            if (lookupTable.exists(block.Material))
            {
                lookupTable[block.Material].count++;
                lookupTable[block.Material].time = popWaitTime;
                lookupTable[block.Material].pos.x *= (lookupTable[block.Material].count / (lookupTable[block.Material].count + 1));
                lookupTable[block.Material].pos.y *= (lookupTable[block.Material].count / (lookupTable[block.Material].count + 1));
                lookupTable[block.Material].pos.x += block.DerivedPos.x / (lookupTable[block.Material].count + 1);
                lookupTable[block.Material].pos.y += block.DerivedPos.y / (lookupTable[block.Material].count + 1);
            }
            else
            {
                lookupTable.set(block.Material, new CountAndTime(1, popWaitTime, block.DerivedPos, block.Material, this.gameTime));
                rebuildAccumulateItems();
            }
        }
    }

    private function rebuildAccumulateItems()
    {
        while (this.accumulateItems.length > 0)
        {
            this.accumulateItems.shift();
        }
        for (item in lookupTable.iterator())
        {
            this.accumulateItems.push(item);
        }
        this.accumulateItems.sort(this.compare);
    }

    private function updateScoreLabels(): Bool
    {
        var changed:Bool = false;
        while (scoreLabels.length < scoreItems.length)
        {
            changed = true;
            var temp:FlxText = textLabelPool.recycle(FlxText);
            this.parent.add(temp);
            scoreLabels.push(temp);
        }
        while (scoreLabels.length > scoreItems.length)
        {
            changed = true;
            var temp:FlxText = scoreLabels.pop();
            this.parent.remove(temp);
            textLabelPool.add(temp);
        }

        for (i in 0...scoreItems.length)
        {
            scoreLabels[i].text = "+" + scoreItems[i].score;
            scoreLabels[i].color = scoreItems[i].color;
        }

        return changed;
    }

    private function updateAccumulateLabels(): Bool
    {
        var changed:Bool = false;
        while (accumulateLabels.length < accumulateItems.length)
        {
            changed = true;
            var temp:FlxText = textLabelPool.recycle(FlxText);
            this.parent.add(temp);
            accumulateLabels.push(temp);
        }
        while (accumulateLabels.length > accumulateItems.length)
        {
            changed = true;
            var temp:FlxText = accumulateLabels.pop();
            this.parent.remove(temp);
            textLabelPool.add(temp);
        }

        for (i in 0...accumulateItems.length)
        {
            accumulateLabels[i].text = "X" + accumulateItems[i].count + " ("+countToScore(accumulateItems[i].count)+")";
            accumulateLabels[i].color = this.colors.getColor(accumulateItems[i].material);
        }

        return changed;
    }
}