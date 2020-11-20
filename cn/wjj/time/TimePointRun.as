package cn.wjj.time 
{
	import cn.wjj.g;
	
	/**
	 * 到时间的一个特定点,运行某一个特定函数
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-04-06
	 */
	public class TimePointRun
	{
		
		private static var lib:Object = new Object();
		/** 是否用addSuperEnterFrame **/
		public static var useSuperEnterFrame:Boolean = true;
		/** 现在运行的时间 **/
		private static var t:Number;
		/** 是否已经添加过监听 **/
		private static var isEvent:Boolean = false;
		
		/**
		 * 添加一个延后多少时间运行的函数
		 * @param	offset		(毫秒)
		 * @param	method
		 */
		public static function addOffset(offset:Number, method:Function):void
		{
			var time:Number = g.time.getTime() + offset;
			add(time, method);
		}
		
		/**
		 * 添加一个特定时间点运行的函数
		 * @param	time		(毫秒)
		 * @param	run
		 */
		public static function add(time:Number, method:Function):void
		{
			if (time < g.time.getTime())
			{
				method();
			}
			else
			{
				var list:Vector.<Function>;
				if (lib.hasOwnProperty(time))
				{
					list = lib[time] as Vector.<Function>;
				}
				else
				{
					list = new Vector.<Function>();
					lib[time] = list;
				}
				list.push(method);
				if(isEvent == false)
				{
					isEvent = true;
					if (useSuperEnterFrame)
					{
						g.event.addSuperEnterFrame(run);
					}
					else
					{
						g.event.addEnterFrame(run);
					}
				}
			}
		}
		
		private static function run():void
		{
			t = g.time.getTime();
			var list:Vector.<Function>;
			var method:Function;
			var has:Boolean = false;
			for (var key:String in lib) 
			{
				if (Number(key) < t)
				{
					list = lib[key] as Vector.<Function>;
					while (list.length) 
					{
						method = list.shift();
						method();
					}
					delete lib[key];
				}
				else
				{
					has = true;
				}
			}
			if (!has)
			{
				if(isEvent)
				{
					isEvent = false;
					if (useSuperEnterFrame)
					{
						g.event.removeSuperEnterFrame(run);
					}
					else
					{
						g.event.removeEnterFrame(run);
					}
				}
			}
		}
		
		/** 释放所有未完成的项目 **/
		public static function dispose():void
		{
			lib = new Object();
			if(isEvent)
			{
				isEvent = false;
				if (useSuperEnterFrame)
				{
					g.event.removeSuperEnterFrame(run);
				}
				else
				{
					g.event.removeEnterFrame(run);
				}
			}
		}
	}

}