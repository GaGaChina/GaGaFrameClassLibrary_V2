package cn.wjj.tool 
{
	import flash.utils.Dictionary;
	
	/**
	 * 工厂管理类
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-03-14
	 */
	public class AdvancedFactory 
	{
		
		private static var lib:Object = new Object();
		
		/**
		 * 设置一个原型最多有多少个强记录对象一方便调用
		 * @param	prototype	类的原型
		 * @param	strength	类强引用的数量
		 */
		public static function setPrototype(prototype:Class, strength:uint):void
		{
			var record:Object;
			if (lib.hasOwnProperty(prototype))
			{
				record = lib[prototype] as Object;
				record.alength = strength;
				var a:Array = record.a as Array;
				if (strength == 0)
				{
					a.splice(0, a.length);
					delete lib[prototype];
				}
				else
				{
					while (a.length > strength)
					{
						record.d[a.pop()] = "";
					}
				}
			}
			else
			{
				record = new Object();
				record.a = new Array();
				record.alength = strength;
				record.d = new Dictionary(true);
				lib[prototype] = record;
			}
		}
		
		/**
		 * 获取一个对象
		 * @param	prototype	类的原型
		 * @return
		 */
		public static function getInstance(prototype:Class):*
		{
			var o:*;
			if (lib.hasOwnProperty(prototype))
			{
				var record:Object = lib[prototype] as Object;
				var a:Array = record.a as Array;
				var d:Dictionary = record.d as Dictionary;
				if (a.length)
				{
					return a.pop();
				}
				for (o in d)
				{
					delete d[o];
					return o;
				}
			}
			o = new prototype();
			return o;
		}
		
		/**
		 * 回收一个对象
		 * @param	prototype	类的原型
		 * @param	o
		 */
		public static function addRecover(prototype:Class, o:*):void
		{
			/**
			lib[prototype] = new Object();
			lib[prototype].a = new Array();//强记录
			lib[prototype].alength = 0;//强记录的个数
			lib[prototype].d = new Dictionary(true);//弱记录对象个数
			 */
			if(o == null)
			{
				throw new Error("对象池中不允许带入空对象!");
				return;
			}
			if(!(o is prototype))
			{
				throw new Error("对象类型不符!");
				return;
			}
			var record:Object;
			var a:Array;
			var d:Dictionary;
			if (lib.hasOwnProperty(prototype))
			{
				record = lib[prototype] as Object;
				a = record.a as Array;
				d = record.d as Dictionary;
			}
			else
			{
				a = new Array();
				d = new Dictionary(true);
				record = new Object();
				record.a = a;
				record.alength = 0;
				record.d = d;
				lib[prototype] = record;
			}
			if (a.indexOf(o) == -1)
			{
				if (a.length < record.alength)
				{
					a.push(o);
				}
				else
				{
					d[o] = "";
				}
			}

		}
	}
}