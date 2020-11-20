package cn.wjj.data.file 
{
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.display.speed.GetBitmapData;
	import cn.wjj.display.ui2d.engine.EngineBitmapX;
	import cn.wjj.display.ui2d.info.U2InfoBitmapX;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.factory.FBitmap;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.tool.Version;
	import com.adobe.crypto.MD5;
	import data.model.system.GFileModel;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.getTimer;
	
	/**
	 * 2015年版GFile打包
	 * 
	 * 1.先处理全部文件夹
	 * 2.把全部文件夹中的文件合并到body中
	 * 
	 * 提示部分
	 * 
	 * 
	 * 处理文件夹
	 * 1.在每个文件夹中建立01_folder_head.gf(GListBase),01_folder_body.gf(二进制)
	 * 2.01_floder_assist.gf (记录文件名和大小,时间 GListBase -> GAssist)
	 * 
	 * 
	 * 在根目录下放置 folder.gf 做记录文件夹的情况
	 * 一个文件夹一个文件夹的创建
	 * 
	 * 没有 01_folder_head.gf 或 01_folder_body.gf 会重新创建
	 * 没有 01_floder_assist.gf 会重新全部刷新
	 * 有 01_floder_assist.gf 会对比文件的大小决定是否全部刷新
	 * 
	 * 预合并
	 * 如果本层有变化,就先要删除本层的文件 02_folder_head.gf 和 02_folder_body.gf
	 * 
	 * 合并GFile的head和body
	 * 1.将每个文件夹的内容取出,读入主head中(取高版本)
	 * 2.将现在的body从0开始写入.
	 * 3.从每个文件夹中取出每个文件的偏移坐标都叠加主body的长度
	 * 4.直接把01_folder_body连入body中
	 * 5.将head保存
	 * 6.备份文件
	 * 
	 * @version 1.0.0
	 * @author GaGa <15020055@qq.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GFilePackage
	{
		/** 操作的GFile对象 **/
		private var gfile:GFile;
		/** GFile里的文件夹和文件的列表 **/
		private var gfileFolderList:Object;
		/** 现在选中的客户端数据 **/
		private var gfileInfo:GFileModel;
		/** 文档目录 **/
		private var document:File;
		/** 文件夹的列表 **/
		private var folderList:Vector.<String> = new Vector.<String>();
		/** 文件夹处理计数 **/
		private var folderCount:uint = 0;
		/** 文件夹的总共数量 **/
		private var folderLength:uint = 0;
		/** 把全部的目录都遍历出来 **/
		private var documentList:Vector.<GListBase> = new Vector.<GListBase>();
		/** 空文件夹列表 **/
		private var emptyList:Vector.<int> = new Vector.<int>();
		/** [懒得做了]记录发生改变的目录层级 **/
		private var makeHeadList:Vector.<String> = new Vector.<String>();
		/** [懒得做了]记录发生改变的目录层级(如果body改变,那么head肯定改变) **/
		private var makeBodyList:Vector.<String> = new Vector.<String>();
		/** 打包完毕回调 **/
		private var complete:Function;
		/** 是否拷贝到updata文件夹 **/
		private var copyUpdata:Boolean;
		/** PNG的默认压缩模式 **/
		private var pngCompress:int = 0;
		/** JPG的默认压缩模式 **/
		private var jpgCompress:int = 0;
		
		/** 有多少文件需要载入 **/
		private var loaderLength:uint = 0;
		/** 已经载入了多少文件 **/
		private var loaderComplete:uint = 0;
		
		/** 是否有连接DOS的批处理文件 **/
		private var joinBatFile:File;
		/** 开始打版时间 **/
		public var timeStart:uint = 0;
		/** 开始打版时间 **/
		public var timeJoin:uint = 0;
		/** 开始合并版本号,处理头文本时间 **/
		public var timeHead:uint = 0;
		/** 完成时间 **/
		public var timeComplete:uint = 0;
		
		/**
		 * 建立文件系统
		 */
		public function GFilePackage():void { }
		
		/**
		 * 设置GFile
		 * @param	gfile		GFile的引用
		 * @param	gfileInfo	信息
		 */
		public function setInfo(gfile:GFile, gfileInfo:GFileModel, complete:Function, copyUpdata:Boolean = true, jpgCompress:int = 5, pngCompress:int = 4):Boolean
		{
			var documentURL:String = gfileInfo.relativePath + gfileInfo.documentPath;
			document = new File(documentURL);
			//把内容都输出出来到界面里来!
			if(document.isDirectory)
			{
				this.gfile = gfile;
				this.gfileInfo = gfileInfo;
				this.copyUpdata = copyUpdata;
				this.jpgCompress = jpgCompress;
				this.pngCompress = pngCompress;
				this.complete = complete;
				folderList.length = 0;
				documentList.length = 0;
				folderCount = 0;
				emptyList.length = 0;
				makeHeadList.length = 0;
				makeBodyList.length = 0;
				return true;
			}
			else
			{
				AllDo.getInstance.components.alert("提示", "未找到名称为 : " + documentURL + " 的资源");
			}
			return false;
		}
		
		/** 开始打包 **/
		public function packageThis():void
		{
			timeStart = getTimer();
			var documentURL:String = gfileInfo.relativePath + gfileInfo.documentPath;
			getAllFolderList(document, documentURL);
			getAllGFileList();
			folderLength = folderList.length;
			g.log.pushLog(this, LogType._UserAction, "[15技术打包GFile]文件夹列表数量 : " + folderLength);
			if (folderLength > folderCount)
			{
				handleFolder();
			}
			else
			{
				handleNextFolder();
			}
		}
		
		/** 获取全部的文件夹 **/
		private function getAllFolderList(folder:File, documentURL:String):void
		{
			var path:String = GFileGetTools.getFileUrl(folder.nativePath.substr(documentURL.length));
			folderList.push(path);
			var list:Array = folder.getDirectoryListing();
			for each(var file:File in list)
			{
				if (file.isDirectory && GFileGetTools.fileIsRight(file.name, file.nativePath))
				{
					getAllFolderList(file, documentURL);
				}
			}
		}
		
		/** 整理出来老的Gfile文件里的情况,对删除文件进行处理 **/
		private function getAllGFileList():void
		{
			var path:String;
			var vector:Vector.<GFileBase>;
			var pathArr:Array;
			gfileFolderList = new Object();
			//整理老GFile内容, 把要删除的文件拿出来
			for each (var item:GFileBase in gfile.list) 
			{
				if (item.path.indexOf("/"))
				{
					pathArr = item.path.split("/");
					pathArr.pop();
					path = pathArr.join("/");
				}
				else
				{
					path = "";
				}
				if (gfileFolderList.hasOwnProperty(path))
				{
					vector = gfileFolderList[path];
				}
				else
				{
					vector = new Vector.<GFileBase>();
					gfileFolderList[path] = vector;
				}
				vector.push(item);
			}
		}
		
		/** 运行下一个文件夹 **/
		private function handleNextFolder():void
		{
			g.event.removeEnterFrame(handleNextFolder);
			folderCount++;
			if (folderCount < folderLength)
			{
				handleFolder();
			}
			else
			{
				var path:String;
				var item:GFileBase;
				//删除空文件夹
				folderLength = folderLength - emptyList.length;
				var vector:Vector.<GFileBase>;
				var pathVector:Vector.<String>;
				for each (var empty:int in emptyList) 
				{
					folderList.splice(empty, 1);
					documentList.splice(empty, 1);
				}
				//反推文件夹,如果GFile有的,folderList里没有,就干掉GFile的文件夹
				for (path in gfileFolderList) 
				{
					if (folderList.indexOf(path) == -1)
					{
						vector = gfileFolderList[path];
						for each (item in vector) 
						{
							gfile.addVer = Version.mergeAuto(item.ver, gfile.addVer, true);
							gfile.remove(item);
						}
					}
				}
				g.log.pushLog(this, LogType._UserAction, "[15技术打包GFile]文件夹准备完毕,数量 : " + folderLength);
				//文件夹全部执行完毕
				if (folderLength == 0)
				{
					//需要把body文件干了
				}
				else
				{
					//把全部的文件夹内内容合并成递归的大包,以让以后快速处理使用
					mackAllFolder();
					fileSize = 0;
					joinBug = 0;
					joinFolderTemp = 0;
					joinFolderLength = 0;
					timeJoin = getTimer();
					joinFileDo();
				}
			}
		}
		
		/** 写入文件的大小 **/
		private var fileSize:uint = 0;
		/** 合并失败次数 **/
		private var joinBug:int = 0;
		/** 临时的连接文件 **/
		private var joinFolderTemp:int = 0;
		/** 已经连接的文件 **/
		private var joinFolderLength:int = 0;
		
		/** 连接文件成功 **/
		private function joinFileOk():void
		{
			timeHead = getTimer();
			//使用DOS,批处理执行内容
			
			
			
			
			
			
			//更新版本号
			var ver:String = "0.0.0";
			for each (var item:GFileBase in gfile.list) 
			{
				ver = Version.mergeAuto(ver, item.ver, true);
			}
			gfile.ver = Version.mergeAuto(ver, gfile.addVer, true);
			try
			{
				gfile.writeHeadFile();
			}
			catch(e:Error)
			{
				throw new Error("把版本号写入头文件失败 : " + e.errorID + " " + e.message + " " + e.name);
			}
			g.log.pushLog(this, LogType._UserAction, "[15技术打包GFile]头文件写入完毕");
			//写入版本号
			GFileGetTools.saveVerText(gfileInfo, gfile);
			g.log.pushLog(this, LogType._UserAction, "[15技术打包GFile]写入版本号 : " + gfile.ver);
			if (copyUpdata)
			{
				GFileGetTools.copyUpdataFile(gfileInfo, gfile.list);
			}
			g.log.pushLog(this, LogType._UserAction, "[15技术打包GFile]合并完毕");
			timeComplete = getTimer();
			if (complete != null)
			{
				complete();
				complete = null;
			}
		}
		
		/** 不停的连接文件,直到 被5除后在进行连接 **/
		private function joinFileDo():void
		{
			
			
			var bodyFile:File;
			var path:String;
			var documentURL:String = gfileInfo.relativePath + gfileInfo.documentPath;
			for (; joinFolderLength < folderLength; joinFolderLength++) 
			{
				joinFolderTemp++;
				if (joinFolderTemp % 5 == 0)
				{
					g.event.addEnterFrame(joinFileDo, this);
					return;
				}
				else
				{
					g.event.removeEnterFrame(joinFileDo, this);
					path = folderList[joinFolderLength];
					bodyFile = new File(documentURL + path + "/01_folder_body.gf");
					try
					{
						fileSize = gfile.writeFolderList(fileSize, path, documentList[joinFolderLength], bodyFile, folderList);
					}
					catch(e:Error)
					{
						joinBug++;
						fileSize = 0;
						joinFolderLength = 0;
						if (joinBug > 10)
						{
							AllDo.getInstance.components.alert("合成文件失败", "合成文件错误次数操作10次," + e.errorID + " " + e.message + " " + e.name + ",建议关闭工具,删除 document 同级目录下, body.gf, blank.gf, head.gf重新打包");
							throw new Error("合并失败数次过高 : " + e.errorID + " " + e.message + " " + e.name);
						}
						else
						{
							joinFileDo();
						}
						g.log.pushLog(this, LogType._ErrorLog, "连接文件失败次数 : " + joinBug);
						return;
					}
				}
			}
			g.event.removeEnterFrame(joinFileDo, this);
			joinFileOk();
		}
		
		/**
		 * 逐级合并01_folder_head 和 01_folder_body 文件
		 * 并保存在下层的文件夹全部内容
		 * 最后合并GFile的时候,只用合并根目录下的就可以
		 * GFile最后的Body可以直接用
		 */
		private function mackAllFolder():void{}
		
		/** 头文件 **/
		private var folderHead:File;
		private var folderBody:File;
		private var floderAssist:File;
		private var folderHeadList:GListBase;
		private var floderAssistList:GListBase;
		private var folderHeadStream:FileStream;
		private var folderBodyStream:FileStream;
		private var floderAssistStream:FileStream;
		
		/** 记录文件夹里的bx图片 **/
		private var pathU2_bx:Vector.<String> = new Vector.<String>();
		/** 记录文件夹里的原始图片 **/
		private var pathU2_img:Vector.<String> = new Vector.<String>();
		
		/** 处理每一个文件夹 **/
		private function handleFolder():void
		{
			var path:String = folderList[folderCount];
			var documentURL:String = gfileInfo.relativePath + gfileInfo.documentPath;
			var folder:File = new File(documentURL + path);
			var file:File;
			var list:Array = folder.getDirectoryListing();
			folderHead = new File(documentURL + path + "/01_folder_head.gf");
			folderBody = new File(documentURL + path + "/01_folder_body.gf");
			floderAssist = new File(documentURL + path + "/01_floder_assist.gf");
			folderHeadStream = new FileStream();
			folderBodyStream = new FileStream();
			floderAssistStream = new FileStream();
			//任何一个文件没有,就要全部刷新全部文件
			folderHeadList = new GListBase();
			folderHeadList.isBuilder = true;
			floderAssistList = new GListBase();
			documentList.push(folderHeadList);
			//是否需要重新搞body文件
			var useMack:Boolean = false;
			var b:SByte;
			if (floderAssist.exists == false || folderHead.exists == false || folderBody.exists == false || folderBody.size == 0)
			{
				useMack = false;
			}
			else
			{
				floderAssistStream.open(floderAssist, FileMode.READ);
				floderAssistStream.position = 0;
				b = SByte.instance();
				floderAssistStream.readBytes(b);
				floderAssistList.setHeadByte(b);
				floderAssistStream.close();
			}
			if (folderHead.exists && folderBody.exists)
			{
				folderHeadStream.open(folderHead, FileMode.READ);
				folderHeadStream.position = 0;
				b = SByte.instance();
				folderHeadStream.readBytes(b);
				folderHeadList.setHeadByte(b);
				folderHeadStream.close();
			}
			var itemPath:String;
			var assistItem:GAssist;
			var folderItem:GFileBase;
			//文件夹内有多少文件
			var folderLength:uint = 0;
			//对比全部的 floderAssistList 文件和 folderHeadList 是否有这个文件
			var pathList:Vector.<String> = new Vector.<String>();
			var i:int = list.length;
			var saveHead:Boolean = false;
			var isImage:Boolean = false;
			var u2ImageMD5:String = "";
			var bxFile:File;
			var imgFile:File;
			pathU2_bx.length = 0;
			pathU2_img.length = 0;
			while (--i > -1) 
			{
				file = list[i];
				itemPath = path + "/" + file.name;
				if (file.isDirectory == false && GFileGetTools.fileIsRight(file.name, file.nativePath) && itemPath.substr(-6, 5) != ".u2bx")
				{
					isImage = false;
					u2ImageMD5 = "";
					if (itemPath.substr( -4, 4) == ".jpg" || itemPath.substr( -4, 4) == ".png")
					{
						pathU2_img.push(itemPath);
						isImage = true;
					}
					//当是图片的时候做特殊处理 jpg png -> u2bxj u2bxp
					//当是 u2bxj u2bxp 的时候,记录起来,如果有对应png出现,就清理,最后如果没有,要删除文件
					//当文件夹都完成的时候处理这个
					//当图片升级的时候, u2bxj u2bxp 肯定要升级
					folderLength++;
					pathList.push(itemPath);
					assistItem = floderAssistList.getPath(itemPath) as GAssist;
					if (useMack == false)
					{
						folderItem = folderHeadList.getPath(itemPath);
						if (folderItem == null)
						{
							useMack = true;
							saveHead = true;
						}
					}
					if (assistItem)
					{
						if (useMack)
						{
							assistItem.size = file.size;
							if (file.modificationDate)
							{
								assistItem.time = file.modificationDate.time;
							}
						}
						else
						{
							if (assistItem.size != file.size)
							{
								assistItem.size = file.size;
								if (file.modificationDate)
								{
									assistItem.time = file.modificationDate.time;
								}
								useMack = true;
								saveHead = true;
							}
							else if (file.modificationDate && assistItem.time != file.modificationDate.time)
							{
								assistItem.time = file.modificationDate.time;
								//对比MD5来确认是否真需要处理,并且开始是不需要处理的
								if (useMack == false)
								{
									//folderItem.md5 这个MD5可能是 GU2BitmapX 二进制的 MD5, 需要获取内部的MD5,对比本地的文件吧
									if (isImage)
									{
										if (GFileGetTools.fileMD5(file, documentURL) != folderItem.md5)
										{
											useMack = true;
										}
										else
										{
											bxFile = GFileGetTools.imageBitmapXFile(itemPath, documentURL);
											if (folderItem.type == GFileType.U2BitmapX)
											{
												//本地无
												if (bxFile)
												{
													//这里要对比二个文件的尺寸
													if (assistItem.bxSize != bxFile.size)
													{
														assistItem.bxSize = bxFile.size;
														if (bxFile.modificationDate)
														{
															assistItem.bxTime = bxFile.modificationDate.time;
														}
														useMack = true;
														saveHead = true;
													}
													else if (bxFile.modificationDate && assistItem.bxTime != bxFile.modificationDate.time)
													{
														assistItem.bxTime = bxFile.modificationDate.time;
														//对比MD5
														if (assistItem.bxMD5 != GFileGetTools.fileMD5(bxFile, documentURL))
														{
															useMack = true;
														}
														saveHead = true;
													}
												}
												else
												{
													//如果是BitmapX,本地无这个文件要处理
													useMack = true;
												}
											}
											else
											{
												//如果不是BitmapX, 本地有BX文件要处理
												if (bxFile)
												{
													useMack = true;
												}
											}
										}
									}
									else
									{
										if (GFileGetTools.fileMD5(file, documentURL) != folderItem.md5)
										{
											useMack = true;
										}
									}
								}
								saveHead = true;
							}
							else if (useMack == false && isImage)
							{
								bxFile = GFileGetTools.imageBitmapXFile(itemPath, documentURL);
								if (folderItem.type == GFileType.U2BitmapX)
								{
									if (bxFile)
									{
										//这里要对比二个文件的尺寸
										if (assistItem.bxSize != bxFile.size)
										{
											assistItem.bxSize = bxFile.size;
											if (bxFile.modificationDate)
											{
												assistItem.bxTime = bxFile.modificationDate.time;
											}
											useMack = true;
											saveHead = true;
										}
										else if (bxFile.modificationDate && assistItem.bxTime != bxFile.modificationDate.time)
										{
											assistItem.bxTime = bxFile.modificationDate.time;
											//对比MD5
											if (assistItem.bxMD5 != GFileGetTools.fileMD5(bxFile, documentURL))
											{
												useMack = true;
											}
											saveHead = true;
										}
									}
									else
									{
										//如果是BitmapX,本地无这个文件要处理
										useMack = true;
										saveHead = true;
									}
								}
								else
								{
									//如果不是BitmapX, 本地有BX文件要处理
									if (bxFile)
									{
										useMack = true;
										saveHead = true;
									}
								}
							}
						}
					}
					else
					{
						assistItem = new GAssist();
						assistItem.path = itemPath;
						assistItem.name = GFileGetTools.getFileNoKZM(file.name);
						assistItem.md5 = MD5.hash(itemPath);
						assistItem.size = file.size;
						if (file.modificationDate)
						{
							assistItem.time = file.modificationDate.time;
						}
						floderAssistList.push(assistItem);
						useMack = true;
						saveHead = true;
					}
				}
				else
				{
					if (itemPath.substr(-6, 5) == ".u2bx")
					{
						//如果找不到这个图片,就要干掉这个文件
						imgFile = GFileGetTools.getBitmapXPath(itemPath, documentURL);
						//这里在次对比原始二进制,和上面的MD5做2个相互呼应,来确保文件OK
						if (useMack == false && imgFile == null)
						{
							useMack = true;
							saveHead = true;
						}
						pathU2_bx.push(itemPath);
					}
					list.splice(i, 1);
				}
			}
			//查看有无删除文件,如果folderItem里有未找到文件就干掉
			var removeList:Vector.<GFileBase> = new Vector.<GFileBase>()
			for each (folderItem in folderHeadList.list) 
			{
				if (pathList.indexOf(folderItem.path) == -1)
				{
					useMack = true;
					removeList.push(folderItem);
				}
			}
			//查看 u2bx 系列文件有无修改
			/*
			在上面已经判断了,这里废弃
			if (useMack == false && pathU2_bx.length)
			{
				//查看图片中有bx类型的内容
				for each (var bx_path:String in pathU2_bx) 
				{
					if (bxChangeIt(bx_path))
					{
						useMack = true;
						break;
					}
				}
			}
			*/
			if (useMack)
			{
				for each (folderItem in removeList) 
				{
					folderHeadList.remove(folderItem);
					folderItem = floderAssistList.getPath(folderItem.path);
					if (folderItem)
					{
						floderAssistList.remove(folderItem);
					}
				}
			}
			//这里需要进行
			if (folderLength)
			{
				if (useMack)
				{
					//重新创建
					for each (file in list) 
					{
						GFileGetTools.handle15File(gfile, file, folderBody, folderBodyStream, documentURL, folderHeadList, imageAdd, imageComplete, jpgCompress, pngCompress);
					}
					readComplete();
				}
				else
				{
					//运行下一个文件夹
					if (saveHead)
					{
						b = floderAssistList.getHeadByte();
						b.position = 0;
						floderAssistStream.open(floderAssist, FileMode.WRITE);
						floderAssistStream.position = 0;
						floderAssistStream.writeBytes(b);
						floderAssistStream.close();
						saveFolderHead();
					}
					g.event.addEnterFrame(handleNextFolder);
				}
			}
			else
			{
				//删除文件
				if (folderHead.exists) folderHead.deleteFile();
				if (folderBody.exists) folderBody.deleteFile();
				if (floderAssist.exists) floderAssist.deleteFile();
				emptyList.unshift(folderCount);
				if (gfileFolderList.hasOwnProperty(path))
				{
					var vector:Vector.<GFileBase> = gfileFolderList[path];
					for each (var item:GFileBase in vector) 
					{
						gfile.addVer = Version.mergeAuto(item.ver, gfile.addVer, true);
						gfile.remove(item);
					}
					delete gfileFolderList[path];
				}
				g.event.addEnterFrame(handleNextFolder);
			}
		}
		
		/** 保存文件先, 头文件和身体文件 **/
		private function saveFolder():void
		{
			//保存身体文件
			var b:SByte = folderHeadList.getBodyByte();
			b.position = 0;
			folderBodyStream.open(folderBody, FileMode.WRITE);
			folderBodyStream.position = 0;
			folderBodyStream.writeBytes(b);
			folderBodyStream.close();
			saveFolderHead();
		}
		
		private function saveFolderHead():void
		{
			var b:SByte = folderHeadList.getHeadByte();
			b.position = 0;
			folderHeadStream.open(folderHead, FileMode.WRITE);
			folderHeadStream.position = 0;
			folderHeadStream.writeBytes(b);
			folderHeadStream.close();
			//清理,缓存的内容,清理OBJ
			folderHeadList.isBuilder = false;
			folderHeadList.sourceByte = null;
			for each (var item:GFileBase in folderHeadList.list) 
			{
				item.isBuilder = false;
				item.sourceByte = null;
				item.disposeObj();
			}
		}
		
		/** 有图片要载入 **/
		private function imageAdd():void
		{
			loaderLength++;
		}
		
		private function imageComplete(e:GFileEvent):void
		{
			loaderComplete++;
			g.log.pushLog(this, LogType._UserAction, "下载完毕 : " + e.file.path);
			if (loaderLength == loaderComplete) readComplete();
		}
		
		/** 图片都搞好了 **/
		private function readComplete():void
		{
			if(loaderLength == loaderComplete)
			{
				//查看图片中有bx类型的内容, 和asset的文件
				for each (var item:String in pathU2_bx) 
				{
					autoDoU2bx(item);
				}
				//保存Assist文件
				var b:SByte = floderAssistList.getHeadByte();
				b.position = 0;
				floderAssistStream.open(floderAssist, FileMode.WRITE);
				floderAssistStream.position = 0;
				floderAssistStream.writeBytes(b);
				floderAssistStream.close();
				//保存Head和Body
				loaderLength = 0;
				loaderComplete = 0;
				//保存文件
				saveFolder();
				g.event.addEnterFrame(handleNextFolder);
			}
		}
		
		/**
		 * 自动处理BX引用对象
		 * 1.找到 pathU2_img 有无对应内容
		 * 2.如果没有,删除这个path的文件,返回null
		 * 3.如果有,将首先获取u2bx对象
		 * 4.根据u2bx对象,获取缩放等信息,如果没有获取默认缩放值为1
		 * 5.找到图片对应的GBitmapData
		 * 6.将bitmapData数据按照u2bx进行优化
		 * 7.保存这个u2bx对象,根据jpg或png,来获取保存的文件名为.u2bxj .u2bxp
		 * 8.将创建的 GU2BitmapX 对象,丢到gfile里保存
		 * 9.删除对应的图片url
		 * 10.删除GBitmapData
		 * 
		 * @param	path
		 * @return
		 */
		private function autoDoU2bx(path:String):void
		{
			var kzm:String = path.substr(-6, 6);
			var imgPath:String = path.substr(0, path.length - 5);
			var imgType:String = "";
			if (kzm == ".u2bxj")
			{
				imgPath += "jpg";
				imgType = "jpg";
			}
			else if (kzm == ".u2bxp")
			{
				imgPath += "png";
				imgType = "png";
			}
			var imgIndex:int = pathU2_img.indexOf(imgPath);
			var assistItem:GAssist = floderAssistList.getPath(imgPath) as GAssist;
			var filePath:String = gfileInfo.relativePath + gfileInfo.documentPath + path;
			if (imgIndex != -1)
			{
				//9.删除对应的图片url
				pathU2_img.splice(imgIndex, 1);
				//5.找到图片对应的GBitmapData
				var gb:GBitmapData = folderHeadList.getPath(imgPath) as GBitmapData;
				if (gb)
				{
					//4.根据u2bx对象,获取缩放等信息,如果没有获取默认缩放值为1
					var U2:U2InfoBitmapX;
					var U2File:File = new File(filePath);
					var U2Stream:FileStream;
					var U2Byte:SByte;
					if (U2File && U2File.exists && U2File.size)
					{
						U2Stream = new FileStream();
						U2Stream.open(U2File, FileMode.READ);
						U2Stream.position = 0;
						U2Byte = SByte.instance();
						U2Stream.readBytes(U2Byte);
						U2Byte.position = 0;
						U2 = new U2InfoBitmapX(null);
						U2.setByte(U2Byte);
						U2Stream.close();
					}
					else
					{
						U2 = new U2InfoBitmapX(null);
					}
					if (U2Byte != null && U2.md5 != gb.md5)
					{
						if (imgType == "jpg")
						{
							U2.transparent = false;
						}
						var bitmap:FBitmap = FBitmap.instance(gb.obj, "auto", U2.smoothing);
						U2.sourceWidth = bitmap.bitmapData.width;
						U2.sourceHeigth = bitmap.bitmapData.height;
						var item:BitmapDataItem = GetBitmapData.cacheBitmap(bitmap, U2.transparent, 0x00000000, 1 / U2.offsetScale, U2.smoothing, "best");
						U2.width = item.bitmapData.width;
						U2.height = item.bitmapData.height;
						U2.offsetX = item.x;
						U2.offsetY = item.y;
						U2.offsetScaleX = U2.sourceWidth / U2.width;
						U2.offsetScaleY = U2.sourceHeigth / U2.height;
						U2.bitmapData = item.bitmapData;
						U2.md5 = gb.md5;
						//7.保存这个u2bx对象,根据jpg或png,来获取保存的文件名为.u2bxj .u2bxp
						U2Byte = U2.getByte();
						U2Byte.position = 0;
						U2Stream = new FileStream();
						U2Stream.open(U2File, FileMode.WRITE);
						U2Stream.position = 0;
						U2Stream.writeBytes(U2Byte);
						U2Stream.close();
						bitmap.dispose();
						bitmap = null;
					}
					//8.将创建的 GU2BitmapX 对象,丢到gfile里保存
					var fileBX:GU2BitmapX = new GU2BitmapX();
					fileBX.name = gb.name;
					fileBX.path = gb.path;
					fileBX.ver = gb.ver;
					fileBX.parent = gb.parent;
					fileBX.md5 = gb.md5;
					fileBX.isBuilder = true;
					U2Byte.position = 0;
					fileBX.sourceByte = U2Byte;
					fileBX.sourceLength = gb.sourceLength;
					//10.删除GBitmapData
					folderHeadList.remove(gb);
					folderHeadList.push(fileBX);
					//处理assistItem
					assistItem.bxSize = U2File.size;
					if (U2File.modificationDate)
					{
						assistItem.bxTime = U2File.modificationDate.time;
					}
					assistItem.bxMD5 = MD5.hashBytes(U2Byte);
					U2Byte.position = 0;
				}
				else
				{
					var removeItem:GFileBase = folderHeadList.getPath(imgPath);
					if(removeItem)
					{
						folderHeadList.remove(removeItem);
					}
					g.log.pushLog(this, LogType._ErrorLog, "严重错误,无法找到整合图片信息 : " + imgPath);
					if (assistItem) floderAssistList.remove(assistItem);
				}
			}
			else
			{
				//2.如果没有,删除这个path的文件,返回null
				var removeFile:File = new File(filePath);
				if (removeFile && removeFile.exists)
				{
					removeFile.deleteFile();
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "严重错误,删除必须删除的文件失败 : " + filePath);
				}
				if (assistItem) floderAssistList.remove(assistItem);
			}
		}
		
		/** 回收这个 **/
		public function dispose():void
		{
			complete = null;
			gfile = null;
			gfileInfo = null;
			document = null;
			folderList.length = 0;
			folderCount = 0;
			documentList.length = 0;
		}
	}
}