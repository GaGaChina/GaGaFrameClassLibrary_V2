package cn.wjj.display
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	/**
	 * 强引用一个记录坐标返回显示对象的功能.这里引用的显示对象是强引用
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class PointVarsLib
	{
		/** 弱引用记录显示对象 **/
		private var lib:Object = new Object();
		/** 显示对象列表里子对象的宽度 **/
		private var displayWidth:int;
		/** 显示对象列表里子对象的高度 **/
		private var displayHeight:int;
		/** 设置起始的X坐标 **/
		private var startX:int = 0;
		/** 设置起始的Y坐标 **/
		private var startY:int = 0;
		
		/**
		 * 新建一个显示对象库
		 * @param displayWidth		显示对象列表里子对象的宽度
		 * @param displayHeight		显示对象列表里子对象的高度
		 */
		public function PointVarsLib(displayWidth:int, displayHeight:int)
		{
			this.displayWidth = displayWidth;
			this.displayHeight = displayHeight;
		}
		
		/**
		 * 设置起始的X,Y坐标
		 * @param	startX
		 * @param	startY
		 */
		public function setStartPoint(startX:int, startY:int):void
		{
			this.startX = startX;
			this.startY = startY;
		}
		
		/** 清除记录数据 **/
		public function clear():void
		{
			for (var key:* in lib)
			{
				delete lib[key];
			}
		}
		
		/**
		 * 根据父级的局部坐标来获取到点击的显示对象
		 * @param localX
		 * @param localY
		 * @return 
		 * 
		 */
		public function getVars(localX:Number, localY:Number):*
		{
			localX = localX - startX;
			localY = localY - startY;
			var x:Number, y:Number;
			x = int(Math.floor(localX / displayWidth) * displayWidth);
			y = int(Math.floor(localY / displayHeight) * displayHeight);
			var s:String = "x:" + x + "y:" + y;
			if(lib.hasOwnProperty(s))
			{
				return lib[s];
			}
			return null;
		}
		
		/**
		 * 添加一个未计算好的坐标,并设置触发的值
		 * @param vars
		 * @param localX
		 * @param localY
		 */
		public function pushVars(vars:*, localX:int, localY:int):void
		{
			localX = localX - startX;
			localY = localY - startY;
			var s:String = "x:" + String(localX) + "y:" + String(localY);
			lib[s] = vars;
		}
	}
}