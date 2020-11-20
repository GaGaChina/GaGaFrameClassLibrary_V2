package cn.wjj.data.file 
{
	import cn.wjj.data.XMLToObject;
	import cn.wjj.display.ui2d.info.U2InfoBitmapX;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.tool.Version;
	import com.adobe.crypto.MD5;
	import data.model.system.GFileModel;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	
	/**
	 * 抽取GFile的时候使用的工具类,为了保持统一
	 * 
	 * 
	 * 自动替换图片,自动查找功能
	 * 
	 * 只需子对应的文件名下添加u2bxj就可以了
	 * jpg, jpeg -> u2bxj
	 * png -> u2bxp
	 * 
	 * 碰到图片,查有无u2bxp文件
	 * 
	 * 
	 * 
	 * 
	 * @author GaGa
	 */
	public class GFileGetTools 
	{
		/** 不打包进GFile的文件 **/
		private static var noReadFile:Array = [".svn", "thumbs.db", "System Volume Information", "RECYCLER", "pagefile.sys", ".DS_Store", ".autoback", "01_folder_head.gf", "01_folder_body.gf", "01_floder_assist.gf"];
		/** 文件名中不能包含的文字 **/
		private static var nameNoIn:Array = ["autoback", "save"];
		/** 文件中不能打入的扩展名 **/
		private static var extensionNoIn:Array = ["fla"];
		/** "不压缩", "zlib", "deflate", "7z" **/
		private static var compressDP:Array = ["不压缩", "zlib", "deflate", "7z"];
		
		public function GFileGetTools() { }
		
		/**
		 * 文件是否可以添加
		 * @param	name	文件名
		 * @param	path	文件路径
		 * @return	返回是否文件可以添加
		 */
		public static function fileIsRight(name:String, path:String):Boolean
		{
			if (noReadFile.indexOf(name) != -1) return false;
			for each (var item:String in nameNoIn) 
			{
				if (path.indexOf(item) != -1)
				{
					return false;
				}
			}
			//检测扩展名是否可以添加
			var kzm:String = getFileKZM(path);
			if (kzm)
			{
				for each (item in extensionNoIn) 
				{
					if (kzm == item)
					{
						return false;
					}
				}
			}
			return true;
		}
		
		/**
		 * 
		 * @param	gFile				GFile的引用
		 * @param	file				文件
		 * @param	p					documentURL
		 * @param	directoryMethod		如果是文件夹就调用此方法,结构 (GFile, 文件夹File, documentURL)
		 * @param	isSpeed
		 * @param	developModel		是否是开发模式,开发模式区MD5是path的MD5
		 * @param	allList				全部的文件列表
		 * @param	imageAdd			function imageAdd():void
		 * @param	imageComplete		function imageComplete(e:GFileEvent):void
		 * @param	newList				操作的GFile对象
		 * @param	assistList			空白二进制文件
		 * @param	jpgCompress			JPG的默认压缩模式
		 * @param	pngCompress			PNG的默认压缩模式
		 */
		public static function handleFile(gFile:GFile, file:File, documentURL:String, directoryMethod:Function, isSpeed:Boolean, developModel:Boolean, allList:Vector.<String>, imageAdd:Function, imageComplete:Function, newList:Vector.<GFileBase>, assistList:Vector.<GFileBase>, jpgCompress:int, pngCompress:int):GFileBase
		{
			var fileItem:GFileBase;
			if (fileIsRight(file.name, file.nativePath) == false) return null;
			if(file.isDirectory)
			{
				directoryMethod(gFile, file, documentURL);
			}
			else
			{
				var isNewFile:Boolean;
				var fileInfo:Object = new Object();
				var assistItem:GAssist;
				var amf_md5:AMFFile;//取amf的MD5用的
				//取相对路径, 需要把 
				fileInfo.path = getFileUrl(file.nativePath.substr(documentURL.length));
				allList.push(fileInfo.path);
				fileItem = gFile.getPath(fileInfo.path);
				if(fileItem)
				{
					if (isSpeed && file.modificationDate)
					{
						assistItem = gFile.getAssist(fileInfo.path);
						if (assistItem)
						{
							if (assistItem.size == file.size && assistItem.time == file.modificationDate.time)
							{
								return null;
							}
						}
						else
						{
							assistItem = new GAssist();
							assistItem.name = fileItem.name;
							assistItem.path = fileItem.path;
							assistItem.ver = fileItem.ver;
							assistItem.md5 = fileItem.md5;
							gFile.assistList.push(assistItem);
						}
						assistItem.size = file.size;
						assistItem.time = file.modificationDate.time;
					}
				}
				var md5:String = "";
				//读取文件
				var byte:SByte = getFileByte(file);
				if(developModel)
				{
					md5 = MD5.hash(fileInfo.path);
				}
				else
				{
					switch(getFileKZM(fileInfo.path))
					{
						case "amf":
							amf_md5 = new AMFFile();
							amf_md5.setByte(byte);
							md5 = amf_md5.md5;
							break;
					}
					if (md5 == "") md5 = MD5.hashBytes(byte);
				}
				if(fileItem)
				{
					isNewFile = false;
					//加版本
					if(developModel == false && fileItem.md5 != md5)
					{
						fileInfo.updata = true;
						fileItem.ver = Version.add(fileItem.ver);
					}
					fileInfo.assets = fileItem.assets;
					fileInfo.type = fileItem.type;
					fileInfo.ver = fileItem.ver;
					fileInfo.autoLoader = fileItem.autoLoader;
					fileInfo.compress = compressDP[fileItem.compress];
				}
				else
				{
					isNewFile = true;
					fileInfo.ver = "0.0.1";
				}
				fileItem = handleItem(fileItem, file, md5, byte, fileInfo, imageAdd, imageComplete, jpgCompress, pngCompress)
				if (isNewFile) gFile.push(fileItem);
				fileItem.isBuilder = true;
				if (isSpeed)
				{
					assistList.push(fileItem);
				}
				else
				{
					newList.push(fileItem);
				}
			}
			return fileItem;
		}
		
		/** 获取一个文件的MD5 **/
		public static function fileBitmapXMD5(path:String, documentURL:String):String
		{
			var file:File = imageBitmapXFile(path, documentURL);
			if (file)
			{
				var byte:SByte = getFileByte(file);
				var U2:U2InfoBitmapX = new U2InfoBitmapX(null);
				U2.setByte(byte);
				return U2.md5;
			}
			return "";
		}
		
		/** 图片的Image文件 **/
		public static function imageBitmapXFile(path:String, documentURL:String):File
		{
			var kzm:String = path.substr( -4, 4);
			var bitmapXName:String = "";
			if (kzm == ".jpg")
			{
				bitmapXName = path.substr(0, path.length - 3) + "u2bxj";
			}
			else if(kzm == ".png")
			{
				bitmapXName = path.substr(0, path.length - 3) + "u2bxp";
			}
			if (bitmapXName)
			{
				var filePath:String = documentURL + bitmapXName;
				var file:File = new File(filePath);
				if (file.exists && file.isDirectory == false)
				{
					return file;
				}
			}
			return null;
		}
		
		/** 获取BitmapX对应的图片 **/
		public static function getBitmapXPath(path:String, documentURL:String):File
		{
			var kzm:String = path.substr( -6, 6);
			var imgPath:String = path.substr(0, path.length - 5);
			if (kzm == ".u2bxj")
			{
				imgPath += "jpg";
			}
			else if (kzm == ".u2bxp")
			{
				imgPath += "png";
			}
			var filePath:String = documentURL + imgPath;
			var file:File = new File(filePath);
			if (file.exists && file.isDirectory == false)
			{
				return file;
			}
			return null;
		}
		
		/** 获取一个文件的MD5 **/
		public static function fileMD5(file:File, documentURL:String):String
		{
			var path:String = getFileUrl(file.nativePath.substr(documentURL.length));
			var byte:SByte = getFileByte(file);
			var md5:String = byteArrayMD5(path, byte);
			return md5;
		}
		
		/** 获取一个二进制的MD5 **/
		public static function byteArrayMD5(path:String, byte:SByte):String
		{
			var md5:String = "";
			//var U2:U2InfoBitmapX;
			if (getFileKZM(path) == "amf")
			{
				var amf_md5:AMFFile = new AMFFile();
				amf_md5.setByte(byte);
				md5 = amf_md5.md5;
			}
			/*
			else if (getFileKZM(path) == "u2bxj")
			{
				U2 = new U2InfoBitmapX(null);
				U2.setByte(byte);
				return U2.md5;
			}
			else if (getFileKZM(path) == "u2bxp")
			{
				U2 = new U2InfoBitmapX(null);
				U2.setByte(byte);
				return U2.md5;
			}
			*/
			else
			{
				md5 = MD5.hashBytes(byte);
			}
			return md5;
		}
		
		/**
		 * 
		 * @param	gfile				GFile的引用
		 * @param	file				文件
		 * @param	documentURL			
		 * @param	list				全部的文件列表
		 * @param	imageAdd			function imageAdd():void
		 * @param	imageComplete		function imageComplete(e:GFileEvent):void
		 * @param	jpgCompress			JPG的默认压缩模式
		 * @param	pngCompress			PNG的默认压缩模式
		 */
		public static function handle15File(gfile:GFile, file:File, bodyFile:File, bodyStream:FileStream, documentURL:String, list:GListBase, imageAdd:Function, imageComplete:Function, jpgCompress:int, pngCompress:int):void
		{
			var fileInfo:Object = new Object();
			//取相对路径, 需要把 
			fileInfo.path = getFileUrl(file.nativePath.substr(documentURL.length));
			var gfileItem:GFileBase = gfile.getPath(fileInfo.path);
			var fileItem:GFileBase = list.getPath(fileInfo.path);
			//读取文件
			var byte:SByte = getFileByte(file);
			//只能获取非bx类的md5
			var md5:String = byteArrayMD5(fileInfo.path, byte);
			if(fileItem)
			{
				//加版本
				fileItem.isBuilder = true;
				if (fileItem.type == GFileType.U2BitmapX)
				{
					//图的MD5是文件内MD5
					//原始的文件MD5是原始文件二进制MD5
					//最后用图片的MD5
				}
				else if(fileItem.md5 != md5)
				{
					fileItem.ver = Version.add(fileItem.ver);
				}
				else
				{
					//读出2进制,直接使用
					var itemByte:SByte = SByte.instance();
					bodyStream.open(bodyFile, FileMode.READ);
					bodyStream.position = list.getPathPosition(fileItem.path);
					var bodylength:uint = bodyStream.readUnsignedInt();
					bodyStream.readBytes(itemByte, 0, bodylength);
					bodyStream.close();
					//这个要解压
					switch (fileItem.compress) 
					{
						case 0://0:不压缩
							break;
						case 1://1.zlib:默认
							itemByte.uncompress();
							break;
						case 2://2.deflate:压缩(尽量别用)
							itemByte.uncompress("deflate");
							break;
						case 3://3.lzma也就是7z
							itemByte.uncompress("lzma");
							break;
						default:
					}
					fileItem.sourceByte = itemByte;
				}
				fileInfo.assets = fileItem.assets;
				fileInfo.type = fileItem.type;
				fileInfo.ver = fileItem.ver;
				fileInfo.autoLoader = fileItem.autoLoader;
				fileInfo.compress = compressDP[fileItem.compress];
			}
			else
			{
				fileInfo.ver = "0.0.1";
			}
			//对比Gfile的版本号,和本地版本号,如果GFile版本号大,用GFile的,并且如果GFile 的 md5和本地不同,提升版本号
			if (gfileItem)
			{
				if (gfileItem.md5 != md5)
				{
					if (Version.compare(gfileItem.ver, fileInfo.ver))
					{
						fileInfo.ver = Version.add(gfileItem.ver);
					}
					gfile.remove(gfileItem);
					if (fileItem)
					{
						gfile.push(fileItem);
						gfileItem = fileItem;
					}
					else
					{
						gfileItem = null;
					}
				}
				if (gfileItem && Version.compare(gfileItem.ver, fileInfo.ver))
				{
					fileInfo.ver = gfileItem.ver;
				}
				if(fileItem) fileItem.ver = fileInfo.ver;
			}
			var u2HelpTemp:GFileBase = fileItem;
			fileItem = handleItem(fileItem, file, md5, byte, fileInfo, imageAdd, imageComplete, jpgCompress, pngCompress);
			if (u2HelpTemp != null && u2HelpTemp != fileItem)
			{
				list.remove(u2HelpTemp);
			}
			fileItem.isBuilder = true;
			if (list.list.indexOf(fileItem) == -1) list.push(fileItem);
		}
		
		/**
		 * 
		 * @param	fileInfo		纯数据形式
		 * @param	imageAdd		当异步图片添加的时候执行
		 * @param	imageComplete	当异步图片完成的时候回调
		 * @param	jpgCompress		JPG的压缩模式
		 * @param	pngCompress		PNG的压缩模式
		 */
		private static function handleItem(fileItem:GFileBase, file:File, md5:String, byte:SByte, fileInfo:Object, imageAdd:Function, imageComplete:Function, jpgCompress:int, pngCompress:int):GFileBase
		{
			var kzm:String = getFileKZM(fileInfo.path);
			if (fileItem && (kzm == "jpg" || kzm == "png"))
			{
				if (fileItem.type != GFileType.bitmapData)
				{
					fileItem = null;
				}
			}
			if (fileItem == null || fileItem.sourceByte == null)
			{
				switch(kzm)
				{
					case "jpg":
						if (imageAdd != null) imageAdd();
						if(fileItem == null)
						{
							fileItem = new GBitmapData();
							fileItem.isBuilder = true;
							(fileItem as GBitmapData).imageCompress = jpgCompress;
							fileInfo.compress = compressDP[0];
							fileInfo.autoLoader = false;
						}
						if(imageComplete != null) g.event.addListener(fileItem, GFileEvent.BITMAPCOMPLETE, imageComplete);
						(fileItem as GBitmapData).setBodyUseFile(byte);
						break;
					case "png":
						if (imageAdd != null) imageAdd();
						if(fileItem == null)
						{
							fileItem = new GBitmapData();
							fileItem.isBuilder = true;
							(fileItem as GBitmapData).imageCompress = pngCompress;
							fileInfo.compress = compressDP[0];
							fileInfo.autoLoader = false;
						}
						if(imageComplete != null) g.event.addListener(fileItem, GFileEvent.BITMAPCOMPLETE, imageComplete);
						(fileItem as GBitmapData).setBodyUseFile(byte);
						break;
					case "xml":
						if(fileItem == null)
						{
							fileItem = new AMFFile();
							fileItem.isBuilder = true;
							fileInfo.compress = compressDP[3];
							fileInfo.autoLoader = false;
						}
						fileItem.obj = XMLToObject.to(new XML(byte.readUTFBytes(byte.length)), false, false);
						break;
					case "json":
						if(fileItem == null)
						{
							fileItem = new AMFFile();
							fileItem.isBuilder = true;
							fileInfo.compress = compressDP[3];
							fileInfo.autoLoader = false;
						}
						fileItem.obj = g.jsonGetObj(byte.readUTFBytes(byte.length));
						break;
					case "amf":
					case "bin":
					case "mbin":
					case "amf":
					case "as3Movie":
					case "glan":
						if(fileItem == null)
						{
							fileItem = new GPackage();
							fileItem.isBuilder = true;
							fileInfo.compress = compressDP[0];
							fileInfo.autoLoader = false;
						}
						fileItem.sourceByte = byte;
						break;
					case "mp3":
						if(fileItem == null)
						{
							fileItem = new GMP3Asset();
							fileItem.isBuilder = true;
							fileInfo.compress = compressDP[0];
							fileInfo.autoLoader = false;
						}
						fileItem.sourceByte = byte;
						break;
						
					case "u2bxj":
					case "u2bxp":
						if(fileItem == null)
						{
							fileItem = new GU2BitmapX();
							fileItem.isBuilder = true;
							fileInfo.compress = compressDP[0];
							fileInfo.autoLoader = false;
						}
						fileItem.sourceByte = byte;
						break;
					case "u2":
						if (fileItem == null)
						{
							fileItem = new GU2Info();
							fileItem.isBuilder = true;
							fileInfo.compress = compressDP[0];
							fileInfo.autoLoader = false;
						}
						fileItem.sourceByte = byte;
						break;
					default:
						if(fileItem == null)
						{
							fileItem = new GFileBase();
							fileItem.isBuilder = true;
							fileInfo.compress = compressDP[3];
							fileInfo.autoLoader = false;
						}
						fileItem.sourceByte = byte;
						
				}
			}
			fileInfo.name = getFileNoKZM(file.name);
			fileInfo.md5 = md5;
			//-----------设置文件----------
			fileItem.name = fileInfo.name;
			fileItem.path = fileInfo.path;
			fileItem.md5 = md5;
			fileItem.isBuilder = true;
			fileItem.ver = fileInfo.ver;
			fileItem.compress = compressDP.indexOf(fileInfo.compress);
			fileItem.autoLoader = fileInfo.autoLoader;
			fileItem.sourceLength = byte.length;
			return fileItem;
		}
		
		/** 转换文件夹的表达方式为 \ 的格式 **/
		public static function getFileUrl(path:String):String
		{
			var arr:Array = path.split("\\");
			return arr.join("/");
		}
		
		/** 获取扩展名 **/
		public static function getFileKZM(path:String):String
		{
			var arr:Array = path.split(".");
			return arr[(arr.length -1)];
		}
		
		/** path文件名,获取不带扩展名的文件名 **/
		public static function getFileNoKZM(path:String):String
		{
			var arr:Array = path.split(".");
			if(arr.length > 1)
			{
				arr.pop();
			}
			return arr.join(".");
		}
		
		/** 获取一个文件的二进制 **/
		public static function getFileByte(file:File):SByte
		{
			var s:FileStream = new FileStream();
			s.open(file, FileMode.READ);
			s.position = 0;
			var b:SByte = SByte.instance();
			s.readBytes(b);
			s.close();
			return b;
		}
		
		/** 写入版本号 **/
		public static function saveVerText(gfileInfo:GFileModel, gfile:GFile):void
		{
			//写版本号
			var ver:File = new File(gfileInfo.relativePath + "ver.txt");
			var verStream:FileStream = new FileStream();
			verStream.open(ver, FileMode.WRITE);
			verStream.writeUTFBytes(gfile.ver);
			verStream.close();
		}
		
		/**
		 * 拷贝自动更新的文件
		 * @param	gfileInfo
		 * @param	list
		 */
		public static function copyUpdataFile(gfileInfo:GFileModel, list:Vector.<GFileBase>):void
		{
			var updataFile:FileReference;
			var documentFile:File;
			var pathStr:String;
			for each (var item:GFileBase in list) 
			{
				if (item.type == GFileType.U2BitmapX)
				{
					if (item.path.substr( -4, 4) == ".jpg")
					{
						pathStr = gfileInfo.relativePath + gfileInfo.documentPath + item.path;
						pathStr = pathStr.substr(0, -3) + "u2bxj";
						documentFile = new File(pathStr);
						pathStr = gfileInfo.relativePath + gfileInfo.updataPath + getCopyPath(item);
						pathStr = pathStr.substr(0, -3) + "u2bxj";
						updataFile = new File(pathStr);
					}
					else if (item.path.substr( -4, 4) == ".png")
					{
						pathStr = gfileInfo.relativePath + gfileInfo.documentPath + item.path;
						pathStr = pathStr.substr(0, -3) + "u2bxp";
						documentFile = new File(pathStr);
						pathStr = gfileInfo.relativePath + gfileInfo.updataPath + getCopyPath(item);
						pathStr = pathStr.substr(0, -3) + "u2bxp";
						updataFile = new File(pathStr);
					}
				}
				else
				{
					documentFile = new File(gfileInfo.relativePath + gfileInfo.documentPath + item.path);
					updataFile = new File(gfileInfo.relativePath + gfileInfo.updataPath + getCopyPath(item));
				}
				try 
				{
					documentFile.copyTo(updataFile, true);
				}
				catch (error:Error)
				{
					AllDo.getInstance.components.alert("Error", error.message);
				}
			}
		}
		
		/** 获取拷贝到那个文件夹 **/
		private static function getCopyPath(f:GFileBase):String
		{
			var arr:Array = f.path.split("/");
			var index:int = arr.length - 1;
			arr[index] = "v" + f.ver + "_" + arr[index];
			return arr.join("/");//\\
		}
	}
}