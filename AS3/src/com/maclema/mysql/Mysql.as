package com.maclema.mysql
{
    /**
     * This class contains many MySql and asSQL constants.
     **/
    public class Mysql
    {
        public static const CLIENT_LONG_PASSWORD:int = 1;
        public static const CLIENT_FOUND_ROWS:int = 2;
        public static const CLIENT_LONG_FLAG:int = 4;
        public static const CLIENT_CONNECT_WITH_DB:int = 8;
        public static const CLIENT_NO_SCHEMA:int = 16;
        public static const CLIENT_COMPRESS:int = 32;
        public static const CLIENT_ODBC:int = 64;
        public static const CLIENT_LOCAL_FILES:int = 128;
        public static const CLIENT_IGNORE_SPACE:int = 256;
        public static const CLIENT_PROTOCOL_41:int = 512;
        public static const CLIENT_INTERACTIVE:int = 1024;
        public static const CLIENT_SSL:int = 2048;
        public static const CLIENT_IGNORE_SIGPIPE:int = 4096;
        public static const CLIENT_TRANSACTIONS:int = 8192;
        public static const CLIENT_RESERVED:int = 16384;
        public static const CLIENT_SECURE_CONNECTION:int = 32768;
        public static const CLIENT_MULTI_STATEMENTS:int = 65536;
        public static const CLIENT_MULTI_RESULTS:int = 131072;
        
        public static const COM_SLEEP:int = 0x00;
        public static const COM_QUIT:int = 0x01;
        public static const COM_INIT_DB:int = 0x02;
        public static const COM_QUERY:int = 0x03;
        public static const COM_FIELD_LIST:int = 0x04;
        public static const COM_CREATE_DB:int = 0x05;
        public static const COM_DROP_DB:int = 0x06;
        public static const COM_REFRESH:int = 0x07;
        public static const COM_SHUTDOWN:int = 0x08;
        public static const COM_STATISTICS:int = 0x09;
        public static const COM_PROCESS_INFO:int = 0x0a;
        public static const COM_CONNECT:int = 0x0b;
        public static const COM_PROCESS_KILL:int = 0x0c;
        public static const COM_DEBUG:int = 0x0d;
        public static const COM_PING:int = 0x0e;
        public static const COM_TIME:int = 0x0f;
        public static const COM_DELAYED_INSERT:int = 0x10;
        public static const COM_CHANGE_USER:int = 0x11;
        public static const COM_BINLOG_DUMP:int = 0x12;
        public static const COM_TABLE_DUMP:int = 0x13;
        public static const COM_CONNECT_OUT:int = 0x14;
        public static const COM_REGISTER_SLAVE:int = 0x15;
        public static const COM_STMT_PREPARE:int = 0x16;
        public static const COM_STMT_EXECUTE:int = 0x17;
        public static const COM_STMT_SEND_LONG_DATA:int = 0x18;
        public static const COM_STMT_CLOSE:int = 0x19;
        public static const COM_STMT_RESET:int = 0x1a;
        public static const COM_SET_OPTION:int = 0x1b;
        public static const COM_STMT_FETCH:int = 0x1c;
        
        /* field types */
        public static const FIELD_TYPE_DECIMAL:int = 0x00;
        public static const FIELD_TYPE_TINY:int = 0x01;
        public static const FIELD_TYPE_SHORT:int = 0x02;
        public static const FIELD_TYPE_LONG:int = 0x03;
        public static const FIELD_TYPE_FLOAT:int = 0x04;
        public static const FIELD_TYPE_DOUBLE:int = 0x05;
        public static const FIELD_TYPE_NULL:int = 0x06;
        public static const FIELD_TYPE_TIMESTAMP:int = 0x07;
        public static const FIELD_TYPE_LONGLONG:int = 0x08;
        public static const FIELD_TYPE_INT24:int = 0x09;
        public static const FIELD_TYPE_DATE:int = 0x0a;
        public static const FIELD_TYPE_TIME:int = 0x0b;
        public static const FIELD_TYPE_DATETIME:int = 0x0c;
        public static const FIELD_TYPE_YEAR:int = 0x0d;
        public static const FIELD_TYPE_NEWDATE:int = 0x0e;
        public static const FIELD_TYPE_VARCHAR:int = 0x0f;
        public static const FIELD_TYPE_BIT:int = 0x10;
        public static const FIELD_TYPE_NEWDECIMAL:int = 0xf6;
        public static const FIELD_TYPE_ENUM:int = 0xf7;
        public static const FIELD_TYPE_SET:int = 0xf8;
        public static const FIELD_TYPE_TINY_BLOB:int = 0xf9;
        public static const FIELD_TYPE_MEDIUM_BLOB:int = 0xfa;
        public static const FIELD_TYPE_LONG_BLOB:int = 0xfb;
        public static const FIELD_TYPE_BLOB:int = 0xfc;
        public static const FIELD_TYPE_VAR_STRING:int = 0xfd;
        public static const FIELD_TYPE_STRING:int = 0xfe;
        public static const FIELD_TYPE_GEOMETRY:int = 0xff;
        
        public static const AS3_TYPE_NUMBER:int = 1;
        public static const AS3_TYPE_DATE:int = 2;
        public static const AS3_TYPE_TIME:int = 3;
        public static const AS3_TYPE_STRING:int = 4;
        public static const AS3_TYPE_BYTEARRAY:int = 5;
        
        /* column flags */
        public static const FLAG_NOT_NULL:int = 0001;
        public static const FLAG_PRIMARY_KEY:int = 0002;
        public static const FLAG_UNIQUE_KEY:int = 0004;
        public static const FLAG_MULTIPLE_KEY:int = 0008;
        public static const FLAG_BLOB:int = 0010;
        public static const FLAG_UNSIGNED_FLAG:int = 0020;
        public static const FLAG_ZEROFILL:int = 0040;
        public static const FLAG_BINARY:int = 0080;
        public static const FLAG_ENUM:int = 0100;
        public static const FLAG_AUTO_INCREMENT:int = 0200;
        public static const FLAG_TIMESTAMP:int = 0400;
        public static const FLAG_SET:int = 0800;
        
        public static function escapeString(str:String):String
        {
        	if ( str.indexOf("\\") != -1 )
        	{
        		str.replace("\\", "\\"+"\\");
        	}
        	
        	if ( str.indexOf("\'") != -1 )
        	{
        		str = str.replace("\'", "\\"+"\'");
        	}
        	
        	if ( str.indexOf("\"") != -1 )
        	{
        		str = str.replace("\'", "\\"+"\"");
        	}
        	
        	return str;
        }
    }
}