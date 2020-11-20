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
	public class MRectangle 
	{
		
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(10);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		/** X的坐标 **/
		public var x:int = 0;
		/** Y的坐标 **/
		public var y:int = 0;
		/** 横向长度 **/
		public var width:int = 0;
		/** 纵向长度 **/
		public var height:int = 0;
		
		public function MRectangle(x:int = 0, y:int = 0, width:int = 0, height:int = 0) 
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		/** 初始化 MRectangle **/
		public static function instance(x:int = 0, y:int = 0, width:int = 0, height:int = 0):MRectangle
		{
			var o:Object = __f.instance();
			if (o)
			{
				o.x = x;
				o.y = y;
				o.width = width;
				o.height = height;
				return o as MRectangle;
			}
			return new MRectangle(x, y, width, height);
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.x != 0) this.x = 0;
			if (this.y != 0) this.y = 0;
			if (this.width != 0) this.width = 0;
			if (this.height != 0) this.height = 0;
			__f.recover(this);
		}
	}
}