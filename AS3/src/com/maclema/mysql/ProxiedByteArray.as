package com.maclema.mysql
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	internal class ProxiedByteArray implements IDataInput
	{
		protected var mgr:DataManager;
		private var offset:int;
		public var length:Number;
		protected var pos:int;
		
		public function ProxiedByteArray(mgr:DataManager, offset:int, length:Number)
		{
			this.mgr = mgr;
			this.offset = offset;
			this.length = length;
			this.pos = 0;
		}
		
		private function setPosition():void {
			mgr.buffer.position = this.offset + this.pos;
		}
		
		private function updatePosition():void {
			this.pos = mgr.buffer.position - this.offset;
		}
		
		public function set position(value:int):void {
			mgr.buffer.position = this.offset + value;
			updatePosition();
		}
		
		public function get position():int {
			return this.pos;
		}
		
		public function get bytesAvailable():uint {
			return length-pos;
		}
		
		public function get endian():String {
			return mgr.buffer.endian;
		}
		
		public function set endian(value:String):void {
			throw new Error("Not Supported");
		}
		
		public function get objectEncoding():uint {
			return mgr.buffer.objectEncoding;
		}
		
		public function readByte():int {
			setPosition();
			var byte:int = mgr.buffer.readByte();
			updatePosition();
			return byte;
		}
		
		public function readBoolean():Boolean {
			setPosition();
			var bool:Boolean = mgr.buffer.readBoolean();
			updatePosition();
			return bool;
		}
		
		public function readBytes(bytes:ByteArray, oset:uint = 0, len:uint = 0):void {
			setPosition();
			var maxLength:int = this.length-this.pos;
			if ( len == 0 ) {
				len = maxLength;
			}
			mgr.buffer.readBytes(bytes, oset, len);
			updatePosition();
		}
		
		public function readDouble():Number {
			setPosition();
			var ret:Number = mgr.buffer.readDouble();
			updatePosition();
			return ret;
		}
		
		public function readFloat():Number {
			setPosition();
			var ret:Number = mgr.buffer.readFloat();
			updatePosition();
			return ret;
		}
		
		public function readInt():int {
			setPosition();
			var ret:int = mgr.buffer.readInt();
			updatePosition();
			return ret;
		}
		
		public function readMultiByte(len:uint, charSet:String):String {
			setPosition();
			var ret:String = mgr.buffer.readMultiByte(len, charSet);
			updatePosition();
			return ret;
		}
		
		public function readObject():* {
			setPosition();
			var ret:Object = mgr.buffer.readObject();
			updatePosition();
			return ret;
		}
		
		public function readShort():int {
			setPosition();
			var ret:int = mgr.buffer.readShort();
			updatePosition();
			return ret;
		}
		
		public function readUnsignedByte():uint {
			setPosition();
			var ret:uint = mgr.buffer.readUnsignedByte();
			updatePosition();
			return ret;
		}
		
		public function readUnsignedInt():uint {
			setPosition();
			var ret:uint = mgr.buffer.readUnsignedInt();
			updatePosition();
			return ret;
		}
		
		public function readUnsignedShort():uint {
			setPosition();
			var ret:uint = mgr.buffer.readUnsignedShort();
			updatePosition();
			return ret;
		}
		
		public function readUTF():String {
			setPosition();
			var ret:String = mgr.buffer.readUTF();
			updatePosition();
			return ret;
		}
		
		public function readUTFBytes(len:uint):String {
			setPosition();
			var ret:String = mgr.buffer.readUTFBytes(len);
			updatePosition();
			return ret;
		}
		
		public function set objectEncoding(value:uint):void {
			throw new Error("Not Supported");
		}

	}
}