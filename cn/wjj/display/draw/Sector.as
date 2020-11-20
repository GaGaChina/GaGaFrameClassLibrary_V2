package cn.wjj.display.draw 
{
	import flash.display.Graphics;
	/**
	 * 画一个扇形
	 * 
	 * 
	 * DrawSector(moviec,200,200,100,S_angle,0,0xffcc00);
	 * DrawSector(moviec,200,200,100,S_angle,S_angle,0xffcccc);
	 * 
	 * @author GaGa
	 */
	public class Sector 
	{
		
		public function Sector() { }
		
		 /**
		  * 扇形的函数
		  * 提前设置 beginFill, lineStyle 的样式
		  * 
		  * @param	mc				扇形所在影片剪辑的名字
		  * @param	x				原点的坐标
		  * @param	y				原点的坐标
		  * @param	r				扇形的半径
		  * @param	angle			角度
		  * @param	startFrom		扇形的起始角度
		  * @param	color			0xffcc00是扇形的颜色
		  */
		public static function draw(graphics:Graphics, x:Number = 200, y:Number = 200, r:Number = 100, angle:Number = 27, startFrom:Number = 270):void
		{
			graphics.moveTo(x, y);
			angle = (Math.abs(angle) > 360)?360:angle;
			var n:Number = Math.ceil(Math.abs(angle) / 45);
			var angleA:Number = angle / n;
			angleA = angleA * Math.PI / 180;
			startFrom = startFrom * Math.PI / 180;
			graphics.lineTo(x + r * Math.cos(startFrom), y + r * Math.sin(startFrom));
			for (var i:int = 1; i <= n; i++)
			{
				startFrom += angleA;
				var angleMid:Number = startFrom - angleA / 2;
				var bx:Number = x + r / Math.cos(angleA / 2) * Math.cos(angleMid);
				var by:Number = y + r / Math.cos(angleA / 2) * Math.sin(angleMid);
				var cx:Number = x + r * Math.cos(startFrom);
				var cy:Number = y + r * Math.sin(startFrom);
				graphics.curveTo(bx, by, cx, cy);
			}
			if (angle != 360)
			{
				graphics.lineTo(x, y);
			}
			graphics.endFill();
		}
	}
}