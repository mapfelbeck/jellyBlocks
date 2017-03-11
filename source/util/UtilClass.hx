package util;

import flixel.math.FlxRandom;

/**
 * ...
 * @author Michael Apfelbeck
 */
class UtilClass 
{
    private static var random:FlxRandom = new FlxRandom();
    
    public static function arrayOfSize<T>(size:Int):Array<T>{
        var newArray = new Array<T>();
        for(i in 0...size){
            newArray.push(null);
        }
        return newArray;
    }
    
    private static var primes:Array<Int> = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37];
    public static function randomInts(count:Int, max:Int, maxSame:Int):Array<Int>
    {
        var blockColors:Array<Int> = new Array<Int>();
        var blockId:Int = 1;
        for (i in 0...count){
            var color:Int = 1;
            var potentialBlockId:Int = 1;
            var checkNumber:Int = 1;
            do{
                color = random.int(0, max - 1);
                potentialBlockId = blockId * primes[color];
                checkNumber = Std.int(Math.pow(primes[color], maxSame + 1));
            }while (potentialBlockId % checkNumber == 0);
            
            blockColors.push(color);
            blockId = potentialBlockId;
        }
        return blockColors;
    }
}