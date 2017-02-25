package util;

/**
 * ...
 * @author Michael Apfelbeck
 */
class Capabilities 
{
    public function new(){}
    
    private static var isMobileBrowser:Bool = false;
    private static var checkedForMobileBrowser:Bool = false;
    public static function IsMobileBrowser():Bool{
        #if (html5)
        if (!checkedForMobileBrowser){
            var r:EReg = new EReg("Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini", "i");
            if (r.match(js.Browser.navigator.userAgent)){
                isMobileBrowser = true;
            }
            checkedForMobileBrowser = false;
        }
        #end
        return isMobileBrowser;
    }
    
}