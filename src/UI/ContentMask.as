//lib.display::contentMask
/**
* Author 		:		 Aorition
* lastUpdate 	: 		 16/02/2012
*/
package UI {
	
	//import flash.display.Graphics;
	
	import org.resize.IReszieChild;
	import org.template.SpriteTemplate;
	
	public class ContentMask extends SpriteTemplate implements IReszieChild {
		
		public function ContentMask() {
			// constructor code
			super();
		}//end fun
		
		protected override function init ():void {
			//
			//_whb = 1024 / 768;
		}//end fun
		
		protected override function destructor ():void {
			//
		}//end fun
	//	public var widthMax:int = 2048;
	//	public var heightMax:int = 1536;
		
		private var _width:Number;
		override public function get width():Number {
			return _width;
		}
		override public function set width(value:Number):void {
			//do nothing
		}
		private var _height:Number;
		override public function get height():Number {
			return _height;
		}
		override public function set height(value:Number):void {
			//do nothing;
		}
		
	//	private var _whb:Number;
		
		public function resizeHandleMothed ($w:Number=1, $h:Number=1, $type:String="default"):void {
			
			/*
			//计算高宽等比缩放
			if($w >= $h){
				//以高度为基准
				if ($h > heightMax){
					_height = heightMax;
				}else{
					_height = $h;
				}
				_width = _height * _whb;
			}else{
				//以宽度为基准
				if($w > widthMax){
					_width = widthMax;
				}else{
					_width = $w;
				}
				_height = _width / _whb;
			}
			*/
			
			_width = $w;
			_height = $h;
			
			drawMask(_width,_height);
			
			x = ($w - _width) * 0.5;
			y = ($h - _height) * 0.5;
			
		}//end fun
		
		private function drawMask ($w:Number,$h:Number):void {
			this.graphics.clear();
			this.graphics.beginFill(0x000000,1);
			this.graphics.drawRect(0,0,$w,$h);
			this.graphics.endFill();
		}//end fun
		
	}//end class
}//end package
