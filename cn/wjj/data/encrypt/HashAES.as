package cn.wjj.data.encrypt {
	
	import com.hurlant.crypto.symmetric.AESKey;
	import flash.utils.ByteArray;
	
	/**
	 * 
		var tempGGG:CustomByteArray = new CustomByteArray();
		tempGGG.endian = Endian.LITTLE_ENDIAN;
		tempGGG.writeUTFBytes("12345678901234567890大家好大家好大家好大家好大家好432436546");
		trace("原始 : " + tempGGG);
		trace("原始 : " + MD5.hashBytes(tempGGG) + " 长度 : " + tempGGG.length);
		DataEncryption.Encryption(DataEncryption.T_AES, tempGGG, key);
		trace("加密 : " + tempGGG);
		trace("加密 : " + MD5.hashBytes(tempGGG) + " 长度 : " + tempGGG.length);
		DataEncryption.Decryption(DataEncryption.T_AES, tempGGG, key);
		trace("解密 : " + tempGGG);
	 * 
	 * @author GaGa
	 */
	public class HashAES {
		
		public function HashAES() {}
		
		/**
		 * 加密
		 * AES加密数据块和密钥长度可以是128比特、192比特、256比特中的任意一个。
		 * @param	temp	要加密的内容
		 * @param	key		加密的key
		 */
		public static function encrypt(temp:ByteArray, key:ByteArray):void
		{
			var myAes:AESKey = new AESKey(key);
			var i:int;
			var len:int;
			/*
			len = (temp.length % 128)
			if(len != 0){
				len = 128 - len;
			}
			for (i = 0; i < len; i++ )
			{
				temp.writeUTFBytes("F");
			}
			
			len = (key.length % 128)
			if(len != 0){
				len = 128 - len;
			}
			for (i = 0; i < len; i++ )
			{
				key.writeUTFBytes("F");
			}
			*/
			len =  Math.ceil(temp.length / 16);
			for (i = 0; i < len; i++ )
			{
				myAes.encrypt(temp, i * 16);
			}
			
			
		}
		
		/**
		 * 解密
		 * @param	temp	要解密的内容
		 * @param	key		解密的key
		 */
		public static function decrypt(temp:ByteArray, key:ByteArray):void
		{
			var myAes:AESKey = new AESKey(key);
			var len:int =  Math.ceil(temp.length / 16);
			for (var i:int = 0; i < len; i++ )
			{
				myAes.decrypt(temp, i * 16);
			}
			//myAes.decrypt(temp);
		}
		
		
	}

}