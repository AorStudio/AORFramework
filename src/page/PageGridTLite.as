package page {
	
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import entry.AORFWEntry;
	
	import org.basic.Aorfuns;
	import org.resize.IReszieChild;
	import org.template.SpriteTLite;
	import org.template.TemplateTool;
	
	public class PageGridTLite extends SpriteTLite implements IReszieChild {
		/**
		 * 可视元素非2维矩阵时,元素横向排列
		 */
		public static const DIRECTION_HORIZONTAL:String = "x";
		/**
		 * 可视元素非2维矩阵时,元素纵向排列
		 */
		public static const DIRECTION_VERTICAL:String = "y";
		
		/**
		 * PageGrid 
		 * $SourceGroup:Array 	:	传入需要显示可视元素，(可以为2维数组,暂时未实现)
		 * $view_width:Number 	:	基本宽度
		 * $view_heihgt:Number	:	基本高度
		 * $direction:int		:	可视元素非2维矩阵时,元素排列的方向,默认为横向
		 * $viewPoint:Point		:	初始化显示的可视元素位置标记,默认为未设置(null)，PageGrid将默认显示第一个可视元素（2维数组中0,0的位置）
		 * $circleView			:	可视元素是否循环排列，默认为否
		 */
		public function PageGridTLite($SourceGroup:Array,$view_width:Number = 1920,$view_heihgt:Number = 1080,$direction:String = "x",$viewPoint:Point = null,$circleView:Boolean = false,$touch:Boolean = true) {
			_SourceGroup = $SourceGroup;
			_SourceGroupLength = $SourceGroup.length;
			_view_width = $view_width;
			_view_heihgt = $view_heihgt;
			_direction = $direction;
			_circleView = $circleView;
			_isTouch = $touch
			if($viewPoint == null){
				_viewPoint = new Point();
			}else{
				_viewPoint = $viewPoint;
			}
			
			super();
		}
		
		private var _isTouch:Boolean;
		/**
		 * 是否开启Touch控制
		 */
		public function get isTouch():Boolean {
			return _isTouch;
		}
		public function set isTouch(value:Boolean):void {
			if(_isTouch == value) return;
			_isTouch = value;
			if(_isTouch){
				createTouchListen();
			}else{
				removeTouchListen();
			}
		}
		
		/**
		 * AORFWEntry框架主类挂载
		 */
		public function get $():AORFWEntry {
			return AORFWEntry.$;
		}
		
		private var _currentSrc:DisplayObject;
		/**
		 * 当前显示的可视元素
		 */
		public function get currentSrc():DisplayObject {
			return _currentSrc;
		}
		
		private var _viewPoint:Point;
		/**
		 * 位置标记，表明当前显示的元素在整个元素集合中的位置
		 */
		public function get viewPoint():Point {
			return _viewPoint;
		}
		public function setViewPoint ($x:int,$y:int = 0):void {
			if(_viewPoint.x == $x && _viewPoint.y == $y) return;
			if(_SourceIsMatrix){
				//_viewPoint.x = $x;
				//_viewPoint.y = $y;
			}else{
				_viewPoint.x = $x;
				setup(true);
			}
		}
		
		private var _SwingTimeThreshold:int = 10;
		/**
		 * 甩动行为_时间阀值
		 */	
		public function get SwingTimeThreshold():int {
			return _SwingTimeThreshold;
		}
		public function set SwingTimeThreshold(value:int):void {
			_SwingTimeThreshold = value;
		}
		
		private var _SwingThreshold:int = 50;
		/**
		 * 甩动行为_距离阀值
		 */
		public function get SwingThreshold():int {
			return _SwingThreshold;
		}
		public function set SwingThreshold(value:int):void {
			_SwingThreshold = value;
		}
		
		private var _TapThreshold:int = 15;
		/**
		 * 单击时长阀值，此值关系到点击事件派发，单位为帧
		 */
		public function get TapThreshold():int {
			return _TapThreshold;
		}
		public function set TapThreshold(value:int):void {
			_TapThreshold = value;
		}
		
		private var _MoveThreshold:int = 10;
		/**
		 * 点击移动阀值,此值关系到点击事件派发。
		 */
		public function get MoveThreshold():int{
			return _MoveThreshold;
		}
		public function set MoveThreshold(value:int):void {
			_MoveThreshold = value;
		}
		
		private var _SwingMoveTime:Number = 0.8;
		/**
		 * Swing滚动动画的速度，单位为秒
		 */
		public function get SwingMoveTime():Number {
			return _SwingMoveTime;
		}
		public function set SwingMoveTime(value:Number):void {
			_SwingMoveTime = value;
		}
		
		private var _homingTime:Number = 0.3;
		/**
		 * 位置校正动画的速度，单位为秒
		 */
		public function get homingTime():Number {
			return _homingTime;
		}
		public function set homingTime(value:Number):void {
			_homingTime = value;
		}
		
		private var _circleView:Boolean;
		/**
		 * 可视元素是否循环排列
		 */
		public function get circleView():Boolean {
			return _circleView;
		}
		public function set circleView(value:Boolean):void {
			_circleView = value;
		}
		
		
		//---------------------------------------------------------------------------------------------------------------------
		private var _msHelper:int;
		private var _isTap:Boolean;
		private var _view_width:Number;
		private var _view_heihgt:Number;
		private var _direction:String;
		private var _SourceGroupLength:int;
		
		private var _mask:Sprite;
		private var _content:Sprite;
		private var _srcCont:Sprite;
		private var _srcContOutline:Point;
		
		private var _newMove:Point;
		private var _msReg:Point;
		private var _srcContReg:Point;
		private var _SourceGroup:Array;
		
		
		override protected function destructor():void {
			
			TweenLite.killTweensOf(_srcCont);
			removeTouchListen();
			
			if(_srcCont){
				_srcCont.removeChildren();
			}
			
			removeChildren();
			
			
			while (_SourceGroup.length > 0){
				_SourceGroup.pop().visible = true;
			}
			
			_msReg = null;
			_srcContReg = null;
			
			_newMove = null;
			_viewPoint = null;
			
			_SourceGroup = null;
			_currentSrc = null;
			_srcContOutline = null;
			_srcCont = null;
			_content = null;
			_mask = null;
		}
		
		override protected function init():void {
			
			if(_circleView && (_SourceGroupLength < 4)){
				throw new Error("PageGrid 使用循环播放必须放置4个以上的可视元素，当前可视元素为" + _SourceGroupLength + "个，PageGrid ShutDown !");
				return;
			}
			
			_content = TemplateTool.createBaseContainer();
			_content.name = "PG_content_mc";
			_content.x = _view_width * 0.5;
			_content.y = _view_heihgt * 0.5;
			addChild(_content);
			
			_mask = TemplateTool.createSimpleBackground(_view_width,_view_heihgt,0x000000,0);
			_mask.name = "PG_mask_mc";
			Aorfuns.setDOCInteractvie(_mask);
			addChild(_mask);
			
			//test
			//_mask.visible = false;
			_content.mask = _mask;
			
			_srcCont = TemplateTool.createBaseContainer();
			_srcCont.name = "PG_srcCont_mc";
			_content.addChild(_srcCont);
			
			if(_SourceGroup == null){
				throw new Error("SourceGroup is null. PageGrid shutdown !");
				return;
			}
			
			if(_SourceGroup.length == 1){
				//只有个元素时，仅仅显示本元素
				//设置_srcCont初始位置；
				_srcCont.addChild(_SourceGroup[0]);
				_srcCont.x = -(_view_width) * 0.5;
				_srcCont.y = -(_view_heihgt) * 0.5;
				_currentSrc = _SourceGroup[0];
				return;
			}
			
			//判断SourceGroup 是否为2维数组
			_SourceIsMatrix = checkSourceGroupIsMatrix();
			
			//创建outline
			_srcContOutline = new Point();
			if(_SourceIsMatrix){
				
				//暂时还没有实现2维数组写入
				
				throw new Error("暂时还没有实现2维数组写入,请勿写入2数组");
				return;
				
			}else{
				if(_direction == "x"){
					_srcContOutline.x = _view_width * _SourceGroupLength;
					_srcContOutline.y = _view_heihgt;
				}else{
					_srcContOutline.x = _view_width;
					_srcContOutline.y = _view_heihgt * _SourceGroupLength;
				}
			}
			
			//创建显示
			setup(true,_isTouch);
			
		}
		
		//-------------------------------------------------------------------------
		
		override public function get height():Number {
			return _view_heihgt;
		}
		
		override public function set height(value:Number):void {
			if(_view_heihgt == value) return;
			_view_heihgt = value;
			if(_mask){
				_mask.height = _view_heihgt;
			}
			if(_content){
				_content.scaleY = _mask.scaleY;
				_content.y = _view_heihgt * 0.5;
			}
			//trace("*** " + height);
		}
		
		override public function get width():Number {
			return _view_width;
		}
		
		override public function set width(value:Number):void {
			if(_view_width == value) return;
			_view_width = value;
			if(_mask){
				_mask.width = _view_width;
			}
			if(_content){
				_content.scaleX = _mask.scaleX;
				_content.x = _view_width * 0.5;
			}
			
			//trace("*** " + width);
		}
		
		public function resizeHandleMothed($w:Number=1, $h:Number=1, $type:String='default'):void{
			height = $w;
			width = $h;
		}
		
		/**
		 * 转到下一个元素
		 */
		public function turnNext ():void {
			if(_SourceIsMatrix) return;
			if(!_circleView && (_viewPoint.x + 1) > (_SourceGroupLength - 1)){
				return;
			}
			_viewPoint.x ++;
			setup();
			runTurnAnimation();
		}
		
		/**
		 * 转到上一个元素
		 */
		public function turnPrevious ():void {
			if(_SourceIsMatrix) return;
			if(!_circleView && (_viewPoint.x - 1) < 0){
				return;
			}
			_viewPoint.x --;
			setup();
			runTurnAnimation();
		}
		
		private function runTurnAnimation ():void {
			_isAnimation = true;
			if(_direction == "x"){
				TweenLite.to(_srcCont,_SwingMoveTime,{x:(-(_view_width) * _viewPoint.x) - (_view_width ) * 0.5,onComplete:srcContOptimize});
			}else{
				TweenLite.to(_srcCont,_SwingMoveTime,{y:(-(_view_heihgt) * _viewPoint.x) - (_view_heihgt ) * 0.5,onComplete:srcContOptimize});
			}
		}
		
		/**
		 * 标识 SourceGroup 是2维矩阵数据；
		 */
		private var _SourceIsMatrix:Boolean;
		
		/**
		 * 检测 SourceGroup 是否为2维数组
		 */
		private function checkSourceGroupIsMatrix ():Boolean {
			
			if(_SourceGroup[0] is Array){
				return true;
			}
			//强制修改_viewPoint中的纵向标记为0
			_viewPoint.y = 0;
			return false;
		}
		
		private function setSrcOnSrcCont ($id:int):void {
			var $tar:DisplayObject;
			var $rl:int;
			if($id >= 0){
				$rl = $id % _SourceGroupLength;
			}else{
				$rl = ($id % _SourceGroupLength) == 0 ? 0 : (_SourceGroupLength + ($id % _SourceGroupLength));
			}
			
			$tar = _SourceGroup[$rl];
			
			if($tar == null){
				Aorfuns.log("PageGrid.setSrcOnSrcCont this $id:" + $id + " can not be find");
				return;
			}
			
			if($tar.stage != null){
				$tar.visible = true;
				if(_direction == "x"){
					$tar.x = $id * _view_width;
					$tar.y = 0;
				}else{
					$tar.x = 0;
					$tar.y = $id * _view_heihgt;
				}
			}else{
				_srcCont.addChild($tar);
				$tar.width = _view_width;
				$tar.height = _view_heihgt;
				if(_direction == "x"){
					$tar.x = $id * _view_width;
					$tar.y = 0;
				}else{
					$tar.x = 0;
					$tar.y = $id * _view_heihgt;
				}
			}
		}
		
		private function setSrcRemoveFromSrcCont ($id:int):void {
			var $tar:DisplayObject;
			var $rl:int;
			if($id >= 0){
				$rl = $id % _SourceGroupLength;
			}else{
				$rl = ($id % _SourceGroupLength) == 0 ? 0 : (_SourceGroupLength + ($id % _SourceGroupLength));
			}
			
			$tar = _SourceGroup[$rl];
			
			if($tar == null){
				Aorfuns.log("PageGrid.setSrcRemoveFromSrcCont this $id:" + $id + " can not be find");
				return;
			}
			
			if($tar.stage != null){
				$tar.visible = false;
			}
		}
		
		private function setup (isInit:Boolean = false, addMouseListen:Boolean = false):void {
			
			if(_SourceIsMatrix){
				//2D
			}else{
				//1D
				
				if(_circleView){
					
					setSrcRemoveFromSrcCont(_viewPoint.x - 2);
					setSrcOnSrcCont(_viewPoint.x - 1);
					setSrcOnSrcCont(_viewPoint.x);
					_currentSrc = _SourceGroup[_viewPoint.x];
					setSrcOnSrcCont(_viewPoint.x + 1);
					setSrcRemoveFromSrcCont(_viewPoint.x + 2);
					
				}else{
					
					if((_viewPoint.x - 2) >= 0){
						setSrcRemoveFromSrcCont(_viewPoint.x - 2);
					}
					
					if((_viewPoint.x - 1) >= 0){
						setSrcOnSrcCont(_viewPoint.x - 1);
					}
					
					setSrcOnSrcCont(_viewPoint.x);
					_currentSrc = _SourceGroup[_viewPoint.x];
					
					if((_viewPoint.x + 1) <= (_SourceGroupLength - 1)){
						setSrcOnSrcCont(_viewPoint.x + 1);
					}
					
					if((_viewPoint.x + 2) <= (_SourceGroupLength - 1)){
						setSrcRemoveFromSrcCont(_viewPoint.x + 2);
					}
				}
				if(isInit){
					//设置_srcCont初始位置；
					if(_direction == "x"){
						_srcCont.x = (-(_view_width) * _viewPoint.x) - (_view_width ) * 0.5;
						_srcCont.y = -(_view_heihgt) * 0.5;
					}else{
						_srcCont.x = -(_view_width) * 0.5;
						_srcCont.y = (-(_view_heihgt) * _viewPoint.x) - (_view_heihgt ) * 0.5;
						
					}
					
					if(addMouseListen){
						createTouchListen();
					}
				}
				
			}
			
		}
		
		private var _isAnimation:Boolean = false;
		
		private function srcContOptimize ():void {
			
			if(_SourceIsMatrix){
				//2D
			}else{
				if(_viewPoint.x >= 0){
					_viewPoint.x = _viewPoint.x % _SourceGroupLength;
				}else{
					_viewPoint.x = (_viewPoint.x % _SourceGroupLength) == 0 ? 0 : (_SourceGroupLength + (_viewPoint.x % _SourceGroupLength));
				}
				setup(true);
			}
			
			_isAnimation = false;
			
		}
		
		
		private function msDown(e:MouseEvent):void {
			//Aorfuns.log("PageGrid.msDown > " + e.target.name + e.target);
			
			if(_isAnimation) return;
			
			TweenLite.killTweensOf(_srcCont);
			_isTap = true;
			_msHelper = 0;
			_msReg = new Point(e.stageX,e.stageY);
			_srcContReg = new Point(_srcCont.x,_srcCont.y);
			addEventListener(Event.ENTER_FRAME,msCoreLoop);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, msMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,msUp);
		}
		
		private function msMove (e:MouseEvent):void {
			e.updateAfterEvent();
		}
		
		private function msUp (e:MouseEvent):void {
			removeEventListener(Event.ENTER_FRAME,msCoreLoop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, msMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,msUp);
			//
			var $mp:Point = new Point(e.stageX,e.stageY);
			if(_isTap && (Point.distance(_msReg,$mp) < _MoveThreshold) ){
				//判定为 Tap 行为；
				Aorfuns.log("判定为 Tap 行为；");
				dispatchEvent(new MouseEvent(MouseEvent.CLICK,e.bubbles,e.cancelable,e.localX,e.localY,e.relatedObject,e.ctrlKey,e.altKey,e.shiftKey,e.buttonDown,e.delta,e.commandKey,e.controlKey,e.clickCount));
				return;
			}
			
			//这里还是甩动判定
			
			if(_msHelper < _SwingTimeThreshold && (Point.distance(_msReg,$mp) > _SwingThreshold)){
				
				Aorfuns.log("判定为 Swing 行为；");
				var $dX:Number = $mp.x - _msReg.x;
				var $dY:Number = $mp.y - _msReg.y;
				if(_SourceIsMatrix){
					//
				}else{
					if(_direction == "x"){
						
						if(_msHelper < _SwingTimeThreshold && (Math.abs($dX) > _SwingThreshold)){
							if($dX > 0){
								turnPrevious();
							}else if ($dX < 0){
								turnNext();
							}
							return;
						}
						
					}else{
						if(_msHelper < _SwingTimeThreshold && (Math.abs($dY) > _SwingThreshold)){
							if($dY > 0){
								turnPrevious();
							}else if ($dY < 0){
								turnNext();
							}
							return;
						}
						//
					}
				}
			}
			
			//移动归位处理
			if(_SourceIsMatrix){
				
			}else{
				if(_direction == "x"){
					_viewPoint.x = round(-(_srcCont.x + (_view_width * 0.5)) / _view_width);
					TweenLite.to(_srcCont,_homingTime,{x:(-(_view_width) * _viewPoint.x) - (_view_width ) * 0.5,onComplete:srcContOptimize});
				}else{
					_viewPoint.x = round(-(_srcCont.y + (_view_heihgt * 0.5)) / _view_heihgt);
					TweenLite.to(_srcCont,_homingTime,{y:(-(_view_heihgt) * _viewPoint.x) - (_view_heihgt ) * 0.5,onComplete:srcContOptimize});
				}
			}
			
		}
		
		private function msCoreLoop(e:Event):void {
			_msHelper ++;
			if(_msHelper == _TapThreshold){
				_isTap = false;
			}
			
			_newMove = new Point(stage.mouseX - _msReg.x, stage.mouseY - _msReg.y);
			
			if(_msHelper < _SwingTimeThreshold){
				return;
			}
			
			if(_SourceIsMatrix){
				
			}else{
				if(_direction == "x"){
					if(Math.abs(_newMove.x) > _MoveThreshold){
						_srcCont.x = (_srcContReg.x + _newMove.x) / _content.scaleX;
						if(!_circleView){
							//边框校正
							if(_srcCont.x > -_view_width * 0.5){
								_srcCont.x = -_view_width * 0.5;
							}else if(_srcCont.x < (-_srcContOutline.x + (_view_width * 0.5))){
								_srcCont.x = (-_srcContOutline.x + (_view_width * 0.5));
							}
						}
					}else{
						_srcCont.x = _srcContReg.x;
					}
					_viewPoint.x = round(-(_srcCont.x + (_view_width * 0.5)) / _view_width);
				}else{
					if(Math.abs(_newMove.y) > _MoveThreshold){
						_srcCont.y = (_srcContReg.y + _newMove.y) / _content.scaleY;
						if(!_circleView){
							//边框校正
							if(_srcCont.y > -_view_heihgt * 0.5){
								_srcCont.y = -_view_heihgt * 0.5;
							}else if(_srcCont.y < (-_srcContOutline.y + (_view_heihgt * 0.5))){
								_srcCont.y = (-_srcContOutline.y + (_view_heihgt * 0.5));
							}
						}
					}else{
						_srcCont.y = _srcContReg.y;
					}
					_viewPoint.x = round(-(_srcCont.y + (_view_heihgt * 0.5)) / _view_heihgt);
				}
			}
			
			setup();
			
		}
		
		private function round (ins:Number):int {
			return Math.round(ins);
		}
		
		private function createTouchListen ():void {
			removeTouchListen();
			addEventListener(MouseEvent.MOUSE_DOWN, msDown);
		}
		
		private function removeTouchListen ():void {
			removeEventListener(Event.ENTER_FRAME,msCoreLoop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, msMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,msUp);
			removeEventListener(MouseEvent.MOUSE_DOWN, msDown);
		}
		
	}
}