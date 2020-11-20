package cn.wjj.tool
{
	
	public class VectorObjectUtil
	{
		
		/**
		 * 确定数组里是否包含这个值.
		 * @param arr
		 * @param value
		 * @return 
		 */
		public static function vectorContainsValue(v:Vector.<Object>, value:Object):Boolean
		{
			return (v.indexOf(value) != -1);
		}
		
		/**
		 * 从数组中删除值为value的对象
		 * @param arr
		 * @param value
		 */
		public static function removeValueFromVector(v:Vector.<Object>, value:Object):void
		{
			var l:uint = v.length;
			for(var i:Number = l; i > -1; i--)
			{
				if(v[i] === value)
				{
					v.splice(i, 1);
				}
			}
		}
		
		/**
		 * 返回一个新数组剔除重复的对象
		 * @param a
		 * @return 
		 */
		public static function createUniqueCopy(v:Vector.<Object>):Vector.<Object>
		{
			var o:Vector.<Object> = new Vector.<Object>();
			var l:Number = v.length;
			var item:Object;
			for (var i:uint = 0; i < l; ++i)
			{
				item = v[i];
				if(o.indexOf(item) != -1)
				{
					continue;
				}
				o.push(item);
			}
			return o;
		}
		
		/**
		 * 找到一个数组中重复的对象
		 * @param	a
		 * @return
		 */
		public static function createRepeatItem(v:Vector.<Object>):Vector.<Object>
		{
			var newArray:Vector.<Object> = new Vector.<Object>();
			var outArray:Vector.<Object> = new Vector.<Object>();
			var l:Number = v.length;
			var item:Object;
			for (var i:uint = 0; i < l; ++i)
			{
				item = v[i];
				if(newArray.indexOf(item) != -1)
				{
					if (outArray.indexOf(item) == -1)
					{
						outArray.push(item);
					}
					continue;
				}
				newArray.push(item);
			}
			
			return outArray;
		}
		
		/**
		 * 从a和b中找到共有的内容,并返回新的内容
		 * @param a
		 * @param b
		 * @return 
		 * 
		 */
		public static function createShare(a:Vector.<Object>, b:Vector.<Object>):Vector.<Object>
		{
			var o:Vector.<Object> = new Vector.<Object>();
			var l:Number = a.length;
			var item:Object;
			for (var i:uint = 0; i < l; ++i)
			{
				item = a[i];
				if(b.indexOf(item) == -1)
				{
					continue;
				}
				o.push(item);
			}
			return o;
		}
		
		/**
		 * 拷贝数组,但是没有递归,普通的拷贝了.
		 * @param arr
		 * @return 
		 * 
		 */
		public static function copyArray(v:Vector.<Object>):Vector.<Object>
		{	
			return v.slice();
		}
		
		/**
		 * 用a的数组随机出一个新数组
		 * @param a
		 * @return 
		 */
		public static function randomArray(a:Vector.<Object>):Vector.<Object>
		{
			if(!a.length){
				return new Vector.<Object>();
			}
			var b:Vector.<Object> = a.slice();
			var out:Vector.<Object> = new Vector.<Object>();
			var l:int = b.length;
			for (var i:int = 0; i < l; i++) 
			{
				out.push(b.splice(Math.floor(Math.random()*(l-i)),1)[0]);
			}
			return out;
		}
		
		/**
		 * 移动数组中的一个值,向前或向后移动,插入
		 * @param	arr			原始数组
		 * @param	index		移动的编号0开始
		 * @param	moveNum		负数为向前移动,正数为向后移动
		 * @return
		 */
		public static function moveItem(arr:Vector.<Object>, index:int, moveNum:int):Vector.<Object>
		{
			var out:Vector.<Object> = arr.slice();
			//当取值位置,比长度大的时候
			if (moveNum == 0 || index >= arr.length)
			{
				return out;
			}
			if (moveNum > 0)
			{
				//向后移动
				moveNum = index + moveNum + 1;
				if (moveNum > arr.length) {
					moveNum = arr.length;
				}
				out.splice(moveNum, 0, arr[index]);
				out.splice(index, 1);
			}
			else
			{
				//向前移动
				moveNum = index + moveNum;
				if (moveNum < 0) {
					moveNum = 0;
				}
				out.splice(index, 1);
				out.splice(moveNum, 0, arr[index]);
			}
			return out;
		}
		
		
		/**
		 * 改变带入的Vector.<Object>的排序,并且输出被改变的列被改到的索引值
		 * @param arr
		 * @param index
		 * @param moveNum
		 * @return 
		 */
		public static function moveItemGetIndex(arr:Vector.<Object>, index:int, moveNum:int):int
		{
			//当取值位置,比长度大的时候
			if (moveNum == 0)
			{
				return index;
			}
			if(index >= arr.length)
			{
				return arr.length - 1;
			}
			if (moveNum > 0)
			{
				//向后移动
				moveNum = index + moveNum + 1;
				if (moveNum > arr.length) {
					moveNum = arr.length;
				}
				arr.splice(moveNum, 0, arr[index]);
				arr.splice(index, 1);
				return moveNum - 1;
			}
			else
			{
				//向前移动
				moveNum = index + moveNum;
				if (moveNum < 0) {
					moveNum = 0;
				}
				var temp:* = arr.splice(index, 1);
				arr.splice(moveNum, 0, temp);
				return moveNum;
			}
		}
	}
}