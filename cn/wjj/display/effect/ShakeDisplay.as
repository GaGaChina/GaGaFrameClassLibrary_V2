package cn.wjj.display.effect
{
	import cn.wjj.display.MPoint;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import cn.wjj.g;
	
	/**
	 * 晃动的特效
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2012-11-30
	 */
	public class ShakeDisplay 
	{
		
		/** 所有晃动的对象 **/
		private static var lib:Dictionary = new Dictionary(true);
		
		private static var fpsLib:Vector.<ShakeDisplay> = new Vector.<ShakeDisplay>();
		
		/**
		 * 添加一个晃动的显示对象,让他按照FPS节奏晃动
		 * @param	display			要晃动的显示对象
		 * @param	fps				剧烈程度
		 * @param	runTime			(毫秒)运行时间
		 * @param	minDistance		最小抖动范围
		 * @param	maxDistance		最大抖动范围
		 * @param	dTime			(毫秒)延迟时间
		 * @param	startPoint		开始坐标
		 * @param	doX				操作X坐标
		 * @param	doY				操作Y坐标
		 */
		public static function run(display:DisplayObject,fps:Number, runTime:Number, minDistance:Number, maxDistance:Number, dTime:Number = 0, startPoint:MPoint = null, doX:Boolean = true, doY:Boolean = true):void
		{
			var info:Object
			if (lib[display])
			{
				info = lib[display];
			}
			else
			{
				info = new Object();
				lib[display] = info;
				if (startPoint)
				{
					info.p = new Point();
					info.p.x = startPoint.x;
					info.p.y = startPoint.y;
				}
				else
				{
					info.p = new Point(display.x, display.y);
				}
			}
			info.startTime = g.time.getTime() + dTime;
			info.endTime = g.time.getTime() + runTime + dTime;
			info.fps = fps;
			info.runTime = runTime;
			info.minDistance = minDistance;
			info.maxDistance = maxDistance;
			info.doX = doX;
			info.doY = doY;
			var item:ShakeDisplay;
			for each (item in fpsLib) 
			{
				if (item.fps == fps)
				{
					item.play();
					return;
				}
			}
			item = new ShakeDisplay(fps);
			fpsLib.push(item);
			item.play();
		}
		
		/** 这个对象的FPS **/
		public var fps:Number;
		
		/**
		 * 添加一个fps的震动对象集
		 * @param	fps
		 */
		public function ShakeDisplay(fps:Number):void
		{
			this.fps = fps;
		}
		
		public function play():void
		{
			g.event.addFPSEnterFrame(fps, run);
		}
		
		/** 停止这个FPS **/
		public function stop():void
		{
			g.event.removeFPSEnterFrame(fps, run);
		}
		
		private function run():void {
			frequency(fps);
		}
		
		private static function frequency(fps:Number):void
		{
			var display:DisplayObject;
			var info:Object;
			var l:int = 0;
			var item:*;
			for (item in lib) 
			{
				display = item as DisplayObject;
				info = lib[display];
				if (g.time.getTime() >= info.startTime)
				{
					if (info.fps == fps)
					{
						if (g.time.getTime() >= info.endTime)
						{
							//时间到了
							display.x = info.p.x;
							display.y = info.p.y;
							delete lib[display];
						}
						else
						{
							l++;
							fly(display);
						}
					}
				}
			}
			if (g.time.getTime() >= info.startTime && l == 0)
			{
				
				for (var key:* in fpsLib) 
				{
					if (fpsLib[key].fps == fps)
					{
						fpsLib[key].stop();
						fpsLib.splice(key, 1);
					}
				}
			}
		}
		
		/**
		 * 找个一个新点,移动过去
		 * @param	display
		 */
		private static function fly(display:DisplayObject):void
		{
			var info:Object = lib[display];
			var n:Point = new Point();
			var distance:Number;
			do
			{
				if (info.doX)
				{
					n.x = Math.floor(Math.random() * info.maxDistance * 2 - info.maxDistance + info.p.x);
				}
				else
				{
					n.x = info.p.x;
				}
				if (info.doY)
				{
					n.y = Math.floor(Math.random() * info.maxDistance * 2 - info.maxDistance + info.p.y);
				}
				else
				{
					n.y = info.p.y;
				}
				distance = Point.distance(info.p, n);
			}while (distance >= info.minDistance && distance <= info.maxDistance)
			display.x = n.x;
			display.y = n.y;
		}
	}
}