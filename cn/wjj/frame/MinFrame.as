package cn.wjj.frame {
	
	/**
	 * 非常迷你的独立小框架,单列模式
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2012-08-20
	 */
	public class MinFrame {
		
		/** 这个swf的根目录,有些像2.0的_root **/
		private var _swfRoot:*;
		
		private static var instance:MinFrame;
		public function MinFrame(_Temp:Enforcer) { }
		public static function getInstance():MinFrame {
			if (instance == null) {
				instance = new MinFrame(new Enforcer());
			}
			return instance;
		}
		
		/**
		 * 获取根目录
		 */
		public function get swfRoot():*
		{
			if (_swfRoot != null )
			{
				return _swfRoot;
			}else {
				return null;
			}
		}
		
		/** 设置根目录,先入为主 **/
		public function set swfRoot(obj:*):void
		{
			if (_swfRoot == null )
			{
				_swfRoot = obj;
			}
		}
	}
}
class Enforcer{}