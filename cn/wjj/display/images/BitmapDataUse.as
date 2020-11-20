package cn.wjj.display.images {
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.geom.Rectangle;
	import com.hurlant.util.Hex;
	
	/**
	 * ...
	 * @author 嘎嘎
	 */
	public class BitmapDataUse {
		
		 
		/**
		 * 通过一个数组来记录数据
		 * @param	arr
		 * @return
		 */
		public static function ArrToBitmapData(arr:Array):BitmapData {
			function getColour(arr:Array, xi:int, yi:int):uint {
				var setColour:Number;
				var tempColour:Number = arr[xi][yi];
				if (tempColour == 1) {
					if (arr[xi][(yi - 1)] < 10) {
						setColour = getColour(arr, xi, (yi - 1));
					}else {
						setColour = arr[xi][(yi - 1)];
					}
				}else if (tempColour == 3) {
					if (arr[(xi - 1)][yi] < 10) {
						setColour = getColour(arr, (xi - 1), yi);
					}else {
						setColour = arr[(xi - 1)][yi];
					}
				}else if (tempColour == 0) {
					if (arr[(xi - 1)][(yi - 1)] < 10) {
						setColour = getColour(arr, (xi - 1), (yi - 1));
					}else {
						setColour = arr[(xi - 1)][(yi - 1)];
					}
				}else if (tempColour == 6) {
					if (arr[xi][(yi + 1)] < 10) {
						setColour = getColour(arr, xi, (yi + 1));
					}else {
						setColour = arr[xi][(yi + 1)];
					}
				}else if (tempColour == 4) {
					if (arr[(xi + 1)][yi] < 10) {
						setColour = getColour(arr, (xi + 1), yi);
					}else {
						setColour = arr[(xi + 1)][yi];
					}
				}else if (tempColour == 5) {
					if (arr[(xi - 1)][(yi + 1)] < 10) {
						setColour = getColour(arr, (xi - 1), (yi + 1));
					}else {
						setColour = arr[(xi - 1)][(yi + 1)];
					}
				}else if (tempColour == 7) {
					if (arr[(xi + 1)][(yi + 1)] < 10) {
						setColour = getColour(arr, (xi + 1), (yi + 1));
					}else {
						setColour = arr[(xi + 1)][(yi + 1)];
					}
				}else if (tempColour == 2) {
					if (arr[(xi + 1)][(yi - 1)] < 10) {
						setColour = getColour(arr, (xi + 1), (yi - 1));
					}else {
						setColour = arr[(xi + 1)][(yi - 1)];
					}
				}else {
					setColour = tempColour;
				}
				return uint(Number(setColour) - 10);
			}
			var tempColour:Number;
			var theBitmapData:BitmapData = new BitmapData(arr.length, arr[0].length);
			for (var xig:int = 0, xl:int = arr.length; xig < xl; xig++) {
				for (var yig:int = 0, yl:int = arr[xig].length; yig < yl; yig++) {
					theBitmapData.setPixel((xig + 1), (yig + 1), getColour(arr, xig, yig));
				}
			}
			return theBitmapData;
		}
		
		/**
		 * 通过一个图片的 BitmapData 获取一个图片信息的 Array
		 * 自己加了一个压缩的算法,0就是取得上边的颜色,1就是取得左面的颜色
		 * 0  1  2    +  +  +
		 * 3  *  4    +  *  -
		 * 5  6  7    -  -  -
		 * @param	theBitmapData	图片的 BitmapData 数据
		 * @return
		 */
		public static function BitmapDataToArr(theBitmapData:BitmapData):Array {
			var theBitInfo:Array = new Array();
			var tempXColour:uint, tempYColour:uint, tempColour:uint;
			var xl:int = theBitmapData.width;
			var yl:int = theBitmapData.height;
			for (var xi:int = 0; xi < xl; xi++) {
				theBitInfo[xi] = new Array();
				for (var yi:int = 0; yi < yl; yi++) {
					tempColour = theBitmapData.getPixel((xi + 1), (yi + 1));
					if (yi != 0 && tempColour == theBitmapData.getPixel((xi + 1), (yi - 0))) {
						theBitInfo[xi][yi] = 1;
					}else if (xi != 0 && tempColour == theBitmapData.getPixel((xi - 0), (yi + 1))) {
						theBitInfo[xi][yi] = 3;
					//}else if (xi != 0 && yi != 0 && tempColour == theBitmapData.getPixel((xi - 1), (yi - 1))) {
					//	theBitInfo[xi][yi] = 0;
					//}else if ((yi + 1) != yl && tempColour == theBitmapData.getPixel(xi, (yi + 1))) {
					//	theBitInfo[xi][yi] = 6;
					//}else if ((xi + 1) != xl && tempColour == theBitmapData.getPixel((xi + 1), yi)) {
					//	theBitInfo[xi][yi] = 4;
					//}else if ((yi + 1) != yl && xi != 0 && tempColour == theBitmapData.getPixel((xi - 1), (yi + 1))) {
					//	theBitInfo[xi][yi] = 5;
					//}else if ((yi + 1) != yl && (xi + 1) != xl && tempColour == theBitmapData.getPixel((xi + 1), (yi + 1))) {
					//	theBitInfo[xi][yi] = 7;
					//}else if (yi != 0 && (xi + 1) != xl && tempColour == theBitmapData.getPixel((xi + 1), (yi - 1))) {
					//	theBitInfo[xi][yi] = 2;
					}else {
						theBitInfo[xi][yi] = Number(tempColour) + 10;
					}
				}
			}
			return theBitInfo;
		}
		
		/**
		 * 通过一个数组来记录数据,另一个colArr来辅助记录
		 * theInfo.ImageInfo   theInfo.ColourInfo
		 * @param	theInfo
		 * @return
		 */
		public static function ObjToBitmapData(theInfo:Object):BitmapData {
			var arr:Array = new Array(new Array);
			var colArr:Array;
			var tempColour:uint;
			if (theInfo.hasOwnProperty("ImageInfo")) {
				arr = theInfo.ImageInfo;
			}
			if (theInfo.hasOwnProperty("ColourInfo")) {
				colArr = theInfo.ColourInfo;
			}
			var theBitmapData:BitmapData = new BitmapData(arr.length,arr[0].length);
			for (var xi:int = 0, xl:int = arr.length; xi < xl; xi++) {
				for (var yi:int = 0, yl:int = arr[xi].length; yi < yl; yi++) {
					if (colArr.length > 1) {
						if (arr[xi][yi] != 0) {
							tempColour = colArr[arr[xi][yi]] - 2;
						}
						theBitmapData.setPixel(xi, yi, tempColour);
					}else {
						theBitmapData.setPixel(xi,yi,arr[xi][yi]);
					}
				}
			}
			return theBitmapData;
		}
		
		public static function BitmapDataToObj(theBitmapData:BitmapData):Object {
			//trace("图片尺寸 : ",theBitmapDate.width,theBitmapDate.height);
			var ImageInfo:Array = new Array();
			var ColourInfo:Array = new Array();
			var tempColour:uint, i:int, l:int, id:int, oldid:int;
			var xl:int = theBitmapData.width;
			var yl:int = theBitmapData.height;
			for (var xi:int = 0; xi < xl; xi++) {
				ImageInfo[xi] = new Array();
				for (var yi:int = 0; yi < yl; yi++) {
					tempColour = theBitmapData.getPixel(xi, yi);
					id = 0;
					for (i = 0, l = ColourInfo.length; i < l; i++) {
						if (ColourInfo[i] == tempColour) {
							id = i;
							break;
						}
					}
					if (id == 0) {
						id = ColourInfo.length;
						ColourInfo.push(tempColour);
					}
					if (id != oldid) {
						ImageInfo[xi][yi] = id;
					}
					oldid = id;
				}
			}
			var theInfo:Object = new Object();
			theInfo.ImageInfo = ImageInfo;
			theInfo.ColourInfo = ColourInfo;
			return theInfo;
		}
		
		/**
		 * 将 BitmapData 转换为 String
		 * @param	avatar
		 * @return
		 */
		public static function BitmapDataToString(avatar:BitmapData):String {
			if (!avatar) {
				return null;
			}
			var avatarBA:ByteArray = new ByteArray;
			avatarBA.clear();
			//从BitmapData提取RGB的ByteArray字节数组
			avatarBA = avatar.getPixels(avatar.rect);
			avatarBA.writeShort(avatar.width);
			avatarBA.writeShort(avatar.height);
			avatarBA.writeBoolean(avatar.transparent); 
			//压缩字节数组
			avatarBA.compress();
			//将图像转为Base64字符串，可以生成xml信息。
			return Hex.fromArray(avatarBA);
		}
		
		/**
		 * 将字符串反转成图像，我们可以对BitmapData进行解码
		 * @param	string
		 * @return
		 */
		public static function StringToBitmapData(string:String):BitmapData {
			if (!string) {
				return null;
			}
			//将ByteArray解码解压缩，转为BitmapData
			var avatarBA:ByteArray = Hex.toArray(string);
			avatarBA.uncompress();
			return decodeBitmapData(avatarBA);
		}
		
		/**
		 * ByteArray解码为BitmapData
		 * @param	data
		 * @return
		 */
		public static function decodeBitmapData(data:ByteArray):BitmapData {
			if (data.length <  6) {
				trace("data 参数为无效值!");
			}
			data.position = data.length - 1;
			var transparent:Boolean = data.readBoolean();
			data.position = data.length - 3;
			var height:int = data.readShort();
			data.position = data.length - 5;
			var width:int = data.readShort();
			data.position = 0;
			var datas:ByteArray = new ByteArray();
			data.readBytes(datas, 0, data.length - 5);
			var bmp:BitmapData = new BitmapData(width, height, transparent, 0);
			bmp.setPixels(new Rectangle(0, 0, width, height), datas);
			return bmp;
		}
		
	}
}