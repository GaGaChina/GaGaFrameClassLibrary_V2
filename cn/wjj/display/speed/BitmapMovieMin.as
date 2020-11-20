package cn.wjj.display.speed
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class BitmapMovieMin extends Bitmap
	{
		/** 播放的帧频 **/
		private var fps:uint = 0;
		
		private var i:uint = 0;
		private var mc:MovieClip;
		private var id:uint = 0;
		private var arr_x:Array = new Array();
		private var arr_y:Array = new Array();
		private var arr_bitmap:Array = new Array();
		
		/**
		 * 没有框架引入的类,MIN的形
		 * @param	bitmapdata		播放数据的引用
		 * @param	fps				播放的fps
		 */
		public function BitmapMovieMin():void{}
		
		/**
		 * 添加一个帧动画
		 * @param	x
		 * @param	y
		 * @param	bitmap
		 */
		public function pushFrame(frame:uint, x:int, y:int, bitmap:BitmapData):void
		{
			arr_x[frame] = x;
			arr_y[frame] = y;
			arr_bitmap[frame] = bitmap;
		}
		
		/**
		 * 按fps循环播放
		 * @param	fps
		 */
		public function play(fps:uint):void
		{
			this.fps = fps;
			if (mc == null)
			{
				mc = new MovieClip();
			}
			mc.addEventListener(Event.ENTER_FRAME, run);
			this.bitmapData = arr_bitmap[id];
			x = x;
			y = y;
		}
		
		private function run(e:Event):void
		{
			i++;
			if (i % fps == 0)
			{
				id++;
				if (id >= arr_x.length) id = 0;
				this.bitmapData = arr_bitmap[id];
				x = x;
				y = y;
			}
		}
		
		override public function get x():Number 
		{
			if (arr_x.length > id)
			{
				return super.x - arr_x[id] * super.scaleX;
			}
			return super.x
		}
		
		override public function set x(value:Number):void 
		{
			if (arr_x.length > id)
			{
				value = value + arr_x[id] * super.scaleX;
			}
			if (super.x != value) super.x = value;
		}
		
		override public function get y():Number 
		{
			if (arr_y.length > id)
			{
				return super.y - arr_y[id] * super.scaleY;
			}
			return super.y
		}
		
		override public function set y(value:Number):void 
		{
			if (arr_y.length > id)
			{
				value = value + arr_y[id] * super.scaleY;
			}
			if(super.y != value) super.y = value;
		}
		
		//----------------------------------------------------一些其他的方法---------------------------------------------------
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (mc)
			{
				if (mc.hasEventListener(Event.ENTER_FRAME))
				{
					mc.removeEventListener(Event.ENTER_FRAME, run);
				}
				mc = null;
			}
			arr_x.length = 0;
			arr_y.length = 0;
			arr_bitmap.length = 0;
		}
	}
}