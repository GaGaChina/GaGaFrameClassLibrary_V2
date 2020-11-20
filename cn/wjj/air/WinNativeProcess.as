package cn.wjj.air 
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	/**
	 * Windows系统,调用bat批处理执行内容
	 * 
	 * @author GaGa
	 */
	public class WinNativeProcess 
	{
		
		public var process:NativeProcess;
		
		public function WinNativeProcess() { }
		
		/**
		 * 表示在当前的配置文件中是否支持运行本机进程。仅当AIR并windows系统运行时，返回 true。此外，对于作为 AIR 文件安装的应用程序，NativeProcess.isSupported 始终为 false。您必须使用 ADT -target native 标志将 AIR 应用程序打包，才能使用 NativeProcess 类
		 * @return
		 */
		public static function get isSupported():Boolean
		{
			if (NativeProcess.isSupported)
			{
				switch(Capabilities.version.substr(0, 3))
				{
					case "AND":
					case "IOS":
						break;
					case "WIN":
						if (Capabilities.playerType == "Desktop")
						{
							return true;
						}
						break;
				}
			}
			return false;
		}
		
        public function setupAndLaunch():void
        {     
            var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            var file:File = File.applicationDirectory.resolvePath("test.py");
            nativeProcessStartupInfo.executable = file;
			
            var processArgs:Vector.<String> = new Vector.<String>();
            processArgs[0] = "foo";
            nativeProcessStartupInfo.arguments = processArgs;
			
            process = new NativeProcess();
            process.start(nativeProcessStartupInfo);
            process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
            process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
            process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
            process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
            process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
        }
		
        public function onOutputData(e:ProgressEvent):void
        {
            trace("Got: ", process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable)); 
        }
        
        public function onErrorData(e:ProgressEvent):void
        {
            trace("ERROR -", process.standardError.readUTFBytes(process.standardError.bytesAvailable)); 
        }
        
        public function onExit(e:NativeProcessExitEvent):void
        {
            trace("Process exited with ", e.exitCode);
        }
        
        public function onIOError(e:IOErrorEvent):void
        {
            trace(e.toString());
        }
	}
}