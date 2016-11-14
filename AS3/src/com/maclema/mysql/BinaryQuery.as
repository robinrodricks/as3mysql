package com.maclema.mysql
{
	import flash.utils.ByteArray;
	
	/**
	 * This class is used to build SQL quries that include binary data such as
	 * files or images.
	 **/
	internal class BinaryQuery extends Buffer
	{
		private var charSet:String = "";
		
		public function BinaryQuery(charSet:String)
		{
			super();
			
			this.charSet = charSet;
		}
		
		/**
		 * Appends a string value to the query. If escape is set to true
		 * the string will be escaped before appended to the query.
		 **/
		public function append(str:String, escape:Boolean=false):void
		{
			if ( !escape )
			{
				writeMultiByte(str, charSet);
			}
			else
			{
				writeMultiByte( Mysql.escapeString(str), charSet );
			}
		}
		
		/**
		 * Appends a chunk of binary data to the query to be executed
		 **/
		public function appendBinary(data:ByteArray):void
		{
			for(var i:int = 0; i < data.length; i++) {
				var byte:int = data[i];
				
				if ( byte == 0x27 )
				{
					writeByte( 0x5C );
				}	
				else if ( byte == 0x22 )
				{
					writeByte( 0x5C );
				}
				else if ( byte == 0x5C )
				{
					writeByte( 0x5C );
				}
				
				writeByte( byte );
			}
		}
	}
}