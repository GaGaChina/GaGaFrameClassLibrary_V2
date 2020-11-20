package cn.wjj.data
{
	import cn.wjj.g;
	
	/**
	 * 将Apple的配置文件PLIST格式,转换为Flash的Object对象
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-03-03
	 */
	public class PlistToObject
	{
		
		 /**
		  * 将Apple的配置文件PLIST格式,转换为Flash的Object对象
		  * @param xml
		  * @param obj
		  * @return 
		  */
		 static public function toObject(xml:XML , isArray:Boolean = false, obj:Object = null):Object
		 {
			if (obj == null)
			{
				if (isArray)
				{
					obj = new Array();
				}
				else
				{
					obj = new Object();
				}
				
			}
			var xmlList:XMLList;
			if (xml is XMLList)
			{
				xmlList = xml as XMLList;
			}
			else
			{
				xmlList = xml.children();
			}
			var localName:String;
			/** 键值的名称 **/
			var keyName:String;
			var theLength:int = xmlList.length();
			//这里一般是第一个值,特殊处理.
			if (theLength == 1 && !(obj is Array))
			{
				localName = xmlList[i].localName();
				switch(localName)
				{
					case "dict":
						obj = toObject(xmlList[i]);
						break;
					case "array":
						obj = toObject(xmlList[i], true);
						break;
					default:
						g.log.pushLog(null, g.logType._ErrorLog, "根目录没有指定是dict或者是array类型!");
						break;
				}
			}
			else
			{
				for (var i:int = 0; i < theLength; i++)
				{
					if (obj is Array)
					{
						//是数组的时候
						localName = xmlList[i].localName();
						switch(localName)
						{
							case "dict":
								(obj as Array).push(toObject(xmlList[i]));
								break;
							case "array":
								(obj as Array).push(toObject(xmlList[i], true));
								break;
							case "String":
							case "string":
								(obj as Array).push(String(xmlList[i].toString()));
								break;
							case "true":
								(obj as Array).push(true);
								break;
							case "false":
								(obj as Array).push(false);
								break;
							default:
								g.log.pushLog(null, g.logType._ErrorLog, "键值标签为:" + localName + "没有找到对应类型,直接对它进行了toString!");
								(obj as Array).push(String(xmlList[i].toString()));
								break;
						}
					}
					else
					{
						localName = xmlList[i].localName();
						if (localName == "key")
						{
							keyName = xmlList[i].toString();
							i = i + 1;
							if (i < theLength)
							{
								localName = xmlList[i].localName();
								switch(localName){
									case "dict":
										obj[keyName] = toObject(xmlList[i]);
										break;
									case "array":
										obj[keyName] = toObject(xmlList[i], true);
										break;
									case "String":
									case "string":
										obj[keyName] = String(xmlList[i].toString());
										break;
									case "true":
										obj[keyName] = true;
										break;
									case "false":
										obj[keyName] = false;
										break;
									default:
										g.log.pushLog(null, g.log.logType._ErrorLog, "键值标签为:" + localName + "没有找到对应类型,直接对它进行了toString!");
										obj[keyName] = String(xmlList[i].toString());
										break;
								}
							}
							else
							{
								g.log.pushLog(null, g.logType._ErrorLog, "解析PLIST文件出错,超过范围");
							}
						}
					}
				}
			}
			return obj;
		}
	}
}