package cn.wjj.tool 
{
	import flash.utils.Dictionary;
	
	/**
	 * 工厂管理类
	 * 被本工厂回收的对象可能会被系统回收掉
	 * 创建的对象不会自动进入工程类的库中,需要用户自己回收的同时调用addRecover方法,加入到这个库里
	 * 下一次取的时候会优先把回收的对象先取出.
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-03-14
	 */
	public class EasyFactory 
	{
		private static var lib:Object = new Object();
		
		/**
		 * 获取一个对象
		 * @param	prototype	类的原型
		 * @return
		 */
		public static function getInstance(prototype:Class):*
		{
			var d:Dictionary;
			var o:*;
			if (lib.hasOwnProperty(prototype))
			{
				m = lib[prototype] as Dictionary;
				for (o in d)
				{
					delete d[o];
					return o;
				}
			}
			o = new prototype();
			return o;
		}
		
		/**
		 * 回收一个对象
		 * @param	prototype	类的原型
		 * @param	o
		 */
		public static function addRecover(prototype:Class, o:*):void
		{
			var d:Dictionary;
			if (lib.hasOwnProperty(prototype))
			{
				d = lib[prototype] as Dictionary;
			}
			else
			{
				d = new Dictionary(true);
				lib[prototype] = d;
			}
			d[o] = "";
		}
	}
}