package com.maclema.mysql
{
    import com.maclema.logging.Logger;
    
    import flash.system.System;
    import flash.utils.ByteArray;
    import flash.utils.getDefinitionByName;
    import flash.utils.getTimer;
    
    /**
    * The ResultSet class represents a data set returned by MySql for a query.
    **/
    public class ResultSet
    {        
        private var _token:MySqlToken;
        
        private var index:int = -1;
        private var columns:Array;
        private var rows:Array;
        private var map:Object;
        private var charSet:String = "";
        
        /**
        * Constructs a new ResultSet object
        **/
        public function ResultSet(token:MySqlToken)
        {
        	this._token = token;
            this.columns = new Array();
            this.rows = new Array();   
        }
        
        /**
		 * @private
		 **/
        internal function initialize(charSet:String):void {
        	this.charSet = charSet;
        	
            map = new Object();
            for ( var i:int=0; i<columns.length; i++ )
            {
                var c:Field = Field(columns[i]);
                map[c.getName()] = i;
                map[String((i+1))] = i;
            }
        }
        
        /**
		 * @private
		 **/
        internal function addColumn(field:Field):void {
        	this.columns[this.columns.length] = field;
        }
        
        /**
		 * @private
		 **/
        internal function addRow(data:ProxiedPacket):void {
        	this.rows[this.rows.length] = [data, null, null, false];
        }
        
        private function initRow(index:int):void {
        	if ( this.rows[index][3] == false ) {
        		var data:ProxiedPacket = this.rows[index][0];
        		var colLengths:Array = new Array();
	        	var colStarts:Array = new Array();
	        	var col:int = 0;
	        	while ( data.bytesAvailable > 0 ) {
	        		colLengths[col] = data.readLengthCodedBinary();
	        		colStarts[col] = data.position;
	        		data.position += colLengths[col];
	        		col++;
	        	}
	        	data.position = 0;
	        	
	        	this.rows[index][1] = colStarts;
	        	this.rows[index][2] = colLengths;
	        	this.rows[index][3] = true;
        	}
        }
        
        public function set position(value:int):void {
        	if ( value < 0 ) {
        		throw new RangeError("Cannot set position less than 0");
        	}
        	else if ( value > size()-1 ) {
        		throw new RangeError("Cannot set position greater then number of rows");
        	}
        	else {
        		index = value;
        		initRow(index); //dont forget to initialize the row.
        	}
        }
        
        public function get position():int {
        	return index;
        }
        
        /**
        * Returns the token object that created this result set.
        **/
        public function get token():MySqlToken {
        	return _token;
        }
        
        /**
         * Returns the number of columns in the ResultSet
         **/
        public function get numColumns():int
        {
            return columns.length;
        }
        
        /**
         * Advances the pointer to the next row
         **/
        public function next():Boolean
        {
            if ( index < rows.length-1 )
            {
                index++;
                initRow(index);
                return true;
            }
            
            return false;
        }
        
        /**
         * Moves the pointer to the previous row
         **/
        public function previous():Boolean
        {
            if ( index > 0 )
            {
                index--;
                initRow(index);
                return true;
            }
            
            return false;
        }
        
		/**
		 * Moves the pointer to the first row
		 **/
		public function first():Boolean
		{
		    if ( rows.length == 0 )
		    {
		        index = -1;
		        return false;
		    }
		    
		    index = 0;
		    initRow(index);
		    return true;
		}
		
		/**
		 * Moves the pointer to the last row.
		 **/
		public function last():Boolean
		{
		    if ( rows.length == 0 )
		    {
		        index = -1;
		        return false;
		    }
		    
		    index = rows.length-1;
		    initRow(index);
		    return true;
		}
        
        /**
         * Returns a String value from the specified column. You may specify
         * columns using a 1-based number or the column name
         **/
        public function getString(column:*):String
        {
        	var rowData:ProxiedPacket = rows[index][0];
        	var colStarts:Array = rows[index][1];
        	var colLengths:Array = rows[index][2];
        	var colIndex:int = int(map[String(column)]);
        	
        	if ( colLengths[colIndex] == 0 ) {
        		return null;
        	}
        	
        	rowData.position = colStarts[colIndex];
        	var out:String = "";
        	if ( charSet == "utf8" ) {
        		out = rowData.readMultiByte(colLengths[colIndex], charSet);
        	}
        	else {
        		out = rowData.readUTFBytes(colLengths[colIndex]);
        	}
        	
        	return out;
        }
        
        /**
         * Returns an int for the specifiec column
         **/
        public function getInt(column:*):int
        {
            return int(getString(column));
        }
        
        /**
        * Returns a boolean value for the specified column.
        **/
        public function getBoolean(column:*):Boolean 
        {
        	return Boolean(getString(column));
        }
        
        /**
        * Returns a Date object, where yyyy-mm-dd is always the current date, but
        * the time values are HH:mm:ss from the column
        **/
        public function getTime(column:*):Date {
        	var timeString:String = getString(column);
            
            if ( timeString == null ) {
            	return null;
            }
        	
        	return new Date(Date.parse( "1970/01/01 " + timeString ));
        }
        
        /**
         * Returns a Number for the specifiec column
         **/
        public function getNumber(column:*):Number
        {
            return Number(getString(column));
        }
        
        /**
         * Returns a Date object for the specified column
         **/
        public function getDate(column:*):Date
        {
            var dateString:String = getString(column);
            
            if ( dateString == null ) {
		    	return null;
		    }
			
			var year:int = int(dateString.substr(0,4));
			var month:int = int(dateString.substr(5,2))-1;
			var day:int = int(dateString.substr(8,2));
			
			if ( year == 0 && month == 0 && day == 0 ) {
				return null;
			}
			
			if ( dateString.length == 10 ) {
				return new Date(year, month, day);
			}
			
			var hour:int = int(dateString.substr(11,2));
			var minute:int = int(dateString.substr(14,2));
			var second:int = int(dateString.substr(17,2));
			
			return new Date(year, month, day, hour, minute, second);
        }
        
        /**
         * Returns a binary ByteArray for the specified column
         **/
        public function getBinary(column:*):ByteArray
        {
        	var rowData:ProxiedPacket = rows[index][0];
        	var colStarts:Array = rows[index][1];
        	var colLengths:Array = rows[index][2];
        	var colIndex:int = int(map[String(column)]);
        	
        	if ( colLengths[colIndex] == 0 ) {
        		return null;
        	}
        	
        	var out:ByteArray = new ByteArray();
        	rowData.position = colStarts[colIndex];
        	rowData.readBytes(out, 0, colLengths[colIndex]);
        	
        	return out;
        }
        
        /**
         * Returns all rows as either an ArrayCollection (if using the flex framework) or as an Array (if using pure actionscript) <br>
         * <br>
         * You can optionally pass a single boolean value indicating if date's and time's should be returned
         * as simple String's rather then being casted to Date objects. This is a lot faster then casting to
         * date objects.<br>
         * <br>
         * You may also pass an offset and length for the number of rows you wish to return, starting at the
         * specified index. This is useful for creating a pageable display.<br>
         * <br>
         * The results of getRows are cached, so additional calls to getRows() will be a lot faster.
         **/
        private var getRowsCache:Array = new Array();
		public function getRows(dateTimesAsStrings:Boolean=false, offset:int=0, len:int=0):*
		{
			Logger.debug(this, "Converting ResultSet to Array...");
			var st:Number = getTimer();
			
			var oldIndex:int = index;
			
			index = (offset-1);
			
			var count:int = 0;
			
			var arr:Array = new Array();
			while ( this.next() ) {
				count++;
				
				if ( getRowsCache[index] != null ) {
					arr.push( getRowsCache[index] );
				}
				else {
					var obj:Object = new Object();
					
					columns.forEach(function(c:Field, index:int, arr:Array):void {
						castAndSetValue(obj, c, dateTimesAsStrings);
					});
					
					getRowsCache[index] = obj;
			 		arr.push(obj);
		 		}
		 	
		 		if ( count == len ) {
		 			break;
		 		}
			}
			
			index = oldIndex;
			
			var run:Number = getTimer()-st;
			Logger.debug(this, "  getRows() in " + run + " ms");
			
			var AC_Class:Object = getDefinitionByName("mx.collections.ArrayCollection");
			if ( AC_Class ) {
				var ac:* = new AC_Class(arr);
				return ac;
			}
			else {
				return arr;
			}
		}
        
        private function castAndSetValue(obj:Object, field:Field, dateTimesAsStrings:Boolean):void
		{
			switch (field.getAsType())
			{
				case Mysql.AS3_TYPE_NUMBER:
					obj[field.getName()] = getNumber(field.getName()); return;
					
				case Mysql.AS3_TYPE_STRING:
					obj[field.getName()] = getString(field.getName()); return;
					
				case Mysql.AS3_TYPE_DATE:
					if ( dateTimesAsStrings ) { break; }
					obj[field.getName()] = getDate(field.getName()); return;
					
				case Mysql.AS3_TYPE_TIME:
					if ( dateTimesAsStrings ) { break; }
					obj[field.getName()] = getTime(field.getName()); return;
				
				case Mysql.AS3_TYPE_BYTEARRAY:
					obj[field.getName()] = getBinary(field.getName()); return;
			}
			obj[field.getName()] = getString(field.getName()); return;
		}
        
        /**
         * Returns an array for Field objects
         **/
        public function getColumns():Array
        {
            return columns;
        }
        
        /**
        * Returns the number of rows in the ResultSet
        **/
        public function size():int {
        	return rows.length;
        }
        
        /**
        * Cleans up resources held by this result set
        **/
        public function dispose():void {
        	var i:int;
        	
        	for ( i=0; i<rows.length; i++ ) {
        		delete rows[i][0];
        		delete rows[i][1];
        		delete rows[i][2];
        		delete rows[i];
        		rows[i] = null;
        	}
        	
        	for ( i=0; i<columns.length; i++ ) {
        		delete columns[i];
        		columns[i] = null;
        	}
        	
        	for ( i=0; i<getRowsCache.length; i++ ) {
        		delete getRowsCache[i];
        	}
        	
			System.gc();System.gc();
			        	
        	rows = new Array();
        	columns = new Array();
        	
        	System.gc();System.gc();
        }
    }
}