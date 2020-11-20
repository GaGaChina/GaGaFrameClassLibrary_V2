﻿package cn.wjj.display.base
{
	
	import cn.wjj.event.DisplayMouseEvent;
	import cn.wjj.g;
	
	import flash.display.MovieClip;
	
	/**
	 * 可以控制播放区间,播放完毕停留区间等功能
	 * 使用EnterFrame来监控达到控制
	 * 
	 * @version 1.6.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2011-11-04
	 */
	public class MovieClipBase extends MovieClip
	{
		
		/** 是否在播放中 **/
		private var __isPlaying:Boolean = false;
		/** 现在正在播放那个Label区间 **/
		public var playLabel:String = "";
		/** 播放的时候循环几次 **/
		private var playLoop:int = 0;
		/** 全部帧的数据 **/
		private var labelData:Vector.<Object>;
		/** 播放完毕后执行某特定函数 **/
		private var method:Function;
		/** 播放完毕后播放那个区间 **/
		private var overPlayLabel:String;
		/** 上一帧播放的动画 **/
		private var _previousFrame:int;
		
		public function MovieClipBase():void
		{
			getAllFrameInfo();
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
				gotoAndStop((i+1));
				labelData[i] = new Object();
				//获取一个数据对象
				/** MovieClip 的 currentLabel **/
				labelData[i].label = this.currentLabel;
				/** MovieClip 的 currentFrameLabel **/
				labelData[i].frameLabel = this.currentFrameLabel;
				i++;
			}
			gotoAndStop(1);
		}
		
		/** 是否在播放中 **/
		public function get _isPlaying():Boolean
		{
			return this.__isPlaying;
		}
		
		//----------------------------------------------------公共方法-----------------------------------------------------
		/**
		 * 
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param frame			播放的标签或第几帧
		 * @param loop			循环的次数.
		 * @param method		播放完毕后触发函数
		 * @param overPlayLabel	播放完毕后播放那个区间
		 */
		public function gotoPlay(frame:*, loop:int = 0, method:Function = null, overPlayLabel:String = ""):void
		{
			this._previousFrame = 0;
			this.method = method;
			this.overPlayLabel = overPlayLabel;
			this.playLoop = loop;
			super.gotoAndStop(frame);
			__isPlaying = true;
			g.event.addEnterFrame(theEnterFrame);
			theEnterFrame();
		}
		
		/**
		 * 播放名称为labelName的几个幀的序列
		 * @param labelName		
		 * @param loop			循环次数,0无限循环,1循环一次停止
		 * @param method		播放完毕后触发函数
		 * @param overPlayLabel	播放完毕后播放那个区间
		 */
		public function gotoAndPlayLabel(labelName:String, loop:int = 0, method:Function = null, overPlayLabel:String = ""):void{
			var frameId:int = 0;
			for(var id:* in labelData)
			{
				if(labelData[id].frameLabel == labelName)
				{
					frameId = id + 1;
					break;
				}
			}
			if(frameId != 0)
			{
				gotoAndStop(frameId);
				this.playLabel = labelName;
				this.playLoop = loop;
				this._previousFrame = 0;
				this.method = method;
				this.overPlayLabel = overPlayLabel;
				if(theLabelLength(labelName) > 1)
				{
					this.play();
					__isPlaying = true;
					g.event.addEnterFrame(theEnterFrame);
					theEnterFrame();
				}
				else
				{
					__isPlaying = false;
					g.event.removeEnterFrame(theEnterFrame);
				}
			}
			else
			{
				g.log.pushLog(this,g.log.logType._Frame,"未在资源里找到名称为" + labelName + "的幀!");
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
		
		/** 从指定帧开始播放 SWF 文件 **/
		override public function gotoAndPlay(frame:Object , scene:String = null):void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			this._previousFrame = 0;
			super.gotoAndPlay(frame , scene);
			__isPlaying = true;
			g.event.addEnterFrame(theEnterFrame);
		}
		
		/** 将播放头移到影片剪辑的指定帧并停在那里 **/
		override public function gotoAndStop(frame:Object , scene:String = null):void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			this._previousFrame = 0;
			super.gotoAndStop(frame , scene);
			__isPlaying = false;
			g.event.removeEnterFrame(theEnterFrame);
		}
		
		/** 将播放头转到下一帧并停止 **/
		override public function nextFrame():void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			this._previousFrame = 0;
			__isPlaying = false;
			g.event.removeEnterFrame(theEnterFrame);
			super.nextFrame();
		}
		
		/** 将播放头转到前一帧并停止 **/
		override public function prevFrame():void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			this._previousFrame = 0;
			__isPlaying = false;
			g.event.removeEnterFrame(theEnterFrame);
			super.prevFrame();
			
		}
		
		/** 在影片剪辑的时间轴中移动播放头,暂停,不会重置播放次数和播放后的自动执行函数 **/
		override public function play():void
		{
			//playLabel = "";
			__isPlaying = true;
			g.event.addEnterFrame(theEnterFrame);
			super.play();
		}
		
		/** 停止影片剪辑中的播放头,暂停,不会重置播放次数和播放后的自动执行函数 **/
		override public function stop():void
		{
			//playLabel = "";
			__isPlaying = false;
			g.event.removeEnterFrame(theEnterFrame);
			super.stop();
		}
		
		/** 如果有Label就在这个Label中播放 **/
		private function theEnterFrame():void
		{
			if(playLabel)
			{
				if(labelData[(this.currentFrame - 1)].label != playLabel)
				{
					//找到第一针,然后在继续播放
					var id:int = 0;
					var max:int = 10000;
					var no1Frame:int = 0;
					do{
						if(no1Frame++ >= labelData.length )
						{
							no1Frame = 1;
						}
						id++;
						if(id > max)
						{
							g.log.pushLog(this, g.log.logType._Frame, "nextFrameInLabel都跑10000遍了也没找到名称为:" + playLabel + "的Label!");
							break;
						}
					} while(labelData[(no1Frame - 1)].label != playLabel);
					super.gotoAndPlay(no1Frame);
					if(playLoop > 0)
					{
						playLoop--;
						if(playLoop == 0)
						{
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
							else
							{
								gotoAndStop(no1Frame);
							}
							return;
						}
					}
				}
			}
			else
			{
				//这里也加入playLoop的控制
				if(_previousFrame >= labelData.length)
				{
					if(playLoop > 0)
					{
						playLoop--;
						if(playLoop == 0)
						{
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
							else
							{
								gotoAndStop(_previousFrame);
							}
							return;
						}
					}
				}
			}
			_previousFrame = this.currentFrame;
		}
		
		//----------------------------------------------------覆盖的方法-----------------------------------------------------
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (DisplayMouseEvent.searchThisAddChild(this))
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
			__isPlaying = false;
			g.event.removeEnterFrame(theEnterFrame);
			method = null;
			overPlayLabel = "";
			labelData = null;
			if(this.hasOwnProperty("parent") && this.parent)
			{
				this.parent.removeChild(this);
			}
		}
	}
}