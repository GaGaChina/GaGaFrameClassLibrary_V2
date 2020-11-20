package cn.wjj.display.draw
{
	import flash.display.Shape;
	
	/**
	 * 绘制网格,显示在OBJ里
	 * 网格的颜色,是否显示,是否贴紧到网格,纵向,横向
	 * @author 嘎嘎
	 */
	public class  DrawingGrid
	{
		/**
		 * 在display上绘制表格
		 * @param	display			要绘制的图形
		 * @param	width			绘制的区域宽度
		 * @param	hight			绘制的区域高度
		 * @param	spacingWidth	绘制的横向间隔
		 * @param	spacingHight	绘制的纵向间隔
		 * @param	color			使用的颜色
		 * @param	alpha			使用的透明度
		 * @param	theX			起始的坐标X位置
		 * @param	theY			起始的坐标Y位置
		 */
		public static function DrawGrid(display:*, width:Number, hight:Number, spacingWidth:Number = 50, spacingHight:Number = 50, color:uint = 0x999999, alpha:Number = 0.3, startX:Number = 0, startY:Number = 0):void
		{
			display.graphics.lineStyle(0, color, alpha);
			//绘制横向的线条
			var i:int = 0;
			while ((spacingHight * i) <= hight) {
				display.graphics.moveTo(startX, (spacingHight * i + startY));
				display.graphics.lineTo(width, spacingHight * i);
				i++;
			}
			//绘制纵向的线条
			i = 0;
			while ((spacingWidth * i) <= width) {
				display.graphics.moveTo((spacingWidth * i + startX), startY);
				display.graphics.lineTo(spacingWidth * i, hight);
				i++;
			}
		}
	}
}