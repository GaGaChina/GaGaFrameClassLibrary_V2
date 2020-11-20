package cn.wjj.data
{
	import cn.wjj.g;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	
	/**
	 * 从本地读取一个文件
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-07-26
	 */
	public class FileBrowseBase
	{
		
		/** 是否开启记录日志,如果不开启,也会记录错误和沙箱错误二种日志 **/
		public static var config_isLog:Boolean = true;
		
		public var file:FileReference;
		/** 回传的数据 **/
		public var data:Object;
		/** 选中后立即载入 **/
		public var selectAndLoad:Boolean = true;
		/** 选中回调函数,function Function(e:Event):void{} **/
		public var selectMethod:Function;
		/** 回调函数,function Function(e:Event):void{} **/
		public var completeMethod:Function;
		/** 是否已经完成 **/
		public var isComplete:Boolean = false;
		/** 完成后是否自动删除这个对象 **/
		public var completeDestroy:Boolean = false;
		
        public function FileBrowseBase(selectMethod:Function, completeMethod:Function, selectAndLoad:Boolean = true, fileFilter:Array = null, completeDestroy:Boolean = false):void
		{
			this.selectMethod = selectMethod;
			this.completeMethod = completeMethod;
			this.isComplete = false;
			this.selectAndLoad = selectAndLoad;
			this.completeDestroy = completeDestroy;
			file = new FileReference();
			addListeners(file);
			if (fileFilter == null)
			{
				file.browse();
			}
			else
			{
				file.browse(fileFilter);
			}
        }
		
		public function destroy():void
		{
			if(file != null)
			{
				removeListeners(file);
			}
			file = null;
			selectMethod = null;
			completeMethod = null;
			isComplete = false;
			data = null;
		}
		
        private function addListeners(dispatcher:IEventDispatcher):void
		{
			g.event.addListener(dispatcher, Event.CANCEL, cancelHandler);
			g.event.addListener(dispatcher, Event.COMPLETE, completeHandler);
			g.event.addListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.addListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.addListener(dispatcher, Event.OPEN, openHandler);
			g.event.addListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.addListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.addListener(dispatcher, Event.SELECT, selectHandler);
			g.event.addListener(dispatcher, DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
        }
		
		/** 删除监听事件 **/
		private function removeListeners(dispatcher:IEventDispatcher):void
		{
			g.event.removeListener(dispatcher, Event.CANCEL, cancelHandler);
			g.event.removeListener(dispatcher, Event.COMPLETE, completeHandler);
			g.event.removeListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.removeListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.removeListener(dispatcher, Event.OPEN, openHandler);
			g.event.removeListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.removeListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.removeListener(dispatcher, Event.SELECT, selectHandler);
			g.event.removeListener(dispatcher, DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
		}
		
        private function cancelHandler(e:Event):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._UserAction, "FileBrowseBase cancelHandler: " + e);
			}
		}
		
		/** 加载完毕 **/
        private function completeHandler(e:Event):void
		{
			this.isComplete = true;
			this.data = e.currentTarget.data;
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "FileBrowseBase 完成 : " + e);
			}
			if (completeMethod != null)
			{
				completeMethod(e);
			}
			if (completeDestroy)
			{
				destroy();
			}
		}
		
        private function uploadCompleteDataHandler(e:Event):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._UserAction, "FileBrowseBase uploadCompleteData: " + e);
			}
        }
		
		/** 非本地加载，并且只有在网络请求可用并可被 Flash Player 检测到的情况下，才会执行 httpStatusHandler() 方法 **/
        private function httpStatusHandler(e:HTTPStatusEvent):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._UserAction, "FileBrowseBase httpStatusHandler: " + e);
			}
        }
        
		/** URL不可用或不可访问 **/
        private function ioErrorHandler(e:IOErrorEvent):void
		{
			g.log.pushLog(this, g.logType._ErrorLog, "FileBrowseBase IO错误 : " + e);
        }
		
		/** 沙箱错误 **/
        private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			g.log.pushLog(this, g.logType._ErrorLog, "HTTPBase 沙箱错误 : " + e);
        }
		
		/** 开打连接的时候 **/
        private function openHandler(e:Event):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._UserAction, "FileBrowseBase openHandler: " + e);
			}
        }
		
		/** 记录下载数量的数量 **/
		private function progressHandler(e:ProgressEvent):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._Record, "FileBrowseBase 下载中 : " + "总大小:" + e.bytesTotal + " 剩余大小:" + e.bytesLoaded);
			}
		}
		
		/** 选中一个文件 **/
        private function selectHandler(e:Event):void
		{
			if(config_isLog)
			{
				g.log.pushLog(this, g.logType._UserAction, "FileBrowseBase selectHandler : " + e);
			}
			if (selectMethod != null)
			{
				selectMethod(e);
			}
			if (selectAndLoad)
			{
				file.load();
			}
			else
			{
				if (completeDestroy)
				{
					destroy();
				}
			}
		}
	}
}