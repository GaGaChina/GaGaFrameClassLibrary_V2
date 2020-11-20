package cn.wjj.display.speed 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * 九宫格对象
	 * 1 2 3
	 * 4 5 6
	 * 7 8 9
	 * @author GaGa
	 */
	public class SudokuSprite extends Sprite
	{
		/** 九宫格对象 **/
		private var display:Object;
		/** 九宫格数据,Type:Bitmap,Shape,  BitmapData,scaleX,scaleY,rotation,autoRect,width,height **/
		private var info:Object;
		/** 九宫格类型 **/
		private var type:int = 0;
		/** 宽度 **/
		private var _width:Number = 0;
		/** 高度 **/
		private var _height:Number = 0;
		
		/**
		 * 九宫格类型, 9个
		 * 1 2 3
		 * 4 5 6
		 * 7 8 9
		 */
		public static const Type9:int = 9;
		
		/**
		 * 九宫格类型, 3个,垂直缩放
		 * 1 2 3
		 */
		public static const Type3:int = 3;
		
		public static const DisplayBitamp:int = 1;
		public static const DisplayShape:int = 2;
		
		public function SudokuSprite():void
		{
			display = new Object();
		}
		
		/**
		 * 设置
		 * @param	o
		 */
		public function setInfo(o:Object):void
		{
			this.type = o.type;
			this.info = o.info;
			show();
		}
		
		/**
		 * 获取用户信息
		 * @return
		 */
		public function getInfo():Object
		{
			var i:int;
			if (info)
			{
				switch (info.type) 
				{
					case SudokuSprite.Type9:
						i = 0;
						while (++i < 10)
						{
							showDisplay(i, info.display["c" + i]);
						}
						break;
					default:
				}
			}
		}
		
		private function showDisplay(i:int, o:Object):void
		{
			var d:DisplayObject;
			switch (o.type) 
			{
				case SudokuSprite.DisplayBitamp:
					
					if (o.rotation % 360 != 0)
					{
						d = new Bitmap(o.bitmapData);
					}
					else
					{
						var item:BitmapDataItem = BitmapDataItem.instance();
						item.bitmapData = o.bitmapData;
						switch (d.rotation) 
						{
							case 90:
								item.x = -d.height;
								item.y = 0;
								break;
							case 180:
								d.x = -d.width;
								d.y = -d.height;
								break;
							case 270:
								d.x = 0;
								d.y = -d.width;
								break;
							default:
						}
						d = BitmapSprite.instance(item);
					}
					d.rotation = o.rotation;
					display["d" + i] = d;
					d.scaleX = o.scaleX;
					d.scaleY = o.scaleY;
					break;
				default:
			}
			if (d) this.addChild(d);
			width = width;
			height = height;
		}
		
		/**
		 * 根据数据,刷新显示对象
		 * @return
		 */
		public function show():Object
		{
			switch (type) 
			{
				case SudokuSprite.Type9:
					showInThis(display.d1, 1);
					showInThis(display.d3, 3);
					showInThis(display.d7, 7);
					showInThis(display.d9, 9);
					showInThis(display.d2, 2);
					showInThis(display.d4, 4);
					showInThis(display.d6, 6);
					showInThis(display.d8, 8);
					showInThis(display.d5, 5);
					break;
				default:
			}
		}
		
		/**
		 * 把这个对象置入九宫格的什么方位,
		 * @param	d
		 * @param	site
		 */
		private function showInThis(d:DisplayObject, site:int):void
		{
			switch (site) 
			{
				case 1:
					d.x = 0;
					d.y = 0;
					break;
				case 2:
					d.width = width - display.d1.width - display.d3.width;
					d.x = d.width;
					d.y = 0;
					break;
				case 3:
					d.x = _width - d.width;
					d.y = 0;
					break;
				case 4:
					d.height = height - display.d1.height - display.d7.height;
					d.x = display.d1.height;
					d.y = 0;
					break;
				case 5:
					d.width = display.d2.width;
					d.height = display.d2.height;
					d.x = display.d1.width;
					d.y = display.d1.height;
					break;
				case 6:
					break;
				case 7:
					d.x = 0;
					d.y = _height - d.height;
					break;
				case 8:
					break;
				case 9:
					d.x = _width - d.width;
					d.y = _height - d.height;
					break;
				default:
			}

		}
		
		override public function get width():Number 
		{
			return _width;
		}
		
		override public function set width(value:Number):void 
		{
			_width = value;
			show();
		}
		
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function set height(value:Number):void 
		{
			_height = value;
			show();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (o.type  != 0) o.type  = 0;
			if (o.info  != null) o.info  = null;
			if (o.display  != null) o.display  = null;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}