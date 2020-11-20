package cn.wjj.display.tween 
{
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	
	/**
	 * TweenLite 的一个对象的队列
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-04-01
	 */
	public class LiteList 
	{
		
		/** 缓动的对象 **/
		public var o:Object;
		public var isDisplay:Boolean;
		public var item:LiteItem;
		public var list:Vector.<LiteItem> = new Vector.<LiteItem>();
		public var isRun:Boolean = false;
		
		public function LiteList() {}
		
		public function push(time:Number, info:Object, offset:Number = 0):void
		{
			var item:LiteItem = LiteItem.instance();
			item.t = time;
			if (info.hasOwnProperty("onComplete"))
			{
				item.complete = info.onComplete;
			}
			if (info.hasOwnProperty("delay"))
			{
				item.delay = info.delay;
			}
			if (offset != 0)
			{
				item.delay = item.delay + offset;
			}
			item.info = info;
			list.push(item);
			if (isRun == false)
			{
				start();
			}
		}
		
		private function start():void
		{
			doItem();
		}
		
		/**
		 * 不断的运行这个对象
		 */
		private function run():void
		{
			if (item && item.complete != null)
			{
				isRun = false;
				var f:Function = item.complete;
				item.complete = null;
				f();
			}
			doItem();
		}
		
		/**
		 * 执行下一个队列
		 */
		private function doItem():void
		{
			//如果是显示对象, 运行时间比一幀还要短,就直接干过, 并检查下面的幀和onComplete对象
			if (list.length)
			{
				isRun = true;
				item = list.shift();
				var t:Number = item.t / LiteManage.timeScale;
				var delay:Number = item.delay / LiteManage.timeScale;
				if (delay != 0)
				{
					item.info.delay = delay;
				}
				if (isDisplay && (delay + t) < LiteManage.fpsTime)
				{
					var runFunction:Vector.<Function> = new Vector.<Function>();
					if (item.complete != null)
					{
						runFunction.push(item.complete);
					}
					var doItem:LiteItem = item;
					var addTime:Number = mergerItem(doItem, (delay + t), runFunction);
					LiteList.displayDo(o as DisplayObject , doItem);
					if (list.length)
					{
						list[0].delay = list[0].delay + addTime * LiteManage.timeScale;
					}
					item.dispose();
					item = null;
					for each (var f:Function in runFunction) 
					{
						f();
					}
					run();
				}
				else
				{
					item.info.onComplete = run;
					TweenLite.to(o, t, item.info);
				}
			}
			else
			{
				LiteManage.removeLite(this);
			}
		}
		
		/** 快速计算 **/
		internal static function displayDo(o:DisplayObject, item:LiteItem):void
		{
			if(item)
			{
				if (item.info.hasOwnProperty("x") && o.x != item.info.x)
				{
					o.x = item.info.x;
				}
				if (item.info.hasOwnProperty("y") && o.y != item.info.y)
				{
					o.y = item.info.y;
				}
				if (item.info.hasOwnProperty("z") && o.z != item.info.z)
				{
					o.z = item.info.z;
				}
				if (item.info.hasOwnProperty("rotation") && o.rotation != item.info.rotation)
				{
					o.rotation = item.info.rotation;
				}
				if (item.info.hasOwnProperty("alpha") && o.alpha != item.info.alpha)
				{
					o.alpha = item.info.alpha;
				}
				if (item.info.hasOwnProperty("scaleX") && o.scaleX != item.info.scaleX)
				{
					o.scaleX = item.info.scaleX;
				}
				if (item.info.hasOwnProperty("scaleY") && o.scaleY != item.info.scaleY)
				{
					o.scaleY = item.info.scaleY;
				}
				if (item.info.hasOwnProperty("scaleZ") && o.scaleZ != item.info.scaleZ)
				{
					o.scaleZ = item.info.scaleZ;
				}
				if (item.info.hasOwnProperty("width") && o.width != item.info.width)
				{
					o.width = item.info.width;
				}
				if (item.info.hasOwnProperty("height") && o.height != item.info.height)
				{
					o.height = item.info.height;
				}
			}
		}
		
		/**
		 * 只有不具备delay的对象才可以合并
		 * @param	arr
		 */
		private function mergerItem(merger:LiteItem, topTime:Number, runFunction:Vector.<Function>):Number
		{
			var temp:LiteItem;
			var t:Number;
			var delay:Number;
			var name:String;
			while (list.length)
			{
				temp = list[0];
				t = temp.t / LiteManage.timeScale;
				delay = temp.delay / LiteManage.timeScale;
				if ((topTime + t + delay) < LiteManage.fpsTime)
				{
					topTime = topTime + t + delay;
					item = list.shift();
					//合并进去
					for (name in item.info) 
					{
						merger.info[name] = item.info[name]
					}
					if (item.complete != null)
					{
						runFunction.push(item.complete);
					}
				}
				else
				{
					return topTime;
				}
			}
			return topTime;
		}
		
		/**
		 * 
		 * @param	c		是否直接完成
		 */
		public function removeAll(c:Boolean = false):void
		{
			if (isRun == true)
			{
				TweenLite.killTweensOf(o, c);
				if (c)
				{
					completeThis();
				}
			}
			LiteManage.removeLite(this);
		}
		
		private function disposeItem():void
		{
			if (item)
			{
				item.dispose();
			}
			if (list.length)
			{
				for each (item in list) 
				{
					item.dispose();
				}
				list.length = 0;
			}
			item = null;
		}
		
		private function completeThis():void
		{
			var name:String;
			var merger:LiteItem;
			var runFunction:Vector.<Function>;
			var f:Function;
			if (item)
			{
				if(item.complete != null)
				{
					f = item.complete;
					item.complete = null;
					f();
					f = null;
				}
				merger = item;
			}
			
			if(list.length)
			{
				for each (item in list) 
				{
					if (merger == null)
					{
						merger = item;
					}
					//合并进去
					for (name in item.info) 
					{
						merger.info[name] = item.info[name]
					}
					if (item.complete != null)
					{
						if (f == null)
						{
							f = item.complete;
						}
						else
						{
							if (runFunction == null)
							{
								runFunction = new Vector.<Function>();
							}
							runFunction.push(item.complete);
						}
					}
				}
			}
			if (isDisplay && o)
			{
				LiteList.displayDo(o as DisplayObject, merger);
			}
			if (f != null)
			{
				f();
				if (runFunction)
				{
					for each (f in runFunction) 
					{
						f();
					}
				}
			}
		}
		
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(40);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint { return __f.length; }
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		public static function instance():LiteList
		{
			var o:LiteList = __f.instance() as LiteList;
			if (!o)
			{
				o = new LiteList();
			}
			return o;
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.o  != null) this.o  = null;
			if (this.isDisplay != false) this.isDisplay = false;
			if (this.item  != null)
			{
				this.item.dispose();
				this.item = null;
			}
			if (this.list.length != 1)
			{
				this.disposeItem();
			}
			if (this.isRun != false) this.isRun = false;
			__f.recover(this);
		}
	}
}