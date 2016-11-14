package com.maclema.mysql
{
	import com.maclema.mysql.events.MySqlErrorEvent;
	
	import flash.events.IEventDispatcher;
	
	internal class ErrorHandler
	{
		public function ErrorHandler( packet:ProxiedPacket, dispatchOn:IEventDispatcher )
		{
			var id:int = packet.readShort();
            packet.readByte(); //# marker
            var sqlstate:String = packet.readUTFBytes(5);    
            var msg:String = packet.readUTFBytes(packet.bytesAvailable);
            
            dispatchOn.dispatchEvent(new MySqlErrorEvent(msg, id));
		}
		
		public static function handleError(id:int, msg:String, dispatchOn:IEventDispatcher):void {
			dispatchOn.dispatchEvent(new MySqlErrorEvent(msg, id));
		}
	}
}