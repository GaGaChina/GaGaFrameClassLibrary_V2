package cn.wjj.data.varslist 
{
	/**
	 * 
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2012-10-24
	 */
	internal class ItemModel 
	{
		/** 里面包含的数据对象 **/
		private var _vars:Object;
		
		public function ItemModel(vars:Object = null):void
		{
			_vars = new Object();
			if (vars != null)
			{
				for (var p:String in vars)
				{
					_vars[p] = vars[p];
				}
			}
		}
		/**
		 * 设置对象的一个属性,如果是null的时候,就删除特定属性
		 * @param	property
		 * @param	value
		 */
		private function _set(property:String, value:*):void
		{
			if (value == null)
			{
				delete _vars[property];
			}
			else
			{
				_vars[property] = value;
			}
		}
		/**
		 * 获取某一个特定属性
		 * @param	property
		 * @return
		 */
		private function _get(property:String):*
		{
			if (_vars.hasOwnProperty(property))
			{
				return _vars[property];
			}
			return null;
		}
		
		/** 添加一个ItemModel对象 **/
		public function addChild(value:ItemModel):void
		{
			if (value == null)
			{
				delete _vars["child"];
			}
			else
			{
				var arr:Array;
				if (_vars.hasOwnProperty("child"))
				{
					arr = _vars["child"] as Array;
				}
				else
				{
					arr = new Array();
				}
				arr.push(value.vars);
			}
		}
		//---- 获取设置参数 -----------------------------------------------------------------
		/**
		 * 获取这个Object对象
		 */
		public function get vars():Object{
			return _vars;
		}
		
		/** 对象名称 **/
		public function set name(value:String):void{
			_set("name", value);
		}
		public function get name():String{
			return _get("name");
		}
		
		/** 对象类型 **/
		public function set type(value:String):void{
			_set("type", value);
		}
		public function get type():String{
			return _get("type");
		}
		
		/** 变量的值 **/
		public function set variable(value:String):void{
			_set("variable", value);
		}
		public function get variable():String{
			return _get("variable");
		}
		
		/** 变量全路径 **/
		public function set groupName(value:String):void {
			if (value.substr(0,1) == ".")
			{
				value = value.substr(1);
			}
			_set("groupName", value);
		}
		public function get groupName():String{
			return _get("groupName");
		}
		
		/** 变量的大类别 **/
		public function set itemType(value:String):void {
			_set("itemType", value);
		}
		public function get itemType():String{
			return _get("itemType");
		}
		
		/** 值的子对象 **/
		public function set child(value:Array):void{
			_set("child", value);
		}
		public function get child():Array{
			return _get("child");
		}
	}
}