package cn.wjj.display
{
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import cn.wjj.g;
	
	public class DisplayScale
	{
		
		/**
		 * 获取一个对象现在在显示对象上被缩放的综合性的一个比例
		 * @param display
		 * @return 
		 */
		public static function getScaleX(display:DisplayObject):Number
		{
			var scale:Number = display.scaleX;
			while(display && display is DisplayObjectContainer)
			{
				if(display.hasOwnProperty("parent") && display.parent is DisplayObject)
				{
					display = display.parent;
					scale = display.scaleX * scale;
					if(display is Stage)
					{
						return scale;
					}
				}
				else
				{
					return scale;
				}
			}
			return scale;
		}
	}
}