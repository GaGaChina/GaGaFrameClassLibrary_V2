package cn.wjj.air 
{
	import cn.wjj.g;
	
	/**
	 * 对一批MAC地址进行处理
	 * @author GaGa
	 */
	public class ListMacDo 
	{
		
		public function ListMacDo() {}
		
		/**
		 * 抽取用户默认的MAC地址,先按照各个平台抽取
		 * @param	type			ios 或其他
		 * @param	MACNameList
		 * @return
		 */
		public static function getHardwareMac(type:String, MACNameList:Object):String
		{
			/** MAC地址 **/
			var str:String;
			/** MAC地址里有出现过的字符串 **/
			var strNum:String = "";
			/** 抽查排序使用 **/
			var i:int;
			/** 现在选中的MAC地址 **/
			var theName:String = "";
			var theMac:String = "";
			var theLength:int = 0;
			/** 走对比流程的时候使用的MAC地址 **/
			var duibi:int = 0;
			var duibi_do:int = 0;
			var duibi_isDo:Boolean = false;
			/** 苹果上默认选中的mac地址 **/
			var en0:String = "";
			var en1:String = "";
			var en2:String = "";
			
			for (var name:String in MACNameList) 
			{
				str = MACNameList[name];
				if (type == "ios")
				{
					if (name == "en0")
					{
						en0 = ListMacDo.isOkMac(str);
					}
					else if (name == "en1")
					{
						en1 = ListMacDo.isOkMac(str);
					}
					else if (name == "en2")
					{
						en2 = ListMacDo.isOkMac(str);
					}
				}
				i = str.length;
				strNum = "";
				while (--i > -1)
				{
					if (strNum.indexOf(str.substr(i, 1)) == -1)
					{
						strNum += str.substr(i, 1);
					}
				}
				if (strNum.indexOf("-") != -1)
				{
					strNum = strNum.substr(0, (strNum.length - 1));
				}
				if (strNum.indexOf(":") != -1)
				{
					strNum = strNum.substr(0, (strNum.length - 1));
				}
				if (theLength < strNum.length)
				{
					theLength = strNum.length;
					theMac = str;
					theName = name;
				}
				else if (theLength == strNum.length)
				{
					if (name == theName)
					{
						//名称相等,找mac地址的区别
						if (str != theMac)
						{
							//如果二个mac地址名称一样就对比内容部分
							duibi = str.length;
							if (duibi > theMac.length)
							{
								duibi = theMac.length;
							}
							duibi_isDo = false;
							//倒序排序,找大的
							while (--duibi > -1)
							{
								if (str.charCodeAt(duibi) > theMac.charCodeAt(duibi))
								{
									
									duibi_isDo = true;
									theLength = strNum.length;
									theMac = str;
									theName = name;
									break;
								}
							}
							//剩余的是内容有相等的,取长的
							if (duibi_isDo == false)
							{
								if (str.length > theMac.length)
								{
									theLength = strNum.length;
									theMac = str;
									theName = name;
								}
							}
						}
					}
					else
					{
						//开始对比二个名称,太小的名称不放弃
						if (name.length < 3 && theName.length > 2)
						{
							//如果现在的mac的地址名称比2个还短,就无视,选择超过3个了
						}
						else if (theName.length < 3 && name.length > 2)
						{
							//替换
							//如果新的网卡名称短,就用新的
							theLength = strNum.length;
							theMac = str;
							theName = name;
						}
						else if(name.length > 2 && theName.length > 2 && theName.length < name.length)
						{
							//如果现在的名称大于2位,并且现在的名称长度比新的短,就用老的,优先取短的
						}
						else if(name.length > 2 && theName.length > 2 && name.length < theName.length)
						{
							//如果新的网卡名称短,就用新的
							theLength = strNum.length;
							theMac = str;
							theName = name;
						}
						else
						{
							//剩下名称长度相等的, name长度比较大的, 排序,如果name里排序值低才可以赋值进去
							duibi = name.length;
							if (duibi > theName.length)
							{
								duibi = theName.length;
							}
							duibi_isDo = false;
							for (duibi_do = 0; duibi_do < duibi; duibi_do++)
							{
								if (name.charCodeAt(duibi_do) < theName.charCodeAt(duibi_do))
								{
									duibi_isDo = true;
									theLength = strNum.length;
									theMac = str;
									theName = name;
									break;
								}
							}
							//剩余的是内容有相等的,取长的名称
							if (duibi_isDo == false)
							{
								if (name.length > theName.length)
								{
									theLength = strNum.length;
									theMac = str;
									theName = name;
								}
							}
						}
					}
				}
			}
			if (en0.length > 0)
			{
				str = en0;
			}
			else if (en1.length > 0)
			{
				str = en1;
			}
			else if (en2.length > 0)
			{
				str = en2;
			}
			else
			{
				str = theMac;
			}
			str = ListMacDo.isOkMac(str);
			return str;
		}
		
		/**
		 * 检查是否是正常的MAC地址,不是就返回空字符串
		 * @param	mac
		 * @return
		 */
		public static function isOkMac(str:String):String
		{
			if (!str)
			{
				return "";
			}
			var mac:String = str;
			if (mac.length > 1 && mac.substr(0, 2) == "0x")
			{
				mac = mac.substr(2);
			}
			var i:int = mac.length;
			var strNum:String = "";
			while (--i > -1)
			{
				if (strNum.indexOf(mac.substr(i, 1)) == -1)
				{
					strNum += mac.substr(i, 1);
				}
			}
			if (strNum.indexOf("-") != -1)
			{
				strNum = strNum.substr(0, (strNum.length - 1));
			}
			if (strNum.indexOf(":") != -1)
			{
				strNum = strNum.substr(0, (strNum.length - 1));
			}
			if (strNum.length < 3)
			{
				g.log.pushLog(ListMacDo, g.logType._Warning, "检测到假MAC : " + str);
				str = "";
			}
			return str;
		}
	}
}