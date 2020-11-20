package cn.wjj.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import cn.wjj.g;
	
	/**
	 * 创建一个HTTPBitmapData对象,并且自动下载内容
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2013-01-08
	 */
	public class HTTPBitmapData
	{
		/** 记录里面的对象,弱引用 **/
		private static var dataLib:Dictionary = new Dictionary(true);
		/** 是否开启记录日志,如果不开启,也会记录错误和沙箱错误二种日志 **/
		public static var config_isLog:Boolean = true;
		
		/**
		 * 通过URL连接地址,获取一恶搞HTTP对象
		 * @param url
		 * @return 
		 */
		public static function getHttp(url:String):BitmapData
		{
			for (var obj:* in dataLib) 
			{
				if(dataLib[obj] == url)
				{
					return obj as BitmapData;
				}
			}
			return null;
		}
		
		public static function destroyHttp(obj:BitmapData):void
		{
			if (obj)
			{
				delete dataLib[obj];
				obj.dispose();
			}
		}
		
		/** 发出的连接地址 **/
		public var url:String;
		/** 回调函数,function Function(e:HTTPBitmapData):void{} **/
		private var completeMethod:Function;
		/** 回调函数,function Function(e:HTTPBitmapData):void{} **/
		public var errorMethod:Function;
		/** URL里的BitmapData信息 **/
		public var bitmapData:BitmapData;
		/** 返回错误或成功的内容 **/
		public var event:Event;
		
		/**
		 * 创建一个HTTPBitmapData对象,并且自动下载内容
		 * @param	url					连接地址
		 * @param	completeMethod		完成后的回调函数,写法 function Function(e:HTTPBitmapData):void{}
		 * @param	completeDestroy		是否完成后运行完执行函数,自动删除这个对象
		 */
		public function HTTPBitmapData(url:String, completeMethod:Function, errorMethod:Function = null):void
		{
			var temp:BitmapData = HTTPBitmapData.getHttp(url);
			if(temp)
			{
				this.bitmapData = temp;
				if(completeMethod != null)
				{
					completeMethod(this);
					return;
				}
			}
			this.url = url;
			this.completeMethod = completeMethod;
			this.errorMethod = errorMethod;
			new HTTPLoader(url, completeHandler, errorHandler);
		}
		
		/** 加载完毕 **/
		private function completeHandler(e:HTTPLoader):void
		{
			this.bitmapData = (e.event.currentTarget.content as Bitmap).bitmapData;
			this.event = e.event;
			dataLib[this.bitmapData] = url;
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPLoader 完成 : " + e);
			}
			if (completeMethod != null)
			{
				completeMethod(this);
			}
		}
		
		/** 加载完毕 **/
		private function errorHandler(e:HTTPLoader):void
		{
			this.event = e.event;
			if (errorMethod != null)
			{
				errorMethod(this);
			}
		}
	}
}