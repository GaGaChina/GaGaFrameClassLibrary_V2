package cn.wjj.air 
{
	import cn.wjj.tool.ArrayUtil;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	
	/**
	 * 获取用户的MAC地址
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-03-14
	 */
	public class NetworkMAC 
	{
		/**
		 * 获取用户的MAC地址 : FF-FF-FF-FF-FF-FF
		 */
		public static function get MAC():String
		{
			var str:String = "";
			if (NetworkInfo.isSupported)
			{
				str = ListMacDo.getHardwareMac("air", NetworkMAC.MACNameList);
			}
			return str;
		}
		
		/**
		 * 获取用户的MAC地址 : FFFFFFFFFFFF
		 */
		public static function get MinMac():String
		{
			var arr:Array = NetworkMAC.MAC.split("-");
			var str:String = arr.join("");
			arr = str.split(":");
			return arr.join("");
		}
		
		/**
		 * 获取用户的MAC地址 : 0xFFFFFFFFFFFF
		 */
		public static function get ShortMAC():String
		{
			var str:String = NetworkMAC.MAC;
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
			var str:String;
			if (NetworkInfo.isSupported)
			{
				var list:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				var addresses:InterfaceAddress;
				for each(var info:NetworkInterface in list)
				{
					str = info.hardwareAddress;
					if (str.substr(0, 2) == "0x")
					{
						str = str.substr(2);
					}
					if (str != "")
					{
						a.push(str);
					}
				}
			}
			//去除重复
			a = ArrayUtil.createUniqueCopy(a);
			return a;
		}
		
		/**
		 * 获取用户的MAC地址 : [FFFFFFFFFFFF,FFFFFFFFFFFF,FFFFFFFFFFFF]
		 */
		public static function get MinMacList():Array
		{
			var old:Array = NetworkMAC.MACList;
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
		 * 获取用户的全部MAC地址 : {"name":"FF-FF-FF-FF-FF-FF,FF-FF-FF-FF-FF-FF",.....}
		 */
		public static function get MACNameList():Object
		{
			var o:Object = new Object();
			var str:String = "";
			/** 同名的处理 **/
			var tm:Array = new Array();
			if (NetworkInfo.isSupported)
			{
				var list:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				var addresses:InterfaceAddress;
				for each(var info:NetworkInterface in list)
				{
					str = String(info.hardwareAddress);
					if (str.substr(0, 2) == "0x")
					{
						str = str.substr(2);
					}
					if (str.length > 0)
					{
						if (o[String(info.name)])
						{
							tm.push(String(info.name));
							o[String(info.name) + "." + o[String(info.name)]] = o[String(info.name)];
							delete o[String(info.name)];
						}
						if (tm.indexOf(String(info.name)) != -1)
						{
							o[String(info.name) + "." + str] = str;
						}
						else
						{
							o[String(info.name)] = str;
						}
					}
				}
			}
			return o;
		}
		
		/**
		 * 获取用户的MAC地址 : ["name":"FFFFFFFFFFFF","name":"FFFFFFFFFFFF","name":"FFFFFFFFFFFF"]
		 */
		public static function get MinMacNameList():Object
		{
			var old:Object = NetworkMAC.MACNameList;
			var arr:Array;
			var str:String;
			var out:Object = new Object();
			for (var name:String in old) 
			{
				arr = old[name].split("-");
				str = arr.join("");
				arr = str.split(":");
				out[name] = arr.join("");
			}
			return out;
		}
	}
}