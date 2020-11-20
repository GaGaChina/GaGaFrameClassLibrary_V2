package cn.wjj.tool
{
	import flash.system.Capabilities;
	
	public class SWFSupported
	{
		
		/**
		 * 把一个Vector对象转换为数组Array对象输出
		 * @param init
		 * @return 
		 *                        没有测试过
		 */
		public static function getSupported():String
		{
			var str:String = "";
			with (Capabilities)
			{
				str += "avHardwareDisable: " + avHardwareDisable + "\n";//指定对用户的摄像头和麦克风的访问是已经通过管理方式禁止 (true) 还是允许 (false)
				str += "hasAccessibility: " + hasAccessibility + "\n";//指定系统是否支持与辅助功能通信，如果是，则为 true，否则为 false。
				str += "hasAudio: " + hasAudio + "\n";//指定系统是否有音频功能。
				str += "hasAudioEncoder: " + hasAudioEncoder + "\n";//指定系统是否可以对音频流（如来自麦克风的音频流）进行编码，如果是，则为 true，否则为 false
				//str += "hasEmbeddedVideo: " + hasColorCorrection + "\n";//指定操作系统是否支持颜色校正，主监视器的颜色配置文件是否可由 Flash Player 或 AIR 读取且为其所理解
				str += "hasEmbeddedVideo: " + hasEmbeddedVideo + "\n";//指定系统是否支持嵌入的视频，如果是，则为 true，否则为 false
				str += "hasIME: " + hasIME + "\n";//指定系统是否安装了输入法编辑器 (IME)，如果是，则为 true，否则为 false
				str += "hasMP3: " + hasMP3 + "\n";//指定系统是否具有 MP3 解码器，如果是，则为 true，否则为 false
				str += "hasPrinting: " + hasPrinting + "\n";//指定系统是否支持打印，如果是，则为 true，否则为 false
				str += "hasScreenBroadcast: " + hasScreenBroadcast + "\n";//指定系统是否支持开发通过 Flash Media Server 运行的屏幕广播应用程序，如果是，则为 true，否则为 false
				str += "hasScreenPlayback: " + hasScreenPlayback + "\n";//指定系统是否支持回放通过 Flash Media Server 运行的屏幕广播应用程序，如果是，则为 true，否则为 false
				str += "hasStreamingAudio: " + hasStreamingAudio + "\n";//指定系统是否可以播放音频流，如果是，则为 true，否则为 false
				str += "hasStreamingVideo: " + hasStreamingVideo + "\n";//指定系统是否可以播放视频流，如果是，则为 true，否则为 false
				str += "hasTLS: " + hasTLS + "\n";//指定系统是否通过 NetConnection 支持本机 SSL 套接字，如果是，则为 true，否则为 false
				str += "hasVideoEncoder: " + hasVideoEncoder + "\n";//指定系统是否可以对视频流（如来自 Web 摄像头的视频流）进行编码，如果是，则为 true，否则为 false
				str += "isDebugger: " + isDebugger + "\n";//指定系统使用的是特殊的调试软件 (true)，还是正式发布的版本 (false)
				str += "isEmbeddedInAcrobat: " + isEmbeddedInAcrobat + "\n";//指定是否将播放器嵌入到在 Acrobat 9.0 或更高版本中打开的 PDF 文件。如果嵌入，则为 true，否则为 false
				str += "language: " + language + "\n";//指定运行内容的系统的语言代码
				//str += "language: " + languages);//AIR     一个字符串数组，它包含通过操作系统设置的用户首选语言的信息
				str += "localFileReadDisable: " + localFileReadDisable + "\n";//指定对用户硬盘的读取权限是已经通过管理方式禁止 (true) 还是允许 (false)
				str += "manufacturer: " + manufacturer + "\n";//指定 Flash Player 的运行版本或 AIR 运行时的制造商，其格式为“Adobe OSName”
				str += "os: " + os + "\n";//指定当前的操作系统
				str += "pixelAspectRatio: " + pixelAspectRatio + "\n";//指定屏幕的像素高宽比
				str += "playerType: " + playerType + "\n";//指定运行时环境的类型
				str += "screenColor: " + screenColor + "\n";//指定屏幕的颜色
				str += "screenDPI: " + screenDPI + "\n";//指定屏幕的每英寸点数 (dpi) 分辨率，以像素为单位
				str += "screenResolutionX: " + screenResolutionX + "\n";//指定屏幕的最大水平分辨率
				str += "screenResolutionY: " + screenResolutionY + "\n";//指定屏幕的最大垂直分辨率
				str += "serverString: " + serverString + "\n";//URL 编码的字符串，用于指定每个 Capabilities 属性的值
				str += "version: " + version + "\n";//指定 Flash Player 或 Adobe® AIR 平台和版本信息
			}
			return str;
		}
	}
}