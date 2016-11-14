package com.maclema.mysql
{
	internal class CharSets
	{		
		private static var inited:Boolean = false;
		
		private static var INDEX_TO_CHARSET:Array;
		
		private static var INDEX_TO_COLLATION:Array;
		
		private static var MYSQL_TO_AS3_CHARSET_MAP:Object;
		
		private static function mysqlToActionscriptCharSet(mysqlCharSet:int):String {
			return INDEX_TO_CHARSET[mysqlCharSet];
		}
		
		private static function mysqlCharSetIndexToCollation(mysqlCharSet:int):String {
			return INDEX_TO_COLLATION[mysqlCharSet];
		}
		
		public static function as3CharSetFromMysqlCharSet(mysqlCharSet:String):String {
			var as3CharSet:String = null;
			
			if ( MYSQL_TO_AS3_CHARSET_MAP[mysqlCharSet] != null ) {
				var parts:Array = MYSQL_TO_AS3_CHARSET_MAP[mysqlCharSet].split(", ");
				if ( parts.length > 0 ) {
					as3CharSet = parts[0];
				}
			}
			
			if ( as3CharSet == null ) {
				throw new Error("Unsupported Char Set '" + mysqlCharSet + "'");
			}
			
			return as3CharSet;
		}
		
		public static function initCharSets():void {
			if ( inited ) { return; }
			
			//Maps MySql CharSet's To All Possible Actionscript CharSets
			MYSQL_TO_AS3_CHARSET_MAP = {};
			MYSQL_TO_AS3_CHARSET_MAP['big5'] = 'big5, cn-big5, csbig5, x-x-big5';
			MYSQL_TO_AS3_CHARSET_MAP['dec8'] = null;
			MYSQL_TO_AS3_CHARSET_MAP['cp850'] = 'ibm850';
			MYSQL_TO_AS3_CHARSET_MAP['hp8'] = 'us-ascii, ANSI_X3.4-1968, ANSI_X3.4-1986, ascii, cp367, csASCII, IBM367, ISO_646.irv:1991, ISO646-US, iso-ir-6us';
			MYSQL_TO_AS3_CHARSET_MAP['koi8r'] = 'koi8-r, csKOI8R, koi, koi8, koi8r';
			MYSQL_TO_AS3_CHARSET_MAP['latin1'] = ' 	iso-8859-1, cp819, csISO, Latin1, ibm819, iso_8859-1, iso_8859-1:1987, iso8859-1, iso-ir-100, l1, latin1';
			MYSQL_TO_AS3_CHARSET_MAP['latin2'] = 'iso-8859-2, csISOLatin2, iso_8859-2, iso_8859-2:1987, iso8859-2, iso-ir-101, l2, latin2';
			MYSQL_TO_AS3_CHARSET_MAP['swe7'] = null;
			MYSQL_TO_AS3_CHARSET_MAP['ascii'] = 'us-ascii, ANSI_X3.4-1968, ANSI_X3.4-1986, ascii, cp367, csASCII, IBM367, ISO_646.irv:1991, ISO646-US, iso-ir-6us';
			MYSQL_TO_AS3_CHARSET_MAP['ujis'] = 'euc-jp, csEUCPkdFmtJapanese, Extended_UNIX_Code_Packed_Format_for_Japanese, x-euc, x-euc-jp';
			MYSQL_TO_AS3_CHARSET_MAP['sjis'] = 'shift_jis, csShiftJIS, csWindows31J, ms_Kanji, shift-jis, x-ms-cp932, x-sjis';
			MYSQL_TO_AS3_CHARSET_MAP['hebrew'] = 'iso-8859-8, csISOLatinHebrew, hebrew, ISO_8859-8, ISO_8859-8:1988, ISO-8859-8, iso-ir-138, visual';
			MYSQL_TO_AS3_CHARSET_MAP['tis620'] = 'windows-874, DOS-874, iso-8859-11, TIS-620';
			MYSQL_TO_AS3_CHARSET_MAP['euckr'] = 'ks_c_5601-1987, csKSC56011987, euc-kr, iso-ir-149, korean, ks_c_5601, ks_c_5601_1987, ks_c_5601-1989, KSC_5601, KSC5601';
			MYSQL_TO_AS3_CHARSET_MAP['koi8u'] = 'koi8-u, koi8-ru';
			MYSQL_TO_AS3_CHARSET_MAP['gb2312'] = 'gb2312, chinese, CN-GB, csGB2312, csGB231280, csISO58GB231280, GB_2312-80, GB231280, GB2312-80, GBK, iso-ir-58';
			MYSQL_TO_AS3_CHARSET_MAP['greek'] = 'iso-8859-7, csISOLatinGreek, ECMA-118, ELOT_928, greek, greek8, ISO_8859-7, ISO_8859-7:1987, iso-ir-126';
			MYSQL_TO_AS3_CHARSET_MAP['cp1250'] = 'windows-1250, x-cp1250';
			MYSQL_TO_AS3_CHARSET_MAP['gbk'] = 'gb2312, chinese, CN-GB, csGB2312, csGB231280, csISO58GB231280, GB_2312-80, GB231280, GB2312-80, GBK, iso-ir-58';
			MYSQL_TO_AS3_CHARSET_MAP['latin5'] = 'iso-8859-9, csISO, Latin5, ISO_8859-9, ISO_8859-9:1989, iso-ir-148, l5, latin5';
			MYSQL_TO_AS3_CHARSET_MAP['armscii8'] = null;
			MYSQL_TO_AS3_CHARSET_MAP['utf8'] = 'utf-8';
			MYSQL_TO_AS3_CHARSET_MAP['ucs2'] = 'unicode, utf-16';
			MYSQL_TO_AS3_CHARSET_MAP['cp866'] = 'cp866, ibm866';
			MYSQL_TO_AS3_CHARSET_MAP['keybcs2'] = null;
			MYSQL_TO_AS3_CHARSET_MAP['macce'] = null;
			MYSQL_TO_AS3_CHARSET_MAP['macroman'] = 'us-ascii, ANSI_X3.4-1968, ANSI_X3.4-1986, ascii, cp367, csASCII, IBM367, ISO_646.irv:1991, ISO646-US, iso-ir-6us';
			MYSQL_TO_AS3_CHARSET_MAP['cp852'] = 'ibm852, cp852';
			MYSQL_TO_AS3_CHARSET_MAP['latin7'] = null;
			MYSQL_TO_AS3_CHARSET_MAP['cp1251'] = 'windows-1251, x-cp1251';
			MYSQL_TO_AS3_CHARSET_MAP['cp1256'] = 'windows-1256, cp1256';
			MYSQL_TO_AS3_CHARSET_MAP['cp1257'] = 'windows-1257';
			MYSQL_TO_AS3_CHARSET_MAP['binary'] = 'ascii';
			MYSQL_TO_AS3_CHARSET_MAP['geostd8'] = null;
			MYSQL_TO_AS3_CHARSET_MAP['cp932'] = 'shift_jis, csShiftJIS, csWindows31J, ms_Kanji, shift-jis, x-ms-cp932, x-sjis';
			MYSQL_TO_AS3_CHARSET_MAP['eucjpms'] = 'euc-jp, csEUCPkdFmtJapanese, Extended_UNIX_Code_Packed_Format_for_Japanese, x-euc, x-euc-jp';

			var i:int;
			
			//MAPS MySql CharSet Index To An Actionscript CharSet
			INDEX_TO_CHARSET = new Array(255);
			INDEX_TO_CHARSET[1] = "big5";
			INDEX_TO_CHARSET[2] = "utf-8";
			INDEX_TO_CHARSET[3] = "iso-8859-1";
			INDEX_TO_CHARSET[4] = "iso-8859-1";
			INDEX_TO_CHARSET[5] = "x-IA5-German";
			INDEX_TO_CHARSET[6] = "iso-8859-1";
			INDEX_TO_CHARSET[7] = "koi8-ru";
			INDEX_TO_CHARSET[8] = "latin1";
			INDEX_TO_CHARSET[9] = "latin2";
			INDEX_TO_CHARSET[10] = "iso-8859-1";
			INDEX_TO_CHARSET[11] = "us-ascii";
			INDEX_TO_CHARSET[12] = "shift_jis";
			INDEX_TO_CHARSET[13] = "shift_jis";
			INDEX_TO_CHARSET[14] = "x-cp1251";
			INDEX_TO_CHARSET[15] = "utf-8"; //danish ??
			INDEX_TO_CHARSET[16] = "hebrew";
			INDEX_TO_CHARSET[17] = null; //NOT USED 
			INDEX_TO_CHARSET[18] = "TIS-620";
			INDEX_TO_CHARSET[19] = "euc-kr";
			INDEX_TO_CHARSET[20] = "utf-8"; //estonia ??
			INDEX_TO_CHARSET[21] = "utf-8"; //hungarian ??
			INDEX_TO_CHARSET[22] = "koi8-r";
			INDEX_TO_CHARSET[23] = "windows-1251";
			INDEX_TO_CHARSET[24] = "gb2312";
			INDEX_TO_CHARSET[25] = "greek";
			INDEX_TO_CHARSET[26] = "windows-1250";
			INDEX_TO_CHARSET[27] = "utf-8"; //croat ??
			INDEX_TO_CHARSET[28] = "GBK";
			INDEX_TO_CHARSET[29] = "windows-1257";
			INDEX_TO_CHARSET[30] = "iso-8859-5";
			INDEX_TO_CHARSET[31] = "utf-8"; //latin1_de ??
			INDEX_TO_CHARSET[32] = "iso-8859-1";
			INDEX_TO_CHARSET[33] = "utf-8"; 
			INDEX_TO_CHARSET[34] = "windows-1250"; 
			INDEX_TO_CHARSET[35] = "unicode";
			INDEX_TO_CHARSET[36] = "cp866";
			INDEX_TO_CHARSET[37] = "utf-8"; //Cp895 ??
			INDEX_TO_CHARSET[38] = "utf-8"; //macce ??
			INDEX_TO_CHARSET[39] = "latin1"; //macroman ??
			INDEX_TO_CHARSET[40] = "latin2";
			INDEX_TO_CHARSET[41] = "utf-8"; //latvian ??
			INDEX_TO_CHARSET[42] = "utf-8"; //latvian1 ??
			INDEX_TO_CHARSET[43] = "utf-8"; //macce ??
			INDEX_TO_CHARSET[44] = "utf-8"; //macce ??
			INDEX_TO_CHARSET[45] = "utf-8"; //macce ??
			INDEX_TO_CHARSET[46] = "utf-8"; //macce ??
			INDEX_TO_CHARSET[47] = "latin1";
			INDEX_TO_CHARSET[48] = "latin1";
			INDEX_TO_CHARSET[49] = "latin1";
			INDEX_TO_CHARSET[50] = "windows-1251";
			INDEX_TO_CHARSET[51] = "windows-1251";
			INDEX_TO_CHARSET[52] = "windows-1251";
			INDEX_TO_CHARSET[53] = "latin1"; //macroman ??
			INDEX_TO_CHARSET[54] = "latin1"; //macroman ??
			INDEX_TO_CHARSET[55] = "latin1"; //macroman ??
			INDEX_TO_CHARSET[56] = "latin1"; //macroman ??
			INDEX_TO_CHARSET[57] = "windows-1256";
			INDEX_TO_CHARSET[58] = null; //NOT_USED
			INDEX_TO_CHARSET[59] = null; //NOT_USED
			INDEX_TO_CHARSET[60] = null; //NOT_USED
			INDEX_TO_CHARSET[61] = null; //NOT_USED
			INDEX_TO_CHARSET[62] = null; //NOT_USED
			INDEX_TO_CHARSET[63] = "us-ascii"; 
			INDEX_TO_CHARSET[64] = "iso-8859-2";
			INDEX_TO_CHARSET[65] = "ascii";
			INDEX_TO_CHARSET[66] = "windows-1250";
			INDEX_TO_CHARSET[67] = "windows-1256";
			INDEX_TO_CHARSET[68] = "cp866";
			INDEX_TO_CHARSET[69] = "us-ascii";
			INDEX_TO_CHARSET[70] = "greek";
			INDEX_TO_CHARSET[71] = "hebrew";
			INDEX_TO_CHARSET[72] = "us-ascii";
			INDEX_TO_CHARSET[73] = "utf-8"; //cp895 ??
			INDEX_TO_CHARSET[74] = "koi8-r";
			INDEX_TO_CHARSET[75] = "koi8-r";
			INDEX_TO_CHARSET[76] = null; //NOT_USED
			INDEX_TO_CHARSET[77] = "latin2";
			INDEX_TO_CHARSET[78] = "iso-8859-5";
			INDEX_TO_CHARSET[79] = "iso-8859-7";
			INDEX_TO_CHARSET[80] = "ibm850";
			INDEX_TO_CHARSET[81] = "cp852";
			INDEX_TO_CHARSET[82] = "iso-8859-1";
			INDEX_TO_CHARSET[83] = "utf-8";
			INDEX_TO_CHARSET[84] = "big5";
			INDEX_TO_CHARSET[85] = "euc-kr";
			INDEX_TO_CHARSET[86] = "gb2312";
			INDEX_TO_CHARSET[87] = "gb2312";
			INDEX_TO_CHARSET[88] = "shift_jis";
			INDEX_TO_CHARSET[89] = "TIS-620";
			INDEX_TO_CHARSET[90] = "unicode";
			INDEX_TO_CHARSET[91] = "shift_jis";
			INDEX_TO_CHARSET[92] = "us-ascii";
			INDEX_TO_CHARSET[93] = "us-ascii";
			INDEX_TO_CHARSET[94] = "latin1";
			INDEX_TO_CHARSET[95] = "shift_jis";
			INDEX_TO_CHARSET[96] = "shift_jis";
			INDEX_TO_CHARSET[97] = "utf-8";
			INDEX_TO_CHARSET[98] = "utf-8";
			
			//99-127 not used
			
			for ( i=99; i<= 146; i++ ) {
				INDEX_TO_CHARSET[i] == "unicode";
			}
			
			//147-191 not used
			
			for ( i=191; i<=211; i++ ) {
				INDEX_TO_CHARSET[i] = "utf-8";
			}
			
			INDEX_TO_COLLATION = new Array(211);
			INDEX_TO_COLLATION[1] = "big5_chinese_ci";
			INDEX_TO_COLLATION[2] = "latin2_czech_cs";
			INDEX_TO_COLLATION[3] = "dec8_swedish_ci";
			INDEX_TO_COLLATION[4] = "cp850_general_ci";
			INDEX_TO_COLLATION[5] = "latin1_german1_ci";
			INDEX_TO_COLLATION[6] = "hp8_english_ci";
			INDEX_TO_COLLATION[7] = "koi8r_general_ci";
			INDEX_TO_COLLATION[8] = "latin1_swedish_ci";
			INDEX_TO_COLLATION[9] = "latin2_general_ci";
			INDEX_TO_COLLATION[10] = "swe7_swedish_ci";
			INDEX_TO_COLLATION[11] = "ascii_general_ci";
			INDEX_TO_COLLATION[12] = "ujis_japanese_ci";
			INDEX_TO_COLLATION[13] = "sjis_japanese_ci";
			INDEX_TO_COLLATION[14] = "cp1251_bulgarian_ci";
			INDEX_TO_COLLATION[15] = "latin1_danish_ci";
			INDEX_TO_COLLATION[16] = "hebrew_general_ci";
			INDEX_TO_COLLATION[18] = "tis620_thai_ci";
			INDEX_TO_COLLATION[19] = "euckr_korean_ci";
			INDEX_TO_COLLATION[20] = "latin7_estonian_cs";
			INDEX_TO_COLLATION[21] = "latin2_hungarian_ci";
			INDEX_TO_COLLATION[22] = "koi8u_general_ci";
			INDEX_TO_COLLATION[23] = "cp1251_ukrainian_ci";
			INDEX_TO_COLLATION[24] = "gb2312_chinese_ci";
			INDEX_TO_COLLATION[25] = "greek_general_ci";
			INDEX_TO_COLLATION[26] = "cp1250_general_ci";
			INDEX_TO_COLLATION[27] = "latin2_croatian_ci";
			INDEX_TO_COLLATION[28] = "gbk_chinese_ci";
			INDEX_TO_COLLATION[29] = "cp1257_lithuanian_ci";
			INDEX_TO_COLLATION[30] = "latin5_turkish_ci";
			INDEX_TO_COLLATION[31] = "latin1_german2_ci";
			INDEX_TO_COLLATION[32] = "armscii8_general_ci";
			INDEX_TO_COLLATION[33] = "utf8_general_ci";
			INDEX_TO_COLLATION[34] = "cp1250_czech_cs";
			INDEX_TO_COLLATION[35] = "ucs2_general_ci";
			INDEX_TO_COLLATION[36] = "cp866_general_ci";
			INDEX_TO_COLLATION[37] = "keybcs2_general_ci";
			INDEX_TO_COLLATION[38] = "macce_general_ci";
			INDEX_TO_COLLATION[39] = "macroman_general_ci";
			INDEX_TO_COLLATION[40] = "cp852_general_ci";
			INDEX_TO_COLLATION[41] = "latin7_general_ci";
			INDEX_TO_COLLATION[42] = "latin7_general_cs";
			INDEX_TO_COLLATION[43] = "macce_bin";
			INDEX_TO_COLLATION[44] = "cp1250_croatian_ci";
			INDEX_TO_COLLATION[47] = "latin1_bin";
			INDEX_TO_COLLATION[48] = "latin1_general_ci";
			INDEX_TO_COLLATION[49] = "latin1_general_cs";
			INDEX_TO_COLLATION[50] = "cp1251_bin";
			INDEX_TO_COLLATION[51] = "cp1251_general_ci";
			INDEX_TO_COLLATION[52] = "cp1251_general_cs";
			INDEX_TO_COLLATION[53] = "macroman_bin";
			INDEX_TO_COLLATION[57] = "cp1256_general_ci";
			INDEX_TO_COLLATION[58] = "cp1257_bin";
			INDEX_TO_COLLATION[59] = "cp1257_general_ci";
			INDEX_TO_COLLATION[63] = "binary";
			INDEX_TO_COLLATION[64] = "armscii8_bin";
			INDEX_TO_COLLATION[65] = "ascii_bin";
			INDEX_TO_COLLATION[66] = "cp1250_bin";
			INDEX_TO_COLLATION[67] = "cp1256_bin";
			INDEX_TO_COLLATION[68] = "cp866_bin";
			INDEX_TO_COLLATION[69] = "dec8_bin";
			INDEX_TO_COLLATION[70] = "greek_bin";
			INDEX_TO_COLLATION[71] = "hebrew_bin";
			INDEX_TO_COLLATION[72] = "hp8_bin";
			INDEX_TO_COLLATION[73] = "keybcs2_bin";
			INDEX_TO_COLLATION[74] = "koi8r_bin";
			INDEX_TO_COLLATION[75] = "koi8u_bin";
			INDEX_TO_COLLATION[77] = "latin2_bin";
			INDEX_TO_COLLATION[78] = "latin5_bin";
			INDEX_TO_COLLATION[79] = "latin7_bin";
			INDEX_TO_COLLATION[80] = "cp850_bin";
			INDEX_TO_COLLATION[81] = "cp852_bin";
			INDEX_TO_COLLATION[82] = "swe7_bin";
			INDEX_TO_COLLATION[83] = "utf8_bin";
			INDEX_TO_COLLATION[84] = "big5_bin";
			INDEX_TO_COLLATION[85] = "euckr_bin";
			INDEX_TO_COLLATION[86] = "gb2312_bin";
			INDEX_TO_COLLATION[87] = "gbk_bin";
			INDEX_TO_COLLATION[88] = "sjis_bin";
			INDEX_TO_COLLATION[89] = "tis620_bin";
			INDEX_TO_COLLATION[90] = "ucs2_bin";
			INDEX_TO_COLLATION[91] = "ujis_bin";
			INDEX_TO_COLLATION[92] = "geostd8_general_ci";
			INDEX_TO_COLLATION[93] = "geostd8_bin";
			INDEX_TO_COLLATION[94] = "latin1_spanish_ci";
			INDEX_TO_COLLATION[95] = "cp932_japanese_ci";
			INDEX_TO_COLLATION[96] = "cp932_bin";
			INDEX_TO_COLLATION[97] = "eucjpms_japanese_ci";
			INDEX_TO_COLLATION[98] = "eucjpms_bin";
			INDEX_TO_COLLATION[99] = "cp1250_polish_ci";
			INDEX_TO_COLLATION[128] = "ucs2_unicode_ci";
			INDEX_TO_COLLATION[129] = "ucs2_icelandic_ci";
			INDEX_TO_COLLATION[130] = "ucs2_latvian_ci";
			INDEX_TO_COLLATION[131] = "ucs2_romanian_ci";
			INDEX_TO_COLLATION[132] = "ucs2_slovenian_ci";
			INDEX_TO_COLLATION[133] = "ucs2_polish_ci";
			INDEX_TO_COLLATION[134] = "ucs2_estonian_ci";
			INDEX_TO_COLLATION[135] = "ucs2_spanish_ci";
			INDEX_TO_COLLATION[136] = "ucs2_swedish_ci";
			INDEX_TO_COLLATION[137] = "ucs2_turkish_ci";
			INDEX_TO_COLLATION[138] = "ucs2_czech_ci";
			INDEX_TO_COLLATION[139] = "ucs2_danish_ci";
			INDEX_TO_COLLATION[140] = "ucs2_lithuanian_ci ";
			INDEX_TO_COLLATION[141] = "ucs2_slovak_ci";
			INDEX_TO_COLLATION[142] = "ucs2_spanish2_ci";
			INDEX_TO_COLLATION[143] = "ucs2_roman_ci";
			INDEX_TO_COLLATION[144] = "ucs2_persian_ci";
			INDEX_TO_COLLATION[145] = "ucs2_esperanto_ci";
			INDEX_TO_COLLATION[146] = "ucs2_hungarian_ci";
			INDEX_TO_COLLATION[192] = "utf8_unicode_ci";
			INDEX_TO_COLLATION[193] = "utf8_icelandic_ci";
			INDEX_TO_COLLATION[194] = "utf8_latvian_ci";
			INDEX_TO_COLLATION[195] = "utf8_romanian_ci";
			INDEX_TO_COLLATION[196] = "utf8_slovenian_ci";
			INDEX_TO_COLLATION[197] = "utf8_polish_ci";
			INDEX_TO_COLLATION[198] = "utf8_estonian_ci";
			INDEX_TO_COLLATION[199] = "utf8_spanish_ci";
			INDEX_TO_COLLATION[200] = "utf8_swedish_ci";
			INDEX_TO_COLLATION[201] = "utf8_turkish_ci";
			INDEX_TO_COLLATION[202] = "utf8_czech_ci";
			INDEX_TO_COLLATION[203] = "utf8_danish_ci";
			INDEX_TO_COLLATION[204] = "utf8_lithuanian_ci ";
			INDEX_TO_COLLATION[205] = "utf8_slovak_ci";
			INDEX_TO_COLLATION[206] = "utf8_spanish2_ci";
			INDEX_TO_COLLATION[207] = "utf8_roman_ci";
			INDEX_TO_COLLATION[208] = "utf8_persian_ci";
			INDEX_TO_COLLATION[209] = "utf8_esperanto_ci";
			INDEX_TO_COLLATION[210] = "utf8_hungarian_ci";
		}

	}
}