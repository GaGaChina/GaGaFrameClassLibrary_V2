package cn.wjj.data
{
	import cn.wjj.tool.EncodeCode;
	import com.adobe.utils.StringUtil;
	
	/**
	 * 将一个Excel导出的Text文本转换为Array输出
	 * 如果变量名和变量类型为空,那么就绕过列
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-07-26
	 */
	public class ExcelTextToObject
	{
		/**
		 * (需要测试)将一个Excel导出的Text文本转换为Array输出
		 * @param	str			文本内容
		 * @param	infoRow		数据开始的行号(1开始)
		 * @param	nameRow		变量名称所在的行号(1开始)
		 * @param	typeRow		变量类型所在的行号(1开始)
		 * @param	cnRow		变量中文注释的行号(1开始)
		 * @return
		 */
		public static function to(str:String, infoRow:uint = 4, nameRow:uint = 2, typeRow:uint = 3, cnRow:uint = 1):Array
		{
			//去掉\r
			var row:Array = str.split("\r\n");
			str = row.join("\n");
			row = str.split("\n\r");
			str = row.join("\n");
			row = str.split("\r");
			str = row.join("");
			if (str.length)
			{
				infoRow--;
				nameRow--;
				typeRow--;
				cnRow--;
				//输出的数组
				var out:Array = new Array();
				//所有行的数据
				row = str.split("\n");
				var l:uint = row.length;
				var rowStr:String;
				var rowArr:Array;
				var rowObject:Object;
				var rowL:uint;
				var i:uint, j:uint;
				//取变量名称
				var varName:Array = new Array();
				varName = row[nameRow].split("	");
				var k:int;
				var kl:int = varName.length;
				for (k = 0; k < kl; k++)
				{
					varName[k] = StringUtil.trim(varName[k]);
				}
				rowL = varName.length;
				//取变量类型
				var varType:Array = new Array();
				varType = row[typeRow].split("	");
				kl = varType.length;
				for (k = 0; k < kl; k++)
				{
					varType[k] = StringUtil.trim(varType[k]);
				}
				//取值
				for (i = infoRow; i < l; i++) 
				{
					rowStr = row[i];
					if(rowStr.length > 0){
						//使用特殊符分割
						rowArr = rowStr.split("	");
						rowObject = new Object();
						for (j = 0; j < rowL; j++)
						{
							if (String(varName[j]).length > 0 && String(varType[j]).length > 0)
							{
								rowObject[varName[j]] = getVar(varType[j], rowArr[j]);
							}
						}
						out.push(rowObject);
					}
				}
				return out;
			}
			return null;
		}
		
		/**
		 * 按一种类型取某一种数据
		 * 支持:string,number,int,uint,array[|分割],boolean[true,1,false,0]
		 * @param	type
		 * @param	vars
		 * @return
		 */
		private static function getVar(type:String , vars:String):*
		{
			type = type.toLowerCase();
			switch (type) 
			{
				case "string":
					if (vars == null || vars.length == 0)
					{
						return "";
					}
					else
					{
						return String(vars);
					}
					break;
				case "number":
					if (vars == null || vars.length == 0)
					{
						return Number(0);
					}
					else
					{
						return Number(vars);
					}
					break;
				case "int":
					if (vars == null || vars.length == 0)
					{
						return int(0);
					}
					else
					{
						return int(Number(vars));
					}
					break;
				case "uint":
					if (vars == null || vars.length == 0)
					{
						return uint(0);
					}
					else
					{
						return uint(Number(vars));
					}
					break;
				case "array":
					if (vars == null || vars.length == 0)
					{
						vars = "";
					}
					var arr:Array = vars.split("|");
					return arr;
					break;
				case "boolean":
					vars = vars.toLowerCase();
					if (vars == "true" || vars == "1")
					{
						return true;
					}
					else
					{
						return false;
					}
					break;
				default:
					if (vars.length == 0)
					{
						return "";
					}
					else
					{
						return String(vars);
					}
			}
		}
	}
}