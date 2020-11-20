package cn.wjj.time 
{
	/**
	 * 算出什么时候某值增长满了,现在时间点某值是否满了
	 * @author GaGa
	 */
	public class RecoveryTime 
	{
		
		public function RecoveryTime() 
		{
			
		}
		
		/**
		 * 需要多久用户的冒一项值会恢复满
		 * 
		 * 如果返回0,标识不需要推送,可能现在体力已经满了
		 * 
		 * @param	time		得到客户端时间(恢复nowVer的时候的时间)
		 * @param	timeValue	时间点的值
		 * @param	maxValue	最大值
		 * @param	useTime		消耗毫秒回复次数
		 * @param	addValue	每次恢复的值
		 * @return				恢复满的时间点
		 */
		public static function getTimeOut(time:Number, timeValue:Number, maxValue:Number, useTime:Number, addValue:Number):Number
		{
			var outTime:Number = 0;
			if (timeValue < maxValue)
			{
				outTime = Math.ceil((maxValue - timeValue) / addValue) * useTime + time;
			}
			return outTime;	
		}
		
	}

}