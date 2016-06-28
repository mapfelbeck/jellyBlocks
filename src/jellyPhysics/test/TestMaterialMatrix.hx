package jellyPhysics.test;

import haxe.unit.TestCase;
import jellyPhysics.MaterialMatrix;
import jellyPhysics.MaterialPair;

/**
 * ...
 * @author Michael Apfelbeck
 */
class TestMaterialMatrix extends TestCase
{

    public function testSingle() 
    {
        var defaultPair:MaterialPair = new MaterialPair();
        defaultPair.Collide = true;
        defaultPair.CollisionFilter = null;
        defaultPair.Elasticity = 0.8;
        defaultPair.Friction = 0.1;
        
        var matrix:MaterialMatrix = new MaterialMatrix(defaultPair, 1);
        assertTrue(true);
        
        assertEquals(1, matrix.Count);
        assertTrue(matrix.Get(0, 0).Collide);
        
        try{
            var outOfBounds = matrix.Get(1, 3);
            assertTrue(false);
        }catch (err:Dynamic)
        {
            assertTrue(true);
        }
    }
    
}