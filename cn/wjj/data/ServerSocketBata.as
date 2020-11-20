package cn.wjj.data
{
	import adobe.utils.CustomActions;
	
	import cn.wjj.g;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	/**
	 * 方便调用的ServerSocket对象
	 * 
	 * 1.建立服务器,构造或connect带ip和端口进去就可以
	 * 2.设置编码 isBigEndian 是否是高八位,如果是false就是第八位
	 * 3.pushLog是否设置日志,userNumber为总连接数,user843Number为本服务器特例为843服务的次数
	 * 4.clientList里存储为现在客户端的所有连接
	 * 5.packageHeadSize,设置一个包最小的尺寸,往往是包头的大小
	 * 6.onClientDataMethod , 当有数据变化的时候执行的方法
	 * 7.onClientCloseMethod , 当客户端中断的时候执行的方法
	 * 8.closeClient / closeForIpPort 关闭客户端所使用的方法
	 * 
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @playerversion AIR 2
	 */
	public class ServerSocketBata 
	{
		
		/** 服务器IP地址 **/
		public var ip:String = "0.0.0.0";
		/** 服务器端口 **/
		public var port:int = 0;
		/** 服务器连接的时间 **/
		public var timeStart:Number;
		/** 服务器最后连接的时间 **/
		public var timeEnd:Number;
		/** 总共有多少用户连接过 **/
		public var userNumber:uint;
		/** 总共有多少个843的用户连接过 **/
		public var user843Number:uint;
		/** Socket服务器 **/
		public var server:ServerSocket;
		/** 所有客户端的连接,里面有发来的数据 **/
		public var clientList:Vector.<ServerSocketBataClient>;
		/** socket 对应的 ServerSocketBataClient 映射 **/
		public var socketToClient:Object;
		/** 包头尺寸 **/
		public var packageHeadSize:uint = 0;
		/** 客户端是否是Flash,是的话就检测沙箱843 **/
		public var clientIsFlash:Boolean = true;
		/** 当客户端有数据过来的时候自动运行的函数,传递参数 : ServerSocketBataClient **/
		public var onClientDataMethod:Function;
		/** 当客户端有数据过来的时候自动运行的函数,传递参数 : ServerSocketBataClient,如果还没有关闭Socket允许继续发出信息 **/
		public var onClientCloseMethod:Function;
		/** 当客户端有连接过来的时候自动运行,传递参数 : ServerSocketBataClient **/
		public var onClientConnectMethod:Function;
		/** 是否打开日志 **/
		public var pushLog:Boolean = true;
		/** 是否使用Endian.BIG_ENDIAN编码 **/
		public var isBigEndian:Boolean = true;
		/** 这个客户端总共有多少数据量 **/
		public var dataReceive:uint = 0;
		/** 这个客户端总共发送多少数据量 **/
		public var dataSend:uint = 0;
		/** 如果没有连接成功会按一个FPS不断的连接,如果为0就是不连接 **/
		private var autoLinkFPS:Number = 0;
		/** 自动运行清理的频率 **/
		private var autoClearFPS:Number = 0;
		/** 自动清理掉多久没有发包的客户端 **/
		private var autoClearTime:Number = 0;
		
		/**
		 * 创建一个 Socket 对象。 若未指定参数，将创建一个最初处于断开状态的套接字。 若指定了参数，则尝试连接到指定的主机和端口。
		 * @param	ip						主机IP地址
		 * @param	port					端口名
		 */
		public function ServerSocketBata(ip:String = null, port:int = 0):void
		{
			clientList = new Vector.<ServerSocketBataClient>();
			socketToClient = new Object();
			connect(ip, port);
		}
		
		/**
		 * 设置心跳包的一些内容
		 * @param	autoClearTime	自动清理超过多少毫秒的Socket连接, 120000,2分钟
		 * @param	autoClearFPS	多少时间清理一次,0.01,100秒一次
		 */
		public function setClearInfo(autoClearTime:Number, autoClearFPS:Number):void
		{
			if (this.autoClearTime > 0)
			{
				g.event.removeFPSEnterFrame(this.autoClearFPS, clearSocket);
			}
			this.autoClearFPS = autoClearFPS;
			this.autoClearTime = autoClearTime;
			if (autoClearTime > 0)
			{
				g.event.addFPSEnterFrame(autoClearFPS, clearSocket);
			}
		}
		
		private function clearSocket():void
		{
			if (clientList.length)
			{
				var t:Number = g.time.getTime();
				for each (var client:ServerSocketBataClient in clientList) 
				{
					if (client.timeEnd > 0 && (client.timeEnd + this.autoClearTime) < t)
					{
						closeClient(client);
					}
				}
			}
		}
		
		/**
		 * 创建服务器Socket连接
		 * @param ip				服务IP地址
		 * @param port				端口名
		 * @param reLinkFPS			如果没有绑定成功会按一个FPS不断的连接,如果为0就是不连接
		 */
		public function connect(ip:String = null, port:int = 0, autoLinkFPS:Number = 0):void
		{
			this.ip = ip;
			this.port = port;
			close();
			server = new ServerSocket();
			//server.addEventListener(Event.CLOSE, onClientClose);
			g.event.addListener(server, ServerSocketConnectEvent.CONNECT, onClientConnect);
			try
			{
				server.bind(port, ip);
				server.listen();
				timeStart = g.time.getTime();
				userNumber = 0;
				user843Number = 0;
				dataReceive = 0;
				dataSend = 0;
				if(pushLog)
				{
					g.log.pushLog(this, g.logType._SocketInfo, "ServerSocketBata 启动 : " + g.tool.time.getString(timeStart, "2000年01月01日 下午 11:59 星期一 毫秒:999"));
				}
				g.event.removeFPSEnterFrame(this.autoClearFPS, clearSocket);
			} 
			catch(e:Error) 
			{
				g.log.pushLog(this, g.logType._Warning, e.toString());
				this.autoLinkFPS = autoLinkFPS;
				if(autoLinkFPS != 0)
				{
					g.event.addFPSEnterFrame(autoLinkFPS, reLinkSocket);
				}
			}
		}
		
		/** 当没有连接上的时候,按一个FPS不断的连接这个服务器 **/
		private function reLinkSocket():void
		{
			connect(ip, port, autoLinkFPS);
			if(pushLog)
			{
				g.log.pushLog(this, g.logType._SocketInfo, "ServerSocketBata 重连 : " + g.tool.time.getString(timeStart, "2000年01月01日 下午 11:59 星期一 毫秒:999"));
			}
		}
		
		/** 关闭服务器 **/
		public function close():void
		{
			if(server != null)
			{
				closeAll();
				//server.removeEventListener(Event.CLOSE, onClientClose);
				g.event.removeListener(server, ServerSocketConnectEvent.CONNECT, onClientConnect);
				if(server.listening)
				{
					server.close();
				}
			}
		}
		
		/** 当有连接发生的时候,连接过来的客户端 **/
		private function onClientConnect(e:ServerSocketConnectEvent):void{
			var temp:Socket = e.socket;
			var s:String = temp.remoteAddress + ":" + String(temp.remotePort);
			if(socketToClient.hasOwnProperty(s))
			{
				if(pushLog)
				{
					g.log.pushLog(this, g.logType._SocketInfo, "ServerSocketBata : " + temp.remoteAddress + ":" + temp.remotePort + " 重复接入");
				}
			}
			else
			{
				var client:ServerSocketBataClient = new ServerSocketBataClient();
				client.timeStart = g.time.getTime();
				client.ip = temp.remoteAddress;
				client.port = temp.remotePort;
				client.socket = temp;
				if(!isBigEndian)
				{
					client.socket.endian = Endian.LITTLE_ENDIAN;
					client.byte.endian = Endian.LITTLE_ENDIAN;
					client.byteFlush.endian = Endian.LITTLE_ENDIAN;
				}
				g.event.addListener(client.socket, Event.CLOSE, onClientClose);
				g.event.addListener(client.socket, ProgressEvent.SOCKET_DATA, onClientData);
				userNumber++;
				clientList.push(client);
				socketToClient[s] = client;
				if(onClientConnectMethod != null)
				{
					onClientConnectMethod(client);
				}
				if(pushLog)
				{
					g.log.pushLog(this, g.logType._SocketInfo, "ServerSocketBata : " + temp.remoteAddress + ":" + temp.remotePort + " 接入");
				}
			}
		}
		
		/** 当客户端关闭连接的时候 **/
		private function onClientClose(e:Event):void
		{
			var temp:Socket = e.target as Socket;
			closeForIpPort(temp.remoteAddress, temp.remotePort);
		}
		
		/** 客户端有数据发送到服务器的时候 **/
		private function onClientData(e:ProgressEvent):void
		{
			var socket:Socket = e.target as Socket;
			var s:String = socket.remoteAddress + ":" + String(socket.remotePort);
			if (socketToClient.hasOwnProperty(s))
			{
				var client:ServerSocketBataClient = socketToClient[s];
				timeEnd = g.time.getTime();
				client.timeEnd = timeEnd;
				client.dataReceive += socket.bytesAvailable;
				dataReceive += socket.bytesAvailable;
				client.byte.position = client.byte.length;
				socket.readBytes((client.byte as ByteArray), client.byte.length, socket.bytesAvailable);
				client.byte.position = 0;
				if(clientIsFlash)
				{
					//这里值有23个字节的长度
					var copyByte:ByteArray = new ByteArray();
					copyByte.writeBytes(client.byte);
					copyByte.position = 0;
					try
					{
						var box843:String = copyByte.readUTFBytes(copyByte.length);
						if (box843 == "<policy-file-request/>")
						{
							var xml:XML = <cross-domain-policy>  
								<site-control permitted-cross-domain-policies="all"/>  
								<allow-access-from domain="*" to-ports="*"/>
								</cross-domain-policy>
							client.socket.writeUTFBytes(xml.toString());
							client.socket.flush();
							closeClient(client);
							client.socket.close();
							userNumber--;
							user843Number++;
							return;
						}
					} 
					catch(e:Error) 
					{
						if(pushLog)
						{
							g.log.pushLog(this,g.logType._SocketInfo, "收取<policy-file-request/>并不能解析");
						}
					}
				}
				if(client.byte.length >= packageHeadSize)
				{
					if(onClientDataMethod != null)
					{
						onClientDataMethod(client);
					}
				}
			}
		}
		
		/** 将一个服务器客户端的数据发送出去 **/
		public function flushInfo(client:ServerSocketBataClient):void
		{
			if(client && client.byteFlush.length > 0)
			{
				var flush:ByteArray = new ByteArray();
				client.byteFlush.position = 0;
				client.byteFlush.readBytes(flush, 0, client.byteFlush.length);
				client.dataSend += flush.length;
				dataSend += flush.length;
				client.socket.writeObject(flush);
				client.socket.flush();
				timeEnd = g.time.getTime();
				client.timeEnd = timeEnd;
			}
		}
		
		/** 通过IP和端口号关闭一个客户端 **/
		public function closeForIpPort(ip:String, port:int):void
		{
			var s:String = ip + ":" + String(port);
			if (socketToClient.hasOwnProperty(s))
			{
				closeClient(socketToClient[s]);
			}
		}
		
		/** 清理数据和内存 **/
		public function closeAll():void
		{
			for each (var client:ServerSocketBataClient in clientList) 
			{
				closeClient(client);
			}
			clientList.length = 0;
		}
		
		/** 关闭一个客户端 **/
		public function closeClient(client:ServerSocketBataClient):void
		{
			var s:String = client.ip + ":" + String(client.port);
			if (socketToClient.hasOwnProperty(s))
			{
				delete socketToClient[s];
			}
			var index:int = clientList.indexOf(client);
			if (index != -1)
			{
				var delInfo:ServerSocketBataClient = clientList[index];
				clientList.splice(index, 1);
				timeEnd = g.time.getTime();
				client.timeEnd = timeEnd;
				if(onClientCloseMethod != null)
				{
					onClientCloseMethod(delInfo);
				}
				if(delInfo.socket)
				{
					g.event.removeListener(delInfo.socket, Event.CLOSE, onClientClose);
					g.event.removeListener(delInfo.socket, ProgressEvent.SOCKET_DATA, onClientData);
					if(delInfo.socket.connected)
					{
						delInfo.socket.close();
					}
				}
				if(pushLog)
				{
					g.log.pushLog(this, g.logType._SocketInfo, "ServerSocketBata " + client.ip + ":" + client.port + " 中断Socket");
				}
			}
			client.dispose();
		}
	}
}