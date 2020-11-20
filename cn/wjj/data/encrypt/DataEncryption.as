package cn.wjj.data.encrypt
{
	import flash.utils.ByteArray;
	import cn.wjj.data.CustomByteArray;
	
	/**
	 * 对数据的加密和解密
	 * 
	 */
	public class DataEncryption{
		
		public static const T_DES:String = "DES";	//DES加密
		public static const T_AES:String = "AES";	//AES加密
		
		public function DataEncryption(){}
		
		/**
		 * 对一个二进制数据加密
		 */
		public static function Encryption(type:String, info:CustomByteArray, key:CustomByteArray):CustomByteArray
		{
			var temp:CustomByteArray = new CustomByteArray();
			temp.writeBytes(info, 0, info.length);
			switch(type)
			{
				case DataEncryption.T_DES:
					//info 转换为二进制
					HashDES.encrypt(temp, key);
					break;
				case DataEncryption.T_AES:
					HashAES.encrypt(temp, key);
					break;
				default :
					trace("没有这种加密方式.");
			}
			return temp;
		}
		
		/**
		 * 对一个二进制数据解密
		 */
		public static function Decryption(type:String, info:ByteArray, key:ByteArray):CustomByteArray
		{
			var temp:CustomByteArray = new CustomByteArray();
			temp.writeBytes(info, 0, info.length);
			switch(type)
			{
				case DataEncryption.T_DES:
					HashDES.decrypt(temp, key);
					break;
				case DataEncryption.T_AES:
					HashAES.decrypt(temp, key);
					break;
				default :
					trace("没有这种解密方式");
			}
			return temp;
		}
	}
}