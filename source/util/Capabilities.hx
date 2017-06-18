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
    private static var isSafari:Bool = false;
    private static var checkedForSafari:Bool = false;
    public static function IsMobileBrowser():Bool{
        #if (html5)
        if (!checkedForMobileBrowser){
            var r:EReg = new EReg("Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini", "i");
            if (r.match(js.Browser.navigator.userAgent)){
                isMobileBrowser = true;
            }
            checkedForMobileBrowser = true;
        }
        #end
        return isMobileBrowser;
    }
    
    public static function IsSafari():Bool{
        #if (html5)
        if (!checkedForSafari){
            var lowerCaseUderAgent:String = js.Browser.navigator.userAgent.toLowerCase();
            var chrome:Bool = lowerCaseUderAgent.indexOf("chrome") >= 0;
            var safari:Bool = lowerCaseUderAgent.indexOf("safari") >= 0;
            if (safari && !chrome){
                isSafari = true;
            }
            checkedForSafari = true;
        }
        #end
        return isSafari;
    }
}