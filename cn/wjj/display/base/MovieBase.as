package cn.wjj.display.base
{
	import cn.wjj.event.DisplayMouseEvent;
	import cn.wjj.g;
	
	import flash.display.MovieClip;
	
	/**
	 * MovieClip
	 * 带FPS控制
	 * 播放区间控制,次数控制,播放完毕回调
	 * 使用程序来控制播放到哪里完成跳转
	 * cn.wjj.display.base.MovieBase
	 * 
	 * @version 1.6.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2011-11-04
	 */
	public class MovieBase extends MovieClip
	{
		
		/** 是否在播放中 **/
		private var __isPlaying:Boolean = false;
		/** 现在播放那一幀 **/
		private var _currentFrame:int = 1;
		/** 现在正在播放那个Label区间 **/
		public var playLabel:String = "";
		/** 播放的时候循环几次 **/
		private var playLoop:int = 0;
		/** 播放的帧频 **/
		private var _FPS:int = 0;
		/** 全部帧的数据 **/
		private var labelData:Vector.<Object>;
		/** 播放完毕后执行某特定函数 **/
		private var method:Function;
		/** 播放完毕后播放那个区间 **/
		private var overPlayLabel:String;
		
		
		public function MovieBase(fps:int = -1):void
		{
			getAllFrameInfo();
			if(fps > 0){
				this.FPS = fps;
			}
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		/**
		 * 获取全部的MovieClip里的内容
		 */
		private function getAllFrameInfo():void
		{
			super.stop();
			var i:int = 0;
			var c:int = this.totalFrames;
			labelData = new Vector.<Object>(c, true);
			while (i < c)
			{
				this.gotoFrame((i+1));
				labelData[i] = new Object();
				//获取一个数据对象
				/** MovieClip 的 currentLabel **/
				labelData[i].label = this.currentLabel;
				/** MovieClip 的 currentFrameLabel **/
				labelData[i].frameLabel = this.currentFrameLabel;
				i++;
			}
			this.gotoFrame(1);
		}
		
		/** 是否在播放中 **/
		public function get _isPlaying():Boolean
		{
			return this.__isPlaying;
		}
		
		/** 设置是否在播放 **/
		public function set _isPlaying(isPlay:Boolean):void
		{
			__isPlaying = isPlay;
			if (isPlay)
			{
				if (_FPS == 0)
				{
					g.event.addEnterFrame(nextFrameInLabel);
				}
				else
				{
					g.event.addFPSEnterFrame(_FPS, nextFrameInLabel);
				}
			}else{
				g.event.removeEnterFrame(nextFrameInLabel);
				g.event.removeFPSMethod(nextFrameInLabel);
				super.stop();
			}
		}
		
		//----------------------------------------------------公共方法-----------------------------------------------------
		/** 从指定帧开始播放 SWF 文件 **/
		override public function gotoAndPlay(frame:Object , scene:String = null):void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			super.gotoAndStop(frame , scene);
			_currentFrame = this.currentFrame;
			_isPlaying = true;
		}
		
		
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param frame			播放的标签或第几帧
		 * @param loop			循环的次数.
		 * @param method		播放完毕后触发函数
		 * @param overPlayLabel	播放完毕后播放那个区间
		 */
		public function gotoPlay(frame:*, loop:int = 0, method:Function = null, overPlayLabel:String = ""):void
		{
			super.gotoAndStop(frame);
			this.method = method;
			this.overPlayLabel = overPlayLabel;
			this.playLoop = loop;
			_currentFrame = this.currentFrame;
			_isPlaying = true;
		}
		
		/**
		 * 播放名称为labelName的几个幀的序列
		 * @param labelName		
		 * @param loop			循环次数,0无限循环,1循环一次停止
		 * @param method		播放完毕后触发函数
		 * @param overPlayLabel	播放完毕后播放那个区间
		 */
		public function gotoAndPlayLabel(labelName:String, loop:int = 0, method:Function = null, overPlayLabel:String = ""):void
		{
			var frameId:int = 0
			this.method = method;
			this.overPlayLabel = overPlayLabel;
			for(var id:* in labelData)
			{
				if(labelData[id].frameLabel == labelName)
				{
					frameId = id + 1;
					break;
				}
			}
			if (frameId != 0)
			{
				this.playLabel = labelName;
				this.playLoop = loop;
				gotoFrame(frameId);
				if (theLabelLength(labelName) > 1)
				{
					_isPlaying = true;
				}
				else
				{
					_isPlaying = false;
				}
			}else{
				g.log.pushLog(this, g.log.logType._Frame, "未在资源里找到名称为"+labelName+"的幀!");
			}
		}
		
		/**
		 * labelName 的名称区间总共有多少个
		 * @param labelName
		 */
		public function theLabelLength(labelName:String):int
		{
			var l:int = 0;
			for(var id:* in labelData)
			{
				if(labelData[id].label == labelName)
				{
					l++;
				}
			}
			return l;
		}
		
		/** 将播放头移到影片剪辑的指定帧并停在那里 **/
		override public function gotoAndStop(frame:Object , scene:String = null):void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			super.gotoAndStop(frame , scene);
			_currentFrame = this.currentFrame;
			_isPlaying = false;
		}
		
		/** 跳转到特定幀 **/
		private function gotoFrame(id:int):void
		{
			if(id > this.totalFrames)
			{
				throw new Error("代码出问题了");
			}
			var num:int = id;
			var max:int = 50;
			var i:int = 0;
			//当是数字帧的时候
			while (this.currentFrame != num)
			{
				super.gotoAndStop(num);
				i++;
				if (i > max)
				{
					//防止死循环
					g.log.pushLog(this,g.logType._Frame,"gotoFrame 函数发生死循环 currentFrame : " + this.name + " , " + id);
					break;
				}
			}
			_currentFrame = this.currentFrame;
		}
		
		/** 将播放头转到下一帧并停止 **/
		override public function nextFrame():void
		{
			if(_currentFrame++ >= labelData.length )
			{
				_currentFrame = 1;
			}
			gotoAndStop(_currentFrame);
		}
		
		/** 如果有Label就在这个Label中播放 **/
		private function nextFrameInLabel():void
		{
			if(labelData == null)
			{
				g.event.removeEnterFrame(nextFrameInLabel);
				g.event.removeFPSMethod(nextFrameInLabel);
				return;
			}
			if(playLabel)
			{
				var max:int = 10000;
				var id:int = 0;
				var tempFrame:int = _currentFrame;
				var tempLable:String = currentLabel;
				do{
					if(_currentFrame++ >= labelData.length )
					{
						_currentFrame = 1;
					}
					id++;
					if(id > max)
					{
						g.log.pushLog(this, g.log.logType._Frame, "nextFrameInLabel都跑10000遍了也没找到名称为:" + playLabel + "的Label!");
						break;
					}
				} while(labelData[(_currentFrame - 1)].label != playLabel);
				if(playLoop > 0 && tempLable == labelData[(_currentFrame - 1)].label)
				{
					if((_currentFrame - tempFrame) != 1)
					{
						playLoop--;
					}
					if(playLoop == 0)
					{
						_currentFrame = tempFrame;
						gotoFrame(_currentFrame);
						playLabel = "";
						stop();
						if(this.method != null)
						{
							method();
							this.method = null;
						}
						if(overPlayLabel != "")
						{
							gotoAndPlayLabel(overPlayLabel);
						}
						return;
					}
				}
			}
			else
			{
				//这里也加入playLoop的控制
				if(_currentFrame++ >= labelData.length )
				{
					_currentFrame = 1;
					if(playLoop > 0)
					{
						playLoop--;
						if(playLoop == 0)
						{
							gotoFrame(_currentFrame);
							playLabel = "";
							stop();
							if(this.method != null)
							{
								method();
								this.method = null;
							}
							if(overPlayLabel != "")
							{
								gotoAndPlayLabel(overPlayLabel);
							}
							return;
						}
					}

				}
			}
			gotoFrame(_currentFrame);
		}
		
		/** 将播放头转到前一帧并停止 **/
		override public function prevFrame():void
		{
			if (_currentFrame-- < 0)
			{
				_currentFrame = labelData.length;
			}
			gotoAndStop(_currentFrame);
		}
		
		/** 在影片剪辑的时间轴中移动播放头,暂停,不会重置播放次数和播放后的自动执行函数 **/
		override public function play():void{
			//playLabel = "";
			_isPlaying = true;
			//super.play();
		}
		
		/** 停止影片剪辑中的播放头,暂停,不会重置播放次数和播放后的自动执行函数 **/
		override public function stop():void{
			//playLabel = "";
			_isPlaying = false;
			//super.stop();
		}
		
		public function set FPS(fps:int):void
		{
			if(g.bridge.swfRoot && g.bridge.swfRoot.stage && g.bridge.swfRoot.stage.frameRate)
			{
				if(fps == g.bridge.swfRoot.stage.frameRate)
				{
					_FPS = 0;
				}
				else
				{
					if(_FPS != fps)
					{
						g.event.removeEnterFrame(nextFrameInLabel);
						g.event.removeFPSMethod(nextFrameInLabel);
						_FPS = fps;
						if (_isPlaying)
						{
							_isPlaying = true;
						}
					}
				}
			}
			else
			{
				_FPS = fps;
				if (_isPlaying)
				{
					_isPlaying = true;
				}
				//g.log.pushLog(this,g.log.logType._Frame,"设置FPS必须先设置frame.bridge.swfRoot对象!并且已经初始化场景,可以获取到stage.frameRate!");
			}
		}
		
		
		//----------------------------------------------------覆盖的方法-----------------------------------------------------
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if(DisplayMouseEvent.searchThisAddChild(this))
			{
				this.mouseEnabled = true;
				this.mouseChildren = true;
			}
			else
			{
				this.mouseEnabled = false;
				this.mouseChildren = false;
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			super.removeEventListener(type, listener, useCapture);
			if(DisplayMouseEvent.searchThisAddChild(this))
			{
				this.mouseEnabled = true;
				this.mouseChildren = true;
			}
			else
			{
				this.mouseEnabled = false;
				this.mouseChildren = false;
			}
		}
		
		//----------------------------------------------------一些其他的方法---------------------------------------------------
		/** 销毁对象，释放资源 **/
		public function dispose():void
		{
			_isPlaying = false;
			this.method = null;
			this.overPlayLabel = "";
			this.labelData = null;
			if (this.hasOwnProperty("parent") && this.parent)
			{
				this.parent.removeChild(this);
			}
		}
	}
}