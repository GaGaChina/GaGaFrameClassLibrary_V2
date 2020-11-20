package cn.wjj.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	
	/**
	 * 创建一个HTTPMinBitmapData对象,并且自动下载内容
	 * 
	 * @version 0.0.2
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2013-10-08 2015-07-02
	 */
	public class HTTPMinBitmapData
	{
		private var loader:Loader;
		/** 回调函数,function Function(e:HTTPMinBitmapData):void{} **/
		private var completeMethod:Function;
		/** URL里的BitmapData信息 **/
		public var bitmapData:BitmapData;
		
		/**
		 * 创建一个HTTPMinBitmapData对象,并且自动下载内容
		 * @param	url					连接地址
		 * @param	completeMethod		完成后的回调函数,写法 function Function(e:HTTPMinBitmapData):void{}
		 */
		public function HTTPMinBitmapData(url:String, completeMethod:Function):void
		{
			this.completeMethod = completeMethod;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			var request:URLRequest = new URLRequest(url);
			loader.load(request);
		}
		
		/** 加载完毕 **/
		private function completeHandler(e:Event):void
		{
			removeListener();
			this.bitmapData = (e.currentTarget.content as Bitmap).bitmapData;
			if (completeMethod != null)
			{
				completeMethod(this);
				completeMethod = null;
			}
		}
		
		/** URL不可用或不可访问 **/
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			removeListener();
			completeMethod = null;
		}
		
		private function removeListener():void
		{
			if (loader && loader.contentLoaderInfo)
			{
				if (loader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
				{
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				}
				if (loader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR))
				{
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
			}
		}
		
		/** 释放 **/
		public function dispose():void
		{
			if (loader)
			{
				removeListener();
				loader = null;
			}
			if (completeMethod != null) completeMethod = null;
			if (bitmapData) bitmapData = null;
		}
	}
}