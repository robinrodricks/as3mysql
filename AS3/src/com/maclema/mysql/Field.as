package com.maclema.mysql
{
	/**
	 * The Field class represents a MySql table column.
	 **/
    public class Field
    {
        /*
         VERSION 4.1
         Bytes                      Name
         -----                      ----
         n (Length Coded String)    catalog
         n (Length Coded String)    db
         n (Length Coded String)    table
         n (Length Coded String)    org_table
         n (Length Coded String)    name
         n (Length Coded String)    org_name
         1                          (filler)
         2                          charsetnr
         4                          length
         1                          type
         2                          flags
         1                          decimals
         2                          (filler), always 0x00
         n (Length Coded Binary)    default
        */
        private var _catalog:String;
        private var _db:String;
        private var _table:String;
        private var _orgTable:String;
        private var _name:String;
        private var _orgName:String;
        private var _charsetnr:int;
        private var _length:int;
        private var _type:int;
        private var _flags:int;
        private var _decimals:int;
        
        private var _as3Type:int;
        
        /**
        * Constructs a new Field instance by reading a Packet returned from MySql.
        **/ 
        public function Field(packet:ProxiedPacket, charSet:String)
        {
            _catalog = packet.readLengthCodedString(charSet);
            _db = packet.readLengthCodedString(charSet);
            _table = packet.readLengthCodedString(charSet);
            _orgTable = packet.readLengthCodedString(charSet);
            _name = packet.readLengthCodedString(charSet);
            _orgName = packet.readLengthCodedString(charSet);
            packet.readByte(); //filler
            _charsetnr = packet.readTwoByteInt();
            _length = packet.readInt();
            _type = packet.readByte() & 0xFF;
            _flags = packet.readTwoByteInt();
            _decimals = packet.readByte() & 0xFF;
            _as3Type = determineAs3Type();
        }
        
        /**
        * Determins the Actionscript type that this column should map to.
        * @priavte
        **/
        private function determineAs3Type():int {
        	switch (_type)
			{
				case Mysql.FIELD_TYPE_DECIMAL:
				case Mysql.FIELD_TYPE_TINY:
				case Mysql.FIELD_TYPE_SHORT:
				case Mysql.FIELD_TYPE_LONG:
				case Mysql.FIELD_TYPE_FLOAT:
				case Mysql.FIELD_TYPE_DOUBLE:
				case Mysql.FIELD_TYPE_LONGLONG:
				case Mysql.FIELD_TYPE_INT24:
				case Mysql.FIELD_TYPE_YEAR:
				case Mysql.FIELD_TYPE_NEWDECIMAL:
				case Mysql.FIELD_TYPE_BIT:
					return Mysql.AS3_TYPE_NUMBER;
					
				case Mysql.FIELD_TYPE_DATE:
				case Mysql.FIELD_TYPE_TIMESTAMP:
				case Mysql.FIELD_TYPE_DATETIME:
				case Mysql.FIELD_TYPE_NEWDATE:
					return Mysql.AS3_TYPE_DATE;
					
				case Mysql.FIELD_TYPE_TIME:
					return Mysql.AS3_TYPE_TIME;
					
				case Mysql.FIELD_TYPE_BLOB:
				case Mysql.FIELD_TYPE_LONG_BLOB:
				case Mysql.FIELD_TYPE_MEDIUM_BLOB:
				case Mysql.FIELD_TYPE_TINY_BLOB:
					return Mysql.AS3_TYPE_BYTEARRAY;
			}
			
			return Mysql.AS3_TYPE_STRING;
        }
        
        /**
         * Catalog. For 4.1, 5.0 and 5.1 the value is "def".
         **/
        public function getCatalog():String
        {
            return _catalog;
        }
        
        /**
         * Database identifier
         **/
        public function getDatabase():String
        {
            return _db;
        }
        
        /**
         * The table identifier after the AS clause
         **/
        public function getTable():String
        {
            return _table;
        }
        
        /**
         * Original table identifier
         **/
        public function getRealTable():String
        {
            return _orgTable;
        }
        
        /**
         * Column identifier after AS clase
         **/
        public function getName():String
        {
            return _name;
        }
        
        /**
         * Original column identifier
         **/
        public function getRealName():String
        {
            return _orgName;
        }
        
        /**
         * Character set number
         **/
        public function getCharacterSet():int
        {
            return _charsetnr;
        }
        
        /**
         * Returns an actionscript type identifier which is defined in MySql.AS3_TYPE_*
         **/
        public function getAsType():int {
        	return _as3Type;
        }
        
        /**
         * Length of column, according to the definition.
         * Also known as "display length". The value given
         * here may be larger than the actual length, for
         * example an instance of a VARCHAR(2) column may
         * have only 1 character in it.
         **/
        public function getLength():int
        {
            return _length;
        }
        
        /**
         * The code for the column's data type
         **/
        public function getType():int
        {
            return _type;
        }
        
        /**
         * Possible flag values
         **/
        public function getFlags():int
        {
            return _flags;
        }
        
        /**
         * The number of positions after the decimal point
         **/
        public function getDecimals():int
        {
            return _decimals;
        }
    }
}