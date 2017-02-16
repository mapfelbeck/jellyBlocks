package util;

/**
 * ...
 * @author Michael Apfelbeck
 */
class UtilClass 
{
    public static function arrayOfSize<T>(size:Int):Array<T>{
        var newArray = new Array<T>();
        for(i in 0...size){
            newArray.push(null);
        }
        return newArray;
    }
}