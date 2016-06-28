package jellyPhysics;

/**
 * ...
 * @author Michael Apfelbeck
 */
class MaterialMatrix
{
    private var count:Int;
    public var Count(get, null):Int;
    public function get_Count():Int{
        return count;
    }
    
    private var defaultMaterial:MaterialPair;
    public var DefaultMaterial(get, null):MaterialPair;
    public function get_DefaultMaterial():MaterialPair{
        return defaultMaterial;
    }
    
    private var materials:Array<Array<MaterialPair>>;
    
    public function new(defaultPair:MaterialPair, ?pairCount:Int)
    {
        if (null == pairCount){
            count = 1;
        }
        count = pairCount;
        defaultMaterial = defaultPair;
        
        materials = new Array<Array<MaterialPair>>();
        for (i in 0...count){
            var materialRow:Array<MaterialPair> = new Array<MaterialPair>();
            for (j in 0...(i+1)){
                materialRow.push(defaultMaterial);
            }
            materials.push(materialRow);
        }
    }
    
    public function Get(i:Int, j:Int):MaterialPair{
        if (i >= count || j >= count){
            throw "Out of bounds.";
            return null;
        }
        
        var first = (i < j)?i:j;
        var second = (j > i)?j:i;
        
        return materials[first][second];
    }
}