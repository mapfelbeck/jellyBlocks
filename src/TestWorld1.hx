package;

import jellyPhysics.Body;
import jellyPhysics.PointMass;
import jellyPhysics.test.*;
import lime.math.Vector2;
import haxe.unit.TestRunner;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author Michael Apfelbeck
 * 
 * Unit test world
 */
class TestWorld1 extends Sprite
{

    public function new() 
    {
        super();
		        
        var runner:TestRunner = new TestRunner();
        runner.add(new TestMaterialMatrix());
        runner.add(new TestVectorTools());
        runner.add(new TestAABB());
        runner.add(new TestClosedShape());
        runner.add(new TestBody());
        runner.add(new TestSpringBody());
        runner.add(new TestPressureBody());
        runner.add(new TestArrayCollider());
        runner.add(new TestWorld());
        runner.run();
    }
    
}