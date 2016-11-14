package com.maclema.logging
{
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Provides logging for asSQl
	 **/
	public class Logger
	{
		public static var NONE:int = 1000;
		public static var FATAL:int = 16;
		public static var ERROR:int = 8;
		public static var DEBUG:int = 4;
		public static var INFO:int = 2;
		public static var ALL:int = 0;
		
		/**
		 * The current logging level. Default is NONE.
		 **/
		public static var level:int = NONE;
		
		/**
		 * @private
		 **/
		public static function info(context:Object, message:String):void {
			log(INFO, context, message);
		}
		
		/**
		 * @private
		 **/
		public static function debug(context:Object, message:String):void {
			log(DEBUG, context, message);
		}
		
		/**
		 * @private
		 **/
		public static function error(context:Object, message:String):void {
			log(ERROR, context, message);
		}
		
		/**
		 * @private
		 **/
		public static function fatal(context:Object, message:String):void {
			log(FATAL, context, message);
		}
		
		private static function log(msgLevel:int, context:Object, message:String):void {
			if ( level <= msgLevel ) {
				trace(pad("[" + levelString(msgLevel) + "] " + getQualifiedClassName(context)) + " : " + message);
			}
		}
		
		private static function pad(str:String):String {
			while ( str.length < 50 ) {
				str += " ";
			}
			return str;
		}
		
		private static function levelString(whichLevel:int):String {
			switch (whichLevel) {
				case NONE: return "";
				case FATAL: return "FATAL";
				case ERROR: return "ERROR";
				case DEBUG: return "DEBUG";
				case INFO: return "INFO";
				case ALL: return "ALL";
			}
			return "";
		}

	}
}