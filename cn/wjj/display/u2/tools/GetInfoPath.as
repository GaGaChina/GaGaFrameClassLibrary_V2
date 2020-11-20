package cn.wjj.display.u2.tools 
{
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	/**
	 * 获取一个U2InfoBaseInfo里所包含的路径
	 * @author GaGa
	 */
	public class GetInfoPath 
	{
		
		public function GetInfoPath() {}
		
		/** 从一个 U2InfoBaseInfo 数据中获取一个路径 **/
		public static function getOnePath(info:U2InfoBaseInfo):String
		{
			var lib:Vector.<U2InfoBaseLayer> = info.layer.lib;
			var frameLib:Vector.<U2InfoBaseFrame>;
			var frame:U2InfoBaseFrame;
			var frameBitmap:U2InfoBaseFrameBitmap;
			var frameDisplay:U2InfoBaseFrameDisplay;
			for each (var layer:U2InfoBaseLayer in lib) 
			{
				frameLib = layer.lib;
				for each (frame in frameLib) 
				{
					if (frame is U2InfoBaseFrameBitmap)
					{
						frameBitmap = frame as U2InfoBaseFrameBitmap;
						if (frameBitmap.display.path)
						{
							return frameBitmap.display.path;
						}
					}
					else if(frame is U2InfoBaseFrameDisplay)
					{
						frameDisplay = frame as U2InfoBaseFrameDisplay;
						if (frameDisplay.display.path)
						{
							return frameDisplay.display.path;
						}
					}
				}
			}
			return "";
		}
		
		/** 从一个 U2InfoBaseInfo 数据中获取全部的路径 **/
		public static function getPathList(info:U2InfoBaseInfo):Vector.<String>
		{
			var list:Vector.<String> = new Vector.<String>();
			var lib:Vector.<U2InfoBaseLayer> = info.layer.lib;
			var frameLib:Vector.<U2InfoBaseFrame>;
			var frame:U2InfoBaseFrame;
			var frameBitmap:U2InfoBaseFrameBitmap;
			var frameDisplay:U2InfoBaseFrameDisplay;
			for each (var layer:U2InfoBaseLayer in lib) 
			{
				frameLib = layer.lib;
				for each (frame in frameLib) 
				{
					if (frame is U2InfoBaseFrameBitmap)
					{
						frameBitmap = frame as U2InfoBaseFrameBitmap;
						if (frameBitmap.display.path)
						{
							if (list.indexOf(frameBitmap.display.path) == -1)
							{
								list.push(frameBitmap.display.path);
							}
						}
					}
					else if(frame is U2InfoBaseFrameDisplay)
					{
						frameDisplay = frame as U2InfoBaseFrameDisplay;
						if (frameDisplay.display.path)
						{
							if (list.indexOf(frameDisplay.display.path) == -1)
							{
								list.push(frameDisplay.display.path);
							}
						}
					}
				}
			}
			return list;
		}
	}

}