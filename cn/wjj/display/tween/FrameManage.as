package cn.wjj.display.tween 
{
	import cn.wjj.g;
	import cn.wjj.time.TimePointRun;
	
	/**
	 * 提供性能分配的功能
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-05-17
	 */
	public class FrameManage 
	{
		/** 运行的函数 **/
		private static var lib_f:Vector.<Function> = new Vector.<Function>();
		/** 运行的时间 **/
		private static var lib_t:Vector.<uint> = new Vector.<uint>();
		/** 有多少运行的内容 **/
		private static var length:uint = 0;
		private static var n:uint;
		public function FrameManage() {}
		
		/**
		 * 提出一个函数的运行
		 * @param	f		要结束的函数
		 */
		public static function killOf(f:Function):void
		{
			var index:int = lib_f.indexOf(f);
			if(index != -1)
			{
				lib_f.splice(index, 1);
				length--;
				if (length == 0) g.event.removeEnterFrame(run);
			}
		}
		
		/**
		 * 砍掉全部的
		 */
		public static function killAll(complete:Boolean = false):void
		{
			lib_f.length = 0;
			lib_t.length = 0;
			length = 0;
			g.event.removeEnterFrame(run);
		}
		
		/**
		 * 添加一个缓动播放动画
		 * @param	f			运行的函数
		 * @param	time		多少幀后执行
		 */
		public static function append(f:Function, time:uint = 0):void
		{
			if(time == 0)
			{
				f();
				return;
			}
			var index:int = lib_f.indexOf(f);
			if(index == -1)
			{
				lib_f.push(f);
				lib_t.push(time);
				length++;
				if (length == 1) g.event.addEnterFrame(run);
			}
		}
		
		private static function run():void
		{
			var i:int = length;
			var tempF:Function;
			while(--i > -1)
			{
				if(i < length)
				{
					n = lib_t[i];
					n--;
					if (n < 1)
					{
						tempF = lib_f[i];
						lib_f.splice(i, 1);
						lib_t.splice(i, 1);
						length--;
						tempF();
					}
					else
					{
						lib_t[i] = n;
					}
				}
				else
				{
					i--;
				}
			}
			if(length == 0)
			{
				g.event.removeEnterFrame(run);
			}
		}
		
		/** 是否还有在运行的部分 **/
		public static function hasRun():Boolean
		{
			if(length == 0)
			{
				return false;
			}
			return true;
		}
	}
}