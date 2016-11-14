package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * This class is the base class for any class that is used as a data
	 * handler for data that the server sends and recieves.
	 **/
	internal class DataHandler extends EventDispatcher
	{
		protected var connInstanceID:int = -1;
		
		private var packets:Array;
		private var _joinNextPacket:Boolean = false;
		
		public function DataHandler(connInstanceID:int)
		{
			super();
			
			this.connInstanceID = connInstanceID;
			
			packets = new Array();
		}
		
		/**
		 * Called by the Connection and adds a new/recieved packet to
		 * the array of packets that need be handled.
		 **/
		public function pushPacket(packet:ProxiedPacket):void
		{
			packets.push(packet);
			
			/*The last short packet will always be present even if it must have a zero-length 
			body. It serves as an indicator that there are no more packet parts left in the 
			stream for this large packet. */
			//http://tutorialsforu.info/mysql/mysql-coding/client/server-communication-in-mysql--packet-format.html
			if ( packet.length == ProxiedPacket.maxThreeBytes ) {
				_joinNextPacket = true;
			}
			
			if ( _joinNextPacket ) {
				joinPackets();
			}
			else {
				newPacket();
			}
		}
        
        //overridden by handlers
        protected function newPacket():void {
        	Logger.fatal(this, "NEW PACKET WAS NOT OVERRIDDEN");
        	throw new Error("newPacket() WAS NOT OVERRIDDEN");
        }
        
        /**
        * Returns the next packet that needs to be handled
        **/
        protected function nextPacket():ProxiedPacket
        {	
        	if ( packets != null && packets.length > 0 )
	        	return ProxiedPacket(packets.shift());
	        else
	        	return null;
        }
		
		private function joinPackets():void {
			if ( packets.length > 1 ) {
				var pack1:ProxiedPacket = nextPacket();
				var pack2:ProxiedPacket = nextPacket();
				
				pack1.position = pack2.length;
				
				//don't call newPacket until we get a packet smaller
				//than maxThreeBytes
				if ( pack2.length < ProxiedPacket.maxThreeBytes ) {
					_joinNextPacket = false;
					newPacket();
				}
				
				pack2 = null;
			}
		}
		
        protected function unregister():void
        {
        	packets = null;
        	
        	dispatchEvent(new Event("unregister"));
        }
        
        protected function get remainingPackets():int {
        	return packets.length;
        }
	}
}