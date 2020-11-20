package cn.wjj.display.particle.gaga
{
	import cn.wjj.g;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * 粒子效果
	 * @author GaGa
	 */
	public class Particle 
	{
		/** 粒子效果的属性 **/
		public var info:Object;
		/** 粒子渲染的尺寸 **/
		public var width:Number = 0;
		/** 粒子渲染的尺寸 **/
		public var height:Number = 0;
		/** 粒子层总共有多少幀 **/
		public var totalFrames:int = 120;
		/** 粒子层播放到多少幀 **/
		public var currentFrame:int = 1;
		/** 粒子层的FPS是多少 **/
		public var fps:int = 30;
		/** 绘制的位图 **/
		public var bitmap:Bitmap;
		/** 绘制的位图数据 **/
		public var bitmapData:BitmapData;
		/** 所有图层的列表 **/
		public var layerLib:Vector.<Layer>;
		
		/** 粒子发射器 **/
		public var emitter:Emitter;
		
		public function Particle():void
		{
			emitter = new Emitter();
		}
		
		public function init():void
		{
			bitmapData = new BitmapData(width, height);
			bitmap = new Bitmap(bitmapData);
			layerLib = new Vector.<Layer>;
			var layer:Layer = new Layer();
			layer.particle = this;
			layer.isSelfData = false;
			layer.granuleDispaly = redBall;
			layer.maxParticles = 100;
			layer.rotation = 5;
			layer.init();
			layerLib.push(layer);
			g.event.addFPSEnterFrame(fps, draw);
		}
		
		public function draw():void
		{
			bitmapData.lock();
			clear();
			var l:int = layerLib.length;
			for each (var item:Layer in layerLib) 
			{
				if (item.isSelfData)
				{
					bitmapData.draw(item.getBitmapData());
				}
				else
				{
					item.draw();
				}
			}
			bitmapData.unlock();
			//g.log.pushLog(this, g.logType._UserAction, "Particle - draw");
		}
		
		public function clear():void
		{
			var w:uint = bitmapData.width;
			var h:uint = bitmapData.height;
			var x:uint = 0;
			var y:uint = 0;
			for (x = 0; x < w; x++) 
			{
				for (y = 0; y < h; y++) 
				{
					bitmapData.setPixel32(x, y, 0x00000000);
				}
			} 
		}
		
		/** 销毁对象，释放资源 **/
		public function dispose():void
		{
			g.event.removeFPSEnterFrame(fps, draw);
			bitmapData.dispose();
			bitmap = null;
			var l:int = layerLib.length;
			var layer:Layer;
			while (l)
			{
				layer = layerLib.shift() as Layer;
				layer.dispose();
				l--;
			}
		}
	}
}