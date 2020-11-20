package cn.wjj.air
{
	import cn.wjj.tool.ArrayUtil;
	import com.flashvisions.mobile.android.extensions.net.NetworkInfo;
	import cn.wjj.g;
	
	public class ANDNetworkMAC
	{
		
		private static var networkInfo:NetworkInfo;
		
		public function ANDNetworkMAC():void { }
		
		/**
		 * 获取用户的MAC地址 : FF-FF-FF-FF-FF-FF
		 */
		public static function get MAC():String
		{
			var str:String = "";
			try
			{
				if (ANDNetworkMAC.networkInfo)
				{
					ANDNetworkMAC.networkInfo = new NetworkInfo();
				}
				if (ANDNetworkMAC.networkInfo.isSupported())
				{
					g.log.pushLog(ANDNetworkMAC, g.logType._UserAction, "networkInfo.getCoarseState() : " + ANDNetworkMAC.networkInfo.getCoarseState());
					g.log.pushLog(ANDNetworkMAC, g.logType._UserAction, "networkInfo.getDetailedState() : " + ANDNetworkMAC.networkInfo.getDetailedState());
					g.log.pushLog(ANDNetworkMAC, g.logType._UserAction, "networkInfo.isNetworkConnected() : " + ANDNetworkMAC.networkInfo.isNetworkConnected());
					g.log.pushLog(ANDNetworkMAC, g.logType._UserAction, "networkInfo.isNetworkAvailable() : " + ANDNetworkMAC.networkInfo.isNetworkAvailable());
				}
				else
				{
					g.log.pushLog(ANDNetworkMAC, g.logType._ErrorLog, "安卓 走ANE 错误 isSupported : false");
				}
			}
			catch (e:Error)
			{
				g.log.pushLog(ANDNetworkMAC, g.logType._ErrorLog, "安卓 走ANE 错误 : " + e.message);
			}
			return str;
		}
		
		/**
		 * 获取用户的MAC地址 : FFFFFFFFFFFF
		 */
		public static function get MinMac():String
		{
			var arr:Array = ANDNetworkMAC.MAC.split("-");
			var str:String = arr.join("");
			arr = str.split(":");
			return arr.join("");
		}
		
		/**
		 * 获取用户的MAC地址 : FFFFFFFFFFFF
		 */
		public static function get ShortMAC():String
		{
			var arr:Array = ANDNetworkMAC.MAC.split("-");
			var str:String = arr.join("");
			arr = str.split(":");
			return "0x" + arr.join("");
		}
		
		/**
		 * 获取用户的全部MAC地址 : [FF-FF-FF-FF-FF-FF,FF-FF-FF-FF-FF-FF,.....]
		 */
		public static function get MACList():Array
		{
			var a:Array = new Array();
			try
			{
				/*
				var list:Vector.<NetworkInterface> = com.adobe.nativeExtensions.Networkinfo.NetworkInfo.networkInfo.findInterfaces();
				for each (var info:NetworkInterface in list)
				{
					if (info.hasOwnProperty("hardwareAddress") && String(info.hardwareAddress))
					{
						a.push(String(info.hardwareAddress));
					}
				}
				*/
			}
			catch (e:Error)
			{
				g.log.pushLog(ANDNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 错误 : " + e.message);
			}
			//去除重复
			a = ArrayUtil.createUniqueCopy(a);
			g.log.pushLog(ANDNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 " + a);
			return a;
		}
		
		/**
		 * 获取用户的MAC地址 : [FFFFFFFFFFFF,FFFFFFFFFFFF,FFFFFFFFFFFF]
		 */
		public static function get MinMacList():Array
		{
			var old:Array = ANDNetworkMAC.MACList;
			var arr:Array;
			var str:String;
			var out:Array = new Array();
			for each (var mac:String in old) 
			{
				arr = mac.split("-");
				str = arr.join("");
				arr = str.split(":");
				out.push(arr.join(""));
			}
			return out;
		}
		
		/**
		 * 获取特定名字的MAC地址 : FF-FF-FF-FF-FF-FF
		 */
		public static function MACName(name:String):String
		{
			try
			{
				/*
				var list:Vector.<NetworkInterface> = com.adobe.nativeExtensions.Networkinfo.NetworkInfo.networkInfo.findInterfaces();
				for each (var info:NetworkInterface in list)
				{
					if (info.name == name)
					{
						if (info.hasOwnProperty("hardwareAddress") && String(info.hardwareAddress))
						{
							return String(info.hardwareAddress);
						}
						else
						{
							return "";
						}
					}
				}
				*/
			}
			catch (e:Error)
			{
				g.log.pushLog(ANDNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 错误 : " + e.message);
			}
			return "";
		}
		
		/**
		 * 获取特定名字的MAC地址 : FFFFFFFFFFFF
		 */
		public static function MinMacName(name:String):String
		{
			var str:String = ANDNetworkMAC.MACName(name);
			if (str.length > 0)
			{
				var arr:Array = str.split("-");
				str = arr.join("");
				arr = str.split(":");
				return arr.join("");
			}
			return "";
		}
	}
}
