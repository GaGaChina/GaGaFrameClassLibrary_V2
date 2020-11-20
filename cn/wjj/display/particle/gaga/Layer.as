package cn.wjj.display.particle.gaga
{
	import cn.wjj.display.particle.gaga.Granule;
	import cn.wjj.display.particle.gaga.Particle;
	import flash.display.BitmapData;
	import cn.wjj.g;
	/**
	 * 粒子的图层
	 * @author GaGa
	 */
	public class Layer 
	{
		/** 粒子所在的粒子对象 **/
		public var particle:Particle;
		/** 是否使用自己独立的bitmapData,这样会开销更多的内容 **/
		public var isSelfData:Boolean = false;
		/** 这个粒子效果的图层 **/
		private var _bitmapData:BitmapData;
		/** 位图是否更新 **/
		public var dataIsChange:Boolean = true;
		/** 粒子层总共有多少幀 **/
		public var totalFrames:int = 120;
		/** 粒子层播放到多少幀 **/
		public var currentFrame:int = 1;
		/** 粒子层的FPS是多少 **/
		public var fps:int = 30;
		/** 所有的粒子所在的图层 **/
		public var granuleLib:Vector.<Granule>;
		
		/** 粒子的生命 **/
		public var lifeSpan:Number = 0;
		/** 粒子的数量 **/
		public var maxParticles:Number = 0;
		/** 粒子的速度 **/
		public var speed:Number = 0;
		/** 粒子的重力 **/
		public var gracity:Number = 0;
		/** 粒子的角度 **/
		public var rotation:Number = 0;
		
		
		/** 粒子调用的图元素,BitmapData,Sprite,MovieClip **/
		public var granuleDispaly:*;
		/** 粒子调用的图的中心X坐标 **/
		public var pDotX:Number = 0;
		/** 粒子调用的图的中心Y坐标 **/
		public var pDotY:Number = 0;
		/** 粒子的横向比例 **/
		public var scaleX:Number = 1;
		/** 粒子的纵向比例 **/
		public var scaleY:Number = 1;
		
		public function Layer() 
		{
			
		}
		
		public function get bitmapData():BitmapData 
		{
			if (isSelfData)
			{
				if (!_bitmapData)
				{
					bitmapData = new BitmapData(this.particle.width, this.particle.height);
				}
				return _bitmapData;
			}else {
				return particle.bitmapData;
			}
		}
		
		public function set bitmapData(value:BitmapData):void 
		{
			_bitmapData = value;
		}
		
		/**
		 * 设置完这个图层后初始化
		 */
		public function init():void
		{
			granuleLib = new Vector.<Granule>;
			var granule:Granule;
			for (var i:int = 0; i < maxParticles; i++) 
			{
				granule = new Granule();
				granule.layer = this;
				granule.init();
				granuleLib.push(granule);
			}
		}
		
		/**
		 * 绘制粒子的位图效果
		 * @return
		 */
		public function draw():void
		{
			for each (var item:Granule in granuleLib) 
			{
				item.draw();
			}
		}
		
		/** 获取这个图层的位图 **/
		public function getBitmapData():BitmapData
		{
			bitmapData.lock();
			for each (var item:Granule in granuleLib) 
			{
				item.draw();
			}
			bitmapData.unlock();
			return bitmapData;
		}
		
		/** 销毁对象，释放资源 **/
		public function dispose():void{
			particle = null;
			
			var l:int = granuleLib.length;
			var granule:Granule;
			while (l)
			{
				granule = granuleLib.shift() as Granule;
				granule.dispose();
				l--;
			}
		}
	}
}