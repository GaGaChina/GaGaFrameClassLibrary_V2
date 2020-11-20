package cn.wjj.air
{
	import cn.wjj.tool.ArrayUtil;
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.freshplanet.nativeExtensions.NativeNetworkInterface;
	import cn.wjj.g;
	
	public class AIRNetworkMAC
	{
		public function AIRNetworkMAC():void { }
		
		/**
		 * 获取用户的MAC地址 : FF-FF-FF-FF-FF-FF
		 */
		public static function get MAC():String
		{
			var str:String = "";
			try
			{
				var list:Vector.<NativeNetworkInterface> = AirNetworkInfo.networkInfo.findInterfaces();
				if (list)
				{
					var addresses:NativeNetworkInterface;
					for each(addresses in list)
					{
						g.log.pushLog(AIRNetworkMAC, g.logType._ErrorLog, "AIR 信息 : " + addresses.name + " " + addresses.displayName + " " + addresses.active + " " + addresses.mtu + " " + addresses.hardwareAddress);
					}
					for each(addresses in list)
					{
						str = addresses.hardwareAddress.toString();
						if (str != "")
						{
							return str;
						}
					}
				}
			}
			catch (e:Error)
			{
				g.log.pushLog(AIRNetworkMAC, g.logType._ErrorLog, "AIR ANE 错误 : " + e.message);
			}
			return str;
		}
		
		/**
		 * 获取用户的MAC地址 : FFFFFFFFFFFF
		 */
		public static function get MinMac():String
		{
			var arr:Array = AIRNetworkMAC.MAC.split("-");
			var str:String = arr.join("");
			arr = str.split(":");
			return arr.join("");
		}
		
		/**
		 * 获取用户的MAC地址 : FFFFFFFFFFFF
		 */
		public static function get ShortMAC():String
		{
			var arr:Array = AIRNetworkMAC.MAC.split("-");
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
				var list:Vector.<NativeNetworkInterface> = AirNetworkInfo.networkInfo.findInterfaces();
				for each (var info:NativeNetworkInterface in list)
				{
					if (info.hasOwnProperty("hardwareAddress") && String(info.hardwareAddress))
					{
						a.push(String(info.hardwareAddress));
					}
				}
			}
			catch (e:Error)
			{
				g.log.pushLog(AIRNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 错误 : " + e.message);
			}
			//去除重复
			a = ArrayUtil.createUniqueCopy(a);
			g.log.pushLog(AIRNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 " + a);
			return a;
		}
		
		/**
		 * 获取用户的MAC地址 : [FFFFFFFFFFFF,FFFFFFFFFFFF,FFFFFFFFFFFF]
		 */
		public static function get MinMacList():Array
		{
			var old:Array = AIRNetworkMAC.MACList;
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
				var list:Vector.<NativeNetworkInterface> = AirNetworkInfo.networkInfo.findInterfaces();
				for each (var info:NativeNetworkInterface in list)
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
			}
			catch (e:Error)
			{
				g.log.pushLog(AIRNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 错误 : " + e.message);
			}
			return "";
		}
		
		/**
		 * 获取特定名字的MAC地址 : FFFFFFFFFFFF
		 */
		public static function MinMacName(name:String):String
		{
			var str:String = AIRNetworkMAC.MACName(name);
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
