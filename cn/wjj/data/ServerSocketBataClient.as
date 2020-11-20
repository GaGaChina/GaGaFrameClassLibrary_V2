package cn.wjj.data
{
	import cn.wjj.data.CustomByteArray;
	
	import flash.net.Socket;
	
	public class ServerSocketBataClient
	{
		/** IP地址 **/
		public var ip:String;
		/** 端口号地址 **/
		public var port:uint;
		/** 连接发生的时间 **/
		public var timeStart:Number;
		/** 最后一个数据包的时间 **/
		public var timeEnd:Number;
		/** 连接的Socket **/
		public var socket:Socket;
		/** 这个客户端里的数据 **/
		public var byte:CustomByteArray;
		/** 客户端需要发送的数据 **/
		public var byteFlush:CustomByteArray;
		/** 这个客户端总共接受多少数据量 **/
		public var dataReceive:uint = 0;
		/** 这个客户端总共发送多少数据量 **/
		public var dataSend:uint = 0;
		
		public function ServerSocketBataClient():void
		{
			byte = new CustomByteArray();
			byteFlush = new CustomByteArray();
		}
		
		/** 销毁对象 **/
		public function dispose():void
		{
			byte = null;
			byteFlush = null;
			socket = null;
		}
	}
}