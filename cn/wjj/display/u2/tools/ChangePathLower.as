package cn.wjj.display.u2.tools 
{
	import cn.wjj.display.ui2d.info.U2InfoBase;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	import cn.wjj.display.ui2d.info.U2InfoSound;
	import cn.wjj.display.ui2d.info.U2InfoType;
	
	/**
	 * 将U2文件内的全部内容都转换为小写
	 * 
	 * @author GaGa
	 */
	public class ChangePathLower 
	{
		
		public function ChangePathLower() { }
		
		public static function runPath(o:U2InfoBaseInfo):void
		{
			o.name = o.name.toLocaleLowerCase();
			o.path = o.path.toLocaleLowerCase();
			
			var lib:Vector.<U2InfoBaseLayer> = o.layer.lib;
			var frameLib:Vector.<U2InfoBaseFrame>;
			var frame:U2InfoBaseFrame;
			var fb:U2InfoBaseFrameBitmap;
			var fd:U2InfoBaseFrameDisplay;
			var sound:U2InfoSound;
			if (o.eventLib.eventLength)
			{
				for each (var item:U2InfoBase in o.eventLib.eventList) 
				{
					switch (item.type) 
					{
						case U2InfoType.sound:
							sound = item as U2InfoSound;
							if (sound.path)
							{
								sound.path = sound.path.toLocaleLowerCase();
							}
							break;
						default:
					}
				}
			}
			for each (var layer:U2InfoBaseLayer in lib) 
			{
				frameLib = layer.lib;
				for each (frame in frameLib) 
				{
					if (frame is U2InfoBaseFrameBitmap)
					{
						fb = frame as U2InfoBaseFrameBitmap;
						if (fb.display && fb.display.path)
						{
							fb.display.path = fb.display.path.toLocaleLowerCase();
						}
					}
					else if (frame is U2InfoBaseFrameDisplay)
					{
						fd = frame as U2InfoBaseFrameDisplay;
						if (fd.display && fd.display.path)
						{
							fd.display.path = fd.display.path.toLocaleLowerCase();
						}
					}
					else
					{
						
					}
				}
			}
		}
	}
}