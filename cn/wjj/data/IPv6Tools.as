package cn.wjj.data 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	/**
	 * 2002::/16 是一个前缀网段，前16位为2002   3ffe:1994:100:a::/64
	 * 通过在IPV6地址后面加一个斜线/，再跟一个十进制的数字来标识一个IPV6地址的起始位由多少位是前缀位，一般前缀为64位
	 * 例如：FE80:1000:0200:0030:AAAA:0004:00C2:0002 -> FE80:1000:200:30:AAAA:4:C2:2
	 * 1:2:3:4:5:6:192.168.1.100 带有ipv4地址
	 * @author GaGa
	 */
	public class IPv6Tools 
	{
		
		public function IPv6Tools() { }
		
		/**
		 * 判断是否是IPv6的IP
		 * @param	ip
		 * @return
		 */
		public static function isIPv6(ip:String):Boolean
		{
			if (ip.indexOf(":") == -1)
			{
				return false;
			}
			return true;
		}
		
		
		/**
		 * 获取IP的整形的IP
		 * @param	ip
		 * @return
		 */
		public static function getAllIp(ip:String):String
		{
			if (isIPv6(ip))
			{
				if (ip == "::/0")
				{
					return "0000:0000:0000:0000:0000:0000:0000:0000";
				}
				if (ip.indexOf(".") != -1)
				{
					g.log.pushLog(IPv6Tools, LogType._ErrorLog, "IPv6无法处理带IPv4地址:" + ip);
					return ip;
				}
				//fe80::20c:29ff:feef:6934/64
				//首先拆分 /
				var allIp:String = "";
				var a:Array;
				var i:int;
				if (ip.indexOf("/") != -1)
				{
					a = ip.split("/");
					//差几个16位
					//i = (128 - int(a[1])) / 16;
					ip = ip[0];
				}
				if (ip.indexOf("%") != -1)
				{
					a = ip.split("%");
					ip = ip[0];
				}
				//前导零压缩法,本来有7个:
				if (ip.indexOf("::") != -1)
				{
					a = ip.split("::");
					i = ip.split(":").length;
					if (a.length == 2)
					{
						if (a[0] == "" && a[1] == "")
						{
							return "0000:0000:0000:0000:0000:0000:0000:0000";
						}
						else if (a[0] == "")
						{
							//在开头位置
							switch (i) 
							{
								case 2://::FFFF      FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
									ip = "0000:0000:0000:0000:0000:0000:0000:" + a[1];
									break;
								case 3://::FFFF:FFFF      FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
									ip = "0000:0000:0000:0000:0000:0000:" + a[1];
									break;
								case 4:
									ip = "0000:0000:0000:0000:0000:" + a[1];
									break;
								case 5:
									ip = "0000:0000:0000:0000:" + a[1];
									break;
								case 6:
									ip = "0000:0000:0000:" + a[1];
									break;
								case 7://::FFFF:FFFF:FFFF:FFFF:FFFF:FFFF    FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
									ip = "0000:0000:" + a[1];
									break;
								default:
									g.log.pushLog(IPv6Tools, LogType._ErrorLog, "IPv6处理出错:" + ip);
							}
							
						}
						else if (a[1] == "")
						{
							//在末尾位置
							switch (i) 
							{
								case 2://FFFF::      FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
									ip = a[0] + ":0000:0000:0000:0000:0000:0000:0000";
									break;
								case 3://FFFF:FFFF::      FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
									ip = a[0] + ":0000:0000:0000:0000:0000:0000";
									break;
								case 4:
									ip = a[0] + ":0000:0000:0000:0000:0000";
									break;
								case 5:
									ip = a[0] + ":0000:0000:0000:0000";
									break;
								case 6:
									ip = a[0] + ":0000:0000:0000";
									break;
								case 7://FFFF:FFFF:FFFF:FFFF:FFFF:FFFF::    FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
									ip = a[0] + ":0000:0000";
									break;
								default:
									g.log.pushLog(IPv6Tools, LogType._ErrorLog, "IPv6处理出错:" + ip);
							}
						}
						else
						{
							//在中间位置
							switch (i) 
							{
								case 2://FFFF::FFFF      FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
									ip = a[0] + ":0000:0000:0000:0000:0000:0000:" + a[1];
									break;
								case 3:
									ip = a[0] + ":0000:0000:0000:0000:0000:" + a[1];
									break;
								case 4:
									ip = a[0] + ":0000:0000:0000:0000:" + a[1];
									break;
								case 5:
									ip = a[0] + ":0000:0000:0000:" + a[1];
									break;
								case 6:
									ip = a[0] + ":0000:0000:" + a[1];
									break;
								case 7:
									ip = a[0] + ":0000:" + a[1];
									break;
								default:
									g.log.pushLog(IPv6Tools, LogType._ErrorLog, "IPv6处理出错:" + ip);
							}
						}
					}
					else
					{
						g.log.pushLog(IPv6Tools, LogType._ErrorLog, "IPv6处理出错:" + ip);
					}
				}
				a = ip.split(":");
				for each (var item:String in a) 
				{
					if (item == "")
					{
						g.log.pushLog(IPv6Tools, LogType._ErrorLog, "IPv6处理出错:" + ip);
					}
					else
					{
						switch (item.length) 
						{
							case 1:
								item = "000" + item;
								break;
							case 2:
								item = "00" + item;
								break;
							case 3:
								item = "0" + item;
								break;
						}
						if (allIp == "")
						{
							allIp = item;
						}
						else
						{
							allIp += ":" + item;
						}
					}
				}
				return allIp;
			}
			return ip;
		}
		
	}

}