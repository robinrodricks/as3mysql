package com.maclema.mysql
{
    import com.adobe.crypto.SHA1;
    
    import flash.utils.ByteArray;
    
    internal class Util
    {
    	/**
    	 * Handles the new encryption for 4.1 and newer servers.
    	 **/
        public static function newCrypt(password:String, seed:String):ByteArray
        {	
            var i:int;
            var b:int;
            var d:Number;
    
            if ((password == null) || (password.length == 0)) 
            {
                return new ByteArray();
            }
    
            var pw:Array = newHash(seed);
            var msg:Array = newHash(password);
            var max:Number = 0x3fffffff;
            var seed1:Number = (pw[0] ^ msg[0]) % max;
            var seed2:Number = (pw[1] ^ msg[1]) % max;
            var chars:Array = new Array(seed.length);
            
            for (i = 0; i < seed.length; i++) 
            {
                seed1 = ((seed1 * 3) + seed2) % max;
                seed2 = (seed1 + seed2 + 33) % max;
                d = seed1 / max;
                b = Math.floor((d * 31) + 64);
                chars[i] = b;
            }
    
            seed1 = ((seed1 * 3) + seed2) % max;
            seed2 = (seed1 + seed2 + 33) % max;
            d = seed1 / max;
            b = Math.floor(d * 31);
    
            for (i = 0; i < seed.length; i++) 
            {
                chars[i] ^= b;
            }
            
            var bytes:ByteArray = new ByteArray();
            for ( i=0; i<seed.length; i++ )
            {
            	var theByte:int = chars[i] & 0xFF;
                bytes.writeByte( theByte );
            }
            bytes.position = 0;
    
            return bytes;
        }
        
        private static function newHash(password:String):Array
        {
            var nr:Number = 1345345333;
            var add:Number = 7;
            var nr2:Number = 0x12345671;
            var tmp:Number;

            for (var i:int = 0; i < password.length; ++i)
            {
                if ((password.charAt(i) == ' ') || (password.charAt(i) == '\t')) 
                {
                    continue; // skip spaces
                }
    
                tmp = ( 0xff & password.charCodeAt(i) );
                nr ^= ((((nr & 63) + add) * tmp) + (nr << 8));
                nr2 += ((nr2 << 8) ^ nr);
                add += tmp;
            }
            
            var result:Array = new Array(2);
            result[0] = nr & 0x7fffffff;
            result[1] = nr2 & 0x7fffffff;

            return result;
        }
        
        /**
        * Handles the 4.1 or newer encryption
        **/
        public static function scramble411(password:String, seed:String):ByteArray
        {
        	var phs1:ByteArray = SHA1.hashToByteArray(password);	
        	var phs2:ByteArray = SHA1.hashBytesToByteArray(phs1);
        	var phs3:ByteArray = new ByteArray();
        	for ( var i:int=0; i<seed.length; i++ ) { phs3.writeByte( seed.charCodeAt(i) & 0xFF ); }
        	phs3.writeBytes(phs2);
        	phs3.position = 0;
        	
        	var toBeXored:ByteArray = SHA1.hashBytesToByteArray(phs3);
        	toBeXored.position = 0;
        	
        	var xored:ByteArray = new ByteArray();
        	
        	for ( var n:int=0; n<toBeXored.length; n++ ) {
        		var b1:int = toBeXored.readByte();
        		var b2:int = phs1.readByte();
        		xored.writeByte( b1 ^ b2 );	
        	}	
        	
        	xored.position = 0;
        	
        	return xored;
        }
        
        public static function getSqlParameters(sql:String):Array {
        	var params:Array = new Array();
        	var inQuotes:Boolean = false;
        	var quoteID:String = "";
        	
        	var paramCount:int = 0;
        	var namesParamCount:int = 0;
        	
        	var param:SqlParam;
        	
        	var i:int = 0;
        	while ( i < sql.length ) {
        		var c:String = sql.charAt(i);
				
				//ignore parameter identifiers that reside inside quotes        		
        		if ( isQuote(c) ) {
        			if ( !inQuotes ) {
        				inQuotes = true;
        				quoteID = c;
        				
        				i++;
        				continue;
        			}
        			else {
        				if ( c == quoteID ) {
        					if ( i > 1 && sql.charAt(i-1) != "\\" ) {
        						inQuotes = false;
        						
        						i++;
        						continue;
        					}
        				}
        			}
        		}
        		
        		//watch for params
        		if ( !inQuotes ) {
        			if ( c == "?" ) {
        				paramCount++;
        				
        				param = new SqlParam();
        				param.startIndex = i;
        				param.length = 1;
        				param.paramIndex = paramCount;
        				params.push(param);
        				
        				i++;
        				continue;
        			}
        			else if ( c == ":" ) {
						namesParamCount++;
						
						//get our param name
						var n:int = i+1;
						while ( isAlphaNumeric(sql.charAt(n)) && n < sql.length ) {
							n++;
						}
						
						if ( n > i+1 ) {
							param = new SqlParam();
							param.startIndex = i;
							param.paramName = sql.substring(i+1, n);
							param.length = n-i;
							params.push(param);
							
							i = n;
							continue;
						}
        			}
        		}
        		
        		i++;
        	}
        	
        	return params;
        }
        
        public static function getSqlPartsForParams(sql:String, params:Array):Array {
        	var parts:Array = new Array();
        	
        	var pos:int = 0;
        	var part:String = "";
        	
        	for ( var i:int=0; i<params.length; i++ ) {
        		var p:SqlParam = params[i];
        		part = sql.substring(pos, p.startIndex);
        		parts.push(part);
        		pos = p.startIndex + p.length;
        	}
        	
        	part = sql.substring(pos);
        	if ( part != "" ) {
        		parts.push(part);
        	}
        	
        	return parts;
        }
        
        private static function isAlphaNumeric(c:String):Boolean {
        	c = c.toLocaleLowerCase();
        	var alphaNumeric:String = "0123456789abcdefghijklmnopqrstuvwxyz";
        	return (alphaNumeric.indexOf(c) != -1);
        }
        
        private static function isQuote(char:String):Boolean {
        	return (char == '"' || char == "'");
        }
    }
}