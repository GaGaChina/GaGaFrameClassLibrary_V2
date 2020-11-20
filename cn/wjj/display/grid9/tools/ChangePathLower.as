package cn.wjj.display.grid9.tools 
{
	import cn.wjj.display.grid9.Grid9Info;
	import cn.wjj.display.grid9.Grid9InfoPiece;
	
	/**
	 * 将U2文件内的全部内容都转换为小写
	 * 
	 * @author GaGa
	 */
	public class ChangePathLower 
	{
		
		public function ChangePathLower() { }
		
		public static function runPath(o:Grid9Info):void
		{
			o.name = o.name.toLocaleLowerCase();
			o.path = o.path.toLocaleLowerCase();
			var list:Vector.<Grid9InfoPiece> = o.list;
			for each (var piece:Grid9InfoPiece in list) 
			{
				if (piece.path)
				{
					piece.path = piece.path.toLocaleLowerCase();
				}
			}
		}
	}
}