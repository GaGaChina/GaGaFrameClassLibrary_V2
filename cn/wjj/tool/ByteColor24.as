package cn.wjj.tool 
{
	import flash.utils.ByteArray;
	/**
	 * 将24位的颜色,转换为32位颜色输出
	 * @author GaGa
	 */
	public class ByteColor24 
	{
		
		public function ByteColor24():void {}
		
		/**
		 * 从byte里抽取24位的颜色,并输出
		 * @param	byte
		 * @return
		 */
		public static function getByte(byte:ByteArray):uint
		{
			var c:ByteArray = new ByteArray();
			c.writeByte(0);
			byte.readBytes(c, 1, 3);
			c.position = 0;
			return c.readUnsignedInt();
		}
		
		/**
		 * 将颜色的值写入二进制
		 * @param	byte
		 * @param	color
		 */
		public static function setByte(byte:ByteArray, color:Number):void
		{
			var c:ByteArray = new ByteArray();
			c.writeUnsignedInt(uint(color));
			c.position = 1;
			c.readBytes(byte, byte.position, 3);
		}
	}
}