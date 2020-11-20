package cn.wjj.display.effect
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import cn.wjj.g;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * 对文本框的值改变特效,提供改变值的增长,和缩放,执行完毕的回调.
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2012-12-05
	 */
	public class TextFieldNumberChange 
	{
		
		/** 所有晃动的对象 **/
		private static var lib:Dictionary = new Dictionary(true);
		/** 所有的对象 **/
		private static var fpsLib:Vector.<TextFieldNumberChange> = new Vector.<TextFieldNumberChange>();
		
		/**
		 * 添加一个自动变化的文本框,让它在一个时间段内按FPS数据变化为另一个值,并且可以缩放和添加文本文字
		 * 由小放到scale,然后在缩放回原先的大小
		 * 
		 * @param	text			文本框
		 * @param	fps				变化速率
		 * @param	runTime			运行的周期
		 * @param	startNumber		开始数字
		 * @param	endNumber		结束数字
		 * @param	scale			缩放比例,非1的时候,完成后将重置比例和x,y坐标
		 * @param	topAddStr		前面加的文字
		 * @param	endAddStr		后面加的文字
		 */
		public static function run(text:TextField, fps:Number, runTime:Number, startNumber:Number, endNumber:Number, scale:Number = 1, topAddStr:String = "", endAddStr:String = "", method:Function = null):void
		{
			var info:Object = addTextField(text);
			info.startTime = g.time.getTime();
			info.endTime = g.time.getTime() + runTime;
			info.fps = fps;
			info.runTime = runTime;
			//每跳一下加的数值
			info.addVar = Math.ceil((endNumber - startNumber) / (fps * (runTime / 1000)));
			info.addScale = (scale - info.ss) / (fps * (runTime / 1000));
			info.topAddStr = topAddStr;
			info.endAddStr = endAddStr;
			info.scale = scale;
			info.method = method;
			//设置初始数字
			info.nowVar = startNumber;
			text.text = topAddStr + String(startNumber) + endAddStr;
			//设置初始位置
			text.scaleX = info.ss;
			text.scaleY = info.ss;
			//记录数字
			info.startNumber = startNumber;
			info.endNumber = endNumber;
			var item:TextFieldNumberChange;
			for each (item in fpsLib) 
			{
				if (item.fps == fps)
				{
					item.play();
					return;
				}
			}
			//g.mlog(g.jsonGetStr(info));
			item = new TextFieldNumberChange(fps);
			fpsLib.push(item);
			item.play();
		}
		
		/**
		 * 根据一个TextField获取里面的Object属性,如果已经有了就返回这个对象,如果没有就返回原始的
		 * @param	text
		 * @return
		 */
		private static function addTextField(text:TextField):Object
		{
			var info:Object
			if (lib[text])
			{
				info = lib[text];
			}
			else
			{
				info = new Object();
				lib[text] = info;
				info.ss = text.scaleX;
				info.sx = text.x;
				info.sy = text.y;
				info.sw = text.width;
				info.sh = text.height;
			}
			return info;
		}
		
		/** 这个对象的FPS **/
		public var fps:Number;
		
		/**
		 * 添加一个fps的震动对象集
		 * @param	fps
		 */
		public function TextFieldNumberChange(fps:Number):void
		{
			this.fps = fps;
		}
		
		public function play():void
		{
			g.event.addFPSEnterFrame(fps, run);
		}
		
		/** 停止这个FPS **/
		public function stop():void
		{
			g.event.removeFPSEnterFrame(fps, run);
		}
		
		private function run():void {
			TextFieldNumberChange.frequency(fps);
		}
		
		/**
		 * 按频率触发的事件
		 * @param	fps		FPS频率
		 */
		private static function frequency(fps:Number):void
		{
			var text:TextField;
			var info:Object;
			var l:int = 0;
			var item:*;
			var method:Function;
			for (item in lib) 
			{
				text = item as TextField;
				info = lib[text];
				if (info.fps == fps)
				{
					if (g.time.getTime() >= info.endTime)
					{
						//时间到了
						if (info.addScale != 0)
						{
							text.scaleX = info.ss;
							text.scaleY = info.ss;
							text.x = info.sx;
							text.y = info.sy;
						}
						text.text = info.topAddStr + String(info.endNumber) + info.endAddStr;
						//trace(text.text);
						if (info.method != null)
						{
							method = info.method;
							method();
						}
						delete lib[text];
					}
					else
					{
						l++;
						runDo(text);
					}
				}
			}
			if (l == 0)
			{
				for (var key:* in fpsLib) 
				{
					if (fpsLib[key].fps == fps)
					{
						fpsLib[key].stop();
						fpsLib.splice(key, 1);
					}
				}
			}
		}
		
		/**
		 * 让数字自动添加
		 * @param	display
		 */
		private static function runDo(text:TextField):void
		{
			var info:Object = lib[text];
			info.nowVar = info.nowVar + info.addVar;
			//endNumber 大,结果不能比endNumber大
			if (info.addVar > 0 && info.endNumber <= info.nowVar)
			{
				info.nowVar = info.endNumber;
			}
			//endNumber 小,结果必能比endNumber小
			else if (info.addVar < 0 && info.endNumber >= info.nowVar)
			{
				info.nowVar = info.endNumber;
			}
			else if (info.addVar == 0)
			{
				info.nowVar = info.endNumber;
			}
			text.text = info.topAddStr + String(info.nowVar) + info.endAddStr;
			//trace(text.text);
			//运算缩放比例
			var allTime:Number = info.endTime - info.startTime;
			var useTime:Number = g.time.getTime() - info.startTime;
			if (info.addScale)
			{
				if (allTime / 2 > useTime)
				{
					//放大 缩放值,使用时间 一半时间
					text.scaleX = text.scaleX + info.addScale;
					text.scaleY = text.scaleY + info.addScale;
					if (text.scaleX > info.scale)
					{
						text.scaleX = info.scale;
						text.scaleY = info.scale;
					}
				}
				else
				{
					//缩小
					//放大 缩放值,使用时间 一半时间
					text.scaleX = text.scaleX - info.addScale;
					text.scaleY = text.scaleY - info.addScale;
					if (text.scaleX < 1)
					{
						text.scaleX = 1;
						text.scaleY = 1;
					}
				}
				if(text.defaultTextFormat.align == TextFieldAutoSize.CENTER)
				{
					text.x = info.sx - info.sw * (text.scaleX - 1) / 2;
				}
				else if(text.defaultTextFormat.align == TextFieldAutoSize.RIGHT)
				{
					text.x = info.sx - info.sw * (text.scaleX - 1);
				}
				else
				{
					//TextFieldAutoSize.LEFT
					//TextFieldAutoSize.NONE
				}
				text.y = info.sy - info.sh * (text.scaleY - 1) / 2;
			}
		}
	}
}