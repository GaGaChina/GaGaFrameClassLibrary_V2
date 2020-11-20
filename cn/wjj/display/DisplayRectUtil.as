package cn.wjj.display
{
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import cn.wjj.g;
	
	public class DisplayRectUtil
	{
		/**
		 * 获得一个,拖动DragMc对象,在MaskMc的遮罩上区域的拖动区域.支持DisplayObject与Rectangle二种参数
		 * @param	maskMc	展示的区域,遮罩层
		 * @param	DragMc	被拖动的区域,内容区域.
		 * @return
		 */
		public static function getDrag(mask:*, drag:*):Rectangle
		{
			//trace("------------------------------");
			var maskRect:Rectangle;
			var dragRect:Rectangle;
			if(mask is DisplayObject){
				maskRect = (mask as DisplayObject).getRect((mask as DisplayObject));
			}else if(mask is Rectangle){
				maskRect = mask as Rectangle;
			}
			if(drag is DisplayObject){
				dragRect = (drag as DisplayObject).getRect((drag as DisplayObject));
			}else if(drag is Rectangle){
				dragRect = drag as Rectangle;
			}
			//trace("maskRect",maskRect);
			//trace("dragRect",dragRect);
			/*
			//下面也是可以运行的,在2012/03/16进行调整
			var rx:Number, ry:Number, rwidth:Number, rheight:Number;
			if(mask is DisplayObject && drag is DisplayObject){
			rx = mask.x - maskRect.x * mask.scaleX - (drag.width - mask.width) - dragRect.x * drag.scaleX;
			ry = mask.y - maskRect.y * mask.scaleY - (drag.height - mask.height) - dragRect.y * drag.scaleY;
			}else if(mask is DisplayObject){
			rx = mask.x - maskRect.x * mask.scaleX - (drag.width - mask.width) - dragRect.x;
			ry = mask.y - maskRect.y * mask.scaleY - (drag.height - mask.height) - dragRect.y;
			}else if(drag is DisplayObject){
			rx = mask.x - maskRect.x - (drag.width - mask.width) - dragRect.x * drag.scaleX;
			ry = mask.y - maskRect.y - (drag.height - mask.height) - dragRect.y * drag.scaleY;
			}else{
			trace("Rectangle + Rectangle");
			rx = mask.x - maskRect.x - (drag.width - mask.width) - dragRect.x;
			ry = mask.y - maskRect.y - (drag.height - mask.height) - dragRect.y;
			}
			rwidth = drag.width - mask.width;
			rheight = drag.height - mask.height;
			var rec:Rectangle = new Rectangle(rx, ry, rwidth, rheight);
			*/
			//找到左上点为中心的Rect
			var leftTop:Rectangle = dragRect.clone();
			leftTop.x = leftTop.x + (maskRect.right - leftTop.right);
			leftTop.y = leftTop.y + (maskRect.bottom - leftTop.bottom);
			//找到右下为角点的Rect
			var rightEnd:Rectangle = dragRect.clone();
			rightEnd.x = maskRect.x;
			rightEnd.y = maskRect.y;
			//合并后得到最后的点,减去内容的宽高
			var rec:Rectangle = leftTop.union(rightEnd);
			rec.width = rec.width - dragRect.width;
			rec.height = rec.height - dragRect.height;
			rec.x = rec.x - dragRect.x;
			rec.y = rec.y - dragRect.y;
			//trace(rec);
			//trace("------------------------------");
			return rec;
		}
		
		/**
		 * 将 Mc 放置在 OtherMc 里,并且将Mc的最大比例调整为size
		 * 并且将X,Y的坐标放入这个OtherMc内
		 * @param	Mc
		 * @param	OtherMc
		 * @param	size
		 * @param	maxScale	缩放最大比例,为防止放大超过比例1而设置,0是不采用这个参数
		 */
		public static function setInOther(Mc:DisplayObject, OtherMc:DisplayObject, size:Number = 0.9, maxScale:Number = 0):void
		{
			OtherMc.visible = false;
			var McScale:Number, McScaleX:Number, McScaleY:Number;
			McScaleX = OtherMc.width * size / Mc.width;
			McScaleY = OtherMc.height * size / Mc.height;
			if (McScaleX > McScaleY) {
				McScale = McScaleY;
			}else {
				McScale = McScaleX;
			}
			if (maxScale != 0) {
				if (McScale > maxScale) {
					McScale = maxScale;
				}
			}
			Mc.width = Mc.width * McScale;
			Mc.height = Mc.height * McScale;
			var McRec:Rectangle = Mc.getBounds(Mc);
			var OtherMcRec:Rectangle = OtherMc.getBounds(OtherMc);
			//trace(McRec.toString());
			//trace(OtherMcRec.toString());
			//         起始坐标          修正这个坐标                 中间位置在减少的大小             修正大的坐标
			Mc.x = (OtherMc.x - OtherMcRec.x * OtherMc.scaleX) + ((OtherMc.width - Mc.width) / 2) - (McRec.x * Mc.scaleX);
			Mc.y = (OtherMc.y - OtherMcRec.y * OtherMc.scaleY) + ((OtherMc.height - Mc.height) / 2) - (McRec.y * Mc.scaleY);
		}
		
		/**
		 * 获取一个对象空白区域的起始点坐标,以及宽度和高度
		 * @param	display			要被绘制的目标对象
		 * @param	transparent		是否透明
		 * @param	fillColor		填充色
		 * @return
		 */
		public static function getDisplayBlankRect(display:DisplayObject, transparent:Boolean = true, fillColor:uint = 0x00000000):Rectangle
		{
			var rect:Rectangle = display.getBounds(display);
			var x:int = Math.round(rect.x);
			var y:int = Math.round(rect.y);
			//防止 "无效的 BitmapData"异常
			if (rect.isEmpty())
			{
				rect.width = 1;
				rect.height = 1;
			}
			var bitData:BitmapData = new BitmapData(Math.ceil(rect.width), Math.ceil(rect.height), transparent, fillColor);
			bitData.draw(display, new Matrix(1, 0, 0, 1, -x, -y), null, null, null, true);
			//剔除边缘空白像素
			var realRect:Rectangle = bitData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			var outRect:Rectangle = new Rectangle((x + realRect.x), (y + realRect.y), realRect.width, realRect.height);
			return outRect;
		}
	}
}