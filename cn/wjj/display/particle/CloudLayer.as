package cn.wjj.display.particle
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import cn.wjj.g;
	
	/**
	 * 云层特效
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-08-09
	 */
	public class CloudLayer extends Sprite 
	{
		
		/** 礼花的范围,宽度 **/
		private var _filterWidth:Number;
		/** 礼花的范围,高度 **/
		private var _filterHeight:Number;
		/** 云块精细度 **/
		private var fine:int;
		/** 随机种子数 **/
		private var randomNum:int;
		/** 平滑过度 **/
		private var stitch:Boolean;
		/** 全局碎片覆盖 **/
		private var noise:Boolean;
		
		/** 是否自动更新UI画面, **/
		private var _autoUpdateUI:Boolean;
		/** 粒子所在的Bitmap **/
		private var myBitmap:Bitmap;
		private var offsetPoint:Array;
		
		/**
		 * 创建一个云层,在哪里飘啊飘
		 * @param	filterWidth		云层的宽度
		 * @param	filterHeight	云层的高度
		 * @param	fine			云块精细度
		 * @param	randomNum		随机种子数
		 * @param	stitch			平滑过度
		 * @param	noise			全局碎片覆盖
		 * @param	autoUpdateUI	是否自动更新UI画面
		 */
		public function CloudLayer(filterWidth:Number, filterHeight:Number, fine:int = 4, randomNum:int = 2, stitch:Boolean = false, noise:Boolean = false, autoUpdateUI:Boolean = true):void
		{
			reSet(filterWidth, filterHeight, fine, randomNum, stitch, noise, autoUpdateUI);
			offsetPoint = new Array();
			offsetPoint.x = 0;
			offsetPoint.y = 0;
		}
		
		/**
		 * 创建一个云层,在哪里飘啊飘
		 * @param	filterWidth		云层的宽度
		 * @param	filterHeight	云层的高度
		 * @param	fine			云块精细度
		 * @param	randomNum		随机种子数
		 * @param	stitch			平滑过度
		 * @param	noise			全局碎片覆盖
		 * @param	autoUpdateUI	是否自动更新UI画面
		 */
		public function reSet(filterWidth:Number, filterHeight:Number, fine:int = 4, randomNum:int = 2, stitch:Boolean = false, noise:Boolean = false, autoUpdateUI:Boolean = true):void
		{
			this.visible = false;
			_filterWidth = filterWidth;
			_filterHeight = filterHeight;
			_autoUpdateUI = autoUpdateUI;
			this.fine = fine;
			this.randomNum = randomNum;
			this.stitch = stitch;
			this.noise = noise;
			stop();
			if (myBitmap) {
				if (this.contains(myBitmap)) {
					this.removeChild(myBitmap);
				}
				myBitmap = null;
			}
			myBitmap = new Bitmap(new BitmapData(_filterWidth, _filterHeight, true, 0xFFFFFFFF));
			myBitmap.smoothing = true;
			this.addChild(myBitmap);
		}
		
		/** 以FPS为30的速度开始运行这个云层 **/
		public function start():void
		{
			g.event.addFPSEnterFrame(15, enterFrame, _autoUpdateUI);
		}
		
		/** 停止运行礼花 **/
		public function stop():void
		{
			g.event.removeFPSEnterFrame(15, enterFrame);
		}
		
		/** 摧毁云层对象 **/
		public function dispose():void
		{
			stop();
		}
		
		private function enterFrame():void
		{
			offsetPoint.x = offsetPoint.x - 20;
			myBitmap.bitmapData.perlinNoise(_filterWidth, _filterHeight, fine, randomNum, stitch, noise, 8, true, offsetPoint);
			myBitmap.bitmapData.colorTransform(myBitmap.bitmapData.rect, new ColorTransform(0, 0, 0, 1, 225, 225, 225, 0));
			if (this.visible == false)
			{
				this.visible = true;
			}
		}
	}
}