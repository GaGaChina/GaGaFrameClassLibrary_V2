package cn.wjj.display
{
	import flash.display.DisplayObjectContainer;
	import flash.text.TextFormat;
	import fl.core.UIComponent;
	import fl.controls.ComboBox;
	
	/**
	 * 为组件快捷设置一些东西用的
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2011-06-24
	 */
	public class ControlsSetSkin {
		
		/**
		 * 设置一个DisplayObjectContainer里的全部组件,让组件的字体为12px
		 * @param	display		显示列表
		 * @param	fontName	字体名称
		 * @param	fontSize	字体大小
		 */
		public static function fontForContainer(display:DisplayObjectContainer, fontName:String = "宋体", fontSize:int = 12):void
		{
			//设置选择框的字体大小
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = fontSize;
			myFormat.font = fontName;
			for (var i:int = 0; i < display.numChildren; i++)
			{
				if (display.getChildAt(i) is UIComponent)
				{
					(display.getChildAt(i) as UIComponent).setStyle("textFormat", myFormat);
					if (display.getChildAt(i) is ComboBox)
					{
						(display.getChildAt(i) as ComboBox).textField.setStyle("textFormat", myFormat);
						(display.getChildAt(i) as ComboBox).dropdown.setRendererStyle("textFormat", myFormat);
						(display.getChildAt(i) as ComboBox).dropdown.rowHeight = Math.round(fontSize * 1.5);
					}
				}
			}
		}
	}
}