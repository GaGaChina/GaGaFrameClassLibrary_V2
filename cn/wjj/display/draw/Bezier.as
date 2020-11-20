package cn.wjj.display.draw
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	* 二阶贝赛尔曲线
	* @author Kevin
	*/
	public class Bezier
	{
		/** 是否保存绘制路径上的点 **/
		private var needStore:Boolean = false;
		/** 关键点 **/
		private var keyPoints:Array;
		/** 绘制路径的点列表 **/
		private var _pathPoints:Array;
		/** 画笔对象 **/
		private var brush:Graphics;
		/** 画点密度 **/
		private var pointDensity:int = 0;
		/**  **/
		private var targetPoint:Point;
		
		/**
		 * 构造函数
		 */
		public function Bezier():void
		{
			targetPoint = new Point();
		}
		
		/**
		 * 初始化对象
		 * @param	brush				画笔对象
		 * @param	needStore			是否需要保存画点
		 * @param	pointDensity		画点密度：值越大越平滑，同时越消耗资源
		 */
		public function initData(brush:Graphics, needStore:Boolean = true, pointDensity:int = 50):void
		{
			this.brush = brush;
			this.needStore = needStore;
			this.pointDensity = pointDensity;
		}
		
		/**
		 * 开始绘图：画出来的线条经过这三个点
		 * @param	startPoint		开始点
		 * @param	controlPoint	控制点
		 * @param	endPoint		结束点
		 */
		public function draw(startPoint:Point, controlPoint:Point, endPoint:Point):void
		{
			this._pathPoints = new Array();
			this.keyPoints = new Array(startPoint, controlPoint, endPoint);
			adjustPoint();
			brush.moveTo(startPoint.x, startPoint.y);
			var range:Number = 0;
			var step:Number = 1 / pointDensity;
			for (var i:int = 0; i < pointDensity; i++)
			{
				range += step;
				findPoint(keyPoints, range, targetPoint);
				brush.lineTo(targetPoint.x, targetPoint.y);
				//保存点
				if (needStore)
				{
					_pathPoints.push(new Point(targetPoint.x,targetPoint.y));
				}
			}
		}
		
		/**
		 * 画点数据：Point对象列表
		 */
		public function get pathPoints():Array
		{
			return _pathPoints;
		}
		
		/**
		 * 修正点
		 */
		private function adjustPoint():void
		{
			var point:Point = new Point();
			point.x = 2 * keyPoints[1].x - (keyPoints[0].x + keyPoints[2].x) / 2;
			point.y = 2 * keyPoints[1].y - (keyPoints[0].y + keyPoints[2].y) / 2;
			keyPoints[1] = point;
		}
		
		/**
		* 递归求解贝赛尔曲线上的点
		* @param  keyPoints
		* @param  t
		* @param  targetPoint
		*/
		private function findPoint(keyPoints:Array, t:Number, targetPoint:Point):void
		{
			var list:Array = new Array();
			var point:Point;
			for (var i:int = 0; i < keyPoints.length - 1; i++ )
			{
				point = new Point();
				point.x = (1 - t) * keyPoints[i].x + t * keyPoints[i + 1].x;
				point.y = (1 - t) * keyPoints[i].y + t * keyPoints[i + 1].y;
				list.push(point);
			}
			//
			if (list.length > 1)
			{
				findPoint(list, t, targetPoint);
				return;
			}
			//
			targetPoint.x = list[0].x;
			targetPoint.y = list[0].y;
		}
	}
}