package cn.wjj.data
{
	import cn.wjj.g;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * 创建一个HTTPByte对象,并且自动下载内容
	 * 
	 * @version 0.9.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-06-01
	 */
	public class HTTPByte
	{
		
		private static var httpLib:Dictionary = new Dictionary();
		/** 是否开启记录日志,如果不开启,也会记录错误和沙箱错误二种日志 **/
		public static var config_isLog:Boolean = true;
		
		/**
		 * 通过URL连接地址,获取一恶搞HTTP对象
		 * @param url
		 * @return 
		 */
		public static function getHttp(url:String):HTTPByte
		{
			for each (var obj:HTTPByte in httpLib) 
			{
				if(obj.url == url)
				{
					return obj;
				}
			}
			return null;
		}
		
		public static function destroyHttp(obj:HTTPByte):void
		{
			if (obj)
			{
				obj.url = "";
				obj.variables = null;
				obj.completeMethod = null;
				obj.loadingMethod = null;
				obj.errorMethod = null;
				obj.stream = null;
				obj.isComplete = false;
				obj.data = null;
				delete httpLib[obj];
			}
		}
		
		/** URLStream 对象 **/
		private var _stream:URLStream;
		/** 发出的连接地址 **/
		public var url:String;
		/** 发出的信息 **/
		public var variables:URLVariables;
		/** 回调函数,function Function(e:HTTPByte):void{} **/
		public var completeMethod:Function;
		/** 回调函数,function Function(e:HTTPByte):void{} **/
		public var loadingMethod:Function;
		/** 回调函数,function Function(e:HTTPByte):void{} **/
		public var errorMethod:Function;
		/** 是否已经完成 **/
		public var isComplete:Boolean = false;
		/** 回传的数据 **/
		public var data:ByteArray;
		/** 完成后是否自动删除这个对象 **/
		public var completeDestroy:Boolean = false;
		/** 事件返回的内容 **/
		public var event:Event;
		
		/** 文件本次加载长度 **/
		public var bytesAdd:int;
		/** 文件已加载长度 **/
		public var bytesLoaded:int;
		/** 文件总长度 **/
		public var bytesTotal:int;
		
		/**
		 * 创建一个HTTPByte对象,并且自动下载内容
		 * @param	url					连接地址
		 * @param	completeMethod		完成后的回调函数,写法 function Function(e:HTTPByte):void{}, e.data 是数据
		 * @param	loadingMethod		有数据的时候回调
		 * @param	variables			发送的时候的参数
		 * @param	isPost				是否是POST连接,false就是GET
		 * @param	completeDestroy		是否完成后运行完执行函数,自动删除这个对象
		 * @param	errorMethod			错误的时候回调
		 */
		public function HTTPByte(url:String, completeMethod:Function, loadingMethod:Function = null, autoReChange:Boolean = false, variables:URLVariables = null, isPost:Boolean = true, completeDestroy:Boolean = true, errorMethod:Function = null):void
		{
			reLoad(url, completeMethod, loadingMethod, autoReChange, variables, isPost, completeDestroy, errorMethod);
		}
		
		public function reLoad(url:String, completeMethod:Function, loadingMethod:Function = null, isCache:Boolean = false, variables:URLVariables = null, isPost:Boolean = true, completeDestroy:Boolean = true, errorMethod:Function = null):void
		{
			httpLib[this] = url;
			this.url = url;
			this.variables = variables;
			this.completeMethod = completeMethod;
			this.loadingMethod = loadingMethod;
			this.errorMethod = errorMethod;
			this.completeDestroy = completeDestroy;
			this.isComplete = false;
			stream = new URLStream();
			var request:URLRequest = new URLRequest(url);
			request.contentType = "multipart/form-data";
			request.contentType = "application/octet-stream";
			if (isCache)
			{
				/*
				request.useCache = false;
				request.cacheResponse = false;
				*/
				if(variables == null)
				{
					variables = new URLVariables();
				}
				variables.exampleSessionId = g.time.getTime();
			}
			if (variables)
			{
				request.data = variables;
			}
			if(isPost)
			{
				request.method = URLRequestMethod.POST;
			}
			else
			{
				request.method = URLRequestMethod.GET;
			}
			_stream.load(request);
		}
		
		/** URLStream 对象 **/
		public function get stream():URLStream
		{
			return _stream;
		}
		
		/** URLStream 对象 **/
		public function set stream(value:URLStream):void
		{
			if (_stream != value)
			{
				if (_stream)
				{
					removeListeners(_stream);
					_stream.close();
				}
				if (value)
				{
					addListeners(value);
				}
				_stream = value;
			}
		}
		
		/** 添加监听事件 **/
		protected function addListeners(dispatcher:IEventDispatcher):void
		{
			g.event.addListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.addListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.addListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.addListener(dispatcher, Event.OPEN, openHandler);
			g.event.addListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.addListener(dispatcher, Event.COMPLETE, completeHandler);
			g.event.addListener(dispatcher, Event.INIT, initHandler);
			g.event.addListener(dispatcher, Event.UNLOAD, unLoadHandler);
		}
		
		/** 删除监听事件 **/
		protected function removeListeners(dispatcher:IEventDispatcher):void
		{
			g.event.removeListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.removeListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.removeListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.removeListener(dispatcher, Event.OPEN, openHandler);
			g.event.removeListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.removeListener(dispatcher, Event.COMPLETE, completeHandler);
			g.event.removeListener(dispatcher, Event.INIT, initHandler);
			g.event.removeListener(dispatcher, Event.UNLOAD, unLoadHandler);
		}
		
		/** 加载完毕 **/
		protected function completeHandler(e:Event):void
		{
			this.event = e;
			this.isComplete = true;
			var byte:ByteArray = new ByteArray();
			e.currentTarget.readBytes(byte);
			this.data = byte;
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPByte 完成 : " + e);
			}
			if (completeMethod != null)
			{
				completeMethod(this);
				completeMethod = null;
			}
			if (completeDestroy)
			{
				HTTPByte.destroyHttp(this);
			}
		}
		
		/** 沙箱错误 **/
		protected function securityErrorHandler(e:SecurityErrorEvent):void
		{
			this.event = e;
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPByte url : " + this.url + " 沙箱错误 : " + e);
			if (errorMethod != null)
			{
				errorMethod(this);
				errorMethod = null;
			}
			HTTPByte.destroyHttp(this);
		}
		
		/** URL不可用或不可访问 **/
		protected function ioErrorHandler(e:IOErrorEvent):void
		{
			this.event = e;
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPByte url : " + this.url + " IO错误 : " + e);
			if (errorMethod != null)
			{
				errorMethod(this);
				errorMethod = null;
			}
			HTTPByte.destroyHttp(this);
		}
		
		/** 非本地加载，并且只有在网络请求可用并可被 Flash Player 检测到的情况下，才会执行 httpStatusHandler() 方法 **/
		protected function httpStatusHandler(e:HTTPStatusEvent):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPByte httpStatusHandler : " + e);
			}
			/*
			这里也会崩溃
			var isBug:Boolean = false;
			if (e.status >= 400 && e.status < 500)
			{
				//Client Error 4xx
				//4xx应答定义了特定服务器响应的请求失败的情况。客户端不应当在不更改请求的情况下重新尝试同一个请求。（例如，增加合适的认证信息）。不过，同一个请求交给不同服务器也许就会成功。 
				isBug = true;
			}
			else if(e.status >= 500 && e.status < 600)
			{
				//Server Error 5xx
				isBug = true;
			}
			if (isBug)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPByte 拒绝请求 httpStatusHandler : " + e.status);
				HTTPByte.destroyHttp(this);
				if (errorMethod != null)
				{
					errorMethod(this);
				}
			}
			*/
		}
		
		/** initHandler() 方法在 completeHandler() 方法之前、progressHandler() 方法之后执行。 通常，init 事件在加载 SWF 文件时更有用 **/
		protected function initHandler(e:Event):void
		{
			if (config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPByte initHandler: " + e);
			}
		}
		
		/** 开打连接的时候 **/
		protected function openHandler(e:Event):void
		{
			if (config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPByte 打开连接 : " + e);
			}
		}
		
		/** 记录下载加载的长度 **/
		private var tempLoaded:int;
		/** 记录下载数量的数量 **/
		protected function progressHandler(e:ProgressEvent):void
		{
			bytesLoaded = e.bytesLoaded;
			bytesAdd = bytesLoaded - tempLoaded;
			tempLoaded = bytesLoaded;
			bytesTotal = e.bytesTotal;
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPByte 下载中 : " + "总大小:" + e.bytesTotal + " 剩余大小:" + e.bytesLoaded);
			}
			if(loadingMethod != null)
			{
				loadingMethod(this);
			}
		}
		
		/** 被卸载 **/
		protected function unLoadHandler(e:Event):void
		{
			if (config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPByte 被卸载 : " + e);
			}
		}
	}
}