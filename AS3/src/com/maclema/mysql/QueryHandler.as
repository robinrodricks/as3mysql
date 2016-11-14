package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	import com.maclema.mysql.events.MySqlEvent;
	import com.maclema.util.ByteFormatter;
	
	import flash.utils.getTimer;
	
	/**
	 * Handles recieving and parsing the data sent by the MySql server
	 * in response to a query.
	 **/
	internal class QueryHandler extends DataHandler
	{
		protected var token:MySqlToken;
		protected var rs:ResultSet;
		
		protected var readHeader:Boolean = false;
		protected var readFields:Boolean = false;
		
		protected var working:Boolean = false;
		
		public function QueryHandler(connInstanceID:int, token:MySqlToken)
		{
			super(connInstanceID);
			
			this.token = token;
		}
		
		override protected function newPacket():void
		{
			handleNextPacket();
		}
		
		protected function handleResponsePacket(packet:ProxiedPacket):void {
			var rows:int = packet.readLengthCodedBinary();
			var insertid:int = packet.readLengthCodedBinary();
			var evt:MySqlEvent = new MySqlEvent(MySqlEvent.RESPONSE);
			evt.affectedRows = rows;
			evt.insertID = insertid;
			
			unregister();
			token.dispatchEvent(evt);
		}
		
		protected function handleErrorPacket(packet:ProxiedPacket):void {
			unregister();
			new ErrorHandler(packet, token);	
		}
		
		protected function handleEofPacket(packet:ProxiedPacket):void {
			packet.position = 0;
						
			//eof packet
			if ( !readFields )
			{
				handleResultSetFieldsEofPacket(packet);
			}
			else
			{
				handleResultSetRowsEofPacket(packet);
			}
		}
		
		protected function handleResultSetRowsEofPacket(packet:ProxiedPacket):void {
			Logger.info(this, "Initializating ResultSet...");
				
			var evt:MySqlEvent = new MySqlEvent(MySqlEvent.RESULT);
			evt.resultSet = rs;
			
			Logger.debug(this, "Mysql Result");
			Logger.debug(this, "  Rows:       " + rs.size());
			Logger.debug(this, "  Query Size: " + ByteFormatter.format(Connection.getInstance(connInstanceID).tx, ByteFormatter.KBYTES, 2));
			Logger.debug(this, "  Total TX:   " + ByteFormatter.format(Connection.getInstance(connInstanceID).totalTX, ByteFormatter.KBYTES, 2));
			Logger.debug(this, "  Query Time: " + (getTimer()-Connection.getInstance(connInstanceID).lastQueryStart) + " ms");
			
			unregister();
			token.dispatchEvent(evt);
		}
		
		protected function handleResultSetFieldsEofPacket(packet:ProxiedPacket):void {
			Logger.info(this, "Reading Row Data...");
			
			rs.initialize(Connection.getInstance(connInstanceID).connectionCharSet);
			
			readFields = true;
			working = false;
			handleNextPacket();
		}
		
		protected function handleDataPacket(packet:ProxiedPacket):void {
			packet.position = 0;
						
			if ( !readHeader )
			{
				handleResultSetHeaderPacket(packet);
			}
			else if ( !readFields )
			{
				handleResultSetFieldPacket(packet);
			}
			else
			{
				handleResultSetRowPacket(packet);
			}
		}
		
		protected function handleResultSetHeaderPacket(packet:ProxiedPacket):void {
			Logger.info(this, "Reading Column Data...");
			rs = new ResultSet(token);
			readHeader = true;
			
			working = false;
			handleNextPacket();
		}
		
		protected function handleResultSetFieldPacket(packet:ProxiedPacket):void {
			var field:Field = new Field(packet, Connection.getInstance(connInstanceID).connectionCharSet);
			rs.addColumn(field);
		
			working = false;
			handleNextPacket();
		}
		
		protected function handleResultSetRowPacket(packet:ProxiedPacket):void {
			rs.addRow(packet);
			
			working = false;
			handleNextPacket();
		}
		
		protected function handleNextPacket():void
		{
			if ( !working )
			{
				working = true;
		
				var packet:ProxiedPacket = nextPacket();
				
				if ( packet != null )
				{
					var field_count:int = packet.readByte() & 0xFF;
				
					if ( field_count == 0x00 )
					{
						handleResponsePacket(packet);
					}
					else if ( field_count == 0xFF || field_count == -1 )
					{
						handleErrorPacket(packet);
					}
					else if ( packet.length == 5 && (field_count == 0xFE || field_count == -2) )
					{	
						handleEofPacket(packet);
					}
					else
					{
						handleDataPacket(packet);
					}
				}
				else
				{
					working = false;
				}
			}
		}
	}
}