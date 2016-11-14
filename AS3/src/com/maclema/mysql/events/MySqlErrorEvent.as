package com.maclema.mysql.events
{
    import flash.events.Event;
    import flash.events.ErrorEvent;
	
	/**
	 * MySqlErrorEvent's are dispatched when MySql sends us an error related to connecting, authentication,
	 * or a command that was sent.
	 **/
    public class MySqlErrorEvent extends ErrorEvent
    {
        public static const SQL_ERROR:String = "sqlError";
        
        /**
        * The error message returned by MySql
        **/
        public var msg:String;
        
        /**
        * The error code returned by MySql
        **/
        public var id:int;
        
        /**
        * Constructs a new MySqlErrorEvent
        **/
        public function MySqlErrorEvent(msg:String, id:int=0)
        {
            super(SQL_ERROR);
            this.msg = msg;
            this.id = id;
            this.text = "SQL Error #" + id + ": " + msg;
        }
		// Issue 71 from Pablo Torres
		override public function clone():Event {
			return new MySqlErrorEvent(msg, id);
		}

    }
}