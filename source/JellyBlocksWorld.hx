package;

import collider.QuadTreeCollider;
import jellyPhysics.AABB;
import jellyPhysics.ArrayCollider;
import jellyPhysics.ColliderBase;
import jellyPhysics.MaterialMatrix;
import jellyPhysics.MaterialPair;
import jellyPhysics.World;

/**
 * ...
 * @author 
 */
class JellyBlocksWorld extends World
{

    public function new(worldMaterialCount:Int, worldMaterialPairs:MaterialMatrix, worldDefaultMaterialPair:MaterialPair, worldPenetrationThreshhold:Float, worldBounds:AABB) 
    {
        super(worldMaterialCount, worldMaterialPairs, worldDefaultMaterialPair, worldPenetrationThreshhold, worldBounds);
    }
    
    /*override public function getBodyCollider(penetrationThreshhold:Float):ColliderBase
    {
        return new collider.QuadTreeCollider(penetrationThreshhold);
    }*/
}