package cn.wjj.air 
{
    // Required packages for push notifications 
	import cn.wjj.g;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.RemoteNotificationEvent;
	import flash.events.StatusEvent;
	import flash.events.ThrottleEvent;
	import flash.events.ThrottleType;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestMethod;
	import flash.notifications.NotificationStyle;
	import flash.notifications.RemoteNotifier;
	import flash.notifications.RemoteNotifierSubscribeOptions;
	
	/**
	 * 苹果推送
	 * @author GaGa
	 */
	public class IOSPushNotifications 
	{
        private var preferredStyles:Vector.<String> = new Vector.<String>(); 
        private var subscribeOptions:RemoteNotifierSubscribeOptions = new RemoteNotifierSubscribeOptions(); 
        private var remoteNot:RemoteNotifier = new RemoteNotifier();
		
        private var urlreq:URLRequest; 
        private var urlLoad:URLLoader = new URLLoader(); 
        private var urlString:String; 
		
		public function IOSPushNotifications() 
		{
			
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]SupportedNotification Styles: " + RemoteNotifier.supportedNotificationStyles.toString());
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]Before Preferred notificationStyles: " + subscribeOptions.notificationStyles.toString());
            // Subscribe to all three styles of push notifications: 
            // ALERT, BADGE, and SOUND. 
            preferredStyles.push(NotificationStyle.ALERT , NotificationStyle.BADGE, NotificationStyle.SOUND);
			subscribeOptions.notificationStyles = preferredStyles;
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]After Preferred notificationStyles:" + subscribeOptions.notificationStyles.toString());
            remoteNot.addEventListener(RemoteNotificationEvent.TOKEN, tokenHandler);
            remoteNot.addEventListener(RemoteNotificationEvent.NOTIFICATION, notificationHandler);
            remoteNot.addEventListener(StatusEvent.STATUS, statusHandler);
			if (g.bridge.swfRoot)
			{
				//g.bridge.swfRoot.stage.addEventListener(Event.ACTIVATE, activateHandler);
				g.event.addListener(g.bridge.swfRoot, ThrottleEvent.THROTTLE, throttleDo);
			}
			g.event.addEventBridge(this, "AIR.推送.开启", startPush);
			g.event.addEventBridge(this, "AIR.推送.取消", unsubscribe);
			g.event.addEventBridge(this, "AIR.推送.订阅", subscribe);
			startPush();
		}
		
		/*
		// 苹果建议，每次应用程序激活，订阅推送通知。
		public function activateHandler(e:Event):void
		{
			// Before subscribing to push notifications, ensure the device supports it.
			// supportedNotificationStyles returns the types of notifications
			// that the OS platform supports
			if(RemoteNotifier.supportedNotificationStyles.toString() != "")
			{
				remoteNot.subscribe(subscribeOptions);
			} 
			else
			{
				g.log.pushLog(this, g.logType._UserAction, "[IOS推送]Remote Notifications not supported on this Platform !");
			}
		}
		*/
		// 苹果建议，每次应用程序激活，订阅推送通知。
		public function throttleDo(e:ThrottleEvent):void
		{
			switch (e.state)
			{
				case ThrottleType.RESUME:
					startPush();
					break;
				case ThrottleType.PAUSE:
				case ThrottleType.THROTTLE:
					break;
				default:
			}
		}
		
		public function startPush():void
		{
			if(RemoteNotifier.supportedNotificationStyles.toString() != "")
			{
				g.log.pushLog(this, g.logType._UserAction, "ThrottleEvent 触发 remoteNot.subscribe");
				subscribe();
			} 
			else
			{
				g.log.pushLog(this, g.logType._UserAction, "[IOS推送]此平台不支持远程通知!");
			}
		}
		
		//用于订阅/注册应用程序以接收来自已注册平台服务器的远程通知。
		public function subscribe():void
		{
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]订阅/注册");
			remoteNot.subscribe(subscribeOptions);
		}
		
		//停止程序接收来自已注册平台服务器的远程通知。
		public function unsubscribe():void
		{
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]停止接收");
			remoteNot.unsubscribe();
		}
		
		//收到通知的有效载荷数据和使用它在您的应用程序
		public function notificationHandler(e:RemoteNotificationEvent):void
		{
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]RemoteNotificationEvent : " + e.toString()); 
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]type : " + e.type);
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]Bubbles : " + e.bubbles);
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]cancelable : " + e.cancelable);
			for (var x:String in e.data)
			{
				g.log.pushLog(this, g.logType._UserAction, "[IOS推送]" + x + ":  " + e.data[x]);
			}
		}
		
		// If the subscribe() request succeeds, a RemoteNotificationEvent of 
		// type TOKEN is received, from which you retrieve e.tokenId, 
		// which you use to register with the server provider (urbanairship, in 
		// this example. 
		public function tokenHandler(e:RemoteNotificationEvent):void 
		{
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]RemoteNotificationEvent : " + e); 
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]type : " + e.type);
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]Bubbles : " + e.bubbles);
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]cancelable : " + e.cancelable);
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]tokenID : " + e.tokenId);
			for (var x:String in e.data)
			{
				g.log.pushLog(this, g.logType._UserAction, "[IOS推送]" + x + ":  " + e.data[x]);
			}
			urlString = new String("https://go.urbanairship.com/api/device_tokens/" + e.tokenId);
			urlreq = new URLRequest(urlString); 
			urlreq.authenticate = true; 
			urlreq.method = URLRequestMethod.PUT;
			URLRequestDefaults.setLoginCredentialsForHost("go.urbanairship.com", "1ssB2iV_RL6_UBLiYMQVfg", "t-kZlzXGQ6-yU8T3iHiSyQ");
			urlLoad.load(urlreq);
			urlLoad.addEventListener(IOErrorEvent.IO_ERROR, iohandler);
			urlLoad.addEventListener(Event.COMPLETE, compHandler);
			urlLoad.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpHandler);
		} 

		private function iohandler(e:IOErrorEvent):void 
		{ 
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]HTTP IOError : " + e.errorID + " " + e.type);
		}
		
		private function compHandler(e:Event):void
		{
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]HTTP Complete : " + e.type);
		}
		
		private function httpHandler(e:HTTPStatusEvent):void
		{
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]HTTP Status : " + e.status);
		}
		
		// If the subscription request fails, StatusEvent is dispatched with 
		// error level and code. 
		public function statusHandler(e:StatusEvent):void
		{
			g.log.pushLog(this, g.logType._UserAction, "[IOS推送]HTTP statusHandler Level:" + e.level + " code:" + e.code + " currentTarget:" + e.currentTarget.toString());
		} 
	}
}