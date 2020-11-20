package cn.wjj.data.file
{
	import cn.wjj.data.CustomByteArray;
	import cn.wjj.data.file.AMFFile;
	import cn.wjj.data.file.AMFFileList;
	import cn.wjj.data.XMLToObject;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * AIR中的快速应用,File.applicationStorageDirectory
	 * @author GaGa
	 */
	public class AIRStorageUse
	{
		
		/**
		 * 从 File.applicationStorageDirectory 目录下读取一个文件的二进制内容
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 */
		public static function readFile(path:String):ByteArray
		{
			var file:File = File.applicationStorageDirectory.resolvePath(path);
			if(file.exists)
			{
				if(file.isDirectory)
				{
					g.log.pushLog(AIRStorageUse, LogType._UserAction, File.applicationStorageDirectory.nativePath + path + "属于文件夹!");
				}
				else
				{
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.READ);
					stream.position = 0;
					var byte:ByteArray = new ByteArray();
					stream.readBytes(byte);
					byte.position = 0;
					return byte;
					//var xmlStr:String = stream.readUTFBytes(stream.bytesAvailable);
					//info.note = String(new XML(xmlStr).classSet.@note);
				}
			}
			else
			{
				g.log.pushLog(AIRStorageUse, LogType._UserAction, File.applicationStorageDirectory.nativePath + path + "文件不存在!");
			}
			return null;
		}
		
		/**
		 * 
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 * 
		 */
		public static function readString(path:String):String
		{
			var byte:ByteArray = readFile(path);
			if(byte)
			{
				return byte.readUTFBytes(byte.length);
			}
			return null;
		}
		
		/**
		 * 读取AMF对象文件
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 */
		public static function readObject(path:String):Object
		{
			var byte:ByteArray = readFile(path);
			if(byte)
			{
				return byte.readObject();
			}
			return null;
		}
		
		/**
		 * 
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 * 
		 */
		public static function readXML(path:String):XML
		{
			var xmlString:String = readString(path);
			if(xmlString)
			{
				return new XML(xmlString);
			}
			return null;
		}
		
		/**
		 * 
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 * 
		 */
		public static function readXMLObj(path:String):Object
		{
			var xml:XML = readXML(path);
			if(xml)
			{
				return XMLToObject.to(xml);
			}
			return null;
		}
		
		/**
		 * 
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 * 
		 */
		public static function readAMFFile(path:String):AMFFile
		{
			var byte:ByteArray = readFile(path);
			if(byte)
			{
				var cbyte:CustomByteArray = new CustomByteArray();
				byte.readBytes(cbyte);
				cbyte.position = 0;
				var amf:AMFFile = new AMFFile();
				amf.setByte(cbyte);
				return amf;
			}
			return null;
		}
		
		/**
		 * 
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 * 
		 */
		public static function readAMFFileList(path:String):AMFFileList
		{
			var byte:ByteArray = readFile(path);
			if(byte)
			{
				var cbyte:CustomByteArray = new CustomByteArray();
				byte.readBytes(cbyte);
				cbyte.position = 0;
				var amf:AMFFileList = new AMFFileList();
				amf.setByte(cbyte);
				return amf;
			}
			return null;
		}
		
		
		/**
		 * 从 File.applicationStorageDirectory 目录下写入一个文件的二进制内容
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @param byte	内容
		 */
		public static function writeFile(path:String, byte:ByteArray):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath(path);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.position = 0;
			stream.writeBytes(byte);
		}
		
		/**
		 * 从 File.applicationStorageDirectory 目录下写入UTF8文本内容
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @param str		内容
		 */
		public static function writeString(path:String, str:String):void
		{
			var byte:ByteArray = new ByteArray();
			byte.writeUTFBytes(str);
			writeFile(path, byte);
		}
		
		/**
		 * 从 File.applicationStorageDirectory 目录下写入UTF8文本内容
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @param o			Object内容
		 */
		public static function writeObject(path:String, o:Object):void
		{
			var byte:ByteArray = new ByteArray();
			byte.writeObject(o);
			writeFile(path, byte);
		}
	}
}