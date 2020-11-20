package cn.wjj.air 
{
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import cn.wjj.g;
	
	/**
	 * 
	 * @author GaGa
	 */
	public class AirMouseEvent 
	{
		
		public function AirMouseEvent() 
		{
			
		}
		
		
		public static function startTransformGestureEvent():void
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			g.bridge.swfRoot.stage.addEventListener(TransformGestureEvent.GESTURE_SWIPE, swipe);
		}
		
		private static function swipe(e:TransformGestureEvent):void
		{
			switch (e.offsetX) 
			{
				case 1:
					//swiped 右
					g.log.pushLog(AirMouseEvent, g.logType._UserAction, "右");
					break;
				case -1:
					// swiped 左
					break;
				default:
			}
			switch (e.offsetY) 
			{
				case 1:
					//swiped 下
					break;
				case -1:
					// swiped 上
					break;
				default:
			}
		}
	}
}