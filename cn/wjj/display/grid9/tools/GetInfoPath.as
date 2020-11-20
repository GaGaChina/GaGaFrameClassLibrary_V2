package cn.wjj.display.grid9.tools 
{
	import cn.wjj.display.grid9.Grid9Info;
	import cn.wjj.display.grid9.Grid9InfoPiece;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	/**
	 * 获取一个U2InfoBaseInfo里所包含的路径
	 * @author GaGa
	 */
	public class GetInfoPath 
	{
		
		public function GetInfoPath() {}
		
		/** 从一个 U2InfoBaseInfo 数据中获取一个路径 **/
		public static function getOnePath(info:Grid9Info):String
		{
			var list:Vector.<Grid9InfoPiece> = info.list;
			for each (var piece:Grid9InfoPiece in list) 
			{
				if (piece.path)
				{
					return piece.path;
				}
			}
			return "";
		}
		
		/** 从一个 U2InfoBaseInfo 数据中获取全部的路径 **/
		public static function getPathList(info:Grid9Info):Vector.<String>
		{
			var out:Vector.<String> = new Vector.<String>();
			var list:Vector.<Grid9InfoPiece> = info.list;
			for each (var piece:Grid9InfoPiece in list) 
			{
				if (piece.path)
				{
					if (out.indexOf(piece.path) == -1)
					{
						out.push(piece.path);
					}
				}
			}
			return out;
		}
	}
}