package cn.wjj.file.zipArchive
{
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	import cn.wjj.g;
	
	/**
	 * 分析器
	 */
	internal class ZipParser {
		
		private var _zip:ZipArchive;
		private var _data:ByteArray;
		private var _entries:int;
		private var _offsetOfFirstEntry:int;
		
		
		public function ZipParser() {
			_entries = 0;
			_offsetOfFirstEntry = 0;
		}
		
		internal function loadZipFromFile(zip:ZipArchive, url:String):void {
			_zip = zip;
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
			load(url);
		}
		
		internal function loadZipFromBytes(zip:ZipArchive, data:ByteArray):void{
			_zip = zip;
			_data = data;
			_data.position = 0;
			_data.endian = Endian.LITTLE_ENDIAN;
			parse();
		}
		
		private function load(url:String):void {
			var stream:URLStream = new URLStream();
			stream.load(new URLRequest(url));
			stream.addEventListener(ProgressEvent.PROGRESS, zipLoadHanlder);
			stream.addEventListener(Event.COMPLETE, zipLoadHanlder);
			stream.addEventListener(IOErrorEvent.IO_ERROR, zipLoadHanlder);
		}
		
		private function zipLoadHanlder(evt:Event):void
		{
			switch(evt.type)
			{
				case Event.COMPLETE:
					evt.target.removeEventListener(ProgressEvent.PROGRESS, zipLoadHanlder);
					evt.target.removeEventListener(Event.COMPLETE, zipLoadHanlder);
					evt.target.removeEventListener(IOErrorEvent.IO_ERROR, zipLoadHanlder);
					URLStream(evt.target).readBytes(_data);
					_zip.dispatchEvent(new ZipEvent(ZipEvent.LOADED));
					parse();
					break;
				case ProgressEvent.PROGRESS:
					_zip.dispatchEvent(new ZipEvent(ZipEvent.PROGRESS, { bytesLoaded: ProgressEvent(evt).bytesLoaded, bytesTotal: ProgressEvent(evt).bytesTotal } ));
					break;
				case IOErrorEvent.IO_ERROR:
					evt.target.removeEventListener(ProgressEvent.PROGRESS, zipLoadHanlder);
					evt.target.removeEventListener(Event.COMPLETE, zipLoadHanlder);
					evt.target.removeEventListener(IOErrorEvent.IO_ERROR, zipLoadHanlder);
					_zip.dispatchEvent(new ZipEvent(ZipEvent.ERROR, IOErrorEvent(evt).text));
				break;
			}
		}
		
		/** 提取的核心模块把 **/
		private function parse():void
		{
			try
			{
				//find the central directory
				//找到中央目录
				var endCentralDir:int = locateBlockWithSignature(ZipConstants.ENDSIG, _data.length, ZipConstants.ENDHDR, 0xffff);
				if (endCentralDir < 0) throw new Error("Cannot find central directory");
				
				//read end of central directory record
				var thisDiskNumber:int = _data.readUnsignedShort();
				var startCentralDirDisk:int = _data.readUnsignedShort();
				var entriesForThisDisk:int = _data.readUnsignedShort();
				var entriesForWholeCentralDir:int = _data.readUnsignedShort();
				var centralDirSize:int = _data.readUnsignedInt();
				var offsetOfCentralDir:int = _data.readUnsignedInt();
				var commentSize:int = _data.readUnsignedShort();
				
				//read comment 读取注释
				if (commentSize > 0)
				{
					var commentBa:ByteArray = new ByteArray();
					_data.readBytes(commentBa, 0, commentSize);
					_zip.comment = commentBa.readMultiByte(commentBa.length, _zip.encoding);				
				}
				
				//find the offset of the first entry
				_offsetOfFirstEntry = 0;
				if (offsetOfCentralDir < endCentralDir - (4 + centralDirSize))
				{
					_offsetOfFirstEntry = endCentralDir - (4 + centralDirSize + offsetOfCentralDir);
					if (_offsetOfFirstEntry <= 0) throw new Error("Invalid embedded zip archive!");
				}
				
				//start to parse all entries 开始解析所有条目
				_entries = entriesForThisDisk;
				_data.position = _offsetOfFirstEntry + offsetOfCentralDir;				
				for (var i:int = 0; i < entriesForThisDisk; i++)
				{
					parseFile();
				}
				_zip.dispatchEvent(new ZipEvent(ZipEvent.INIT));
			}
			catch (e:Error)
			{
				_zip.dispatchEvent(new ZipEvent(ZipEvent.ERROR, e.message));
			}
			//release memory 释放内存
			_data = null;
		}
		
		private function parseFile():void
		{
			if (_data.readUnsignedInt() != ZipConstants.CENSIG) 
			throw new Error("Invalid central directory signature!");
			
			//read infos
			var version:int = _data.readUnsignedShort();
			var versionToExtract:int = _data.readUnsignedShort();
			var flag:int = _data.readUnsignedShort();
			var method:int = _data.readUnsignedShort();
			var dostime:int = _data.readUnsignedInt();
			var crc32:int = _data.readUnsignedInt();
			var csize:int = _data.readUnsignedInt();
			var size:int = _data.readUnsignedInt();
			var nameLen:int = _data.readUnsignedShort();
			var extraLen:int = _data.readUnsignedShort();
			var commentLen:int = _data.readUnsignedShort();			
			var diskStartNo:int = _data.readUnsignedShort();
			var internalAttributes:int = _data.readUnsignedShort();
			var externalAttributes:int = _data.readUnsignedInt();
			var offset:int = _data.readUnsignedInt();			
			
			//read name 读取名字
			var encoding:String = ((flag & 0x0800) != 0) ? "utf-8" : _zip.encoding;
			var name:String = _data.readMultiByte(nameLen, encoding);
			
			//create file 创建文件
			var file:ZipFile = new ZipFile(name);
			file._crc32 = crc32 & 0xffffffff;
			file._size = size & 0xffffffff;
			file._compressedSize = csize & 0xffffffff;
			file._compressionMethod = method;
			file._flag = flag;
			file._dostime = dostime;
			file._encoding = encoding;
			file._encrypted = (flag & 1) == 1;
			
			//crypto check value
			//if ((flag & 8) == 0) file._cryptoCheckValue = crc32 >> 24;
			//else file._cryptoCheckValue = (dostime >> 8) & 0xff;
			
			//extra field
			if (extraLen > 0){
				var extraBa:ByteArray = new ByteArray();
				_data.readBytes(extraBa, 0, extraLen);
				file._extra = extraBa;
			}
			
			//comment 注释
			if (commentLen > 0){
				file._comment = _data.readMultiByte(commentLen, file._encoding);
			}
			
			//content
			parseContent(file, offset);
			
			//store file 存储文件
			_zip.addFile(file);
		}
		
		//好像是分割内容把
		private function parseContent(file:ZipFile, offset:int):void
		{
			var oldPos:int = _data.position;
			_data.position = offset + ZipConstants.LOCHDR + file.name.length;
			if (file._extra != null)
			{
				_data.position += file._extra.length;
			}
			var compressed_data:ByteArray = new ByteArray();
			_data.readBytes(compressed_data, 0, file._compressedSize);
			_data.position = oldPos;
			
			if (file.encrypted)
			{
				file._data = compressed_data;
				return;
			}
			switch(file._compressionMethod)
			{
				case ZipConstants.STORED:
					file._data = compressed_data;
					break;
				case ZipConstants.DEFLATED:
					var ba:ByteArray = new ByteArray();
					var inflater:ZipInflater = new ZipInflater();
					inflater.setInput(compressed_data);
					try
					{
						inflater.inflate(ba);
					}
					catch (e:Error)
					{
						if(this._zip)
						{
							g.log.pushLog(this, g.logType._ErrorLog, this._zip.name + "出错");
						}
						else
						{
							g.log.pushLog(this, g.logType._ErrorLog, "出错");
						}
					}
					file._data = ba;
					break;
				default:
					throw new Error("Invalid compression method!");
			}			
		}
		
		/**
		 * Returns the offset of the first byte after the signature; -1 if not found
		 * 返回抵消后的第一个字节的签名；- 1如果没有找到
		 */
		private function locateBlockWithSignature(signature:int, endLocation:int, minimumBlockSize:int, maximumVariableData:int):int
		{
			var pos:int = endLocation - minimumBlockSize;
			var len:int = Math.max(pos - maximumVariableData, 0);
			if (pos < 0 || pos < len) return -1;
			for (pos; pos >= len; pos--)
			{
				if (_data[pos] != 0x50)
				{
					continue;
				}
				_data.position = pos;
				if (_data.readUnsignedInt() == signature)
				{
					return pos;
				}
			}			
			return -1;
		}
	}
}
