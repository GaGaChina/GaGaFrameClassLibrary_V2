package cn.wjj.display.particle
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import cn.wjj.g;
	import flash.utils.Dictionary;
	
	/**
	 * 礼花特效
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-08-08
	 */
	public class Firework1 extends Sprite
	{
		
		/** 多少时间间隔释放一个礼花 **/
		public var interval:int = 2000;
		private var tempx:Number;
		/** 等于1的时候立刻爆炸一个烟花 **/
		public var isDestroy:Number;
		private var holder:Sprite;
		private var _t:int;
		private var _pt:int;
		private var _p:Dictionary;
		private var bmp:Bitmap;
		/** 礼花的范围,宽度 **/
		private var _filterWidth:Number;
		/** 礼花的范围,高度 **/
		private var _filterHeight:Number;
		/** 是否自动更新UI画面, **/
		private var _autoUpdateUI:Boolean;
		
		/** 烟花在爆炸的时候的最小分支数量 **/
		private var bombMin:uint = 40;
		/** 烟花在爆炸的时候的最大分支数量 **/
		private var bombMax:uint = 40;
		
		/**
		 * 创建一个礼花特效
		 * 中途修改礼花释放频率,直接修改interval的值就可以了
		 * 
		 * @param	interval		多少毫秒时间间隔释放一个礼花
		 * @param	theWidth		礼花的范围,宽度
		 * @param	theHeight		礼花的范围,高度
		 * @param	autoUpdateUI	正对这个FPS是否自动刷新
		 */
		public function Firework1(interval:int, filterWidth:Number, filterHeight:Number, autoUpdateUI:Boolean = true):void
		{
			_filterWidth = filterWidth;
			_filterHeight = filterHeight;
			_autoUpdateUI = autoUpdateUI;
			this.interval = interval;
			holder = new Sprite();
			this.addChild(holder);
			_pt = -interval;
			_p = new Dictionary();
			bmp = new Bitmap(new BitmapData(filterWidth, filterHeight, true, 0));
			this.addChild(bmp);
		}
		
		/** 以FPS为30的速度开始运行这个礼花 **/
		public function start():void
		{
			g.event.addFPSEnterFrame(30, enterFrame, _autoUpdateUI);
		}
		
		/** 停止运行礼花 **/
		public function stop():void
		{
			g.event.removeFPSEnterFrame(30, enterFrame);
		}
		
		/** 摧毁礼花对象 **/
		public function dispose():void
		{
			stop();
			//for each (var p:Object in _p)
			//{
				//delete _p[holder.removeChild(p.t)];
			//}
			//_p = null;
			if (this.contains(holder))
			{
				this.removeChild(holder);
			}
			if (this.contains(bmp))
			{
				this.removeChild(bmp);
			}
		}
		
		/**
		 * 弹出的烟花爆炸的时候有多少个分支
		 * @param	min		最小多少个
		 * @param	max		最高多少个
		 */
		public function setBombNum(min:uint, max:uint):void
		{
			if (min > max)
			{
				var tempMin:int = min;
				min = max;
				max = tempMin;
			}
			
		}
		
		/** 获取随机的一个烟花的数量 **/
		private function getBombNum():int
		{
			if (bombMin == bombMax)
			{
				return bombMin;
			}
			else
			{
				return int(Math.floor(Math.random() * (bombMax - bombMin) + bombMin));
			}
		}
		
		private function enterFrame():void
		{
			var f:ColorMatrixFilter = new ColorMatrixFilter([0.93, 0, 0, 0, 0, 0, 0.85, 0, 0, 0, 0, 0, 0.9, 0, 0, 0, 0, 0, 0.9, 0]);
			bmp.bitmapData.applyFilter(bmp.bitmapData, bmp.bitmapData.rect, new Point(), f);
			for each (var p:Object in _p)
			{
				if (p.type == "r" && ((_t - p.tS) > p.lS || isDestroy == 1))
				{
					emit("s2", { x:p.t.x, y:p.t.y }, p.color, getBombNum());
				}
				else if (p.type == "r")
				{
					emit("s", { x:p.t.x, y:p.t.y }, 1);
				}
				if ((_t - p.tS) > p.lS || (p.type == "r" && isDestroy-- == 1))
				{
					delete _p[holder.removeChild(p.t)];
				}
				if (p.type == "s")
				{
					if (p.type == "r")
					{
						p.v = { x:p.v.x * 0.99, y:(p.v.y + 0.35) * 0.99 };
					}
					else if (p.type == "s")
					{
						p.v = { x:p.v.x * 0.99, y:(p.v.y + -0.03) * 0.99 };
					}
					else
					{
						p.v = { x:p.v.x * 0.99, y:(p.v.y + 0.2) * 0.99 };
					}
					
				}
				else if(p.type == "s2")
				{
					if (p.type == "r")
					{
						p.v = { x:p.v.x * 0.91, y:(p.v.y + 0.35) * 0.91 };
					}
					else if (p.type == "s")
					{
						p.v = { x:p.v.x * 0.91, y:(p.v.y + -0.03) * 0.91 };
					}
					else
					{
						p.v = { x:p.v.x * 0.91, y:(p.v.y + 0.2) * 0.91 };
					}
				}
				else
				{
					if (p.type == "r")
					{
						p.v = { x:p.v.x * 1, y:(p.v.y + 0.35) * 1 };
					}
					else if (p.type == "s")
					{
						p.v = { x:p.v.x * 1, y:(p.v.y + -0.03) * 1 };
					}
					else
					{
						p.v = { x:p.v.x * 1, y:(p.v.y + 0.2) * 1 };
					}
					
				}
				if (p.type == "r")
				{
					p.t.transform.matrix = new Matrix((p.t.scaleX * 0.98) * Math.cos(Math.atan2(p.v.y, p.v.x)), (p.t.scaleY * 0.98) * Math.sin(Math.atan2(p.v.y, p.v.x)), -((p.t.scaleY * 0.98) * Math.sin(Math.atan2(p.v.y, p.v.x))), (p.t.scaleX * 0.98) * Math.cos(Math.atan2(p.v.y, p.v.x)), p.t.x + p.v.x, p.t.y + p.v.y);
				}
				else if (p.type == "s")
				{
					p.t.transform.matrix = new Matrix((p.t.scaleX * 1.02) * Math.cos(Math.atan2(p.v.y, p.v.x)), (p.t.scaleY * 1.02) * Math.sin(Math.atan2(p.v.y, p.v.x)), -((p.t.scaleY * 1.02) * Math.sin(Math.atan2(p.v.y, p.v.x))), (p.t.scaleX * 1.02) * Math.cos(Math.atan2(p.v.y, p.v.x)), p.t.x + p.v.x, p.t.y + p.v.y);
				}
				else
				{
					p.t.transform.matrix = new Matrix((p.t.scaleX * 0.9) * Math.cos(Math.atan2(p.v.y, p.v.x)), (p.t.scaleY * 0.9) * Math.sin(Math.atan2(p.v.y, p.v.x)), -((p.t.scaleY * 0.9) * Math.sin(Math.atan2(p.v.y, p.v.x))), (p.t.scaleX * 0.9) * Math.cos(Math.atan2(p.v.y, p.v.x)), p.t.x + p.v.x, p.t.y + p.v.y);
				}
				bmp.bitmapData.draw(p.t, new Matrix(p.t.scaleX * Math.cos(Math.atan2(p.v.y, p.v.x)), p.t.scaleY * Math.sin(Math.atan2(p.v.y, p.v.x)), -(p.t.scaleY * Math.sin(Math.atan2(p.v.y, p.v.x))), p.t.scaleX * Math.cos(Math.atan2(p.v.y, p.v.x)), p.t.x, p.t.y), new ColorTransform(1, 1, 1, 0.98));
			}
			_t = g.time.getTime() + 550;
			if ((_t - _pt) >= interval)
			{
				emit("r", { x:((Math.random() * _filterWidth /2 ) + _filterWidth / 4), y:_filterHeight }, 1);
			}
		}
		
		/**
		 * 创造一个烟花的对象.
		 * 
		 * @param	type	r是烟火的炮弹,s是屁股后面的烟
		 * @param	pt		炮弹弹出起始点,{x:X坐标,y:Y坐标}的坐标
		 * @param	color
		 * @param	num		礼花爆炸后的数量
		 */
		private function emit(type:String, pt:Object, color:Number = NaN, num:uint = 1):void
		{
			if (type == "r")
			{
				_pt = _t;
			}
			for (var i:int = 0; i < num; i++)
			{
				var p:Object = new Object();
				p.type = type;
				p.tS = _t;
				p.t = holder.addChild(new Sprite());
				p.color = Math.random() * 0xFFFFFF;
				if (type == "r")
				{
					p.lS = 2000;
				}
				else if(type == "s")
				{
					p.lS = 1660;
				}
				else
				{
					p.lS = 1300;
				}
				p.v = new Object();
				if (type == "r")
				{
					p.v.x = Math.random() * (5 - -5) + -5;
					p.v.y = -20;
				}
				else if (type == "s")
				{
					p.v.x = Math.random() * (0.25 - -0.25) + -0.25;
					p.v.y = 0;
				}
				else
				{
					p.v.x = (tempx = (Math.random() * (20 - 10) + 10)) * Math.cos((Math.random() * 360) * (180 / Math.PI));
					p.v.y = tempx * Math.sin((Math.random() * 360) * (180 / Math.PI));
				}
				if (type == "s")
				{
					p.t.graphics.beginGradientFill("radial", [0xFFFFFF, 0xFFFFFF], [0.1, 0.012], [0, 255], new Matrix(0.023, 0, 0, 0.023));
				}
				else if(type == "r")
				{
					p.t.graphics.beginGradientFill("radial", [0xFFFFFF, 0xFFFFFF, p.color, p.color], [1, 1, 0.25, 0.25], [0, 150, 151, 255], new Matrix(0.0213, 0, 0, 0.0024, 0, 0));
				}
				else
				{
					p.t.graphics.beginGradientFill("radial", [0xFFFFFF, 0xFFFFFF, color, color], [0.5, 0.5, 0.075, 0.075], [0, 150, 151, 255], new Matrix(0.0213, 0, 0, 0.0024, 0, 0));
				}
				if (type == "s")
				{
					p.t.graphics.drawCircle(0, 0, 20);
				}
				else
				{
					p.t.graphics.drawEllipse( -21, -5.5, 42, 11);
				}
				if (type == "r")
				{
					p.t.transform.matrix = new Matrix(1, 0, 0, 1, pt.x, pt.y);
				}
				else if (type == "s")
				{
					p.t.transform.matrix = new Matrix((Math.random() * (0.5 - 0.25) + 0.25), 0, 0, (Math.random() * (0.5 - 0.25) + 0.25), pt.x, pt.y);
				}
				else
				{
					p.t.transform.matrix = new Matrix((Math.random() * (2.3 - 1.5) + 1.5), 0, 0, (Math.random() * (2.3 - 1.5) + 1.5), pt.x, pt.y);
				}
				_p[p.t] = p;
			}
		}
	}

}