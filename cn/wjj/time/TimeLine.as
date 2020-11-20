package cn.wjj.time 
{
	import cn.wjj.g;
	
	/**
	 * 按时间来运行某一些特定函数的库
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-04-06
	 */
	public class TimeLine 
	{
		/** 时间线全局速度 **/
		public static var globalSpeed:Number = 1;
		/** 是否用addSuperEnterFrame **/
		public static var useSuperEnterFrame:Boolean = true;
		private var lib:Object;
		private var libTime:Vector.<uint>;
		/** 有多少时间 **/
		private var timeLength:uint = 0;
		/** 现在运行的速度,收到全局速度影响 **/
		private var _speed:Number = 1;
		/** 已经运行的毫秒数 **/
		private var runTime:Number = 0;
		/** 上一个运行的时间点 **/
		private var endTime:Number = 0;
		/** 现在运行的时间点 **/
		private var runPoint:Number = 0;
		/** 开始时间 **/
		private var startTime:Number;
		/** 在完毕的时候运行什么函数 **/
		private var complete:Function;
		/** 临时time的时间 **/
		private var st:String;
		/** 是否启用时间线加速 **/
		public var useGlobalSpeed:Boolean = true;
		
		public function TimeLine() 
		{
			lib = new Object();
			libTime = new Vector.<uint>();
		}
		
		/**
		 * 添加一个时间运行的函数
		 * @param time			毫秒,在这个Line开始后的多少毫秒运行
		 * @param method		运行的函数,特定时间只能运行一个相同的函数,重复添加无效
		 */
		public function push(time:uint, method:Function):void
		{
			var list:Vector.<Function>;
			st = String(time);
			if (libTime.indexOf(time) != -1)
			{
				list = lib[st] as Vector.<Function>;
			}
			else
			{
				list = new Vector.<Function>();
				lib[st] = list;
				libTime.push(time);
				libTime.sort(Array.NUMERIC);
				timeLength++;
			}
			if (list.indexOf(method) == -1) list.push(method);
		}
		
		/**
		 * 运行完毕的时候运行什么函数
		 * @param	method
		 */
		public function onComplete(method:Function):void
		{
			complete = method;
		}
		
		/**
		 * 删除一个特定时间,或一个特定时间内的函数
		 * @param	time				毫秒,在这个Line开始后的多少毫秒运行
		 * @param	method		运行的函数,特定时间只能运行一个相同的函数,重复添加无效
		 */
		public function remove(time:uint, method:Function = null):void
		{
			var t:int = libTime.indexOf(time);
			if (t != -1)
			{
				st = String(time);
				var key:int;
				if (method == null)
				{
					delete lib[st];
					libTime.splice(t, 1)
					timeLength--;
				}
				else
				{
					var list:Vector.<Function> = lib[st] as Vector.<Function>;
					var s:int = list.indexOf(method);
					if (s != -1) list.splice(s, 1);
					if(list.length == 0)
					{
						delete lib[st];
						libTime.splice(t, 1)
						timeLength--;
					}
				}
			}
		}
		
		/**
		 * 删除全部
		 */
		public function removeAll():void
		{
			if (timeLength > 0)
			{
				var i:int = timeLength;
				while (--i > -1)
				{
					st = String(libTime[i]);
					delete lib[st];
				}
				libTime.length = 0;
				timeLength = 0;
			}
		}
		
		/** 停止释放资源 **/
		public function dispose():void
		{
			removeAll();
			if (TimeLine.useSuperEnterFrame)
			{
				g.event.removeSuperEnterFrame(run);
			}
			else
			{
				g.event.removeEnterFrame(run);
			}
			complete = null;
		}
		
		/** 开始运行这个队列 **/
		public function start():void
		{
			runTime = 0;
			startTime = g.time.getTime();
			endTime = startTime;
			if (TimeLine.useSuperEnterFrame)
			{
				g.event.addSuperEnterFrame(run);
			}
			else
			{
				g.event.addEnterFrame(run);
			}
		}
		
		/**
		 * 不停的检测
		 */
		private function run():void
		{
			runPoint = new Date().time;
			if (useGlobalSpeed)
			{
				runTime += (runPoint - endTime) * _speed * globalSpeed;
			}
			else
			{
				runTime += (runPoint - endTime) * _speed;
			}
			endTime = runPoint;
			var list:Vector.<Function>;
			var method:Function;
			var a:int = -1;
			while (++a < timeLength)
			{
				runPoint = libTime[a];
				if (runPoint < runTime)
				{
					st = String(runPoint);
					list = lib[st] as Vector.<Function>;
					for each(method in list)
					{
						method();
					}
					delete lib[st];
					list = null;
				}
				else
				{
					if (a > 0) libTime.splice(0, a);
					timeLength = timeLength - a;
					return;
				}
			}
			libTime.length = 0;
			timeLength = 0;
			if (complete != null)
			{
				complete();
			}
			dispose();
		}
		
		/**
		 * 设置这个时间队列的速度,即时启动,即时生效
		 * @param	vars
		 */
		public function speed(vars:Number = 1):void
		{
			this._speed = vars;
		}
		
		/**
		 * 还有多少个对象在
		 */
		public function get runLength():uint
		{
			return this.timeLength;
		}
	}
}