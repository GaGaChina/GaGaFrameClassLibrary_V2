package cn.wjj.display 
{
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	/**
	 * 代替系统Rectangle
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2014-10-18
	 */
	public class MPointRect 
	{
		
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(15);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		/** X的坐标 **/
		public var x1:int = 0;
		/** Y的坐标 **/
		public var y1:int = 0;
		/** 横向长度 **/
		public var x2:int = 0;
		/** 纵向长度 **/
		public var y2:int = 0;
		
		public function MPointRect(x1:int = 0, y1:int = 0, x2:int = 0, y2:int = 0) 
		{
			this.x1 = x1;
			this.y1 = y1;
			this.x2 = x2;
			this.y2 = y2;
		}
		
		/** 初始化 MRectangle **/
		public static function instance(x1:int = 0, y1:int = 0, x2:int = 0, y2:int = 0):MPointRect
		{
			var o:Object = __f.instance();
			if (o)
			{
				o.x1 = x1;
				o.y1 = y1;
				o.x2 = x2;
				o.y2 = y2;
				return o as MPointRect;
			}
			return new MPointRect(x1, y1, x2, y2);
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.x1 != 0) this.x1 = 0;
			if (this.y1 != 0) this.y1 = 0;
			if (this.x2 != 0) this.x2 = 0;
			if (this.y2 != 0) this.y2 = 0;
			__f.recover(this);
		}
	}
}