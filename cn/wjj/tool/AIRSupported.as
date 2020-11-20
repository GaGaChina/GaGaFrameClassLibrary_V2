package cn.wjj.tool
{
	import flash.desktop.NativeApplication;
	import flash.html.HTMLLoader;
	import flash.media.Camera;
	import flash.media.CameraUI;
	import flash.media.Microphone;
	import flash.media.StageVideo;
	import flash.media.StageWebView;
	import flash.net.DatagramSocket;
	import flash.net.ServerSocket;
	import flash.net.NetworkInfo;
	import flash.system.Worker;
	import flash.sensors.Accelerometer;
	import flash.sensors.Geolocation;
	import flash.ui.ContextMenu;
	import flash.ui.Multitouch;
	
	import flash.display.Stage;
	import flash.display.Stage3D;
	
	public class AIRSupported
	{
		
		/**
		 * 把一个Vector对象转换为数组Array对象输出
		 * @param init
		 * @return 
		 *                        没有测试过
		 */
		public static function getSupported():String
		{
			var str:String = "";
			try
			{
				str = str + "检测 supportsDockIcon ,任务栏图标 : " + NativeApplication.supportsDockIcon + "\n";
				str = str + "检测 supportsMenu ,应用程序菜单栏 : " + NativeApplication.supportsMenu + "\n";
				str = str + "检测 supportsStartAtLogin ,登录启动程序 : " + NativeApplication.supportsStartAtLogin + "\n";
				str = str + "检测 HTMLLoader : " + HTMLLoader.isSupported + "\n";
				str = str + "检测 StageWebView : " + StageWebView.isSupported + "\n";
				//str = str + "\n检测 StageVideo 支持\n";
				//str = str + StageVideo + "\n";
				str = str + "检测 Camera : " + Camera.isSupported + "\n";
				str = str + "检测 CameraUI ,截图,录像 : " + CameraUI.isSupported + "\n";
				str = str + "检测 Microphone : " + Microphone.isSupported + "\n";
				str = str + "检测 UDP DatagramSocket : " + DatagramSocket.isSupported + "\n";
				str = str + "检测 NetworkInfo ,网络接口信息 : " + NetworkInfo.isSupported + "\n";
				str = str + "检测 ServerSocket : " + ServerSocket.isSupported + "\n";
				str = str + "检测 Worker ,多核支持 : " + Worker.isSupported + "\n";
				str = str + "检测 Accelerometer ,运动传感器活动事件 : " + Accelerometer.isSupported + "\n";
				str = str + "检测 Geolocation ,GPS : " + Geolocation.isSupported + "\n";
				str = str + "检测 ContextMenu : " + ContextMenu.isSupported + "\n";
				str = str + "检测 Multitouch 最大触摸点数 : " + Multitouch.maxTouchPoints + "\n";
				str = str + "检测 Stage ,支持舞台旋转 : " + Stage.supportsOrientationChange;
			}
			catch (e:Error)
			{
				str = str + "可能为非AIR平台" + "\n";
				str = str + e.toString();
			}
			return str;
		}
	}
}