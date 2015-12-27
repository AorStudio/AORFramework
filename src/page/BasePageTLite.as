package page {
	import flash.display.Sprite;
	
	import org.resize.IReszieChild;
	import org.template.SpriteTLite;
	
	import entry.AORFWEntry;
	
	/**
	 * 页面类基类
	 * 自创页面请继承自本类，要求重写init,destructor,resizeHandleMothed方法，并实例化本类依赖元素：_bg (注意：_bg为本类的依赖属性，如不将其实现则会引发不可遇见的错误)；
	 */
	public class BasePageTLite extends SpriteTLite implements IReszieChild {
		
		public function get $():AORFWEntry {
			return AORFWEntry.$;
		}
		
		public function BasePageTLite() {
			super();
		}
		
		protected var _bg:Sprite;
		
		public function resizeHandleMothed ($w:Number = 1, $h:Number = 1, $type:String = 'default'):void {
			if(_bg){
				_bg.width = $w;
				_bg.height = $h;
			}
			
		}
		
		override protected function init():void
		{
			// TODO Auto Generated method stub
			super.init();
		}
		
		override protected function destructor():void {
			_bg = null;
		}
		
		
		override public function get height():Number {
			if(_bg){
				return _bg.height;
			}
			return 0;
		}
		override public function set height(value:Number):void {
			//do nothing;
		}
		
		override public function get width():Number {
			if(_bg){
				return _bg.width;
			}
			return 0;
		}
		
		override public function set width(value:Number):void {
			//do nothing;
		}
		
		
	}
	
}
