package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	
	import flash.utils.ByteArray;
	
	/**
	 * This class handles completing the handshake between this driver
	 * and the mysql server
	 **/
	internal class HandshakeHandler extends DataHandler
	{
		private static const AUTH_411_OVERHEAD:int = 33;
		
		private var username:String;
		private var password:String;
		private var database:String;
		
		private var connectWithDb:Boolean = false;
		
		private var inPacketCount:int = 0;
		
		private var savePacketSequence:int;
		
		private var server:ServerInformation;
		
		public function HandshakeHandler(connInstanceID:int, username:String, password:String, database:String)
		{
			super(connInstanceID);
			
			CharSets.initCharSets();
			
			this.username = username;
			this.password = password;
			this.database = database;
		}
		
		override protected function newPacket():void
		{	
			inPacketCount++;
			var packet:ProxiedPacket;
			var field_count:int;
			
			if ( inPacketCount == 1 )
			{
				Logger.info(this, "Server Information Packet");
				packet= nextPacket();
				server = new ServerInformation( packet );
				Connection.getInstance(connInstanceID).server = new ServerInformation( packet );
				doHandshake();
			}
			else if ( inPacketCount == 2 )
			{
				packet= nextPacket();
				
				field_count = packet.readByte() & 0xFF;
				
				if ( field_count == 0xFE && packet.length < 9 )
				{
					Logger.info(this, "323 Scramble Request Packet");
					//By sending this very specific reply server asks us to send scrambled
                  	//password in old format. The reply contains scramble_323.
                  	inPacketCount--;
                  	sendScramble323();
				}
				else if ( field_count == 0x00 )
				{
					Logger.info(this, "Success Packet");
					
					//ok packet
					if ( connectWithDb )
					{
						//send command
						Connection.getInstance(connInstanceID).internalChangeDatabaseTo(database);
					}
					else
					{
						//woop! were authenticated
						unregister();
						Connection.getInstance(connInstanceID).initConnection();
					}
				}
				else if ( field_count == 0xFF )
				{
					Logger.info(this, "Error Packet");
					unregister();
					new ErrorHandler( packet, Connection.getInstance(connInstanceID) );
				}
			}
			else if ( connectWithDb && inPacketCount == 3 )
			{
				packet = nextPacket();
				field_count = packet.readByte() & 0xFF;
				
				if ( field_count == 0x00 )
				{
					Logger.info(this, "Connect With DB Success Packet");
					
					//woop! were authenticated
					unregister();
					Connection.getInstance(connInstanceID).initConnection();
				}
				else if ( field_count == 0xFF || field_count == -1 )
				{
					Logger.info(this, "Connect With DB Error Packet");
					
					unregister();
					new ErrorHandler( packet, Connection.getInstance(connInstanceID) );
				}
			}
		}
		
		private function doHandshake():void
		{
			Logger.info(this, "doHandshake");
			if ( server.meetsVersion( 4, 1, 22 ) )
			{
				var clientParam:Number = 0;
				Connection.getInstance(connInstanceID).clientParam = 0;
				
				if ( database != null && database.length > 0 )
				{
					clientParam |= Mysql.CLIENT_CONNECT_WITH_DB;
					connectWithDb = true;
				}
				
				if ( server.isCapableOf( Mysql.CLIENT_LONG_FLAG ) )
				{
					clientParam |= Mysql.CLIENT_LONG_FLAG;
				}
				
				//return found rows
                clientParam |= Mysql.CLIENT_FOUND_ROWS;
    
                //use the new password encryption
                clientParam |= Mysql.CLIENT_LONG_PASSWORD;
                
                //use the 4.1.1 protocol
                clientParam |= Mysql.CLIENT_PROTOCOL_41;
                
                //use transactions
                clientParam |= Mysql.CLIENT_TRANSACTIONS;
                
                //return multiple result sets
                clientParam |= Mysql.CLIENT_MULTI_RESULTS;
                
                if ( server.isCapableOf(Mysql.CLIENT_SECURE_CONNECTION) )
                {
                	clientParam |= Mysql.CLIENT_SECURE_CONNECTION;
                	Connection.getInstance(connInstanceID).clientParam = clientParam;
                	doSecureAuthentication411();
                }
                else
                {
                	//since we are doing the check for 4.1.22, we should
                	//never get here. Fix: Adjust checks to allow previous
                	//versions
                	Connection.getInstance(connInstanceID).clientParam = clientParam;
                	doAuthentication();
                }
			}
			else
			{
				throw new Error("Unsupported Server Version");
			}
		}
		
		/* completes the authentication */
		private function doAuthentication():void
		{
			Logger.info(this, "doAuthentication");
			
			var clientParam:Number = Connection.getInstance(connInstanceID).clientParam;
			
			//the packet to send
			var packet:OutputPacket = new OutputPacket();
			
			//write the client parameters
			//packet.writeShort( con.clientParam );
			packet.writeByte( clientParam & 0xFF );
			packet.writeByte( clientParam >>> 8 );
			
			// write the maximum packet sixe
			packet.writeThreeByteInt( OutputPacket.maxThreeBytes );
			
			//the username
			packet.writeString(username, "latin1");
			
			if ( password != null )
			{
				var scrambledPassword:ByteArray = Util.newCrypt( password, server.seed );
				packet.writeBytes( scrambledPassword );
				packet.writeByte(0x00);
			}
			else
			{
				//empty password
				packet.writeByte(0x00);
			}
			
			//are we connecting using a database name?
			if ( connectWithDb && database != null )
			{
			    packet.writeString(database, "latin1");
			}
			
			packet.send(Connection.getInstance(connInstanceID).getSocket(), 1);
		}
	
		private function sendScramble323():void
		{
			var packet:OutputPacket = new OutputPacket();
			
			var seed323:String = server.seed.substring(0, 8);
			var scrambled323:ByteArray = Util.newCrypt(password, seed323);
			packet.writeBytes( scrambled323 );
			packet.writeByte(0x00);
			packet.send(Connection.getInstance(connInstanceID).getSocket(), ++savePacketSequence);
		}
		
		/* completes the authentication */
		private function doSecureAuthentication411():void
		{
			Logger.info(this, "doSecureAuthentication");
			
			var clientParam:Number = Connection.getInstance(connInstanceID).clientParam;
			
			//the packet to send
			var packet:OutputPacket = new OutputPacket();
			
			//write the client parameters
			packet.writeByte( clientParam & 0xFF );
			packet.writeByte( clientParam >>> 8 );
			packet.writeByte( clientParam >>> 16 );
			packet.writeByte( clientParam >>> 24 );
			
			// write the maximum packet sixe
			packet.writeInt( OutputPacket.maxThreeBytes );
			
			//language
			packet.writeByte( 8 ); //charset
			
			//the 23-byte null filler
			packet.writeNullBytes(23);
			
			//the username
			packet.writeString(username, "latin1");
			
			if ( password != null )
			{
				packet.writeByte(0x14);
				var scrambledPassword:ByteArray = Util.scramble411( password, server.seed );
				
				packet.writeBytes(scrambledPassword);
			}
			else
			{
				//empty password
				packet.writeByte(0x00);
			}
			
			//are we connecting using a database name?
			if ( connectWithDb && database != null )
			{
			    packet.writeString(database, "latin1");
			}
			
			savePacketSequence = packet.send(Connection.getInstance(connInstanceID).getSocket(), 1);
		}
	}
}