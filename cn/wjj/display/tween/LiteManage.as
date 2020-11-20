package cn.wjj.display.tween 
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	/**
	 * TweenLite 辅助工具,提升TweenLite的效率.
	 * 支持一个个的播放TweenLite对象
	 * 
	 * LiteManage.append(top, 0.5, { alpha:1, y:gameStage.content.y - 100, ease:Back.easeOut } );
	 * LiteManage.append(top, 0.25, { alpha:0, y:gameStage.content.y - 250 }, 1);
	 * LiteManage.append(end, 0.5, { alpha:1, y:gameStage.content.y + 100 } );
	 * LiteManage.append(end, 0.25, { alpha:0, y:gameStage.content.y + 250, onComplete:completeBar }, 1 );
	 * 
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-04-01
	 */
	public class LiteManage 
	{
		private static var lib:Dictionary = new Dictionary(true);
		/** 没幀的最短时间,小于这个时间的内容,整合后直接设置 **/
		internal static var fpsTime:Number;
		
		private static var _timeScale:Number = 1;
		
		public function LiteManage() {}
		
		/**
		 * 
		 * @param	o			要关闭的对象
		 * @param	complete	是否直接完成里面的函数和参数
		 */
		public static function killTweensOf(o:Object, complete:Boolean = false):void
		{
			var list:LiteList = lib[o];
			if (list)
			{
				list.removeAll(complete);
				list.dispose();
			}
			else
			{
				TweenLite.killTweensOf(o, complete);
			}
			delete lib[o];
		}
		
		public static function removeLite(list:LiteList):void
		{
			delete lib[list.o];
			list.dispose();
		}
		
		/**
		 * 砍掉全部的
		 * @param	complete
		 */
		public static function killAll(complete:Boolean = false):void
		{
			for each (var o:Object in lib) 
			{
				killTweensOf(o, complete);
			}
		}
		
		/**
		 * 添加一个缓动播放动画
		 * @param	o			对象
		 * @param	time		(秒)播放时间
		 * @param	info		播放内容
		 * @param	offset		(秒)延后时间开始播放
		 */
		public static function append(o:Object, time:Number, info:Object, offset:Number = 0):void
		{
			var list:LiteList;
			if (lib[o])
			{
				list = lib[o];
			}
			else
			{
				list = new LiteList();
				list.o = o;
				if (o is DisplayObject)
				{
					list.isDisplay = true;
				}
				else
				{
					list.isDisplay = false;
				}
				lib[o] = list;
			}
			list.push(time, info, offset);
		}
		
		/**
		 * 设置系统的FPS帧频率
		 */
		public static function set stageFPS(fps:Number):void
		{
			fpsTime = 1 / fps;
		}
		
		/** 播放速率,1是普通速度 **/
		public static function get timeScale():Number 
		{
			return _timeScale;
		}
		
		public static function set timeScale(value:Number):void 
		{
			_timeScale = value;
		}
	}
}