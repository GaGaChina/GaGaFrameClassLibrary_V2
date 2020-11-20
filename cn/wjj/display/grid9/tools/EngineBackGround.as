package cn.wjj.display.grid9.tools
{
	import cn.wjj.display.grid9.Grid9Info;
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
		public static function backGround(display:DisplayObject, o:Grid9Info):void
		{
			var d:Sprite = display as Sprite;
			if (d)
			{
				var graphics:Graphics = d.graphics;
				graphics.clear();
				/** 画背景 **/
				graphics.lineStyle(0, 0, 0);
				graphics.beginFill(0xCCCCCC, 1);
				var startX:int, startY:int, width:uint, height:uint;
				if (o.width)
				{
					startX = -o.width * 2;
					width = o.width * 4;
				}
				else
				{
					startX = -200;
					width = 400;
				}
				if (o.height)
				{
					startY = -o.height * 2;
					height = o.height * 4;
				}
				else
				{
					startY = -200;
					height = 400;
				}
				graphics.drawRect(startX, startY, width, height);
				
				var contourW:int = width;
				var contourH:int = height;
				if (contourW && contourH)
				{
					graphics.lineStyle(1, 0x000000, 1);
					graphics.beginFill(0, 0);
					graphics.drawRect(startX, startY, contourW, contourH);
				}
				/** 画网格 **/
				var w:Number, h:Number, x:int, y:int;
				var gridWidth:uint = 50;
				var gridHeight:uint = 50;
				graphics.lineStyle(1, 0x999999, 1);
				graphics.beginFill(0, 0);
				
				//画竖线
				x = startX - (startX % gridWidth);
				w = startX + width;
				while (x <= w) 
				{
					graphics.moveTo(x, startY);
					graphics.lineTo(x, startY + height);
					x += gridWidth;
				}
				//画横线
				y = startY - (startY % gridHeight);
				h = startY + height;
				while (y <= h)
				{
					graphics.moveTo(startX, y);
					graphics.lineTo(startX + width, y);
					y += gridHeight;
				}
					
				/**
				 * 添加标尺
				 * 画个白圈圈里面一个灰圈,2条线, 加2条线
				 * 在辅助线上画100像素每个的节点 , 5像素高
				 */
				gridWidth = 100;
				x = startY - (startY % gridWidth);
				if (startY < x) x -= gridWidth;
				w = startY + width + (startY - x);
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
				y = startY - (startY % gridHeight);
				if (startY < y) y -= gridHeight;
				h = startY + height + (startY - y);
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