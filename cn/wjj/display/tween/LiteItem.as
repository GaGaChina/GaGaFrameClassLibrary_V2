package cn.wjj.display.tween 
{
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	
	/**
	 * 辅助,TweenLite,代替TimelineLite使用
	 * @author GaGa
	 */
	public class LiteItem
	{
		/** (单位:秒)缓动的时候 **/
		public var t:Number = 0;
		/** (单位:秒)原始延迟时间+偏移时间,会动态改变info的时间,所以就要记录原始时间 **/
		public var delay:Number = 0;
		/** 缓动的信息 **/
		public var info:Object;
		/** 完成执行的函数 **/
		public var complete:Function;
		
		public function LiteItem():void { }
		
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(50);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint { return __f.length; }
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		
		public static function instance():LiteItem
		{
			var o:LiteItem = __f.instance() as LiteItem;
			if (!o)
			{
				o = new LiteItem();
			}
			return o;
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.t != 0) this.t = 0;
			if (this.delay != 0) this.delay = 0;
			if (this.info  != null) this.info  = null;
			if (this.complete  != null) this.complete  = null;
			__f.recover(this);
		}
	}
}