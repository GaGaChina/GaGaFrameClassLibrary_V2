package cn.wjj.data.encrypt {
	
	import com.hurlant.crypto.symmetric.DESKey;
	
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * http://www.cnblogs.com/alala666888/archive/2011/05/09/2040861.html
	 * @author GaGa
	 */
	public class HashDES {
		
		public function HashDES() {}
		
		/**
		 * 加密
		 * @param	temp	要加密的内容
		 * @param	key		加密的key
		 */
		public static function encrypt(temp:ByteArray, key:ByteArray):void
		{
			var myDes:DESKey = new DESKey(key);
			var i:int;
			var len:int;
			//var startLen:int = temp.length;
			/*
			len = (temp.length % 8)
			if(len != 0){
				len = 8 - len;
			}
			for (i = 0; i < len; i++ )
			{
				temp.writeUTFBytes("F");
			}
			*/
			len =  Math.ceil(temp.length / 8);
			for (i = 0; i < len; i++ )
			{
				myDes.encrypt(temp, i * 8);
			}
		}
		
		/**
		 * 解密
		 * @param	temp	要解密的内容
		 * @param	key		解密的key
		 */
		public static function decrypt(temp:ByteArray, key:ByteArray):void
		{
			var myDes:DESKey = new DESKey(key);
			var len:int =  Math.ceil(temp.length / 8);
			for (var i:int = 0; i < len; i++ )
			{
				myDes.decrypt(temp, i * 8);
			}
			//myDes.decrypt(temp, 0);
		}
	}

}