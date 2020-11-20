package cn.wjj.display.u2.tools {
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * 处理背景
	 * @author GaGa
	 */
	public class EngineBackGround 
	{
		public function EngineBackGround() {}
		
		/**
		 * 通过数据,重置背景
		 * 
		 * @param	display			绘制显示对象的地方
		 * @param	o				数据
		 * @param	stageIsThis		是否强制绘制
		 */
		public static function backGround(display:DisplayObject, o:U2InfoBaseInfo):void
		{
			var d:Sprite = display as Sprite;
			if (d)
			{
				var graphics:Graphics = d.graphics;
				graphics.clear();
				/** 画一个大画布
				if (stageIsThis)
				{
					graphics.lineStyle(0, 0, 0);
					graphics.beginFill(0xFFFFFF, 1);
					var addLength:int;
					if (o.stageInfo.width > o.stageInfo.height)
					{
						addLength = int(o.stageInfo.width / 2);
					}
					else
					{
						addLength = int(o.stageInfo.height / 2);
					}
					
					graphics.drawRect(o.stageInfo.startX - addLength, o.stageInfo.startY - addLength, o.stageInfo.width + addLength, o.stageInfo.height + addLength);
				}
				 **/
				/** 画背景 **/
				graphics.lineStyle(0, 0, 0);
				var bgAlpha:Number = o.stageInfo.bgAlpha;
				if (bgAlpha == 0) bgAlpha = 1;
				graphics.beginFill(o.stageInfo.bgColor, bgAlpha);
				graphics.drawRect(o.stageInfo.startX, o.stageInfo.startY, o.stageInfo.width, o.stageInfo.height);
				
				var contourW:int = o.contour.endX - o.contour.startX;
				var contourH:int = o.contour.endY - o.contour.startY;
				if (contourW && contourH)
				{
					graphics.lineStyle(1, 0x000000, 1);
					graphics.beginFill(0, 0);
					graphics.drawRect(o.contour.startX, o.contour.startY, contourW, contourH);
				}
				/** 画网格 **/
				var w:Number, h:Number, x:int, y:int;
				var gridWidth:uint;
				var gridHeight:uint;
				if (o.grid.alpha > 0)
				{
					graphics.lineStyle(1, o.grid.color, (o.grid.alpha / 100));
					graphics.beginFill(0, 0);
					gridWidth = o.grid.width;
					gridHeight = o.grid.height;
					
					//画竖线
					w = o.stageInfo.startX + o.stageInfo.width;
					x = o.stageInfo.startX - (o.stageInfo.startX % gridWidth);
					while (x <= w) 
					{
						graphics.moveTo(x, o.stageInfo.startY);
						graphics.lineTo(x, o.stageInfo.startY + o.stageInfo.height);
						x += gridWidth;
					}
					//画横线
					y = o.stageInfo.startY - (o.stageInfo.startY % gridHeight);
					h = o.stageInfo.startY + o.stageInfo.height;
					while (y <= h)
					{
						graphics.moveTo(o.stageInfo.startX, y);
						graphics.lineTo(o.stageInfo.startX + o.stageInfo.width, y);
						y += gridHeight;
					}
				}
				
				/**
				 * 添加标尺
				 * 画个白圈圈里面一个灰圈,2条线, 加2条线
				 * 在辅助线上画100像素每个的节点 , 5像素高
				 */
				gridWidth = 100;
				x = o.stageInfo.startY - (o.stageInfo.startY % gridWidth);
				if (o.stageInfo.startY < x) x -= gridWidth;
				w = o.stageInfo.startY + o.stageInfo.width + (o.stageInfo.startY - x);
				if (w % gridWidth != 0) w = w - (w % gridWidth) + gridWidth;
				
				//画白色背景线
				graphics.lineStyle(3, 0xFFFFFF, 0.3);
				graphics.moveTo(x, 0);
				graphics.lineTo(w, 0);
				//画黑色辅助线
				graphics.lineStyle(1, 0x000000, 0.5);
				graphics.moveTo(x, 0);
				graphics.lineTo(w, 0);
				while (x <= w) 
				{
					//画竖线
					graphics.lineStyle(3, 0xFFFFFF, 0.3);
					graphics.moveTo(x, -5);
					graphics.lineTo(x, 5);
					graphics.lineStyle(1, 0x000000, 0.7);
					graphics.moveTo(x, -5);
					graphics.lineTo(x, 5);
					x += gridWidth;
				}
				gridHeight = 100;
				y = o.stageInfo.startY - (o.stageInfo.startY % gridHeight);
				if (o.stageInfo.startY < y) y -= gridHeight;
				h = o.stageInfo.startY + o.stageInfo.height + (o.stageInfo.startY - y);
				if (h % gridHeight != 0) h = h - (h % gridHeight) + gridHeight;
				//画白色背景线
				graphics.lineStyle(3, 0xFFFFFF, 0.3);
				graphics.moveTo(0, y);
				graphics.lineTo(0, h);
				//画黑色辅助线
				graphics.lineStyle(1, 0x000000, 0.5);
				graphics.moveTo(0, y);
				graphics.lineTo(0, h);
				while (y <= h)
				{
					graphics.lineStyle(3, 0xFFFFFF, 0.3);
					graphics.moveTo(-5, y);
					graphics.lineTo(5, y);
					graphics.lineStyle(1, 0x000000, 0.7);
					graphics.moveTo(-5, y);
					graphics.lineTo(5, y);
					y += gridHeight;
				}
				
				//画个白圆
				graphics.lineStyle(0, 0, 0);
				graphics.beginFill(0xFFFFFF, 1);
				graphics.drawCircle(0, 0, 4);
				graphics.beginFill(0x999999, 1);
				graphics.drawCircle(0, 0, 2);
			}
			graphics.endFill();
		}
	}
}