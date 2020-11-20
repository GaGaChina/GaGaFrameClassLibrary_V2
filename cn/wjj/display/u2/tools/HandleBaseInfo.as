package cn.wjj.display.u2.tools 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import cn.wjj.g;
	import cn.wjj.display.ui2d.IU2Base;
	import cn.wjj.display.ui2d.U2Timer;
	import cn.wjj.display.ui2d.engine.EngineInfo;
	import cn.wjj.display.ui2d.engine.EngineLayer;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;

	/**
	 * ...
	 * @author GaGa
	 */
	public class HandleBaseInfo 
	{
		
		public function HandleBaseInfo() { }
		
		/**
		 * 处理时间图层等信息
		 * @param	info
		 */
		public static function handle(info:U2InfoBaseInfo):void
		{
			if (info)
			{
				//info.layer.length = info.layer.lib.length;
				var maxLayerTime:Number = 0;
				var number:Number;
				for each (var layer:U2InfoBaseLayer in info.layer.lib) 
				{
					//算出每一帧的时间
					if (layer.fps)
					{
						number = 1000 / layer.fps;
						if (layer.frequency != number) layer.frequency = number;
						if (layer.length != layer.lib.length) layer.length = layer.lib.length;
						number = layer.length * number;
						if (layer.timeLength != number) layer.timeLength = number;
					}
					else
					{
						if (layer.frequency != 0) layer.frequency = 0;
						if (layer.timeLength != 0) layer.timeLength = 0;
						if (layer.length > 1)
						{
							layer.lib.splice(1, layer.length - 1);
							layer.length = 1;
						}
					}
					if (maxLayerTime < layer.timeLength)
					{
						maxLayerTime = layer.timeLength;
					}
					EngineLayer.autoConfig(layer);
				}
				info.layer.timeLength = maxLayerTime;
				EngineLayer.autoConfigLib(info);
			}
		}
		
		/** 根据内容自动设置背景的尺寸,后面留空就好了 **/
		public static function autoBgSize(info:U2InfoBaseInfo, fps:Number = 60, times:int = 1, gfile:* = null):void
		{
			if (gfile != null) info.gfile = gfile;
			var core:Number = 0;
			var addTime:Number = 1 / fps;//FPS120的速度运行
			var u2:DisplayObject = EngineInfo.create(info, false, core, -1);
			var timer:U2Timer = (u2 as Object).timer;
			var s:Sprite = new Sprite();
			s.addChild(u2);
			var doTime:Number = info.layer.timeLength * times;
			var x:Number = 0;
			var y:Number = 0;
			var w:Number = 0;
			var h:Number = 0;
			var r:Rectangle;
			var start:Boolean = false;
			if(core < doTime)
			{
				while (core < doTime)
				{
					//获取尺寸
					r = s.getBounds(s);
					if (start == false)
					{
						start = true;
						x = r.x;
						y = r.y;
						w = r.right;
						h = r.bottom;
					}
					else
					{
						if (x > r.x) x = r.x;
						if (y > r.y) y = r.y;
						if (w < r.right) w = r.right;
						if (h < r.bottom) h = r.bottom;
					}
					if(timer) timer.timeCore(core, -1, false, false);
					core = core + addTime;
				}
			}
			else
			{
				//获取尺寸
				r = s.getBounds(s);
				x = r.x;
				y = r.y;
				w = r.right;
				h = r.bottom;
			}

			x = Math.floor(x);
			y = Math.floor(y);
			w = Math.ceil(w);
			h = Math.ceil(h);
			info.contour.startX = x;
			info.contour.startY = y;
			info.contour.endX = w;
			info.contour.endY = h;
			
			if (info.stageInfo.autoBg)
			{
				var width:Number = w - x;
				var height:Number = h - y;
				info.stageInfo.startX = int(x - (width * 0.2));
				info.stageInfo.startY = int(y - (height * 0.2));
				info.stageInfo.width = int(width * 1.4);
				info.stageInfo.height = int(height * 1.4);
				if (info.stageInfo.width < 10) info.stageInfo.width = 10;
				if (info.stageInfo.height < 10) info.stageInfo.height = 10;
			}
		}
		
	}

}