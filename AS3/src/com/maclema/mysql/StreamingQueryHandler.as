package com.maclema.mysql
{
	import com.maclema.mysql.events.MySqlEvent;
	
	internal class StreamingQueryHandler extends QueryHandler
	{
		protected var streamingInterval:int = 100;
		
		public function StreamingQueryHandler(connInstanceID:int, token:MySqlToken, streamingInterval:int=1)
		{
			super(connInstanceID, token);
			this.streamingInterval = streamingInterval;
		}
		
		override protected function handleResultSetRowPacket(packet:ProxiedPacket):void {
			rs.addRow(packet);
			
			if ( rs.size() % streamingInterval == 0 ) {
				var evt:MySqlEvent = new MySqlEvent(MySqlEvent.ROWDATA);
				evt.resultSet = rs;
				evt.rowsAvailable = rs.size();
				token.dispatchEvent(evt);
			} 
			
			working = false;
			handleNextPacket();
		}
		
		override protected function handleResultSetFieldsEofPacket(packet:ProxiedPacket):void {
			super.handleResultSetFieldsEofPacket(packet);
			
			var evt:MySqlEvent = new MySqlEvent(MySqlEvent.COLUMNDATA);
			evt.resultSet = rs;
			token.dispatchEvent(evt);
		}
		
		override protected function handleResultSetRowsEofPacket(packet:ProxiedPacket):void {
			var evt:MySqlEvent = new MySqlEvent(MySqlEvent.ROWDATA);
			evt.resultSet = rs;
			evt.rowsAvailable = rs.size();
			token.dispatchEvent(evt);
				
			super.handleResultSetRowsEofPacket(packet);
		}
	}
}