package cn.wjj.data.file 
{
	import cn.wjj.data.XMLToObject;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.loader.AssetItem;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.tool.Version;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * GFile的管理类,外部调用的接入点
	 * 分包头,包体二部分
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GFile extends GListBase
	{
		/** 文件的头内容 **/
		public var head:Array;
		/** 文件更新网址 **/
		public var updataURL:Vector.<String>;
		/** 是否使用空白二进制区域 **/
		public var useBlank:Boolean = false;
		/** 空白二进制文件身体部分的URL地址 **/
		public var blankPath:String;
		/** 空白二进制文件 **/
		public var blankList:GListBase;
		/** 空白二进制的文件引用 **/
		public var blankStream:ByteLink;
		/** 文件身体部分的URL地址 **/
		public var headPath:String;
		/** 文件头的文件引用 **/
		public var headStream:ByteLink;
		/** 文件身体部分的URL地址 **/
		public var bodyPath:String;
		/** [同步]文件身体的文件引用 **/
		public var bodyStream:ByteLink;
		/** 文件的长度 **/
		public var bodyLength:uint = 0;
		
		/** 是否使用空白二进制区域 **/
		private var useAssist:Boolean = false;
		/** 辅助文件部分URL地址 **/
		public var assistPath:String;
		/** 空白二进制文件 **/
		public var assistList:GListBase;
		/** [同步]辅助文件身体的文件引用 **/
		public var assistStream:ByteLink;
		/** 文档的文件夹 **/
		private var documentPath:String = "";
		
		
		/** 更新成功后的回调方法 **/
		private var updataComplete:Function;
		/** 空白二进制区域 **/
		public var asyncList:Vector.<GFileBase>;
		/** 绕过沙箱文件 **/
		private var securityURL:String;
		/** 是否不备份到苹果的iCloud上 **/
		private var preventBackup:Boolean = true;
		/** 是否在操作文件的时候自动备份head.gf,防止文件中断导致文件体系受损,如果有整体参数控制可以关闭以提高性能 **/
		private var autoBackHead:Boolean = true;
		/**
		 * 使用的文件系统
		 * 1.File.applicationStorageDirectory
		 * 2.File.applicationDirectory			包含应用程序已安装文件的文件夹
		 * 3.File.cacheDirectory				临时目录,空间不够的时候可能会被清理
		 * 4.File.documentsDirectory			用户的文档目录
		 */
		private var useFileType:int = 0;
		/**
		 * 建立文件系统
		 * @param	headPath		二进制的头部分
		 * @param	bodyPath		二进制的内容部分
		 * @param	isBuilder		是否以只读打开
		 * @param	blankPath		空白文件
		 * @param	preventBackup	是否不备份到苹果的iCloud上
		 * @param	autoBackHead	是否在操作文件的时候自动备份head.gf,防止文件中断导致文件体系受损,如果有整体参数控制可以关闭以提高性能
		 * @param	assistPath		辅助加速打包文件
		 * @param	documentPath	文档的文件夹
		 * @param	noFileCreate	没有GFile文件的时候是否创建
		 * @param	headIn			头文件传入(传入后无需在找本文件)
		 * @param	bodyIn			身体文件传入(传入后无需在找本文件)
		 */
		public function GFile(headPath:String, bodyPath:String = "", isBuilder:Boolean = false, blankPath:String = "", useFileType:int = 1, preventBackup:Boolean = true, autoBackHead:Boolean = true, assistPath:String = "", documentPath:String = "", noFileCreate:Boolean = false, headIn:File = null, bodyIn:File = null):void
		{
			list = new Vector.<GFileBase>();
			updataURL = new Vector.<String>();
			asyncList = new Vector.<GFileBase>();
			this.useFileType = useFileType;
			this.blankPath = blankPath;
			this.preventBackup = preventBackup;
			this.autoBackHead = autoBackHead;
			blankList = new GListBase();
			blankStream = pathByteLink(blankPath, noFileCreate);
			var b:SByte;
			if (blankStream)
			{
				try
				{
					blankStream.file.preventBackup = preventBackup;
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile preventBackup 出错 : " + securityURL + "出错 :" + e.message);
				}
				try
				{
					blankStream.changeMode(ByteLink.READ);
					blankStream.position = 0;
					b = SByte.instance();
					blankStream.link.readBytes(b);
					if(b.length > 0)
					{
						b.position = 0;
						blankList.setByte(b);
					}
					b.dispose();
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile blankStream 出错 : " + securityURL + "出错 :" + e.message);
				}
			}
			this.headPath = headPath;
			this.isBuilder = isBuilder;
			checkBackHeadFile();
			headStream = pathByteLink(headPath, noFileCreate, headIn);
			if(headStream)
			{
				try
				{
					headStream.file.preventBackup = preventBackup;
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile preventBackup 出错 : " + securityURL + "出错 :" + e.message);
				}
				headStream.changeMode(ByteLink.READ);
				headStream.position = 0;
				if (headStream.file.size > 0)
				{
					getHeadInfo();
					g.log.pushLog(this, LogType._UserAction, "GFile 获取文件数 : " + list.length);
				}
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "GFile headStream 出错 : " + securityURL);
			}
			if (bodyPath != "")
			{
				this.bodyPath = bodyPath;
				bodyStream = pathByteLink(bodyPath, noFileCreate, bodyIn);
				if(bodyStream)
				{
					try
					{
						bodyStream.file.preventBackup = preventBackup;
					}
					catch (e:Error)
					{
						g.log.pushLog(this, LogType._ErrorLog, "GFile preventBackup 出错 : " + securityURL + "出错 :" + e.message);
					}
					bodyLength = bodyStream.file.size;
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile bodyFile 出错 : " + securityURL);
				}
			}
			assistList = new GListBase();
			if (assistPath && documentPath)
			{
				this.assistPath = assistPath;
				this.documentPath = documentPath;
				assistStream = pathByteLink(assistPath, noFileCreate);
				if(assistStream)
				{
					try
					{
						assistStream.file.preventBackup = preventBackup;
					}
					catch (e:Error)
					{
						g.log.pushLog(this, LogType._ErrorLog, "GFile preventBackup 出错 : " + securityURL + "出错 :" + e.message);
					}
					assistStream.changeMode(ByteLink.READ);
					assistStream.position = 0;
					b = SByte.instance();
					assistStream.readBytes(b);
					if(b.length > 0)
					{
						b.position = 0;
						assistList.setByte(b);
					}
					b.dispose();
					useAssist = true;
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile assistFile 出错 : " + securityURL);
				}
			}
		}
		
		/** 给出文件路径获取文件, create:true如果没有就创建 **/
		private function useFileGetPath(path:String, create:Boolean = false):File
		{
			if (path)
			{
				var f:File;
				//根据文件系统获取现在要用的File体系
				switch (useFileType) 
				{
					case 1:
						f = File.applicationStorageDirectory;
						break;
					case 2:
						f = File.applicationDirectory;
						break;
					case 3:
						f = File.cacheDirectory;
						break;
					case 4:
						f = File.documentsDirectory;
						break;
				}
				if (f)
				{
					securityURL = f.nativePath.toString();
					if (securityURL)
					{
						securityURL += "/" + path;
					}
					else
					{
						switch (useFileType) 
						{
							case 1:
								securityURL = "File.applicationStorageDirectory/" + path;
								break;
							case 2:
								securityURL = "File.applicationDirectory/" + path;
								break;
							case 3:
								securityURL = "File.cacheDirectory/" + path;
								break;
							case 4:
								securityURL = "File.documentsDirectory/" + path;
								break;
						}
					}
					f = f.resolvePath(path);
				}
				else
				{
					securityURL = path;
					f = new File(path);
				}
				if(f.exists == false && create && useFileType != 2)
				{
					var stream:FileStream = new FileStream();
					stream.open(f, FileMode.WRITE);
					stream.close();
				}
				return f;
			}
			return null;
		}
		
		/** 通过Path路径获取ByteLink, create:true如果没有就创建, file是否已经将文件传入 **/
		private function pathByteLink(path:String, create:Boolean = false, file:File = null):ByteLink
		{
			var filePath:String;
			if (file && file.exists)
			{
				filePath = file.nativePath.toString();
				return ByteLink.GetLink(new FileStream(), file, filePath);
			}
			else
			{
				var o:File = useFileGetPath(path, create);
				if (o && o.exists)
				{
					filePath = o.nativePath.toString();
					if (filePath == "")
					{
						switch (useFileType) 
						{
							case 1:
								filePath = "File.applicationStorageDirectory/" + path;
								break;
							case 2:
								filePath = "File.applicationDirectory/" + path;
								break;
							case 3:
								filePath = "File.cacheDirectory/" + path;
								break;
							case 4:
								filePath = "File.documentsDirectory/" + path;
								break;
						}
					}
					return ByteLink.GetLink(new FileStream(), o, filePath);
				}
			}

			return null;
		}
		
		/** 获取全部的文件信息 **/
		private function getHeadInfo():void
		{
			headStream.changeMode(ByteLink.READ);
			headStream.position = 0;
			var b:SByte = SByte.instance();
			headStream.readBytes(b);
			this.setHeadByte(b, true);
			b.dispose();
		}
		
		/** 获取要预载入的内容 **/
		public function getBodyInfo(useAsync:Boolean = true):void
		{
			var assets:AssetItem;
			for each (var item:GFileBase in list) 
			{
				if (isBuilder)
				{
					item.isRecover = true;
					readBody(item);
				}
				else
				{
					item.parent = this;
					if (item.assets != "" || item.autoLoader)
					{
						item.isRecover = false;
						readBody(item);
						if (item.assets != "")
						{
							assets = g.loader.asset.asset.newAssetItem(item.assets);
							assets.isOnly = true;
							assets.isOnlyLink = false;
							assets.name = item.assets;
							if (assets) assets.data = item.obj;
						}
					}
				}
			}
		}
		
		/** 同步读取 **/
		private function readBody(item:GFileBase):void
		{
			if (item == null || bodyPosition[item] == null)
			{
				g.log.pushLog(this, LogType._ErrorLog, "未找到文件指针 : " + item.path);
			}
			else
			{
				var p:uint = bodyPosition[item];
				bodyStream.changeMode(ByteLink.READ);
				bodyStream.position = p;
				var l:uint = bodyStream.link.readUnsignedInt();
				var b:SByte = SByte.instance();
				bodyStream.readBytes(b, 0, l);
				switch (item.compress) 
				{
					case 1://1.zlib:默认
						b.uncompress();
						break;
					case 2://2.deflate:压缩(尽量别用)
						b.uncompress("deflate");
						break;
					case 3://3.lzma也就是7z
						b.uncompress("lzma");
						break;
				}
				b.position = 0;
				item.setBodyByte(b);
			}
		}
		
		/** 写入文件,包含头为身体 **/
		public function writeFile():void
		{
			bodyStream.changeMode(ByteLink.WRITE);
			//操作身体
			bodyStream.position = 0;
			this.writeBodyByte(bodyStream);
			//bodyStream.writeBytes(this.getBodyByte());
			//操作脑袋
			writeHeadFile();
		}
		
		/** 要写入新的文件 **/
		private var writeFileBase:GFileBase;
		/** 写入文件回调 **/
		private var writeFileMethod:Function;
		
		/** 写入单个文件 **/
		public function writeBaseFile(fileBase:GFileBase, byte:SByte, method:Function):void
		{
			this.writeFileBase = fileBase;
			this.writeFileMethod = method;
			var arr:Array = fileBase.path.split(".");
			var type:String = arr[(arr.length - 1)];
			switch (type)
			{
				case "jpg":
					g.event.addListener(fileBase, GFileEvent.BITMAPCOMPLETE, writeFileEvent);
					(fileBase as GBitmapData).setBodyUseFile(byte);
					return;
					break;
				case "png":
					g.event.addListener(fileBase, GFileEvent.BITMAPCOMPLETE, writeFileEvent);
					(fileBase as GBitmapData).setBodyUseFile(byte);
					return;
					break;
				case "xml":
					fileBase.obj = XMLToObject.to(new XML(byte.readUTFBytes(byte.length)), false, false);
					break;
				case "json":
					fileBase.obj = g.jsonGetObj(byte.readUTFBytes(byte.length));
					break;
				/*
				case "bin":
				case "mbin":
				case "amf":
				case "as3Movie":
				case "glan":
				case "mp3":
				*/
				default: 
					fileBase.sourceByte = byte;
			}
			writeFileEvent();
		}
		
		/** 写入的文件的二进制也处理好的, 如果定义savePath的documentPath就会写入本地的文件夹 **/
		public function writeBaseByteFileList(list:Vector.<GFileBase>, savePath:String = ""):void
		{
			if (list.length)
			{
				var source:GFileBase;
				var file:File;
				var fileStream:FileStream;
				for each (var item:GFileBase in list) 
				{
					if (savePath)
					{
						file = new File(savePath + item.path);
						fileStream = new FileStream();
						fileStream.open(file, FileMode.WRITE);
						item.sourceByte.position = 0;
						fileStream.writeBytes(item.sourceByte);
						item.sourceByte.position = 0;
						fileStream.close();
					}
					//找下原包里有那个文件没有, 有文件就删除,腾出空间来
					source = this.getPath(item.path);
					if (source) this.clear(source);
					this.push(item);
					item.isBuilder = true;
					this.getWritePosition(item);
					//写入包头
					item.isBuilder = false;
					item.sourceByte = null;
				}
				this.writeBlank();
				this.writeHeadFile();
			}
		}
		
		/** 写入的文件的二进制也处理好的 **/
		public function writeBaseByteFile(writeFile:GFileBase):void
		{
			this.writeFileBase = writeFile;
			this.writeFileMethod = null;
			writeFileEvent();
		}
		
		/** 把网上下的文件写入 **/
		private function writeFileEvent(e:* = null):void
		{
			//写入内容
			if (writeFileBase)
			{
				//找下原包里有那个文件没有, 有文件就删除,腾出空间来
				var source:GFileBase = this.getPath(writeFileBase.path);
				if (source)
				{
					this.clear(source);
					this.writeBlank();
					this.writeHeadFile();
				}
				this.push(writeFileBase);
				writeFileBase.isBuilder = true;
				this.getWritePosition(writeFileBase);
				//写入包头
				this.writeBlank();
				this.writeHeadFile();
				writeFileBase.isBuilder = false;
				writeFileBase.sourceByte = null;
				writeFileBase = null;
				if (writeFileMethod != null)
				{
					writeFileMethod();
					writeFileMethod = null;
				}
			}
		}
		
		/**
		 * 15年打版技术,将一个文件夹的内容合并进这个GFile,并且把body连接起来
		 * @param	bodyStart		从什么地方开始写入
		 * @param	folderPath		文件夹路径,不包含末尾的"/"
		 * @param	headInfo		头文件
		 * @param	bodyFile		身体部分内容
		 * @param	folderBodyPath	路径对应是否有列表
		 * @return	返回现在body的长度
		 */
		public function writeFolderList(bodyStart:uint, folderPath:String, headInfo:GListBase, folderBodyFile:File, folderBodyPath:Vector.<String>):uint
		{
			if (bodyStart == 0)
			{
				bodyStream.changeMode(ByteLink.WRITE);
			}
			else
			{
				bodyStream.changeMode(ByteLink.UPDATE);
			}
			//把老的没有的文件删除掉
			var folderLength:uint = folderPath.length;
			var folderPathLength:uint = 0;
			if (folderLength)
			{
				folderPathLength = folderPath.split("/").length + 1;
			}
			var removeList:Vector.<GFileBase> = new Vector.<GFileBase>();
			var itemPath:String;
			var itemPathArr:Array;
			var itemPathLength:uint;
			for each (var item:GFileBase in list) 
			{
				itemPath = item.path;
				if (folderLength == 0 || itemPath.substr(0, folderLength) == folderPath)
				{
					//查看是否是同级目录
					itemPathArr = itemPath.split("/");
					itemPathLength = itemPathArr.length;
					if (itemPathLength == folderPathLength)
					{
						if (headInfo.pathLib.hasOwnProperty(itemPath) == false)
						{
							removeList.push(item);
						}
					}
					else if (itemPathLength > folderPathLength && removeList.indexOf(item) == -1)
					{
						//找出路径,查路径列表中是否有对应的数据.如果没有就要删除这个文件
						itemPathArr.pop();
						itemPath = itemPathArr.join("/");
						if (folderBodyPath.indexOf(itemPath) == -1)
						{
							removeList.push(item);
						}
					}
				}
			}
			//删除可能不存在的文件
			for each (item in removeList) 
			{
				this.addVer += item.ver;
				this.remove(item);
			}
			//现在对比新的文件
			var thisItem:GFileBase;
			for each (item in headInfo.list) 
			{
				itemPath = item.path;
				if (this.pathLib.hasOwnProperty(itemPath))
				{
					thisItem = this.pathLib[itemPath];
					if (thisItem.ver != item.ver)
					{
						if (Version.compare(item.ver, thisItem.ver))
						{
							thisItem.ver = item.ver;
						}
						else
						{
							item.ver = thisItem.ver;
						}
					}
					if (thisItem.md5 != item.md5 || thisItem.type != item.type)
					{
						this.remove(thisItem);
						this.push(item);
						thisItem = item;
					}
				}
				else
				{
					thisItem = item;
					this.push(thisItem);
				}
				//把修正头文件的起始位置
				this.bodyPosition[thisItem] = headInfo.bodyPosition[item] + bodyStart;
			}
			//写入身体
			var folderSize:uint = folderBodyFile.size;
			var folderBodyFileStream:FileStream = new FileStream();
			var folderBodyFilePosition:uint = 0;
			folderBodyFileStream.open(folderBodyFile, FileMode.READ);
			if (folderSize < folderBodyFileStream.bytesAvailable)
			{
				folderSize = folderBodyFileStream.bytesAvailable;
			}
			var readSize:uint = 0;
			var writeByte:SByte = SByte.instance();
			while (folderSize > folderBodyFilePosition)
			{
				writeByte.clear();
				//读出5M 2 * 1024 * 1024 = 2097152
				//读出5M 5 * 1024 * 1024 = 5242880
				//读出10M 10* 1024 * 1024 = 10485760
				//读出1000M 1000* 1024 * 1024 = 1048576000
				readSize = 1048576000;
				if ((folderBodyFilePosition + readSize) > folderSize) readSize = folderSize - folderBodyFilePosition;
				folderBodyFileStream.position = folderBodyFilePosition;
				folderBodyFileStream.readBytes(writeByte, 0, readSize);
				writeByte.position = 0;
				bodyStream.position = bodyStart;
				bodyStream.link.writeBytes(writeByte);
				folderBodyFilePosition = folderBodyFilePosition + readSize;
				bodyStart = bodyStart + readSize;
				bodyStream.changeMode(ByteLink.UPDATE);
			}
			writeByte.dispose();
			writeByte = null;
			folderBodyFileStream.close();
			//保存头文件,记录下
			writeHeadFile();
			return bodyStart;
		}
		
		/** 写入头部分的内容 **/
		public function writeHeadFile():void
		{
			backHeadFile();
			headStream.changeMode(ByteLink.WRITE);
			headStream.position = 0;
			headStream.link.writeBytes(this.getHeadByte());
			delBackHeadFile();
		}
		
		//这个比较消耗CPU,老是反复拷贝这个 _back_head 文件
		/**
		 * 小文件备份好头文件不用删除,等10秒或20秒后在删除
		 * 
		 * 
		 */
		/** 备份头文件 **/
		private function backHeadFile():void
		{
			if (autoBackHead)
			{
				try
				{
					var f:File = useFileGetPath(headPath + "_back_head");
					try
					{
						f.preventBackup = true;
					}
					catch (e:Error)
					{
						g.log.pushLog(this, LogType._ErrorLog, "GFile 创建备份 preventBackup 失败 : " + securityURL + " " + e.message);
					}
					headStream.close();
					headStream.file.copyTo(f, true);
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile 创建备份失败 : " + securityURL + " " + e.message);
				}
			}
		}
		
		/** 删除备份的头文件 **/
		private function delBackHeadFile():void
		{
			if (autoBackHead)
			{
				try
				{
					var f:File = useFileGetPath(headPath + "_back_head");
					if (f && f.exists) f.deleteFile();
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile 删除备份失败 : " + securityURL + " " + e.message);
				}
			}
		}
		
		/** 检测是否有备份的头文件 **/
		private function checkBackHeadFile():void
		{
			if (autoBackHead)
			{
				try
				{
					var f:File = useFileGetPath(headPath + "_back_head");
					if (f && f.exists)
					{
						if (headStream == null) headStream = pathByteLink(headPath);
						if (headStream) headStream.close();
						f.copyTo(headStream.file, true);
						f.deleteFile();
					}
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile 恢复备份失败 : " + securityURL + " " + e.message);
				}
			}
		}
		
		/** 获取一个文件的写入位置 **/
		public function getWritePosition(fileItem:GFileBase):void
		{
			//生成包体
			var fileByte:SByte = fileItem.getBodyByte();
			fileByte.position = 0;
			switch (fileItem.compress) 
			{
				case 1://1.zlib:默认
					fileByte.compress();
					break;
				case 2://2.deflate:压缩(尽量别用)
					fileByte.compress("deflate");
					break;
				case 3://3.lzma也就是7z
					fileByte.compress("lzma");
					break;
			}
			fileByte.position = 0;
			var fileSize:uint = fileByte.length + 4;
			var isAdd:Boolean = false;
			if (useBlank)
			{
				var blankLength:uint;
				var list:Vector.<GFileBase> = blankList.list;
				var blank:GBlank;
				for each (var item:GFileBase in list) 
				{
					blank = (item as GBlank);
					if (blank)
					{
						blankLength = blank.length;
						if (blankLength > fileSize)
						{
							bodyStream.changeMode(ByteLink.UPDATE);
							bodyPosition[fileItem] = blank.start;
							bodyStream.link.position = blank.start;
							blank.start = blank.start + fileSize;
							blank.length = blankLength - fileSize;
							bodyStream.link.writeUnsignedInt(fileByte.length);
							bodyStream.link.writeBytes(fileByte);
							isAdd = true;
							break;
						}
						else if (blankLength == fileSize)
						{
							bodyStream.changeMode(ByteLink.UPDATE);
							bodyPosition[fileItem] = blank.start;
							bodyStream.link.position = blank.start;
							blankList.remove(item);
							bodyStream.link.writeUnsignedInt(fileByte.length);
							bodyStream.link.writeBytes(fileByte);
							isAdd = true;
							break;
						}
					}
				}
			}
			if(isAdd == false)
			{
				bodyStream.changeMode(ByteLink.APPEND);
				bodyPosition[fileItem] = bodyLength;
				bodyLength += fileSize;
				bodyStream.link.writeUnsignedInt(fileByte.length);
				bodyStream.link.writeBytes(fileByte);
			}
		}
		
		/**
		 * 另外一种删除文件的方式,腾出空间方式,并生成一个空白的区域,并且保存空白区域
		 * @param	file
		 */
		public function clear(item:GFileBase):void
		{
			var blank:GBlank = new GBlank();
			blank.ver = item.ver;
			var position:uint = bodyPosition[item];
			blank.start = position;
			bodyStream.changeMode(ByteLink.READ);
			bodyStream.position = position;
			var length:uint = bodyStream.link.readUnsignedInt();
			blank.length = length;
			this.blankList.superPush(blank);
			remove(item);
		}
		
		/** 把现在的空白区域文件写入文件 **/
		public function writeBlank():void
		{
			if (blankPath)
			{
				if (blankStream == null)
				{
					blankStream = pathByteLink(blankPath);
					try
					{
						blankStream.file.preventBackup = preventBackup;
					}
					catch (e:Error)
					{
						g.log.pushLog(this, LogType._ErrorLog, "writeBlank 操作文件 preventBackup 出错 : " + blankPath + "出错 :" + e.message);
					}
				}
				if(blankStream)
				{
					blankStream.changeMode(ByteLink.WRITE);
					var blankByte:SByte = blankList.getByte();
					blankByte.position = 0;
					blankStream.link.writeBytes(blankByte);
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile writeBlank 操作文件出错 : " + blankPath);
				}
			}
		}
		
		/** 把现在的空白区域文件写入文件,每次写GFile的时候随便写进去 **/
		public function writeAssist():void
		{
			if (useAssist)
			{
				//找出全不的Assist内容
				if (assistList) assistList.dispose();
				assistList = new GListBase();
				var assist:GAssist;
				var file:File;
				for each (var item:GFileBase in list) 
				{
					file = useFileGetPath(documentPath + item.path);
					if (file && file.exists && file.modificationDate)
					{
						assist = new GAssist();
						assist.name = item.name;
						assist.md5 = item.md5;
						assist.path = item.path;
						assist.ver = item.ver;
						assist.size = file.size;
						assist.time = file.modificationDate.time;
						assistList.push(assist);
					}
				}
				writeAssistSpeed();
			}
		}
		
		/** 在外部已经操作了这个GFile的Assist的处理,然后直接保存 **/
		public function writeAssistSpeed():void
		{
			if (useAssist)
			{
				if (assistStream == null)
				{
					assistStream = pathByteLink(assistPath, true);
					try
					{
						assistStream.file.preventBackup = preventBackup;
					}
					catch (e:Error)
					{
						g.log.pushLog(this, LogType._ErrorLog, "assistFile 操作文件 preventBackup 出错 : " + assistPath + "出错 :" + e.message);
					}
				}
				if(assistStream)
				{
					assistStream.changeMode(ByteLink.WRITE);
					var assistByte:SByte = assistList.getByte();
					assistByte.position = 0;
					assistStream.link.writeBytes(assistByte);
					assistByte.dispose();
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile writeBlank 操作文件出错 : " + blankPath);
				}
			}
		}
		
		/** 获取资源的地址 **/
		public function getAssist(path:String):GAssist
		{
			if (this.assistList)
			{
				return this.assistList.getPath(path) as GAssist;
			}
			return null;
		}
		
		/** 直接把内容输出 **/
		public function getPathObj(path:String):*
		{
			var out:GFileBase;
			if (pathLib && pathLib.hasOwnProperty(path))
			{
				out = pathLib[path] as GFileBase;
				return getPathObjRun(out);
			}
			return null;
		}
		
		/** 直接把内容输出 **/
		public function getPathObjRun(out:GFileBase):*
		{
			if(out.isComplete)
			{
				return out.obj;
			}
			else
			{
				var length:uint;
				try
				{
					bodyStream.changeMode(ByteLink.READ);
					bodyStream.link.position = bodyPosition[out];//内容体偏移量
					if(bodyStream.link.bytesAvailable < 4)
					{
						g.log.pushLog(this, LogType._ErrorLog, "GFile溢出:" + out.path);
						g.log.pushLog(this, LogType._ErrorLog, "FileBody:" + bodyStream.path);
						if (bodyStream.file)
						{
							g.log.pushLog(this, LogType._ErrorLog, "FileBodyPath:" + bodyStream.file.nativePath.toString());
							g.log.pushLog(this, LogType._ErrorLog, "FileBodySize:" + bodyStream.file.size);
						}
						g.log.pushLog(this, LogType._ErrorLog, "FileHead:" + headStream.path);
						if (headStream.file)
						{
							g.log.pushLog(this, LogType._ErrorLog, "FileHeadPath:" + headStream.file.nativePath.toString());
							g.log.pushLog(this, LogType._ErrorLog, "FileHeadSize:" + headStream.file.size);
						}
						return null;
					}
					length = bodyStream.link.readUnsignedInt();
					if(bodyStream.link.bytesAvailable < length)
					{
						g.log.pushLog(this, LogType._ErrorLog, "GFile溢出:" + out.path + ",长度:" + length);
						if (bodyStream.file)
						{
							g.log.pushLog(this, LogType._ErrorLog, "File:" + bodyStream.file.nativePath.toString());
							g.log.pushLog(this, LogType._ErrorLog, "FileSize:" + bodyStream.file.size);
						}
						if (bodyStream.link)
						{
							g.log.pushLog(this, LogType._ErrorLog, "剩余容量:" + bodyStream.link.bytesAvailable);
						}
						length = bodyStream.link.bytesAvailable;
					}
					var byte:SByte = SByte.instance();
					bodyStream.link.readBytes(byte, 0, length);
					switch (out.compress) 
					{
						case 1://1.zlib:默认
							byte.uncompress();
							break;
						case 2://2.deflate:压缩(尽量别用)
							byte.uncompress("deflate");
							break;
						case 3://3.lzma也就是7z
							byte.uncompress("lzma");
							break;
					}
					return out.setBodyByte(byte, true);
				}
				catch (e:Error)
				{
					if (useFileType == 1)
					{
						g.log.pushLog(this, LogType._ErrorLog, "读取 File.applicationStorageDirectory : " + File.applicationStorageDirectory.nativePath.toString() + " bodyPath : " + bodyPath + "的" + out.path + "出错 :" + e.message);
					}
					else if (useFileType == 2)
					{
						g.log.pushLog(this, LogType._ErrorLog, "读取 File.applicationDirectory : " + File.applicationDirectory.nativePath.toString() + " bodyPath : " + bodyPath + "的" + out.path + "出错 :" + e.message);
					}
					else if (useFileType == 3)
					{
						g.log.pushLog(this, LogType._ErrorLog, "读取 File.cacheDirectory : " + File.cacheDirectory.nativePath.toString() + " bodyPath : " + bodyPath + "的" + out.path + "出错 :" + e.message);
					}
					else if (useFileType == 4)
					{
						g.log.pushLog(this, LogType._ErrorLog, "读取 File.documentsDirectory : " + File.documentsDirectory.nativePath.toString() + " bodyPath : " + bodyPath + "的" + out.path + "出错 :" + e.message);
					}
					else
					{
						g.log.pushLog(this, LogType._ErrorLog, "读取 : " + bodyPath + "的" + out.path + "出错 :" + e.message);
					}
					g.log.pushLog(this, LogType._ErrorLog, "溢出 Position:" + bodyPosition[out]);
					g.log.pushLog(this, LogType._ErrorLog, "溢出 文件长度:" + length);
					if (bodyStream.link)
					{
						g.log.pushLog(this, LogType._ErrorLog, "溢出 现在位置:" + bodyStream.link.position);
						g.log.pushLog(this, LogType._ErrorLog, "溢出 剩余容量:" + bodyStream.link.bytesAvailable);
					}
					else
					{
						g.log.pushLog(this, LogType._ErrorLog, "溢出 缺少内容 bodyStream.link");
					}
					if (bodyStream.file)
					{
						g.log.pushLog(this, LogType._ErrorLog, "溢出 文件大小:" + bodyStream.file.size);
					}
				}
			}
			return null;
		}
		
		/**
		 * 获取信息并且载入二进制内容
		 * @param path
		 * @return 
		 */
		public function getPathLoad(path:String):GFileBase
		{
			var out:GFileBase;
			if (pathLib.hasOwnProperty(path))
			{
				out = pathLib[path] as GFileBase;
				if(out.isComplete)
				{
					return out;
				}
				else
				{
					bodyStream.changeMode(ByteLink.READ);
					bodyStream.position = bodyPosition[out];//内容体偏移量
					var length:uint = bodyStream.link.readUnsignedInt();
					if(bodyStream.link.bytesAvailable < length)
					{
						g.log.pushLog(this, LogType._ErrorLog, "文件读取失败,比较严重的bug,估计数据包已经损坏!path:" + path);
						length = out.sourceLength;
					}
					var itemByte:SByte = SByte.instance();
					bodyStream.readBytes(itemByte, 0, length);
					switch (out.compress) 
					{
						case 1://1.zlib:默认
							itemByte.uncompress();
							break;
						case 2://2.deflate:压缩(尽量别用)
							itemByte.uncompress("deflate");
							break;
						case 3://3.lzma也就是7z
							itemByte.uncompress("lzma");
							break;
					}
					if (itemByte.length)
					{
						out.setBodyByte(itemByte);
						return out;
					}
				}
			}
			return null;
		}
		
		/** 按照URL获取一个图片 **/
		public function getPathBitmapData(path:String):BitmapData
		{
			return getPath(path).obj as BitmapData;
		}
		
		/** 设置bitmap的内容,因为有些Image是异步解码 **/
		public function setPathBitmap(bitmap:Bitmap, path:String):void
		{
			if (getPath(path).obj)
			{
				bitmap.bitmapData = getPath(path).obj as BitmapData;
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "走异步加载,还没做");
			}
		}
		
		/** 销毁并移除对象，释放资源 **/
		override public function dispose():void
		{
			super.dispose();
			var list:Vector.<GFileBase> = blankList.list;
			for each (var item:GFileBase in list) 
			{
				item.dispose();
			}
			list.length = 0;
			if (blankStream)
			{
				blankStream.dispose();
				blankStream = null;
			}
			if (headStream)
			{
				headStream.dispose();
				headStream = null;
			}
			if (bodyStream)
			{
				bodyStream.dispose();
				bodyStream = null;
			}
			if (assistStream)
			{
				assistStream.dispose();
				assistStream = null;
			}
		}
	}
}