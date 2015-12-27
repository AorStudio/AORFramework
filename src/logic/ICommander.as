package logic {
	public interface ICommander {
		
		/**
		 * 发布指令接口
		 * @params $comArgs:一个数组,表示一段或者多段字符串
		 */
		function command ($comArgs:Array):void;
	}
}