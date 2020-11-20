package cn.wjj.display.base
{
	import flash.display.Sprite;
	
	/**
	 * Sprite
	 * 当设置这个宽度和高度的时候,是设置子元件的宽度和高度,防止九宫格失效
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2012-11-20
	 */
	public class ChildSprite extends Sprite
	{
		public function ChildSprite()
		{
			super();
		}
		
		override public function get width():Number 
		{
			return super.width;
		}
		
		override public function set width(value:Number):void 
		{
			var l:int = this.numChildren;
			for (var i:int = 0; i < l; i++) 
			{
				this.getChildAt(i).width = value;
			}
			//super.width = value;
		}
		
		override public function get height():Number 
		{
			return super.height;
		}
		
		override public function set height(value:Number):void 
		{
			var l:int = this.numChildren;
			for (var i:int = 0; i < l; i++) 
			{
				this.getChildAt(i).height = value;
			}
			//super.height = value;
		}
		
	}
}