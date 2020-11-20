package cn.wjj.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * 最mini的修改中心坐标点Bitmap
	 */
	public class MinBitmapSprite extends Bitmap
	{
		/** x轴偏移 **/
		public var ox:Number = 0;
		/** y轴偏移 **/
		public var oy:Number = 0;
		
		/** 记录对外的值 **/
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _rotation:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		
		/** 偏离中心点的角度(弧度),添加缩放比例的 **/
		private var offsetAngle:Number = 0;
		/** 偏离中心点的长度,添加缩放比例的 **/
		private var offsetLength:Number = 0;
		
		/**
		 * 继承于Bitmap的对象
		 * @param	bitmapData
		 * @param	pixelSnapping
		 * @param	smoothing
		 */
		public function MinBitmapSprite(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):void
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		/**
		 * 重新设置坐标
		 * @param	ox
		 * @param	oy
		 * @param	data
		 */
		public function setData(ox:Number, oy:Number, data:BitmapData):void
		{
			this.bitmapData = data;
			this.ox = ox;
			this.oy = oy;
			offsetAngleCount();
		}
		
		//----------------------------------------------------覆盖的方法-----------------------------------------------------
		override public function get x():Number { return _x; }
		override public function set x(value:Number):void { if (_x != value) { _x = value; offsetCount(); }}
		override public function get y():Number { return _y; }
		override public function set y(value:Number):void { if (_y != value) { _y = value; offsetCount(); }}
		override public function set rotation(value:Number):void { if (_rotation != value) { _rotation = value; offsetCount(); }}
		override public function set scaleX(value:Number):void { if (_scaleX != value) { _scaleX = value; offsetCount(); }}
		override public function set scaleY(value:Number):void { if (_scaleY != value) { _scaleY = value; offsetCount(); }}
		
		/** 根据偏移量算出角度 **/
		private function offsetAngleCount():void
		{
			offsetAngle = 0;
			offsetLength = 0;
			if (ox != 0 && oy != 0)
			{
				offsetLength = Math.sqrt(ox * ox + oy * oy);
				offsetAngle = Math.atan2( -oy, -ox);
			}
			else if (ox == 0 && oy == 0) { }
			else if (ox == 0)
			{
				offsetAngle = 2 * Math.PI;
				offsetLength = oy;
			}
			else if (oy == 0)
			{
				offsetAngle = 0;
				offsetLength = ox;
			}
			offsetCount();
		}
		
		public function offsetCount():void
		{
			var tr:Number = _rotation % 360;
			if (tr < 0) tr += 360;
			var tx:Number = _x;
			var ty:Number = _y;
			if (tr == 0)
			{
				if (ox != 0) tx += ox * _scaleX;
				if (oy != 0) ty += oy * _scaleY;
			}
			else if (tr == 90)
			{
				if (ox != 0) ty += ox * _scaleX;
				if (oy != 0) tx -= oy * _scaleY;
			}
			else if (tr == 270)
			{
				if (ox != 0) ty -= ox * _scaleX;
				if (oy != 0) tx += oy * _scaleY;
			}
			else
			{
				if (ox != 0 && oy != 0)
				{
					var tempAngle:Number = tr / 180 * Math.PI + offsetAngle;
					tx -= Math.cos(tempAngle) * offsetLength * _scaleX;
					ty -= Math.sin(tempAngle) * offsetLength * _scaleY;
				}
			}
			if (super.rotation != tr) super.rotation = tr;
			if (super.scaleX != _scaleX) super.scaleX = _scaleX;
			if (super.scaleY != _scaleY) super.scaleY = _scaleY;
			if (super.x != tx) super.x = tx;
			if (super.y != ty) super.y = ty;
		}
		
	}
}