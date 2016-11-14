package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	import com.maclema.mysql.events.MySqlErrorEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * Dispatched when successfully connected to the MySql Server
	 **/
	[Event(name="connect", type="flash.events.Event")]
	
	/**
	 * Dispatched when the connection to the server is terminated.
	 **/
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * Dispatched when a socket error occurs.
	 **/
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	/**
	 * Dispatch when an SQL error occurs on connecting to MySql
	 **/
	[Event(name="sqlError", type="com.maclema.mysql.events.MySqlErrorEvent")]
	
	/**
	 * A Connection is used to manage the creation and connection to a MySql Database.
	 * <br><br>
	 * The connection class manages all data input/output from MySql using a Socket connection. Since all 
	 * operations are asyncronous the Connection class also manages pooling queries and commands so they
	 * are executed in the order called.
	 **/
	public class Connection extends EventDispatcher
	{
		//connection instances.
		private static var instances:Array = new Array();
		
		/**
		 * @private
		 **/
		internal static function getInstance(instanceID:int):Connection {
			return Connection(instances[instanceID]);
		}
		
		/*internal static function getInstance(connInstanceID:int):Connection {
			return instances[connInstanceID];
		}*/
		
		//this instanceID;
		/**
		 * @private
		 **/
		internal var instanceID:int = -1;
		
		//the actual socket
		/**
		 * @private
		 **/
		internal var sock:Socket;
		
		//connection information
		private var host:String;
		private var port:int;
		private var username:String;
		private var password:String;
		private var database:String;
		
		/**
		 * @private
		 **/
		internal var connectionCharSet:String = "utf-8";
		
		//the current data reader
		private var dataHandler:DataHandler;
		
		/**
		 * @private
		 **/
		internal var clientParam:Number = 0;
		
		//the server information
		/**
		 * @private
		 **/
		internal var server:ServerInformation;
		
		//private vars
		private var expectingClose:Boolean = false;
		private var _connected:Boolean = false;
		private var _totalTX:Number;
		private var _tx:Number;
		private var _queryStart:Number;
		private var _busy:Boolean = false;
		private var commandPool:Array;
		
		private var _executingStoredProcedure:Boolean = false;
		
		private var mgr:DataManager;
		
		/**
		 * Creates a new Connection instance.
		 **/
		public function Connection( host:String, port:int, username:String, password:String = null, database:String = null )
		{
			super();
			
			instanceID = instances.length;
			instances.push(this);
			
			mgr = new DataManager();
			
			//set the connection information	
			this.host = host;
			this.port = port;
			this.username = username;
			this.password = password;
			this.database = database;
			
			this.commandPool = new Array();
			
			if ( this.database == "" )
			{
				this.database = null;
			}
			
			if ( this.password == "" )
			{
				this.password = null;
			}
			
			this.addEventListener(Event.CONNECT, onConnected);
			this.addEventListener(Event.CLOSE, onDisconnect);
			
			//create the connection to the server
			sock = new Socket();
			sock.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
            sock.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketError);
            sock.addEventListener(Event.CONNECT, onSocketConnect);
            sock.addEventListener(Event.CLOSE, onSocketClose);
            sock.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		}
		
		/**
		 * Returns true or false indicating if this Connection instance is connected to MySql
		 **/
		[Bindable("connectionStateChanged")]
		public function get connected():Boolean
		{
			return _connected;
		}
		
		/**
		 * Opens the socket connection to the server. You can optionally specify a character set. The specified charset
		 * should match a charset found in INFORMATION_SCHEMA.CHARACTER_SETS of the MySql database you are connecting
		 * to. It will then be converted to a compatible actionscript character set name and used for the duration of
		 * the connection. The default character set if utf8;
		 **/
		public function connect(charSet:String="utf8"):void
		{
			Logger.info(this, "connect()");
			
			_tx = 0;
			_totalTX = 0;
			
			this.connectionCharSet = charSet;
			
			//set the dataHandler
			setDataHandler( new HandshakeHandler(instanceID, username, password, database) );
			
			sock.connect( host, port );
		}
		
		/**
		 * Disconnects the socket from the server.
		 **/
		public function disconnect():void
		{
			Logger.info(this, "disconnect()");
			
			if ( dataHandler != null ) {
				Logger.error(this, "It seems there is still a pending qeury operation. Disconnect should be called after all queries are completed");
				throw new Error("It seems there is still a pending qeury operation. Disconnect should be called after all queries are completed");
			}
			
			expectingClose = true;
			
			if ( sock.connected )
			{
				sock.close();
				
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		/**
         * Creates a new statement object
         **/
        public function createStatement():Statement
        {
            return new Statement(this);
        }
        
        
        /**
        * Changes the currently selected database database
        **/
        public function changeDatabaseTo(whatDb:String):MySqlToken
        {	
        	Logger.info(this, "Change Database (" + whatDb + ")");
        	
        	var token:MySqlToken = new MySqlToken();
        	
        	if ( dataHandler != null ) {
        		poolCommand(doChangeDatabaseTo, null, token, whatDb);
        	}
        	else {
	        	doChangeDatabaseTo(null, token, whatDb);
         	}
            
            return token;
        }
        
        /**
        * Returns the number of bytes recieved since the last query
        **/
        public function get tx():Number {
        	return _tx;
        }
        
        /**
        * Returns the number of bytes recieved since the connection was opened
        **/
        public function get totalTX():Number {
        	return _totalTX;
        }
        
        /**
        * Returns the time the last query was executed
        **/
        public function get lastQueryStart():Number {
        	return _queryStart;
        }
        
        /**
        * Returns true if the connection is currently executing a query
        **/
        [Bindable("busyChanged")]
        public function get busy():Boolean {
        	return _busy;
        }
        
        /**
        * Returns the current size of the command pool
        **/
        public function get poolSize():int {
        	return commandPool.length;
        }
        
        /**
        * Returns the server information object for this connection
        **/
        public function getServerInformation():ServerInformation {
        	return server;
        }
        
        /**
         * Used by Statement to execute a query or update sql statement. 
         * @private
         **/
        internal function executeQuery(st:Statement, token:MySqlToken, sql:String, isStoredProcedure:Boolean=false):void
        {
        	Logger.info(this, "Execute Query (" + sql + ")");
			
        	if ( dataHandler != null ) {
        		poolCommand(executeQuery, st, token, sql, false, isStoredProcedure);
        	}
        	else {
				if ( isStoredProcedure ) {
					_executingStoredProcedure = true;
					Logger.debug(this, "Stored Procedure Call Starting");
				}
				
	        	_busy = true;
	        	dispatchEvent(new Event("busyChanged"));
	        	_tx = 0;
	        	_queryStart = getTimer();
	        	
	        	var handler:DataHandler = 
	        		(st != null && st.streamResults ) ? 
	        			new StreamingQueryHandler(instanceID, token, st.streamingInterval) : 
	        			new QueryHandler(instanceID, token);
	        			
	            setDataHandler(handler);
	            sendCommand(Mysql.COM_QUERY, sql);
	    	}
        }
		
		internal function storedProcedureComplete():void {
			Logger.debug(this, "Stored Procedure Call Complete");
			_executingStoredProcedure = false;
			checkPool();
		}
        
        /**
        * Executes a binary query object as a sql statement.
        * @private
        **/
        internal function executeBinaryQuery(st:Statement, token:MySqlToken, query:BinaryQuery):void
        {
        	Logger.info(this, "Execute Binary Query");
        	
        	if ( dataHandler != null ) {
        		poolCommand(executeBinaryQuery, st, token, query);
        	}
        	else {
	        	_busy = true;
	        	dispatchEvent(new Event("busyChanged"));
	        	_tx = 0;
	        	_queryStart = getTimer();
	        	
	        	var handler:DataHandler = 
	        		(st != null && st.streamResults ) ? 
	        			new StreamingQueryHandler(instanceID, token, st.streamingInterval) : 
	        			new QueryHandler(instanceID, token);
	        	
	        	setDataHandler(handler);
	        	sendBinaryCommand(Mysql.COM_QUERY, query);
        	}
        }
        
        /**
        * Used by HandshakeHandler to change the database when connecting.
        * @private
        **/
        internal function internalChangeDatabaseTo(whatDb:String):void
        {	
        	Logger.info(this, "Change Database (" + whatDb + ")");
        	
            if ( whatDb == null || whatDb.length == 0 )
                return;
            
            sendCommand(Mysql.COM_INIT_DB, whatDb);
        }
        
        /**
		 * @private
		 **/
        internal function initConnection():void {
        	var mysqlCharSet:String = connectionCharSet;
        	connectionCharSet = CharSets.as3CharSetFromMysqlCharSet(connectionCharSet);
        	
        	var st:Statement = createStatement();
        	st.sql = "SET NAMES ?";
        	st.setString(1, mysqlCharSet);
        	
        	Logger.debug(this, "SET NAMES " + mysqlCharSet);
        	
        	var token:MySqlToken = st.executeQuery();
        	token.addResponder({
        		result: function(data:Object):void {
        			dispatchEvent(new Event(Event.CONNECT));
        		},
        		fault: function(info:Object):void {
        			var evt:MySqlErrorEvent = new MySqlErrorEvent("Error connection char set");
        			dispatchEvent(evt);
        		}
        	});
        }
        
        /**
		 * @private
		 **/
        internal function getSocket():Socket {
        	return sock;
        }
		
		/**
		 * Handshake handler dispatches a connection event on the Connection object
		 * when successfully connected / authenticated to MySql. We need to update our
		 * connected variable here.
		 * @private
		 **/
		private function onConnected(e:Event):void
		{
			Logger.info(this, "Connected");
			
			this._connected = true;
			dispatchEvent(new Event("connectionStateChanged"));
		}
		
		/**
		 * When we lose our connection, update our connected variable.
		 * @private
		 **/
		private function onDisconnect(e:Event):void
		{
			Logger.info(this, "Disconnected");
			
			this._connected = false;
			dispatchEvent(new Event("connectionStateChanged"));
		}
		
		/**
		 * Handle any socket errors.
		 * @private
		 **/
		private function onSocketError(e:ErrorEvent):void
		{
			Logger.error(this, "Socket Error: " + e.toString());
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, e.text));
		}
		
		/**
		 * Handle a new socket connection
		 * @private
		 **/
		private function onSocketConnect(e:Event):void
		{
			Logger.info(this, "Socket Connected");
		}
		
		/**
		 * Handle a socket close event
		 * @private
		 **/
		private function onSocketClose(e:Event):void
		{
			Logger.info(this, "Socket Closed (Expected: " + expectingClose +")");
			
			if ( !expectingClose ) {
				throw new Error("Server terminated connection!");
			}
			
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * Handle new socket data
		 * @private
		 **/
		private function onSocketData(e:ProgressEvent):void
		{	
			_tx += sock.bytesAvailable;
			_totalTX += sock.bytesAvailable;
			
			sock.readBytes( mgr.buffer, mgr.buffer.length, sock.bytesAvailable );
			checkForPackets();
		}
		
		/**
		 * Keep scanning our socket data buffer and pass new full packets to the 
		 * currently active data handler. Be sure not to use recursion here because
		 * if MySql sends data to fase we will end up with a StackOverflowError.
		 * @private
		 **/
		private var cfpPosition:int = 0;
		private var cfpAvail:int = 0;
		private function checkForPackets():void
        {
        	try {
        		cfpAvail = mgr.buffer.length-cfpPosition;
        		while ( cfpAvail > 4 ) {
	        		var len:int = ((mgr.buffer[cfpPosition] & 0xff)) |
                        		  ((mgr.buffer[cfpPosition+1] & 0xff) << 8) |
                        		  ((mgr.buffer[cfpPosition+2] & 0xff) << 16);
	        		
	           		if ( (cfpAvail-3) >= len ) {
	           			var num:int = mgr.buffer[cfpPosition+3] & 0xFF;
	           			
	           			var pack:ProxiedPacket = new ProxiedPacket(mgr, (cfpPosition+4), len, num);
	                    
	                    cfpPosition = (cfpPosition+4) + len;
	                    
	                   	dataHandler.pushPacket( pack );

	                   	cfpAvail = mgr.buffer.length-cfpPosition;
	           		}
	           		else {
	           			//we dont have enough data, wait for 
	           			//the socket to give us some more data
	           			break;
	           		}
        		}
        	}
         	catch ( err:Error ) {
         		if ( dataHandler is HandshakeHandler == false ) {
	         		//this needs to be here for when we are quering very large data sets.
	         		//sometimes the checkForPackets method causes a stack overflow and
	         		//actually throws an EOF error. So if we use setTimeout, it will stop
	         		//the recurssion, and continue normally.
					Logger.debug(this, "checkForPackets Overflow. Breaking out of recurssion to recover.");
	         		setTimeout(checkForPackets, 1);
         		}
         		else {
         			throw err;
         		}
         	}
        }
		
		/**
		 * Sets a new DataHandler to handle the next batch of data coming
		 * from MySql. If the dataHandler variable is null we are not pooling
		 * commands properly somewhere so throw an error.
		 * @private
		 **/
		internal function setDataHandler(handler:DataHandler, data:String=null):void
		{
			if ( dataHandler != null ) {
				throw new Error("Concurrency Error");
			}
			
			Logger.info(this, "Set Data Handler To: " + getQualifiedClassName(handler));
			
			dataHandler = handler;
			dataHandler.addEventListener( "unregister", unregisterDataHandler );
		}
		
		/**
		 * Handle the unregistration of a datahandler.
		 * @private
		 **/
		private function unregisterDataHandler(e:Event=null):void
		{
			if ( dataHandler != null ) {
				Logger.info(this, "Unregistered Data Handler");
			
				dataHandler.removeEventListener( "unregister", unregisterDataHandler );
				dataHandler = null;
				
				_busy = false;
				dispatchEvent(new Event("busyChanged"));
				
				checkPool();
			}
		}
        
        /**
        * Pool a command. We need the method to call, the token to use, and the data to 
        * pass to the method. Any method passed to this method should have a signature of:
        * 
        * method(token:MySqlToken, data:*):void
        * @private
        **/
        private function poolCommand(method:Function, arg1:*, arg2:*, arg3:*, inject:Boolean=false, isStoredProcedure:Boolean=false):void {
        	Logger.info(this, "Pooling Query");
        	if ( !inject ) {
        		commandPool.push({method: method, arg1: arg1, arg2: arg2, arg3: arg3, isStoredProcedure: isStoredProcedure});
        	}
        	else {
        		commandPool.splice(0, 0, {method: method, arg1: arg1, arg2: arg2, arg3: arg3, isStoredProcedure: isStoredProcedure});
        	}
        }
        
        /**
        * Check our pool, if there is any waiting commands, execute them.
        * @private
        **/
        private function checkPool():void {
			if ( !_executingStoredProcedure ) {
	        	if ( commandPool.length > 0 ) {
	        		Logger.info(this, "Executing Pooled Query");
	        		
	        		var obj:Object = commandPool.shift();
	        		var method:Function = obj.method;
	        		var arg1:* = obj.arg1;
	        		var arg2:* = obj.arg2;
	        		var arg3:* = obj.arg3;
	        		var isStoredProcedure:Boolean = obj.isStoredProcedure;
				
					if ( isStoredProcedure && method == executeQuery ) {
						method(arg1, arg2, arg3, isStoredProcedure);
					}
					else {
	        			method(arg1, arg2, arg3);
					}
	        	}
			}
        }
        
        /**
        * Send a query command that is an instance of BinaryQuery
        * @private
        **/
        private function sendBinaryCommand(command:int, data:BinaryQuery):void
        {
        	Logger.info(this, "Send Binary Command (" + command + ")");
        	//check that the data is at position 0
        	data.position = 0;
        	
            var packet:OutputPacket = new OutputPacket();
            packet.writeByte(command);
            data.readBytes( packet, packet.position, data.bytesAvailable );
            packet.send(sock);
        }
		
		/**
		 * Send a query that is an instance of a String
		 * @private
		 **/
		private function sendCommand(command:int, data:String):void
        {
        	Logger.info(this, "Send Command (Command: " + command + " Data: " + data + ")");
        	
            var packet:OutputPacket = new OutputPacket();
            packet.writeByte(command);
            packet.writeMultiByte(data, connectionCharSet);
            packet.send(sock);
        }
        
        /**
        * This is our private method to change the database. We need this method because of
        * command pooling.
        * @private
        **/
        private function doChangeDatabaseTo(st:Statement, token:MySqlToken, whatDb:String):void
        {	
        	setDataHandler(new CommandHandler(instanceID, token));
        	
            if ( whatDb == null || whatDb.length == 0 ) {
                throw new Error("Database Name cannot be null or empty");
            }
            
            sendCommand(Mysql.COM_INIT_DB, whatDb);
        }
	}
}