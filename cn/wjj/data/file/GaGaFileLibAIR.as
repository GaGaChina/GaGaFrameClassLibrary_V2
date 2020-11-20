package cn.wjj.data.file 
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * 使用AIR操作AMFList文件,使用同步操作
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-05-31
	 */
	public class GaGaFileLibAIR 
	{
		/** [谨慎操作]文件内容 **/
		public var list:Vector.<AMFFile>;
		/** [谨慎操作]文件名称映射文件 **/
		public var listName:Object;
		
		/** 打开后保存指针 **/
		private var file:File;
		/** 打开后保存指针 **/
		private var stream:FileStream;
		
		public function GaGaFileLibAIR(path:String = ""):void
		{
			list = new Vector.<AMFFile>;
			listName = new Object();
			openFile(path);
		}
		
		/**
		 * 从 File.applicationStorageDirectory 目录下读取一个文件的二进制内容
		 * @param path	File.applicationStorageDirectory 的相对路径,不用"\"开头
		 * @return 
		 */
		public function openFile(path:String):Boolean
		{
			file = File.applicationStorageDirectory.resolvePath(path);
			stream = new FileStream();
			stream.open(file, FileMode.UPDATE);
			/*
			var byte:ByteArray = new ByteArray();
			stream.readBytes(byte);
			byte.position = 0;
			*/
		}
		
		/**
		 * 清空现有数据,并设置老数据
		 * @param	byte
		 */
		public function setByte(byte:SByte):void
		{
			var name:String;
			//清空数据
			if (list.length > 0)
			{
				list.length = 0;
				for (name in listName) 
				{
					delete listName[name]
				}
			}
			byte.position = 0;
			var headPos:uint = byte._r_Uint32() + 4;
			var itemInfo:Object;
			var itemByte:SByte;
			var file:AMFFile;
			/** 包头读取到的位置 **/
			var readPos:uint = byte.position;
			var s:uint;
			var l:uint;
			while (readPos < headPos)
			{
				byte.position = readPos;
				name = byte._r_String();
				s = byte._r_Uint32();
				l = byte._r_Uint32();
				readPos = byte.position;
				//开始位置
				byte.position = headPos + s;
				itemByte = SByte.instance();
				byte.readBytes(itemByte, 0, l);
				file = new AMFFile();
				file.name = name;
				file.setByte(itemByte);
				this.list.push(file);
				listName[name] = file;
			}
		}
		
		/**
		 * [扯淡方法]返回这个AMF列表里是否全部已经下载完毕了
		 * @return 
		 */
		public function get allComplete():Boolean
		{
			for each (var item:AMFFile in list) 
			{
				if(!item.data)
				{
					return false;
				}
			}
			return true;
		}
		
		/**
		 * 通过子对象的name来获取到AMFFile
		 * @param	itemName
		 * @return
		 */
		public function getItem(itemName:String):AMFFile
		{
			if (listName.hasOwnProperty(itemName))
			{
				return listName[itemName];
			}
			return null;
		}
		
		/**
		 * 将里面的全部的对象数据用name的方式,添加到obj里
		 * @param	obj
		 */
		public function setAlltoObj(obj:Object):void
		{
			for each (var item:AMFFile in list) 
			{
				obj[item.name] = item.data;
			}
		}
		
		/**
		 * 将这个对象以内容形式输出Object对象
		 * @return 
		 */
		public function getAllObj():Object
		{
			return listName;
		}
	}
}