package cn.wjj.data.file 
{
	import cn.wjj.data.CustomByteArray;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.loader.AssetItem;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * File文件管理工具
	 * 分包头,包体二部分
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class FileTools
	{
		
		public function FileTools():void { }
		
		/**
		 * 检查目录下是否可以操作,将会写入一个文件 check_path_can_use_temp.txt 文件,成功就返回true,并删除
		 * 1.File.applicationStorageDirectory
		 * 2.File.applicationDirectory			包含应用程序已安装文件的文件夹
		 * 3.File.cacheDirectory				临时目录,空间不够的时候可能会被清理
		 * 4.File.documentsDirectory			用户的文档目录
		 * @param	path	要检查的路径
		 * @param	type	
		 */
		public static function CheckPathCanUse(path:String, type:int = 1):Boolean
		{
			var f:File = useFile(type);
			if (f)
			{
				var ok:Boolean = false;
				//检查path,如果最后位是
				if (path.length)
				{
					var a:Array = path.split("/");
					var end:String = a.pop();
					path = a.join("/");
					if (end.indexOf(".") == -1)
					{
						path = path + "/" + end;
					}
					else
					{
						path = path;
					}
				}
				path = path + "/check_path_can_use_temp.txt";
				var s:FileStream;
				try
				{
					f = f.resolvePath(path);
					s = new FileStream();
					s.open(f, FileMode.WRITE);
					s.position = 0;
					s.writeBytes(new CustomByteArray());
					s.close();
					ok = true;
				}
				catch (e:Error){}
				if (s)
				{
					try
					{
						s.close();
					}
					catch(e:Error){}
				}
				try
				{
					if (f && f.exists)
					{
						f.deleteFile();
					}
				}
				catch(e:Error){}
				return ok;
			}
			return false;
		}
		
		/** 根据文件系统获取现在要用的File体系 **/
		private static function useFile(type:int):File
		{
			switch (type) 
			{
				case 1:
					return File.applicationStorageDirectory;
					break;
				case 2:
					return File.applicationDirectory;
					break;
				case 3:
					return File.cacheDirectory;
					break;
				case 4:
					return File.documentsDirectory;
					break;
			}
			return null;
		}
	}
}