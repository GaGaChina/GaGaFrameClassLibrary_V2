package cn.wjj.data.varslist 
{
	import cn.wjj.data.XMLToObject;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	/**
	 * 把Flash里面的变量或Object输出为一个数组,以方便在Flex里展示出内容来
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2012-10-24
	 */
	public class ObjectToArrayList 
	{
		/** 缺少类型 **/
		private static var noType:Array;
		/** 最大允许递归多少层 **/
		private static var maxlayer:uint;
		
		public static function getArray(obj:* , maxlayer:uint = 0):Array
		{
			noType = new Array();
			var out:Array = new Array();
			var item:ItemModel = new ItemModel();
			item.name = "根"
			item.groupName = "";
			ObjectToArrayList.maxlayer = maxlayer;
			getChildItem(item, obj, 0);
			out.push(item.vars);
			trace("缺少类型 : " + noType.toString())
			return out;
		}
		
		/**
		 * 把obj的内容,加入到item的Child里面,最后返回
		 * @param	inArr
		 * @param	obj
		 * @param	layer		最多层数
		 * @return
		 */
		private static function getChildItem(item:ItemModel, obj:*, layer:uint):ItemModel
		{
			layer++;
			if(maxlayer == 0 || layer <= maxlayer)
			{
				var info:XML = describeType(obj);
				var infoObj:Object = XMLToObject.to(info);
				item.type = info.@name.toString();
				switch (item.type) 
				{
					case "String":
					case "Boolean":
					case "Number":
					case "int":
					case "uint":
						item.itemType = item.type;
						item.variable = obj;
						break;
					case "Object":
						item.itemType = item.type;
						item.child = forObject(obj, item, layer);
						break;
					case "Array":
						item.itemType = item.type;
						item.child = forArray(obj, item, layer);
						break;
					default:
						if (obj is DisplayObjectContainer)
						{
							if(obj is MovieClip)
							{
								item.itemType = "MovieClip";
							}
							else if(obj is Sprite)
							{
								item.itemType = "Sprite";
							}
							else if(obj is Loader)
							{
								item.itemType = "Loader";
							}
							else if(obj is Stage)
							{
								item.itemType = "Stage";
							}
							else
							{
								item.itemType = "DisplayObjectContainer";
							}
							item.child = forDisplayObjectContainer(obj, item, layer);
						}
						else if (obj is DisplayObject)
						{
							if(obj is Shape)
							{
								item.itemType = "Shape";
							}
							else if(obj is SimpleButton)
							{
								item.itemType = "SimpleButton";
							}
							else if(obj is Bitmap)
							{
								item.itemType = "Bitmap";
							}
							else
							{
								item.itemType = "DisplayObject";
							}
							//item.variable = "";
						}
						else if(obj is ByteArray)
						{
							item.itemType = "ByteArray";
						}
						else
						{
							noType[item.type] = item.type;
						}
				}
			}
			else
			{
				item.itemType = "层级过长";
				item.variable = "层级过长";
			}
			return item;
		}
		
		/**
		 * 把一个Object对象输出出一个Array的对象
		 * @param	obj
		 * @return
		 */
		private static function forObject(obj:Object, parent:ItemModel, layer:uint):Array
		{
			var out:Array = new Array();
			var item:ItemModel;
			var vars:*;
			for (var name:String in obj) 
			{
				item = new ItemModel();
				item.name = name;
				item.groupName = parent.groupName + "." + name;
				vars = obj[name];
				getChildItem(item, vars, layer);
				out.push(item.vars);
			}
			return out;
		}
		
		/**
		 * 把一个Array对象输出出一个Array的对象
		 * @param	obj
		 * @param	parent
		 * @return
		 */
		private static function forArray(obj:Array, parent:ItemModel, layer:uint):Array
		{
			var out:Array = new Array();
			var item:ItemModel;
			var vars:*;
			for (var name:String in obj) 
			{
				item = new ItemModel();
				item.name = name;
				item.groupName = parent.groupName + "." + name;
				vars = obj[name];
				getChildItem(item, vars, layer);
				out.push(item.vars);
			}
			return out;
		}
		
		/**
		 * 获取显示对象列表中一些数据
		 * @param	obj
		 * @return
		 */
		private static function forDisplayObjectContainer(obj:DisplayObjectContainer, parent:ItemModel, layer:uint):Array
		{
			var out:Array = new Array();
			var item:ItemModel;
			var vars:*;
			var l:uint = obj.numChildren;
			for (var i:int = 0; i < l; i++) 
			{
				item = new ItemModel();
				vars = obj.getChildAt(i);
				item.name = vars.name;
				item.groupName = parent.groupName + "." + item.name;
				item.name = "[index:" + i + "]" + item.name;
				getChildItem(item, vars, layer);
				out.push(item.vars);
			}
			return out;
		}
	}

}