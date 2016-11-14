package com.maclema.mysql
{
	public dynamic class MySqlOutputParams
	{
		public function MySqlOutputParams()
		{
		}
		
		public function getParam(name:String):String { 
			return this[name];
		}

	}
}