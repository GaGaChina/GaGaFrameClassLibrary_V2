package cn.wjj.sound
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 */
	public class Spectrum extends Bitmap
	{
		private var channel:SoundChannel;
		private var spectrumGraph:BitmapData;
		/** 示波器的颜色 **/
		private var lineColor:uint;
		
		/**
		 * 示波器
		 * @param	channel		声道的声音
		 * @param	lineColor	32位的颜色,不能少
		 */
		public function Spectrum(channel:SoundChannel, lineColor:uint = 0xffffffff)
		{
			this.lineColor = lineColor;
			spectrumGraph = new BitmapData(256, 60, true, 0x00000000);
			this.bitmapData = spectrumGraph;
			this.channel = channel;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function onEnterFrame(event:Event):void
		{
			// Create the byte array and fill it with data
			var spectrum:ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(spectrum);
			
			// 清理bitmap
			spectrumGraph.fillRect(spectrumGraph.rect, 0x00000000);
			
			// Create the left channel visualization
			for (var i:int = 0; i < 256; i++)
			{
				spectrumGraph.setPixel32(i, 20 + spectrum.readFloat() * 20, lineColor);
			}
			
			// Create the right channel visualization
			for (var j:int = 0; j < 256; j++)
			{
				spectrumGraph.setPixel32(j, 40 + spectrum.readFloat() * 20, lineColor);
			}
		}
	}
}