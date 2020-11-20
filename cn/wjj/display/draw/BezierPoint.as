package cn.wjj.display.draw 
{
	import cn.wjj.display.MPoint;
	import flash.display.Graphics;
	
	/**
	 * 应用数学家皮埃尔·贝塞尔公式,制作能按照0-1之间的数字标识的贝塞尔曲线
	 * 
	 * 线性公式 P0 - P1
	 * B(t) = P0 + (P1 - P0) * t = (1 - t) * P0 + tP1
	 * 
	 * 二次方公式
	 * B(t) = (1 - t) * (1 - t) * P0 + 2 * t * (1 - t) * P1 + t * t * P2
	 * 
	 * 三次方公式
	 * B(t) = P0 * (1 - t) * (1 - t) * (1 - t) + 3 * P1 * t * (1 - t) * (1 - t) + 3 * P2 * t * t * (1 - t) + P3 * t * t * t
	 * 
	 * 一般公式
	 * B(t) = 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * @author GaGa
	 */
	public class BezierPoint 
	{
		
		public function BezierPoint() { }
		
		/**
		 * 二次方公式 画线
		 * @param	brush		画笔对象
		 * @param	p0			起始点
		 * @param	p1			经过点1
		 * @param	p2			结束点
		 * @param	density		线密度
		 */
		public static function DrawBezier2(brush:Graphics, p0:MPoint, p1:MPoint, p2:MPoint, density:int = 50):void
		{
			brush.moveTo(p0.x, p0.y);
			var p:MPoint = MPoint.instance();
			var t:Number = 0;
			var step:Number = 1 / density;
			for (var i:int = 0; i < density; i++)
			{
				t += step;
				Bezier2(p0, p1, p2, t, p);
				brush.lineTo(p.x, p.y);
			}
		}
		
		/**
		 * 三次方公式 画线
		 * @param	brush		画笔对象
		 * @param	p0			起始点
		 * @param	p1			经过点1
		 * @param	p2			经过点2
		 * @param	p3			结束点
		 * @param	density		线密度
		 */
		public static function DrawBezier3(brush:Graphics, p0:MPoint, p1:MPoint, p2:MPoint, p3:MPoint, density:int = 50):void
		{
			brush.moveTo(p0.x, p0.y);
			var p:MPoint = MPoint.instance();
			var t:Number = 0;
			var step:Number = 1 / density;
			for (var i:int = 0; i < density; i++)
			{
				t += step;
				Bezier3(p0, p1, p2, p3, t, p);
				brush.lineTo(p.x, p.y);
			}
		}
		
		/**
		 * 二次方公式
		 * @param	p0		起始点
		 * @param	p1		经过点1
		 * @param	p2		结束点
		 * @param	t		0-1之间的区间值
		 * @param	o		输出点
		 */
		public static function Bezier2(p0:MPoint, p1:MPoint, p2:MPoint, t:Number, o:MPoint):void
		{
			var t1:Number = 1 - t;
			var t12:Number = t1 * t1;
			var t2:Number = t * t;
			var tt1:Number = t * t1;
			o.x = t12 * p0.x + 2 * tt1 * p1.x + t2 * p2.x;
			o.y = t12 * p0.y + 2 * tt1 * p1.y + t2 * p2.y;
		}
		
		/**
		 * 三次方公式
		 * @param	p0		起始点
		 * @param	p1		经过点1
		 * @param	p2		经过点2
		 * @param	p3		结束点
		 * @param	t		0-1 之间的区间值
		 * @param	o		输出点
		 * @return
		 */
		public static function Bezier3(p0:MPoint, p1:MPoint, p2:MPoint, p3:MPoint, t:Number, o:MPoint):void
		{
			var t1:Number = 1 - t;
			var t12:Number = t1 * t1;
			var t13:Number = t12 * t1;
			var t2:Number = t * t;
			var t3:Number = t2 * t;
			var tt123:Number = 3 * t * t12;
			var t1t23:Number = 3 * t2 * t1;
			o.x = p0.x * t13 + p1.x * tt123 + p2.x * t1t23 + p3.x * t3;
			o.y = p0.y * t13 + p1.y * tt123 + p2.y * t1t23 + p3.y * t3;
		}
	}
}