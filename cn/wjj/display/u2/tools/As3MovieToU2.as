package cn.wjj.display.u2.tools
{
	import com.adobe.crypto.MD5;
	
	import cn.wjj.g;
	import cn.wjj.data.file.GBitmapData;
	import cn.wjj.data.file.GBitmapDataItem;
	import cn.wjj.data.file.GBitmapMovieData;
	import cn.wjj.data.file.GBitmapMovieDataFrameItem;
	import cn.wjj.data.file.GFileBase;
	import cn.wjj.data.file.GListBase;
	import cn.wjj.data.file.GU2Info;
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.display.speed.BitmapMovieDataFrameItem;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameType;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;

	/**
	 * 把一个GFile里的as3Movie文件全部转换为U2的动画文件
	 * 方便做数据迁移,并进行调整
	 * 
	 */
	public class As3MovieToU2
	{
		public function As3MovieToU2(){}
		
		
		/**
		 * 将一个GFile里的全部As3Movie保存到GFile路径,并
		 * @param gfile
		 * @param complete
		 * 
		 */
		public static function movieSave(gfile:*, documentPath:String, gfileName:String, complete:Function):void
		{
			var list:Vector.<U2InfoBaseInfo> = movieAll(gfile, gfileName);
			var writeList:Vector.<GFileBase> = new Vector.<GFileBase>();
			var file:GU2Info;
			for each (var u2:U2InfoBaseInfo in list) 
			{
				file = new GU2Info();
				file.isBuilder = true;
				file.obj = u2;
				file.path = u2.path;
				file.name = u2.name;
				file.ver = "0.0.0";
				file.sourceByte = u2.getByte();
				file.md5 = MD5.hashBytes(file.sourceByte);
				writeList.push(file);
			}
			gfile.writeBaseByteFileList(writeList, documentPath);
			complete();
		}
		
		/** 从一个GFile里把全部的As3Movie转换为U2数据 **/
		public static function movieAll(gfile:*, gfileName:String):Vector.<U2InfoBaseInfo>
		{
			var list:Vector.<GFileBase> = gfile.list;
			var pathList:Vector.<String> = new Vector.<String>();
			for each (var base:GFileBase in list) 
			{
				if(fileIsAs3Movie(base.path))
				{
					pathList.push(base.path);
				}
			}
			var out:Vector.<U2InfoBaseInfo> = new Vector.<U2InfoBaseInfo>();
			var baseInfo:U2InfoBaseInfo;
			for each (var path:String in pathList) 
			{
				baseInfo = moviePath(gfile, path, gfileName);
				out.push(baseInfo);
			}
			return out;
		}
		
		/** 将一个GFile的path路径的As3Movie转换为U2数据 **/
		public static function moviePath(gfile:*, path:String, gfileName:String):U2InfoBaseInfo
		{
			var list:GListBase = g.gfile.getPathObj(gfile, path) as GListBase;
			var name:String = movieGetName(path);
			var movie:GBitmapMovieData = list.getPath(name) as GBitmapMovieData;
			if(movie)
			{
				return movieChange(list, movie, name, path, gfileName);
			}
			return null;
		}
		
		
		
		/** 将一个GFile的path路径的GBitmapMovieData转换为U2数据 **/
		public static function movieChange(gfile:GListBase, movie:GBitmapMovieData, name:String, path:String, gfileName:String):U2InfoBaseInfo
		{
			var u2:U2InfoBaseInfo = new U2InfoBaseInfo(null);
			u2.gfile = gfile;
			u2.name = name;
			u2.path = moviePathChange(path);
			/** 父级文件夹 **/
			var fatherPath:String = moviePathFather(path);
			u2.dType = 3;
			u2.gfileName = gfileName;
			
			var scale:Number = movie.scaleX;
			var fileBase:GFileBase;
			var fileGBase:GFileBase;
			var movieDataItem:GBitmapMovieDataFrameItem;
			var movieDataItemInfo:BitmapMovieDataFrameItem;
			var frame:U2InfoBaseFrameBitmap;
			var bitmapDataItem:BitmapDataItem;
			var gBitmapDataItem:GBitmapDataItem
			var id:int = 0;
			var layer:U2InfoBaseLayer = new U2InfoBaseLayer(u2);
			layer.name = name;
			layer.dType = 1;
			layer.fps = 8;
			u2.layer.addLayer(layer);
			var x:Number = 0;
			var y:Number = 0;
			var width:Number = 0;
			var height:Number = 0;
			var right:Number = 0;
			var end:Number = 0;
			for each (var md5:String in movie.list) 
			{
				fileBase = gfile.getMD5(md5);
				if(fileBase as GBitmapMovieDataFrameItem)
				{
					movieDataItem = fileBase as GBitmapMovieDataFrameItem;
					movieDataItemInfo = movieDataItem.obj;
					if(movieDataItemInfo)
					{
						frame = new U2InfoBaseFrameBitmap(u2);
						frame.label = movieDataItemInfo.label;
						frame.display.offsetScaleX = scale;
						frame.display.offsetScaleY = scale;
						bitmapDataItem = movieDataItemInfo.data;
						frame.display.offsetX = bitmapDataItem.x;
						frame.display.offsetY = bitmapDataItem.y;
						if(x > bitmapDataItem.x)
						{
							x = bitmapDataItem.x;
						}
						if(y > bitmapDataItem.y)
						{
							y = bitmapDataItem.y;
						}
						right = bitmapDataItem.x + bitmapDataItem.bitmapData.width;
						end = bitmapDataItem.y + bitmapDataItem.bitmapData.height;
						if(width < right)
						{
							width = right;
						}
						if(height < end)
						{
							height = end;
						}
						gBitmapDataItem = gfile.getMD5(movieDataItem.itemMD5) as GBitmapDataItem;
						frame.display.path = fatherPath + gBitmapDataItem.bitmapMD5 + ".png";
						layer.pushFrame(frame);
						id++;
					}
				}
			}
			u2.stageInfo.startX = x * scale;
			u2.stageInfo.startY = y * scale;
			u2.stageInfo.width = (width - x) * scale;
			u2.stageInfo.height = (height - y) * scale;
			return u2;
		}
		
		public static function moviePathChange(path:String):String
		{
			var arr:Array = path.split(".");
			var length:uint = arr.length;
			if(length)
			{
				var type:String = arr[length - 1];
				if(type == "as3Movie")
				{
					arr.pop();
					arr.push("u2");
					return arr.join(".");
				}
			}
			return path;
		}
		
		/** 获取父级文件夹 **/
		public static function moviePathFather(path:String):String
		{
			var arr:Array = path.split(".");
			var length:uint = arr.length;
			if(length)
			{
				var type:String = arr[length - 1];
				if(type == "as3Movie")
				{
					arr.pop();
					return arr.join(".") + "/";
				}
			}
			return path + "/";
		}
		
		public static function movieGetName(path:String):String
		{
			var arr:Array = path.split(".");
			var length:uint = arr.length;
			if(length)
			{
				var type:String = arr[length - 1];
				if(type == "as3Movie")
				{
					arr.pop();
				}
				path = arr.join(".");
				arr = path.split("/");
				return arr.pop();
			}
			return path;
		}
		
		
		public static function fileIsAs3Movie(path:String):Boolean
		{
			var arr:Array = path.split(".");
			var length:uint = arr.length;
			if(length)
			{
				var type:String = arr[length - 1];
				if(type == "as3Movie")
				{
					return true;
				}
			}
			return false;
		}
	}
}