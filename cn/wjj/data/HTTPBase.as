package cn.wjj.data
{
	import cn.wjj.g;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	
	/**
	 * 创建一个HTTPBase对象,并且自动下载内容
	 * 
	 * @version 0.9.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-06-01
	 */
	public class HTTPBase
	{
		private static var httpLib:Dictionary = new Dictionary();
		/** 是否开启记录日志,如果不开启,也会记录错误和沙箱错误二种日志 **/
		public static var config_isLog:Boolean = true;
		
		/**
		 * 通过URL连接地址,获取一恶搞HTTP对象
		 * @param url
		 * @return 
		 */
		public static function getHttp(url:String):HTTPBase
		{
			for each (var obj:HTTPBase in httpLib) 
			{
				if(obj.url == url)
				{
					return obj;
				}
			}
			return null;
		}
		
		public static function destroyHttp(o:HTTPBase):void
		{
			if (o)
			{
				o.url = "";
				o.variables = null;
				o.errorMethod = null;
				o.completeMethod = null;
				o.loader = null;
				o.isComplete = false;
				o.data = null;
				o.ioTimeout = 0;
				o.ioStart = 0;
				o.ioEnd = 0;
				delete httpLib[o];
			}
		}
		
		/** URLLoader 对象 **/
		private var _loader:URLLoader;
		/** 发出的连接地址 **/
		public var url:String;
		/** 发出的信息 **/
		public var variables:URLVariables;
		/** 回调函数,function Function(e:HTTPBase):void{} **/
		public var completeMethod:Function;
		/** 回调函数,function Function(e:HTTPBase):void{} **/
		public var errorMethod:Function;
		/** 是否已经完成 **/
		public var isComplete:Boolean = false;
		/** 回传的数据 **/
		public var data:Object;
		/** 返回错误或成功的内容 **/
		public var event:Event;
		/** 完成后是否自动删除这个对象 **/
		public var completeDestroy:Boolean = false;
		/** 建立连接的超时时间 **/
		public var ioTimeout:uint = 0;
		/** 连接开始时间 **/
		private var ioStart:Number = 0;
		/** 连接最晚时间 **/
		private var ioEnd:Number = 0;
		/**
		 * 创建一个HTTPBase对象,并且自动下载内容
		 * @param	url					连接地址
		 * @param	completeMethod		完成后的回调函数,写法 function Function(e:HTTPBase):void{}, e.currentTarget.data 是数据
		 * @param	useCache			是否优先查询本地缓存的数据,并保存到本地缓存
		 * @param	variables			发送的时候的参数
		 * @param	isPost				是否是POST连接,false就是GET
		 * @param	completeDestroy		是否完成后运行完执行函数,自动删除这个对象
		 * @param	errorMethod			完成后的回调函数,写法 function Function(e:HTTPBase):void{}
		 * @param	ioTimeout			建立连接的超时时间
		 * @param	idleTimeout			指定此请求的空闲超时值（以毫秒为单位）空闲超时值是指客户端在建立连接之后、放弃请求之前等待服务器响应的时间
		 */
		public function HTTPBase(url:String, completeMethod:Function, useCache:Boolean = false, variables:URLVariables = null, isPost:Boolean = true, completeDestroy:Boolean = true, errorMethod:Function = null, ioTimeout:uint = 0, idleTimeout:uint = 0):void
		{
			reLoad(url, completeMethod, useCache, variables, isPost, completeDestroy, errorMethod, ioTimeout, idleTimeout);
		}
		
		public function reLoad(url:String, completeMethod:Function, isCache:Boolean = false, variables:URLVariables = null, isPost:Boolean = true, completeDestroy:Boolean = true, errorMethod:Function = null, ioTimeout:uint = 0, idleTimeout:uint = 0):void
		{
			httpLib[this] = url;
			this.url = url;
			this.variables = variables;
			this.completeMethod = completeMethod;
			this.completeDestroy = completeDestroy;
			this.errorMethod = errorMethod;
			this.isComplete = false;
			this.ioTimeout = ioTimeout;
			loader = new URLLoader();
			var request:URLRequest = new URLRequest(url);
			if (idleTimeout != 0)
			{
				//request.idleTimeout = idleTimeout;
			}
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
			if (ioTimeout)
			{
				ioStart = new Date().time;
				ioEnd = ioStart + ioTimeout;
				g.event.addEnterFrame(ioEnterFrame);
			}
			loader.load(request);
		}
		
		private function ioEnterFrame():void
		{
			if (ioEnd < new Date().time)
			{
				errorDo();
			}
		}
		
		/** URLLoader 对象 **/
		public function get loader():URLLoader {
			return _loader;
		}
		
		/** URLLoader 对象 **/
		public function set loader(value:URLLoader):void {
			if (value === _loader)
			{
				return;
			}
			else
			{
				if (_loader)
				{
					try
					{
						_loader.close();
					}
					catch (e:Error) { }
					removeListeners(_loader);
				}
				if (value)
				{
					addListeners(value);
				}
			}
			_loader = value;
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
		
		private function closeHandler(e:Error):void
		{
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPBase 错误 : " + e);
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
			this.isComplete = true;
			this.event = e;
			this.data = e.currentTarget.data;
			if (config_isLog) g.log.pushLog(this, g.logType._Record, "HTTPBase 完成 : " + e);
			if (completeMethod != null)
			{
				var method:Function = completeMethod;
				completeMethod = null;
				method(this);
			}
			if (completeDestroy) HTTPBase.destroyHttp(this);
		}
		
		/** 沙箱错误 **/
		protected function securityErrorHandler(e:SecurityErrorEvent):void
		{
			this.event = e;
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPBase 沙箱错误 : " + url + " : " + e);
			errorDo();
		}
		
		/** URL不可用或不可访问 **/
		protected function ioErrorHandler(e:IOErrorEvent):void
		{
			this.event = e;
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPBase IO错误 : " + url + " : " + e);
			errorDo();
		}
		
		private function errorDo():void
		{
			g.event.removeEnterFrame(ioEnterFrame);
			if (errorMethod != null) errorMethod(this);
			HTTPBase.destroyHttp(this);
		}
		
		/** 非本地加载，并且只有在网络请求可用并可被 Flash Player 检测到的情况下，才会执行 httpStatusHandler() 方法 **/
		protected function httpStatusHandler(e:HTTPStatusEvent):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPBase httpStatusHandler : " + e);
			}
			/*
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
				g.log.pushLog(this, g.logType._Record, "HTTPBase 拒绝请求 httpStatusHandler : " + e.status + " url : " + url);
				var f:Function = errorMethod;
				try
				{
					if (loader)
					{
						loader.close();
					}
				}
				catch (e:Error) { }
				errorMethod = null;
				completeMethod = null;
				isComplete = false;
				data = null;
				delete httpLib[this];
				if (f != null)
				{
					f(this);
				}
			}
			*/
			/*
			switch (e.status) 
			{
				case 0:
					//一切正常
					break;
				case 400://请求中的语法错误。Reason-Phrase应当标志这个详细的语法错误，比如”Missing Call-ID header field”
				case 401://请求需要用户认证。这个应答是由UAS和注册服务器产生的，当407（Proxy Authentication Required）是proxy服务器产生的
				case 403://服务端支持这个请求，但是拒绝执行请求。增加验证信息是没有必要的，并且请求应当不被重试。
				case 404://服务器尚未找到所请求 URI 的匹配项
				case 405://Method Not Allowed
				case 407://这个返回码和401（Unauthorized）很类四，但是标志了客户端应当首先在proxy上通过认证
				case 408://在一段时间内，服务器不能产生一个终结应答
				case 410://请求的资源在本服务器上已经不存在了，并且不知道应当把请求转发到哪里
				case 413://请求实体过大。 服务器拒绝处理请求，因为这个请求的实体超过了服务器希望或者能够处理的大小。这个服务器应当关闭连接避免客户端重发这个请求。 
				case 414://服务器拒绝这个请求，因为Request-URI超过了服务器能够处理的长度
				case 415://服务器由于请求的消息体的格式本服务器不支持，所以拒绝处理这个请求
				case 416://服务器由于不支持Request-URI中的URI方案而终止处理这个请求
				case 421://UAS需要特定的扩展来处理这个请求
				case 423://服务器因为在请求中设置的资源刷新时间（或者有效时间）过短而拒绝请求
				case 480://请求成功到达被叫方的终端系统，但是被叫方当前不可用
				case 481://这个状态表示了UAS接收到请求，但是没有和现存的对话或者事务匹配
				case 482://服务器检测到了一个循环
				case 483://服务器接收到了一个请求包含的Max-Forwards(20.22)头域是0
				case 484://服务器接收到了一个请求，它的Request-URI是不完整的
				case 485://Request -URI是不明确的
				case 486://当成功联系到被叫方的终端系统，但是被叫方当前在这个终端系统上不能接听这个电话，那么应答应当回给呼叫方一个更合适的时间在Retry-After头域重试
				case 487://请求被BYE或者CANCEL所终止
				case 488://这个应答和606（Not Acceptable）有相同的含义，但是只是应用于Request-URI所指出的特定资源不能接受，在其他地方请求可能可以接受
				case 491://在同一个对话中，UAS接收到的请求有一个依赖的请求正在处理
				case 493://UAS接收到了一个请求，包含了一个加密的MIME,并且不知道或者没有提供合适的解密密钥
					
				case 500://服务器遇到了未知的情况，并且不能继续处理请求
				case 501://服务器没有实现相关的请求功能
				case 502://如果服务器，作为gateway或者proxy存在
				case 503://由于临时的过载或者服务器管理导致的服务器暂时不可用
				case 504://服务器在一个外部服务器上没有收到一个及时的应答
				case 505://服务器不支持对应的SIP版本
				
					g.log.pushLog(this, g.logType._Record, "HTTPBase 拒绝请求 httpStatusHandler : " + e.status);
					if (errorMethod != null)
					{
						errorMethod(this);
					}
					HTTPBase.destroyHttp(this);
					break;
				default:
			}
			*/
		}
		
		/** initHandler() 方法在 completeHandler() 方法之前、progressHandler() 方法之后执行。 通常，init 事件在加载 SWF 文件时更有用 **/
		protected function initHandler(e:Event):void
		{
			if (config_isLog) g.log.pushLog(this, g.logType._Record, "HTTPBase initHandler: " + e);
		}
		
		/** 开打连接的时候 **/
		protected function openHandler(e:Event):void
		{
			if (config_isLog) g.log.pushLog(this, g.logType._Record, "HTTPBase 打开连接 : " + e);
		}
		
		/** 记录下载数量的数量 **/
		protected function progressHandler(e:ProgressEvent):void
		{
			if (ioTimeout && ioStart)
			{
				ioStart = 0;
				g.event.removeEnterFrame(ioEnterFrame);
			}
			if (config_isLog) g.log.pushLog(this, g.logType._Record, "HTTPBase 下载中 : " + "总大小:" + e.bytesTotal + " 剩余大小:" + e.bytesLoaded);
		}
		
		/** 被卸载 **/
		protected function unLoadHandler(e:Event):void
		{
			if (config_isLog) g.log.pushLog(this, g.logType._Record, "HTTPBase 被卸载 : " + e);
		}
	}
}