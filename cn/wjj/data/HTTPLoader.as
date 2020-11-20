package cn.wjj.data
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	import cn.wjj.g;
	
	/**
	 * 创建一个HTTPLoader对象,并且自动下载内容
	 * 
	 * @version 0.9.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2013-01-08
	 */
	public class HTTPLoader
	{
		/** 是否开启记录日志,如果不开启,也会记录错误和沙箱错误二种日志 **/
		public static var config_isLog:Boolean = true;
		/** 回调函数,function Function(e:HTTPLoader):void{} **/
		public var completeMethod:Function;
		/** 回调函数,function Function(e:HTTPLoader):void{} **/
		public var errorMethod:Function;
		/** 完成后是否自动删除这个对象 **/
		public var completeDestroy:Boolean = false;
		/** 事件返回的内容 **/
		public var event:Event;
		
		/**
		 * 创建一个HTTPLoader对象,并且自动下载内容
		 * @param	url					连接地址
		 * @param	completeMethod		完成后的回调函数,写法 function Function(e:Event):void{}, e.currentTarget.data 是数据
		 */
		public function HTTPLoader(url:String, completeMethod:Function, errorMethod:Function = null):void
		{
			this.completeMethod = completeMethod;
			this.errorMethod = errorMethod;
			var loader:Loader = new Loader();
			addListeners(loader.contentLoaderInfo);
			var request:URLRequest = new URLRequest(url);
			loader.load(request);
		}
		
		private function destroy(loader:Loader):void
		{
			if (loader)
			{
				removeListeners(loader.contentLoaderInfo);
				loader.unload();
			}
			this.completeMethod = null;
			this.errorMethod = null;
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
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPLoader 完成 : " + e);
			}
			this.event = e;
			if (completeMethod != null)
			{
				completeMethod(this);
			}
			destroy(e.currentTarget as Loader);
		}
		
		/** 沙箱错误 **/
		protected function securityErrorHandler(e:SecurityErrorEvent):void
		{
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPLoader 沙箱错误 : " + e);
			destroy(e.currentTarget as Loader);
			this.event = e;
			if (errorMethod != null)
			{
				errorMethod(this);
			}
		}
		
		/** URL不可用或不可访问 **/
		protected function ioErrorHandler(e:IOErrorEvent):void
		{
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPLoader IO错误 : " + (e.currentTarget as LoaderInfo).url + " 数据 " + e);
			destroy(e.currentTarget as Loader);
			this.event = e;
			if (errorMethod != null)
			{
				errorMethod(this);
			}
		}
		
		/** 非本地加载，并且只有在网络请求可用并可被 Flash Player 检测到的情况下，才会执行 httpStatusHandler() 方法 **/
		protected function httpStatusHandler(e:HTTPStatusEvent):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPLoader httpStatusHandler : " + e);
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
				g.log.pushLog(this, g.logType._Record, "HTTPLoader 拒绝请求 httpStatusHandler : " + e.status);
				destroy(e.currentTarget as Loader);
				this.event = e;
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
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPLoader initHandler: " + e);
			}
		}
		
		/** 开打连接的时候 **/
		protected function openHandler(e:Event):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPLoader 打开连接 : " + e);
			}
		}
		
		/** 记录下载数量的数量 **/
		protected function progressHandler(e:ProgressEvent):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPLoader 下载中 : " + "总大小:" + e.bytesTotal + " 剩余大小:" + e.bytesLoaded);
			}
		}
		
		/** 被卸载 **/
		protected function unLoadHandler(e:Event):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "HTTPLoader 被卸载 : " + e);
			}
			destroy(e.currentTarget as Loader);
		}
	}
}