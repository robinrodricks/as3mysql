package com.maclema.util
{
	import com.maclema.mysql.Field;
	import com.maclema.mysql.Mysql;
	import com.maclema.mysql.ResultSet;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.formatters.DateFormatter;
	
	/**
	 * Provides some useful utility methods for dealing with ResultSet's
	 **/
	public class ResultsUtil
	{
		/**
		 * Takes a ResultSet and returns an array valid for being used as a 
		 * DataGrid's columns property.
		 **/
		public static function getDataGridColumns(rs:ResultSet):Array {
			var cols:Array = rs.getColumns();
			var newcols:Array = new Array();
			
			cols.forEach(function(c:Field, index:int, arr:Array):void {
				var clm:DataGridColumn = new DataGridColumn( c.getName() );
				clm.dataField = c.getName();
				
				if ( c.getAsType() == Mysql.AS3_TYPE_DATE ) {
					clm.labelFunction = columnDateFunction;
				}
				else if ( c.getAsType() == Mysql.AS3_TYPE_TIME ) {
					clm.labelFunction = columnTimeFunction;
				}
				
				newcols.push(clm);
			});
			
			return newcols;
		}
		
		/**
		 * This is the labelFunction used for DataGrid Date columns
		 **/
		public static function columnDateFunction(item:Object, column:DataGridColumn):String {
			if ( item[column.dataField] is String ) {
				return item[column.dataField];
			}
			var dt:Date = item[column.dataField] as Date;
			var df:DateFormatter = new DateFormatter();
			df.formatString = "YYYY-MM-DD";
			return df.format(dt);
		};
		
		/**
		 * This is the labelFunction used for DataGrid Time columns
		 **/
		public static function columnTimeFunction(item:Object, column:DataGridColumn):String {
			if ( item[column.dataField] is String ) {
				return item[column.dataField];
			}
			
			var dt:Date = item[column.dataField] as Date;
			var df:DateFormatter = new DateFormatter();
			df.formatString = "J:NN:SS";
			return df.format(dt);
		};
		
		/**
		 * Takes a value and and a Field, and returns a String ready for use in 
		 * an SQL statement. You can optionally specify not to add quotes to the values.
		 * 
		 * Example: prepareForSqlString([some date in milliseconds], field) would return
		 * '2008-01-01 00:00:00' ready for an insert statement
		 **/
		public static function prepareForSqlString(value:Object, field:Field, addQuotes:Boolean=true):String
		{
			if ( value == null ) {
				return "NULL";
			}
			
			if (value is Object)
			{							
				var ds:DateFormatter = new DateFormatter();
				var outValue:String;
				
				switch (field.getType())
				{
					case Mysql.FIELD_TYPE_DECIMAL:
					case Mysql.FIELD_TYPE_TINY:
					case Mysql.FIELD_TYPE_SHORT:
					case Mysql.FIELD_TYPE_LONG:
					case Mysql.FIELD_TYPE_FLOAT:
					case Mysql.FIELD_TYPE_DOUBLE:
					case Mysql.FIELD_TYPE_LONGLONG:
					case Mysql.FIELD_TYPE_INT24:
					case Mysql.FIELD_TYPE_YEAR:
					case Mysql.FIELD_TYPE_NEWDECIMAL:
					case Mysql.FIELD_TYPE_BIT:
						return value.toString();
						
					case Mysql.FIELD_TYPE_DATE:
						// MySQL date port
						ds.formatString = "YYYY-MM-DD";
						
						outValue = ds.format(new Date(value));
						
						if ( addQuotes ) {
							return "'" + outValue + "'";
						}
						else {
							return outValue;
						}
					
					case Mysql.FIELD_TYPE_TIMESTAMP:
					case Mysql.FIELD_TYPE_DATETIME:
					case Mysql.FIELD_TYPE_NEWDATE:
						// MySQL datetime port
						ds.formatString = "YYYY-MM-DD JJ:NN:SS";
						
						outValue = ds.format(new Date(value));
						
						if ( addQuotes ) {
							return "'" + outValue + "'";
						}
						else {
							return outValue;
						}
						
					case Mysql.FIELD_TYPE_TIME:
						// MySQL time port
						ds.formatString = "JJ:NN:SS";
						
						outValue = ds.format(new Date(value));
						
						if ( addQuotes ) {
							return "'" + outValue + "'";
						}
						else {
							return outValue;
						}
					
					case Mysql.FIELD_TYPE_ENUM:
					case Mysql.FIELD_TYPE_VARCHAR:
					case Mysql.FIELD_TYPE_VAR_STRING:
					case Mysql.FIELD_TYPE_STRING:
						outValue = Mysql.escapeString(value.toString());
						
						if ( addQuotes ) {
							return "'" + outValue + "'";
						}
						else {
							return outValue;
						}
				}
			}
			
			return String(value);
		}
	}
}