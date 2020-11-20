package cn.wjj.tool 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class RegExpStr
	{
		
		/** 全部的屏蔽词 **/
		private static var lib:Vector.<String>;
		
		/**
		 * 添加一个屏蔽词
		 * @param	str
		 */
		public static function addPingBiLib(str:String):void
		{
			
			var l:uint = 0;
			if (lib)
			{
				l = lib.length + 1;
			}
			var temp:Vector.<String> = new Vector.<String>(l);
			var item:String;
			if (lib)
			{
				for each (item in lib) 
				{
					temp.push(item);
				}
			}
			temp.push(str);
		}
		
		/**
		 * 添加一个屏蔽词
		 * @param	str
		 * @param	split
		 */
		public static function addPingBiLibForStr(str:String , split:String):void
		{
			var l:uint = 0;
			if (lib)
			{
				l = lib.length;
			}
			var a:Array = str.split(split);
			var index:int = a.indexOf(" ");
			while (index != -1)
			{
				a.splice(index, 1);
				index = a.indexOf(" ");
			}
			l += a.length;
			var temp:Vector.<String> = new Vector.<String>(l);
			var item:String;
			if (lib)
			{
				for each (item in lib) 
				{
					temp.push(item);
				}
			}
			for each (item in a) 
			{
				temp.push(item);
			}
			lib = temp;
		}
		
		/**
		 * 添加一个屏蔽词
		 * @param	str
		 * @param	split
		 */
		public static function addPingBiLibForArray(a:Array):void
		{
			var l:uint = 0;
			if (lib)
			{
				l = lib.length;
			}
			l += a.length;
			var temp:Vector.<String> = new Vector.<String>(l);
			var item:String;
			if (lib)
			{
				for each (item in lib) 
				{
					temp.push(item);
				}
			}
			for each (item in a) 
			{
				temp.push(item);
			}
			lib = temp;
		}
		
		/**
		 * 查询是否有这个屏蔽词
		 * @param	str
		 * @return
		 */
		public static function PingBi(str:String):Boolean
		{
			for each(var s:String in lib)
			{
				if (str.indexOf(s) != -1)
				{
					return true;
				}
			}
			return false;
		}
	}
}