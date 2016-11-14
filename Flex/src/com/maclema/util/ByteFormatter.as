package com.maclema.util
{
	import mx.formatters.NumberFormatter;
	
	/**
	 * @private
	 **/
	public class ByteFormatter
	{
		public static const KBYTES : int = 1;
	    public static const MBYTES : int = 2;
	    public static const GBYTES : int = 3
	    public static const TBYTES : int = 4
	    
	    private static var _formats : Array = [ "KB", "MB", "GB", "TB" ];
	
		private static var nf:NumberFormatter = new NumberFormatter();
		
	    public static function format( value:Number, format:int, decimals:int = 2 ):String {
	        var divider : Number = Math.pow( 1024, format )
	        nf.precision = decimals;
	        return nf.format( value / divider ) + " " + _formats[format-1];
	    }
	}
}