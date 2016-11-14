package com.maclema.mysql
{
    import com.maclema.logging.Logger;
    
    /**
     * @private
     **/
    internal class ServerInformation
    {
        public var protocolVersion:int;
        public var serverVersion:String;
        public var threadID:int;
        public var seed:String;
        public var serverCapabilities:int;
        public var serverLanguage:int;
        public var serverStatus:int;
        
        public var useLongPassword:Boolean;
        
        private var major:int;
        private var minor:int;
        private var revision:int;
        
        public function ServerInformation(packet:ProxiedBuffer)
        {
        	packet.position = 0;
        	
            protocolVersion = packet.readByte() & 0xFF;
            
            if ( protocolVersion < 10 )
            {
                throw new Error("Unsupported Protocol Version");
            }
            
            serverVersion = packet.readString("latin1");
            
            var point:int = serverVersion.indexOf(".");
            if ( point != -1 )
            {
                major = int(serverVersion.substr(0, point));
                
                var remaining:String = serverVersion.substr(point+1);
                point = remaining.indexOf(".");
                
                if ( point != -1 )
                {
                    minor = int(remaining.substr(0, point));
                    
                    remaining = remaining.substr(point+1);
                    
                    var pos:int = 0;
                    
                    while ( pos < remaining.length )
                    {
                        if ( String("0123456789").indexOf(remaining.charAt(pos)) == -1 )
                        {
                            break;
                        }
                        
                        pos++;
                    }
                    
                    revision = int(remaining.substr(0, pos));
                }
            }
            
            threadID = packet.readInt();
            
            seed = packet.readString("latin1");
           
            this.serverCapabilities = 0;
            
            if ( packet.position < packet.length ) {
            	serverCapabilities = packet.readTwoByteInt();
            }
            
            //Re: Issue 5 (Thanks Michael! http://code.google.com/p/asdox/)
            if ( meetsVersion(4, 1, 1) ) {
	            var oldpos:int = packet.position;
	            serverLanguage = packet.readByte() & 0xff;
	            serverStatus = packet.readTwoByteInt();
	            packet.position = oldpos+16;
	            
	            seed += packet.readString("latin1");
            }
            useLongPassword = true; //we only support min protocol version 10.
            
            Logger.debug(this, "Version: " + serverVersion);
        }
        
        public function meetsVersion(mjr:int, mnr:int, rvn:int):Boolean
        {
            if ( major >= mjr )
            {
                if ( major == mjr )
                {
                    if ( minor >= mnr )
                    {
                        if ( minor == mnr )
                        {
                            return (revision >= rvn );
                        }
                        return true;
                    }
                    return false; //fixed: Re: Issue #4
                }
                return true;
            }
            return false;
        }
        
        public function isCapableOf(param:int):Boolean
        {
            return ( (serverCapabilities & param) != 0 );
        }
    }
}