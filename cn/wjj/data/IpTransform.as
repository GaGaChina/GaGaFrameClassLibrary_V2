package cn.wjj.data 
{
	import cn.wjj.data.CustomByteArray;
	import flash.utils.Endian;
	
	/**
	 * IP地址的字符串和Uint互相转换
	 * @author ...
	 */
	public class IpTransform 
	{
		/**
		 * 把一个IP地址转换为uint值
		 * @param	ip
		 * @return
		 */
		public static function ipToUint(ip:String, endian:String = "bigEndian"):uint
		{
			var ipArr:Array = ip.split(".");
			var byte:CustomByteArray = new CustomByteArray();
			byte.endian = endian;
			while (ipArr.length)
			{
				byte._w_Uint8(uint(Number(ipArr.shift())));
			}
			byte.position = 0;
			return byte._r_Uint32();
		}
		
		/**
		 * 把一个uint的IP地址转换为String
		 * @param	ipUint
		 * @return
		 */
		public static function uintToIp(ipUint:uint, endian:String = "bigEndian"):String
		{
			var byte:CustomByteArray = new CustomByteArray();
			byte.endian = endian;
			byte._w_Uint32(ipUint);
			byte.position = 0;
			var s:String = "";
			while (byte.bytesAvailable)
			{
				if (s != "")
				{
					s += ".";
				}
				s += String(byte._r_Uint8());
			}
			return s;
		}
	}

}