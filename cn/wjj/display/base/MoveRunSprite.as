package cn.wjj.display.base
{
	import flash.display.Sprite;
	
	/**
	 * 当位置变化的时候自动触发函数
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-05-24
	 */
	public class MoveRunSprite extends Sprite
	{
		
		private var xRun:Function;
		private var yRun:Function;
		
		public function MoveRunSprite()
		{
			
		}
		
		public function setXRun(method:Function = null):void
		{
			xRun = method;
		}
		
		public function setYRun(method:Function = null):void
		{
			yRun = method;
		}
		
		override public function get x():Number 
		{
			return super.x;
		}
		
		override public function set x(value:Number):void 
		{
			super.x = value;
			if (xRun != null) xRun();
		}
		
		override public function get y():Number 
		{
			return super.y;
		}
		
		override public function set y(value:Number):void 
		{
			super.y = value;
			if (yRun != null) yRun();
		}
	}
}