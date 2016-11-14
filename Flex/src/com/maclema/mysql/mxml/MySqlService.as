package com.maclema.mysql.mxml
{
	import com.maclema.mysql.MySqlService;
	import com.maclema.mysql.MySqlToken;
	import com.maclema.mysql.events.MySqlErrorEvent;
	import com.maclema.mysql.events.MySqlEvent;
	
	import flash.events.Event;
	
	import mx.core.IMXMLObject;
	import mx.managers.CursorManager;
	import mx.rpc.mxml.Concurrency;
	import mx.rpc.mxml.IMXMLSupport;
	
	/**
	 * Use the &lt;assql:MySqlService&gt; tag to represent a MySqlService object in an MXML file. When you call the MySqlService object's
	 * send method, it makes a query to the currently connection MySql database.
	 * 
	 * @see com.maclema.mysql.mxml.MySqlService
	 **/
	public class MySqlService extends com.maclema.mysql.MySqlService implements IMXMLSupport, IMXMLObject
	{
		private var _showBusyCursor:Boolean = false;
		
		/**
		 * Specifies if the service should automaticly connect to MySql when ready. Default is false.
		 **/
		public var autoConnect:Boolean = false;
		
		/**
		 * Constructs a new MySqlService object
		 **/
		public function MySqlService()
		{
			super();
		}
		
		/**
		 * Implemented method
		 **/
		public function initialized(document:Object, id:String):void {
			if ( autoConnect ) {
				connect();
			}
		}
		
		/**
		 * Implemented method (Always Concurrency.LAST)
		 **/
		public function get concurrency():String {
			return Concurrency.LAST;
		}
		
		/**
		 * Implemented method
		 **/
		public function set concurrency(value:String):void {
			//do nothing
		}
		
		/**
		 * Returns true or false indicating is the busy cursor is show when executing queries.
		 **/		
		public function get showBusyCursor():Boolean {
			return _showBusyCursor;
		}
		
		/**
		 * Sets if the busy cursor should be show when executing queries.
		 **/
		public function set showBusyCursor(value:Boolean):void {
			_showBusyCursor = value;
		}
		
		/**
		 * Executes a query, you may pass in either an sql string or a Statement object.
		 **/
		override public function send(queryObject:*):MySqlToken {
			var token:MySqlToken = super.send(queryObject);
			
			if ( showBusyCursor ) {
				CursorManager.setBusyCursor();
				token.addEventListener(MySqlErrorEvent.SQL_ERROR,removeBusyCursor);
				token.addEventListener(MySqlEvent.RESULT, removeBusyCursor);
				token.addEventListener(MySqlEvent.RESPONSE, removeBusyCursor);
				token.addEventListener(Event.CLOSE, removeBusyCursor);
			}
			
			return token;
		}
		
		private function removeBusyCursor(e:*=null):void {
			CursorManager.removeBusyCursor();
		}
	}
}