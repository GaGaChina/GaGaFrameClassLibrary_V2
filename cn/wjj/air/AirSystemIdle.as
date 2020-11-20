package cn.wjj.air 
{
	import flash.desktop.SystemIdleMode;
	import flash.desktop.NativeApplication;
	import cn.wjj.g;
	import flash.events.MouseEvent;
	
	/**
	 * SystemIdleMode 类为系统空闲行为提供常量值。这些常量在 NativeApplication 类的 systemIdleMode 属性中使用。
	 * 
	 * KEEP_AWAKE : String = "keepAwake"  防止系统进入空闲模式。
	 * NORMAL : String = "normal" 系统采用正常的“空闲用户”行为
	 * 
	 * Android
	 * 允许程序禁用键盘锁
	 * <uses-permission android:name="android.permission.DISABLE_KEYGUARD"/>
	 * 允许程序在手机屏幕关闭后后台进程仍然运行
	 * <uses-permission android:name="android.permission.WAKE_LOCK"/>
	 * 
	 * @author GaGa
	 */
	public class AirSystemIdle 
	{
		/**
		 * 设置休眠模式为防止系统进入空闲模式
		 * true : 防止系统进入空闲模式
		 * false: 系统采用正常的“空闲用户”行为
		 */
		private static var mode:Boolean = false;
		/** 多少时间后让用户切回到休眠模式,然后用户点击屏幕再次进入防止休眠模式 **/
		private static var awakeTime:Number = 0;
		/** 用户上一次点击屏幕的时间 **/
		private static var userTime:Number;
		/** 结束休眠的切换时间点 **/
		private static var endDelayTime:Number = 0;
		
		public function AirSystemIdle():void { }
		
		/**
		 * 设置休眠模式为防止系统进入空闲模式
		 * true : 防止系统进入空闲模式
		 * false: 系统采用正常的“空闲用户”行为
		 * 
		 * 
		 * @param	mode
		 */
		public static function set SetKeepAwake(mode:Boolean):void
		{
			mode = mode
			if (mode)
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			}
			else
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
			}
		}
		
		/**
		 * 开始将系统切防空闲模式,然后进入自身的倒计时系统
		 * @param	awakeTime	毫秒,1000 * 60 * 20 20分钟 : 1200000
		 */
		public static function StartAwakeTime(awakeTime:Number):void
		{
			endDelayTime = 0;;
			g.event.removeFPSEnterFrame(0.1, delayFrame);
			SetKeepAwake = true;
			awakeTime = awakeTime;
			userTime = new Date().time;
			g.event.addListener(g.bridge.root, MouseEvent.MOUSE_DOWN, mouseDo);
			g.event.addFPSEnterFrame(0.1, enterFrame);
		}
		
		/**
		 * 停止防空闲模式,并且把系统转入可休闲模式
		 * @param	delay	延迟执行(毫秒)
		 */
		public static function EndAwakeTime(delay:Number = 0):void
		{
			if (delay == 0)
			{
				endDelayTime = 0;
				g.event.removeFPSEnterFrame(0.1, delayFrame);
				endTimeDo();
			}
			else
			{
				endDelayTime = new Date().time + delay;
				g.event.addFPSEnterFrame(0.1, delayFrame);
			}
		}
		
		private static function delayFrame():void
		{
			if (endDelayTime < new Date().time)
			{
				g.event.removeFPSEnterFrame(0.1, delayFrame);
				endDelayTime = 0;;
				endTimeDo();
			}
		}
		
		private static function endTimeDo():void
		{
			g.event.removeListener(g.bridge.root, MouseEvent.MOUSE_DOWN, mouseDo);
			g.event.removeFPSEnterFrame(0.1, enterFrame);
			SetKeepAwake = false;
			awakeTime = 0;
		}
		
		/** 用户刚刚操作了一下,用户不是因为点击屏幕,但是也算一种用户是活动的,防止进入休眠 **/
		public static function UserDo():void
		{
			if (awakeTime != 0)
			{
				userTime = new Date().time;
			}
		}
		
		private static function enterFrame():void
		{
			if ((userTime + awakeTime) < new Date().time)
			{
				//将用户的模式切回来,并修正
				SetKeepAwake = false;
				g.event.removeFPSEnterFrame(0.1, enterFrame);
			}
		}
		
		private static function mouseDo(e:MouseEvent):void
		{
			if (awakeTime != 0)
			{
				userTime = new Date().time;
				if (!mode)
				{
					SetKeepAwake = true;
					g.event.addFPSEnterFrame(0.1, enterFrame);
				}
			}
		}
	}
}