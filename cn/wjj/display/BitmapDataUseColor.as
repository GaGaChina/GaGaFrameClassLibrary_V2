package cn.wjj.display 
{
	import flash.display.BitmapData;
	/**
	 * 统计出一个 BitmapData 里用到的全部颜色
	 * @author GaGa
	 */
	public class BitmapDataUseColor 
	{
		
		public function BitmapDataUseColor() {}
		
		/** 统计出一个 BitmapData 里用到的全部颜色 **/
		public static function getAllColor(b:BitmapData):Vector.<uint>
		{
			var w:int = b.width;
			var h:int = b.height;
			var hl:int = h;
			var c:uint;
			var o:Vector.<uint> = new Vector.<uint>();
			while (w > -1)
			{
				h = hl;
				while (h > -1)
				{
					c = b.getPixel32(w, h);
					if (o.indexOf(c) == -1)
					{
						o.push(c);
					}
					h--;
				}
				w--;
			}
			return o;
		}
		
		/** 统计出一个 BitmapData 如果大于max的话返回true **/
		public static function getAllColorMax(b:BitmapData, max:int):Boolean
		{
			var w:int = b.width;
			var h:int = b.height;
			var hl:int = h;
			var c:uint;
			var o:Vector.<uint> = new Vector.<uint>();
			var l:int = 0;
			while (w > -1)
			{
				h = hl;
				while (h > -1)
				{
					c = b.getPixel32(w, h);
					if (o.indexOf(c) == -1)
					{
						o.push(c);
						l++;
						if (l >= max)
						{
							return true;
						}
					}
					h--;
				}
				w--;
			}
			return false;
		}
	}
}