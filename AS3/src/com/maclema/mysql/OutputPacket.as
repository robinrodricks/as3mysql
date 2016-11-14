package com.maclema.mysql
{
    import com.maclema.logging.Logger;
    
    import flash.net.Socket;
    
    /**
     * @private
     **/
    internal class OutputPacket extends Buffer
    {	
        private static const maxAllowedPacket:int = 1024 * 1024 * 1024; //1GB
        public static const maxThreeBytes:int = (256 * 256 * 256) - 1; //16MB
        
        private var _packetLength:int = -1;
        private var _packetNumber:int = 0;
        
        private var packetSeq:int = 0;
        
        public function OutputPacket(len:int=-1, num:int=0) {
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
        
        public function send(sock:Socket, seqOverride:int=0):int
        {
            if ( packetLength > maxAllowedPacket )
            {
            	Logger.error(this, "Packet Larger Than maxAllowedPacket of " + maxAllowedPacket + " bytes");
            	throw new Error("Packet Larger Than maxAllowedPacket of " + maxAllowedPacket + " bytes");
            }
            
            if ( seqOverride != 0 ) {
            	this.packetSeq = seqOverride;
            }
            
            if ( packetLength > maxThreeBytes )
            {
                sendSplitPackets(sock);
            }
            else
            {
                sendFullPacket(sock);
            }
            
            return packetSeq;
        }
        
        private function buildAndSendPacket(uncompressedLength:int, seq:int, sock:Socket):void
        {
            var packetToSend:Buffer = new Buffer();
            var compPacket:Buffer;
            var sendCompressed:Boolean = false;
            
            seq = seq & 0xFF;
            
        	packetToSend.writeThreeByteInt(uncompressedLength);
        	packetToSend.writeByte(seq);
        	this.readBytes(packetToSend, 4, uncompressedLength);
            
            packetToSend.position = 0;
            
          	sock.writeBytes( packetToSend );
            sock.flush();
        }
        
        private function sendFullPacket(sock:Socket):void
        {   
            var seq:int = this.packetSeq;
            
            this.packetSeq++;
            
            this.position = 0;
            buildAndSendPacket(this.packetLength, seq, sock);
        }
        
        private function sendSplitPackets(sock:Socket):void
        {
            var seq:int = 0;
            var pack:OutputPacket;
            
            this.position = 0;
            
            while ( this.bytesAvailable > maxThreeBytes )
            {           
                pack = new OutputPacket();
                pack.packetSeq = seq++;
                this.readBytes(pack, 0, maxThreeBytes);
                pack.send(sock);
            }
            
            //send last packet
            pack = new OutputPacket();
            pack.packetSeq = seq++;
            this.readBytes(pack, 0, this.bytesAvailable);
            pack.send(sock);
        }
    }
}