package
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	
	public class SearchQQWryIp
	{
		
		private var file:File;
		private var fileStream:FileStream;
		/** 首四个字节是第一条索引的绝对偏移 **/
		private var ipIndexBeginOffSet:uint;
		/** 后四个字节是最后一条索引的绝对偏移 **/
		private var ipIndexEndOffSet:uint;
		/** 总共多少组索引 **/
		private var ipBlockCount:Number;
		
		/**  **/
		private var searchBeginIpInfo:IpInfo = new IpInfo();
		/**  **/
		private var searchEndIpInfo:IpInfo = new IpInfo();
		/**  **/
		private var searchMidIpInfo:IpInfo = new IpInfo();
		/** 第一个索引位 **/
		private var searchBeginPos:uint;
		/** 索引结束位 **/
		private var searchEndPos:uint;
		
		public function SearchQQWryIp():void
		{
			init();
		}
	
		private function init():void
		{
			
			file = File.applicationDirectory.resolvePath("qqwry.dat");
			fileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.endian = Endian.LITTLE_ENDIAN;
			//文件头只有8个字节
			var byteArr:ByteArray = new ByteArray();
			fileStream.readBytes(byteArr, 0, 8);
			
			ipIndexBeginOffSet = byteArr[0] + (byteArr[1] << 8) + (byteArr[2] << 16) + (byteArr[3] << 24);
			ipIndexEndOffSet = byteArr[4] + (byteArr[5] << 8) + (byteArr[6] << 16) + (byteArr[7] << 24);
			ipBlockCount = (ipIndexEndOffSet - ipIndexBeginOffSet) / 7 + 1;
			//设置二分查找法的头和尾
			this.searchBeginPos = 0;
			this.searchEndPos = ipBlockCount - 1;
			//加这句，不然乱码
			System.useCodePage = true;
			//这里修改你要查找的ip地址
			trace(searchIpInfo("218.240.16.20"));
		}
		
		//二分查找法搜索索引区
		public function searchIpUint(uintIp:uint):String
		{
			while (true)
			{
				//头
				searchBeginIpInfo = getIpInfo(this.searchBeginPos);
				//尾
				searchEndIpInfo = getIpInfo(this.searchEndPos);
				
				if (uintIp > searchBeginIpInfo.ipBegin && uintIp < searchBeginIpInfo.ipEnd)
				{
					return readAddressInfo(searchBeginIpInfo.ipOffset);
				}
				if (uintIp > searchEndIpInfo.ipBegin && uintIp < searchEndIpInfo.ipEnd)
				{
					return readAddressInfo(searchEndIpInfo.ipOffset);
				}
				searchMidIpInfo = getIpInfo((this.searchBeginPos + this.searchEndPos) / 2);
				if (uintIp > searchMidIpInfo.ipBegin && uintIp < searchMidIpInfo.ipEnd)
				{
					return readAddressInfo(searchMidIpInfo.ipOffset);
				}
				if (uintIp > searchMidIpInfo.ipEnd)
				{
					this.searchBeginPos=(this.searchBeginPos+this.searchEndPos)/2;
				}
				else
				{
					this.searchEndPos=(this.searchBeginPos+this.searchEndPos)/2;
				}
			}
			return "";
		}
		
		//二分查找法搜索索引区
		public function searchIpStr(ip:String):String
		{
			return searchIpUint(ipToNumber(ip));
		}
		
		//读取该
		private function readAddressInfo(pos:uint):String
		{
			var country:String = "";
			var area:String = "";
			var countryOffset:Number = 0;
			var tag:uint;
			
			fileStream.position = pos + 4;
			//读取模式
			tag = readTag();
			
			if (tag == 1)
			{
				//当模式为1的时候，指向改偏移地址
				fileStream.position = getIpOffset();
				tag = readTag();
				//国家模式为2
				if (tag == 2)
				{
					countryOffset = getIpOffset();
					area = this.readArea();
					fileStream.position = countryOffset;
					country = this.readString();
				}
				else
				{
					fileStream.position -= 1;
					country = this.readString();
					area = this.readArea();
				}
			}
			else if (tag == 2)
			{
				//当模式为2的时候，指向改偏移地址
				countryOffset = getIpOffset();
				//先读取地区**
				area = this.readArea();
				//再读取国家
				fileStream.position = countryOffset;
				country = this.readString();
			}
			else
			{
				fileStream.position -= 1;
				country = this.readString();
				area = this.readArea();
			}
			var address:String = country + " " + area;
			return address;
		}
		
		//读取记录模式
		private function readTag():uint
		{
			return fileStream.readByte();
		}
		
		//读取地区
		private function readArea():String
		{
			var tag:uint = readTag();
			if (tag==1 || tag==2)
			{
				fileStream.position = getIpOffset();
				return readString(); 
			}
			else
			{
				fileStream.position-=1;
				return readString();
			}
		}
		
		//读取fileStream的数据
		private function readString():String
		{
			var subOffset:uint = 0;
			var stringArr:ByteArray = new ByteArray();
			stringArr[subOffset] = fileStream.readByte();
			while (stringArr[subOffset] != 0)
			{
				subOffset++;
				stringArr[subOffset] = fileStream.readByte();
			}
			return stringArr.toString();
		}
		
		/** 根据参数pos(记录点)读取改记录的起始ip,偏移地址和结束ip **/
		private function getIpInfo(pos:uint):IpInfo
		{
			fileStream.position = this.ipIndexBeginOffSet + 7 * pos;
			var subIpInfo:IpInfo = new IpInfo();
			subIpInfo.ipBegin = getIpNum();
			subIpInfo.ipOffset = getIpOffset();
			fileStream.position = subIpInfo.ipOffset;
			subIpInfo.ipEnd = getIpNum();
			return subIpInfo;
		}
		
		//读取第一层索引ip地址
		private function getIpNum():Number
		{
			var byteArr:ByteArray = new ByteArray();
			fileStream.readBytes(byteArr, 0, 4);
			return byteArr[0] + byteArr[1] * 256 + byteArr[2] * 256 * 256 + byteArr[3] * 256 * 256 * 256;
		}
		
		//读取偏移地址
		private function getIpOffset():Number
		{
			var byteArr:ByteArray = new ByteArray();
			fileStream.readBytes(byteArr, 0, 3);
			return byteArr[0] + byteArr[1] * 256 + byteArr[2] * 256 * 256;
		}
		
		//ip转换为数值
		private function ipToNumber(ip:String):uint
		{
			var ipArr:Array = ip.split(".");
			if (ipArr.length == 4)
			{
				var _n:uint = uint(ipArr[0] << 24) + uint(ipArr[1] << 16) + uint(ipArr[2] << 8) + uint(ipArr[3]);
				return _n;
			}
			return 0;
		}
	}
}