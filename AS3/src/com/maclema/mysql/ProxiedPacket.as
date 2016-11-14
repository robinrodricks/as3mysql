package com.maclema.mysql
{
	internal class ProxiedPacket extends ProxiedBuffer
	{
		private static const maxAllowedPacket:int = 1024 * 1024 * 1024; //1GB
        public static const maxThreeBytes:int = (256 * 256 * 256) - 1; //16MB
        
        private var _packetLength:int = -1;
        private var _packetNumber:int = 0;
        
		public function ProxiedPacket(dmgr:DataManager, oset:int, len:int, num:int) {
		 	super(dmgr, oset, len);
		 	
        	if ( this.length > 4 ) {
        		_packetLength = len;
                _packetNumber = num;
                
                position = 0;
        	}
        }
        
        public function get packetLength():int
        {
            if ( _packetLength != -1 )
                return _packetLength;
            else
                return this.length;
        }
        
        public function get packetNumber():int
        {
            return _packetNumber;
        }

	}
}