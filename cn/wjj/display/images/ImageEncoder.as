package cn.wjj.display.images
{
	
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.utils.ByteArray;
	
	public class ImageEncoder
	{
		/**
		 * 把一个BitmapData转出 JPEG ByteArray
		 * @param	bmd			bitmapData位图
		 * @param	quality		品质
		 * @return
		 */
		public static function getJPGByte(bmd:BitmapData, quality:uint = 80):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			//新特性：AS原生的图片格式编码
			bmd.encode(bmd.rect, new JPEGEncoderOptions(quality), bytes);
			return bytes;
		}
		
		/**
		 * 把一个BitmapData转出 PNG ByteArray
		 * @param	bmd					载入的BitmapData
		 * @param	fastCompression		是否使用加速模式
		 * @return
		 */
		public static function getPNGByte(bmd:BitmapData, fastCompression:Boolean = false):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bmd.encode(bmd.rect, new PNGEncoderOptions(fastCompression), bytes);
			return bytes;
		}
	}
}