package cn.wjj.tool
{
	import flash.utils.describeType;
	
	/**
	 * 获取一堆有重复的String里取出单独的字符串
	 * 辅助输出字体的时候使用
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2012-08-02
	 */
	public class StringRepeatGetOnly
	{
		
		private var strOnly:Object;
		
		public function StringRepeatGetOnly()
		{
			strOnly = new Object();
		}
		
		/**
		 * 获取所有已经添加的字符串里的不重复的的内容
		 * @return 
		 * 
		 */
		public function getOnly():String
		{
			var out:String = "";
			for (var temp:String in strOnly) 
			{
				out = out + temp;
			}
			return out;
		}
		
		/**
		 * 添加字符串到这个重复库里
		 * @param str
		 * 
		 */
		public function addString(str:String):void
		{
			if(!str)
			{
				str = "";
			}
			var l:int = str.length;
			var inStr:String;
			for (var i:int = 0; i < l; i++) 
			{
				inStr = str.substr(i, 1);
				if(strOnly.hasOwnProperty(inStr))
				{
					strOnly[inStr] = Number(strOnly[inStr]) + 1;
				}
				else
				{
					strOnly[inStr] = 1;
				}
			}
		}
		
		/**
		 * 添加递归Object里面所有的值,数组一样会被加入
		 * @param addInfo
		 * @param addVars
		 * @param addKey
		 */
		public function addObject(addInfo:Object, addVars:Boolean = true, addKey:Boolean = true):void
		{
			var objInfo:XML;
			var type:String;
			for (var key:String in addInfo)
			{
				if(addKey)
				{
					addString(key);
				}
				if(addVars)
				{
					objInfo = describeType(addInfo[key]);
					type = objInfo.@name.toString();
					switch (type) 
					{
						case "String":
						case "Boolean":
						case "Number":
						case "int":
						case "uint":
							addString(String(addInfo[key]));
							break;
						case "Object":
						case "Array":
							addObject(addInfo[key]);
							break;
						default:
							
					}
				}
			}
		}
		
		/**
		 * 添加字符串到这个重复库里,但是不会累计计数
		 * @param str
		 * 
		 */
		public function addStringNoTotal(str:String):void
		{
			var l:int = str.length;
			var inStr:String;
			for (var i:int = 0; i < l; i++) 
			{
				inStr = str.substr(i, 1);
				if(!strOnly.hasOwnProperty(inStr))
				{
					strOnly[inStr] = 0;
				}
			}
		}
		
		/**
		 * 把0123456789添加的字符串里
		 * 
		 */
		public function addNumber():void
		{
			addStringNoTotal("0123456789");
		}
		
		/**
		 * 添加英文部分的标点符号
		 * 
		 */
		public function addPunctuation():void
		{
			addABCPunctuation();
			addChinaPunctuation();
			addChinaABC();
		}
		
		/**
		 * 添加英文标点符号
		 * 
		 */
		public function addABCPunctuation():void
		{
			addStringNoTotal("\"\\ |^./@?!#$%&+~,-­'¯´`:•;*ˆ¸¿¡˜=<>[](){}‹›");
		}
		
		/**
		 * 添加中文大角标点符号
		 * 
		 */
		public function addChinaPunctuation():void
		{
			addStringNoTotal("　，．、。·…＃＋×＊＝＠＆＄％！？¨：∶；～｜‖︴﹉﹊﹎﹍_＿‐―－—ˉ￣﹏﹋﹌／＼﹨〃＂″々￥＇“”＜＞〈〉［］「」｛｝〔〕『』〖〗《》【】（）‘’ˇ＾");
		}
		
		/**
		 * 把abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ添加的字符串里
		 * 
		 */
		public function addABC():void
		{
			addStringNoTotal("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
		}
		
		/**
		 * 把ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ添加的字符串里
		 * 
		 */
		public function addChinaABC():void
		{
			addStringNoTotal("ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ");
		}
		
		/**
		 * 添加英文音标
		 * 
		 */
		public function addABCPhoneticAlphabet():void
		{
			addStringNoTotal("");
		}
	}
}