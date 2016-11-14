package com.maclema.util
{
	/**
	 * @private
	 **/
	public class ByteFormatter
	{
		public static const KBYTES : int = 1;
	    public static const MBYTES : int = 2;
	    public static const GBYTES : int = 3
	    public static const TBYTES : int = 4
	    
	    public static function format( value:Number, format:int, decimals:int = 2 ):String {
	       return value + " bytes";
	    }
	}
}