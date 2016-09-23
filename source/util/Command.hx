package util;

/**
 * @author 
 */
interface Command 
{
    public function execute():Void;
    public function undo():Void;
}