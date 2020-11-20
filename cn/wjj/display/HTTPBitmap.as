package cn.wjj.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import cn.wjj.data.HTTPBitmapData;
	
	/**
	 * 设置一个Bitmap对象,把图片下载下来,设置到Bitmap对象里
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2013-01-07
	 */
	public class HTTPBitmap
	{
		/** 要设置的位图元素 **/
		private var bitmap:Bitmap;
		/** 大图是否下载成功 **/
		private var isBigFinish:Boolean = false;
		/** 小图是否下载成功 **/
		private var isSmallFinish:Boolean = false;
		/** 大图载入完毕回调 **/
		private var completeMethod:Function;
		/** 小图载入完毕回调 **/
		private var completeSmallMethod:Function;
		
		 /**
		  * 设置一个Bitmap对象,把图片下载下来,设置到Bitmap对象里
		  * @param	img					要给那个Bitmap设置图形内容
		  * @param	url					这个图形的url地址
		  * @param	width				最后的宽度
		  * @param	height				最后的高度
		  * @param	smallUrl			这个图形的缩略图地址
		  * @param	completeMethod		大图载入完毕的时候回调
		  * @param	completeSmallMethod	小图载入完毕的时候回调
		  */
		public function HTTPBitmap(bitmap:Bitmap, url:String, width:uint = 0,height:uint = 0, smallUrl:String = "", completeMethod:Function = null, completeSmallMethod:Function = null):void
		{
			reLoad(bitmap, url, width, height, smallUrl, completeMethod, completeSmallMethod);
		}
		
		public function reLoad(bitmap:Bitmap, url:String, width:uint = 0,height:uint = 0, smallUrl:String = "", completeMethod:Function = null, completeSmallMethod:Function = null):void
		{
			this.bitmap = bitmap;
			if (width != 0 || height != 0)
			{
				this.bitmap.bitmapData = new BitmapData(width, height);
			}
			if (smallUrl)
			{
				new HTTPBitmapData(smallUrl, smallComplete);
			}
			new HTTPBitmapData(url, bigComplete);
		}
		
		/** 大图下载成功的回调函数 **/
		private function bigComplete(e:HTTPBitmapData):void
		{
			return;
			var bitmapData:BitmapData = e.bitmapData;
			changeBitmapData(bitmapData);
			isBigFinish = true;
			if (completeMethod != null)
			{
				completeMethod();
				completeMethod = null;
			}
		}
		
		/** 缩略图下载成功回调 **/
		private function smallComplete(e:HTTPBitmapData):void
		{
			if (this.isBigFinish == false)
			{
				if (bitmap && bitmap.width && bitmap.height)
				{
					var temp:Bitmap = new Bitmap();
					temp.bitmapData = e.bitmapData;
					temp.width = bitmap.width;
					temp.height = bitmap.height;
					bitmap.bitmapData.draw(temp);
					//这个是否可以通过别的执行
					//temp.bitmapData.dispose();
				}
			}
			isSmallFinish = true;
			if (completeSmallMethod != null)
			{
				completeSmallMethod();
				completeSmallMethod = null;
			}
		}
		
		/**
		 * 将老的BitmapData数据清理,并将新的BitmapData数据添加上去
		 * @param	newData
		 */
		private function changeBitmapData(newData:BitmapData):void
		{
			var old:BitmapData = bitmap.bitmapData;
			bitmap.bitmapData = newData;
			if (old)
			{
				old.dispose();
			}
		}
	}
}