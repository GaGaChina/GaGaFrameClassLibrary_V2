package cn.wjj.air
{
	import cn.wjj.tool.ArrayUtil;
	import com.adobe.nativeExtensions.Networkinfo.InterfaceAddress;
	import com.adobe.nativeExtensions.Networkinfo.NetworkInfo;
	import com.adobe.nativeExtensions.Networkinfo.NetworkInterface;
	
	import cn.wjj.g;
	
	public class IOSNetworkMAC
	{
		public function IOSNetworkMAC():void { }
		
		/**
		 * 获取用户的MAC地址 : FF-FF-FF-FF-FF-FF
		 * 这里有bug, en0 不能随便获取,好像是个变化值
		 */
		public static function get MAC():String
		{
			var str:String = "";
			try
			{
				str = ListMacDo.getHardwareMac("ios", IOSNetworkMAC.MACNameList)
			}
			catch (e:Error)
			{
				g.log.pushLog(IOSNetworkMAC, g.logType._ErrorLog, "IOS 走ANE 错误 : " + e.message);
			}
			return str;
		}
		
		/**
		 * 获取用户的MAC地址 : FFFFFFFFFFFF
		 */
		public static function get MinMac():String
		{
			var arr:Array = IOSNetworkMAC.MAC.split("-");
			var str:String = arr.join("");
			arr = str.split(":");
			return arr.join("");
		}
		
		/**
		 * 获取用户的MAC地址 : 0xFFFFFFFFFFFF
		 */
		public static function get ShortMAC():String
		{
			var str:String = IOSNetworkMAC.MAC;
			if (str.length > 0)
			{
				var arr:Array = str.split("-");
				str = arr.join("");
				arr = str.split(":");
				return "0x" + arr.join("");
			}
			return str;
		}
		
		/**
		 * 获取用户的全部MAC地址 : [FF-FF-FF-FF-FF-FF,FF-FF-FF-FF-FF-FF,.....]
		 */
		public static function get MACList():Array
		{
			var a:Array = new Array();
			try
			{
				//com.adobe.nativeExtensions.Networkinfo.NetworkInfo.networkInfo.findInterfaces();
				var list:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				for each (var info:NetworkInterface in list)
				{
					if (info.hasOwnProperty("hardwareAddress") && String(info.hardwareAddress))
					{
						a.push(String(info.hardwareAddress));
					}
				}
			}
			catch (e:Error)
			{
				g.log.pushLog(IOSNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 错误 : " + e.message);
			}
			//去除重复
			a = ArrayUtil.createUniqueCopy(a);
			g.log.pushLog(IOSNetworkMAC, g.logType._UserAction, "IOS 走ANE读取列表 " + a);
			return a;
		}
		
		/**
		 * 获取用户的全部MAC地址 : {"name":"FF-FF-FF-FF-FF-FF,FF-FF-FF-FF-FF-FF",.....}
		 */
		public static function get MACNameList():Object
		{
			var o:Object = new Object();
			/** 同名的处理 **/
			var tm:Array = new Array();
			try
			{
				//com.adobe.nativeExtensions.Networkinfo.NetworkInfo.networkInfo.findInterfaces();
				var list:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				for each (var info:NetworkInterface in list)
				{
					if (info.hasOwnProperty("hardwareAddress") && String(info.hardwareAddress))
					{
						if (o[info.name])
						{
							tm.push(info.name);
							o[info.name + "." + o[info.name]] = o[info.name];
							delete o[info.name];
						}
						if (tm.indexOf(info.name) != -1)
						{
							o[info.name + "." + String(info.hardwareAddress)] = String(info.hardwareAddress);
						}
						else
						{
							o[info.name] = String(info.hardwareAddress);
						}
					}
				}
			}
			catch (e:Error)
			{
				g.log.pushLog(IOSNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 错误 : " + e.message);
			}
			//去除重复
			g.log.pushLog(IOSNetworkMAC, g.logType._UserAction, "IOS 走ANE读取列表 " + g.jsonGetStr(o));
			return o;
		}
		
		/**
		 * 获取用户的MAC地址 : {"name":"FFFFFFFFFFFF","name":"FFFFFFFFFFFF","name":"FFFFFFFFFFFF"}
		 */
		public static function get MinMacNameList():Object
		{
			var old:Object = IOSNetworkMAC.MACNameList;
			var arr:Array;
			var str:String;
			var out:Object = new Object();
			for (var name:String in old) 
			{
				arr = old[name].split("-");
				str = arr.join("");
				arr = str.split(":");
				out[String(name)] = arr.join("");
			}
			return out;
		}
		
		/**
		 * 获取用户的MAC地址 : [FFFFFFFFFFFF,FFFFFFFFFFFF,FFFFFFFFFFFF]
		 */
		public static function get MinMacList():Array
		{
			var old:Array = IOSNetworkMAC.MACList;
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
				//com.adobe.nativeExtensions.Networkinfo.NetworkInfo.networkInfo.findInterfaces();
				var list:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
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
			}
			catch (e:Error)
			{
				g.log.pushLog(IOSNetworkMAC, g.logType._ErrorLog, "IOS 走ANE读取列表 错误 : " + e.message);
			}
			return "";
		}
		
		/**
		 * 获取特定名字的MAC地址 : FFFFFFFFFFFF
		 */
		public static function MinMacName(name:String):String
		{
			var str:String = IOSNetworkMAC.MACName(name);
			if (str.length > 0)
			{
				var arr:Array = str.split("-");
				str = arr.join("");
				arr = str.split(":");
				return arr.join("");
			}
			return str;
		}
	}
}
