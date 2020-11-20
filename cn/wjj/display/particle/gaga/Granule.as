package cn.wjj.display.particle.gaga
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import cn.wjj.g;
	
	/**
	 * 粒子颗粒现在的状态
	 * @author GaGa
	 */
	public class Granule 
	{
		/** 所调用的图层 **/
		public var layer:Layer;
		/** 这个粒子的角度 **/
		public var rotation:Number = 0;
		/** 现在粒子的速度 **/
		public var speed:Number = 0;
		/** 现在粒子的生命 **/
		public var life:Number = 0;
		
		public var display:Sprite;
		
		public function Granule() 
		{
			
		}
		
		public function init():void
		{
			display = new Sprite();
			var child:DisplayObject;
			if (layer.granuleDispaly is Class)
			{
				var c:Class = layer.granuleDispaly as Class;
				if(c is BitmapData)
				{
					child = new Bitmap(layer.granuleDispaly) as DisplayObject;
				}
				else
				{
					var temp:* = new c();
					if(temp is BitmapData)
					{
						child = new Bitmap(temp) as DisplayObject;
					}
					else
					{
						child = temp;
					}
				}
			}
			//g.log.pushLog(this, g.logType._ErrorLog, "缺少类型 : " + layer.granuleDispaly);
			child.x = -layer.pDotX;
			child.y = -layer.pDotY;
			display.addChild(child);
			display.scaleX = layer.scaleX;
			display.scaleY = layer.scaleY;
		}
		
		/**
		 * 绘制粒子的位图效果
		 * @return
		 */
		public function draw():void
		{
			
			var child:DisplayObject = display.getChildAt(0);
			child.rotation += layer.rotation;
			child.x += Math.floor(Math.random() * 20);
			child.y += Math.floor(Math.random() * 20);
			//var rect:Rectangle = new Rectangle(display.x, display.y, display.width, display.height);
			layer.bitmapData.draw(display);
		}
		
		/** 销毁对象，释放资源 **/
		public function dispose():void{
			layer = null;
			if (display)
			{
				while (display.numChildren) 
				{
					display.removeChildAt(0);
				}
				display = null;
			}
		}
	}
}