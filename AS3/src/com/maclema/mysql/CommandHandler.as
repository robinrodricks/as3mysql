package com.maclema.mysql
{
	import com.maclema.mysql.events.MySqlEvent;
	
	internal class CommandHandler extends DataHandler
	{
		private var token:MySqlToken;
		
		public function CommandHandler(connInstanceID:int, token:MySqlToken)
		{
			super(connInstanceID);
			
			this.token = token;
		}
		
		override protected function newPacket():void
		{
			handleNextPacket();
		}
		
		private function handleNextPacket():void
		{
			var packet:ProxiedPacket = nextPacket();
			
			if ( packet != null )
			{
				var evt:MySqlEvent;
				var field_count:int = packet.readByte() & 0xFF;
			
				if ( field_count == 0x00 )
				{
					evt = new MySqlEvent(MySqlEvent.RESPONSE);
					token.dispatchEvent(evt);
					unregister();
				}
				else if ( field_count == 0xFF || field_count == -1 )
				{
					unregister();
					new ErrorHandler(packet, token);
				}
			}
		}
	}
}