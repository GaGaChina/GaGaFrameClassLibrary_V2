package cn.wjj.display
{
	import cn.wjj.g;
	
	import flash.display.MovieClip;
	
	public class MovieClipTool
	{
		
		/**
		 * 替换AS3的gotoAndStop.
		 * Obj.gotoAndStop(str)  等同于   gotoStop(Obj,str);
		 * @param	mc			要控制的影片剪辑
		 * @param	str			要调整的幀,可以是标签名或者是幀位置
		 * @param	maxTimes	可以重复尝试的次数
		 */
		public static function gotoStop(mc:MovieClip, str:*, maxTimes:int = 50):void
		{
			var num:int = int(str);
			var i:int = 0;
			mc.stop();
			if(String(num) == str)
			{
				//当是数字帧的时候
				while (mc.currentFrame != num)
				{
					mc.gotoAndStop(num);
					i++;
					if (i > maxTimes)
					{
						//防止死循环
						g.log.pushLog(null,g.logType._Frame,"gotoStop函数发生死循环 currentFrame:" + mc.name + " , " + str);
						break;
					}
				}
			}else{
				//当是数字帧的时候
				while (mc.currentFrameLabel == null || mc.currentFrameLabel != str)
				{
					//trace("已经运行到这里了");
					mc.gotoAndStop(str);
					i++;
					if (i > maxTimes)
					{
						//防止死循环
						g.log.pushLog(null,g.logType._Frame,"gotoStop函数发生死循环 currentFrameLabel:" + mc.name + " , " + str);
						break;
					}
				}
			}
		}
	}
}