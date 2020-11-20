package cn.wjj.display
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	/**
	 * 一个记录坐标返回显示对象的功能.这里引用的显示对象是弱引用
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class PointDisplayLib
	{
		/** 弱引用记录显示对象 **/
		private var lib:Dictionary = new Dictionary(true);
		/** 显示对象列表里子对象的宽度 **/
		private var _displayWidth:int;
		/** 显示对象列表里子对象的高度 **/
		private var _displayHeight:int;
		
		/**
		 * 新建一个显示对象库
		 * @param displayWidth		显示对象列表里子对象的宽度
		 * @param displayHeight		显示对象列表里子对象的高度
		 */
		public function PointDisplayLib(displayWidth:int, displayHeight:int)
		{
			this._displayWidth = displayWidth;
			this._displayHeight = displayHeight;
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
		public function getDisplay(localX:Number, localY:Number):DisplayObject
		{
			var x:Number, y:Number;
			x = int(Math.floor(localX / displayWidth) * displayWidth);
			y = int(Math.floor(localY / displayHeight) * displayHeight);
			var s:String = "x:" + x + "y:" + y;
			for (var key:* in lib)
			{
				if (lib[key] == s)
				{
					return key as DisplayObject;
				}
			}
			return null;
		}
		
		/** 获取里面全部的显示对象 **/
		public function getAllDisplay():Vector.<DisplayObject>
		{
			var o:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for (var key:* in lib) 
			{
				if(key is DisplayObject)
				{
					o.push(key as DisplayObject);
				}
			}
			return o;
		}
		
		/**
		 * 添加一个显示对象,并设置触发坐标
		 * @param display
		 * @param localX
		 * @param localY
		 */
		public function pushDisplay(display:DisplayObject, localX:int, localY:int):void
		{
			lib[display] = "x:" + String(localX) + "y:" + String(localY);
		}
		
		/**
		 * 清理所有记录的数据,并遍历子对象,获取全部子对象的坐标
		 * @param displayContainer
		 * 
		 */
		public function getAllDisplayXY(container:DisplayObjectContainer):void
		{
			clear();
			var l:Number = container.numChildren;
			var d:DisplayObject;
			for (var i:int = 0; i < l; i++)
			{
				d = container.getChildAt(i);
				lib[d] = "x:" + String(uint(Math.floor(d.x))) + "y:" + String(uint(Math.floor(d.y)));
			}
		}
		
		public function get displayWidth():int 
		{
			return _displayWidth;
		}
		
		public function get displayHeight():int 
		{
			return _displayHeight;
		}
	}
}