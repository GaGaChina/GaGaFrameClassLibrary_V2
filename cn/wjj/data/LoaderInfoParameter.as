package cn.wjj.data{
	
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	
	import cn.wjj.g;
	
	/**
	 * 获取URL.
	 * 可以定义如果焦点在某对象上,就生效某些快捷键.
	 * 
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class LoaderInfoParameter{
		
		/**
		 * 从LoaderInfo里取出对应的parameter变量
		 * @param name
		 * @return 
		 */
		public static function getParameter(name:String):*
		{
			var info:LoaderInfo = g.bridge.swfRoot.stage.loaderInfo as LoaderInfo;
			var parameter:Object = info.parameters;
			if(parameter.hasOwnProperty(name))
			{
				return parameter[name];
			}
			else
			{
				return null;
			}
		}
	}
}