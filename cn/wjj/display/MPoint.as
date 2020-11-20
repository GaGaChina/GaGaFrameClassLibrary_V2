package cn.wjj.display 
{
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	
	/**
	 * 代替系统Point
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-03-26
	 */
	public class MPoint 
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(100);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		/** X的坐标 **/
		public var x:int = 0;
		/** Y的坐标 **/
		public var y:int = 0;
		
		public function MPoint(x:int = 0, y:int = 0):void
		{
			this.x = x;
			this.y = y;
		}
		
		/** 初始化 MPoint **/
		public static function instance(x:int = 0, y:int = 0):MPoint
		{
			var o:Object = __f.instance();
			if (o)
			{
				o.x = x;
				o.y = y;
				return o as MPoint;
			}
			return new MPoint(x, y);
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.x != 0) this.x = 0;
			if (this.y != 0) this.y = 0;
			__f.recover(this);
		}
	}
}