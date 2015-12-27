//logic::Core
package logic {
	
	import com.air.net.ServerSocketManagerEvent;
	import com.command.AorCommander;
	import com.console.AorConsoleEvent;
	import com.debug.TracePanel;
	import com.net.SocketManagerEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeWindow;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import entry.AORFWEntry;
	
	import org.basic.Aorfuns;
	import org.math.ValueFormatConver;
	import org.motion.AorMotion;
	import org.motion.easing.Linear;
	import org.motion.easing.Strong;
	import org.units.ByteArrayParser;
	
	public class Core extends EventDispatcher {
		
		private static var Instance:Core;
		
		public function get $ ():AORFWEntry {
			if(AORFWEntry.$){
				return AORFWEntry.$;
			}
			return null;
		}
		
		public function Core($null:COMNullClass = null,target:IEventDispatcher=null) {
			super(target);
			if ($null == null) {
				throw new Error("You cannot instantiate this class directly, please use the static getInstance method.");
				return;
			}//end fun
		}
		
		/**
		 * 单件实例化
		 */
		public static function getInstance (target:IEventDispatcher=null):Core {
			if (Core.Instance == null) {
				Core.Instance = new Core(new COMNullClass(), target);
			}//end if
			return Core.Instance;
		}//end fun
		
		public function destructor ():void {
			$.removeEventListener(Event.ENTER_FRAME,waitForFindNativeWindow);
//			$.stage.removeEventListener(MouseEvent.CLICK, MsLogic_Click);
		}	
		
		
		private var _afterFunc:Function;
		public function start (afterFunc:Function):void {
			Aorfuns.log('LogicManager.start  > ',true);
			
			_afterFunc = afterFunc;
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING,APPExitFunc);
			
			//设置窗口的大小和位置
			//Aorfuns.log("get *********************** > " + $x + "," + $y + "," + $width + "," + $height + "," + $alwaysInFront);
			
			var w:NativeWindow  = NativeApplication.nativeApplication.activeWindow;
			if(w){
				
				var $x:int = int($.cfg.window.x);
				var $y:int = int($.cfg.window.y);
				var $width:int = int($.cfg.window.width);
				var $height:int = int($.cfg.window.height);
				var $alwaysInFront:String = String($.cfg.window.alwaysInFront);
				
				Aorfuns.log("AORFWEntry.core.start > window will set to [" + $x + "," + $y + "," + $width + "," + $height + "," + $alwaysInFront + "]\n");
				
				Aorfuns.delayCall(200,setDelaySetWindowMove,[$x,$y,$width,$height,$alwaysInFront]);
				
			}else{
				
				$.addEventListener(Event.ENTER_FRAME,waitForFindNativeWindow);
				/*
				Aorfuns.log("AORFWEntry.core.start Warring : can not find the NativeWindow !");
				
				//是否启用全屏
				if(String($.cfg.fullScreen.EnableFullScreen).toLowerCase() == 'true' ? true : false){
					
					$.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}
				
				//运行程序
				appStart();
				*/
			}
			
		}
		
		private function waitForFindNativeWindow(e:Event):void {
			var w:NativeWindow  = NativeApplication.nativeApplication.activeWindow;
			if(w){
				$.removeEventListener(Event.ENTER_FRAME,waitForFindNativeWindow);
				//
				var $x:int = int($.cfg.window.x);
				var $y:int = int($.cfg.window.y);
				var $width:int = int($.cfg.window.width);
				var $height:int = int($.cfg.window.height);
				var $alwaysInFront:String = String($.cfg.window.alwaysInFront);
				
				Aorfuns.log("AORFWEntry.core.start > window will set to [" + $x + "," + $y + "," + $width + "," + $height + "," + $alwaysInFront + "]\n");
				
				Aorfuns.delayCall(200,setDelaySetWindowMove,[$x,$y,$width,$height,$alwaysInFront]);
			}
		}
		
		private function setDelaySetWindowMove($x:int,$y:int,$w:int,$h:int,$alwaysInFront:String):void {
			
			//$.console.dispatchCommand("window s " + $x + " " + $y + " " + $w + " " + $h);
			var w3:NativeWindow  = NativeApplication.nativeApplication.activeWindow;
			w3.x = $x;
			w3.y = $y;
			w3.width = $w;
			w3.height = $h;
			
			Aorfuns.delayCall(200,setDelaySetWindowInFront,[$alwaysInFront]);
			
		}
		
		private function setDelaySetWindowInFront($switch:String):void {
			//$.console.dispatchCommand("window a " + $switch);
			
			var w2:NativeWindow  = NativeApplication.nativeApplication.activeWindow;
			w2.alwaysInFront = ($switch == "true" ? true : false);
			
			//是否启用全屏
			if(String($.cfg.fullScreen.EnableFullScreen).toLowerCase() == 'true' ? true : false){
				
				$.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			
			//运行程序
			appStart();
			
		}
		
		private var _enabledFullScreenAways:Boolean;
		public function get enabledFullScreenAways():Boolean {
			return _enabledFullScreenAways;
		}
		public function set enabledFullScreenAways(value:Boolean):void {
			if(_enabledFullScreenAways == value) return;
			_enabledFullScreenAways = value;
			if(_enabledFullScreenAways){
				fulScnStart();
			}else{
				fulScnClose();
			}
		}
		
		private function fulScnStart ():void {
			fulScnClose();
			$.stage.addEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, fullScreenFun);
			$.stage.addEventListener(KeyboardEvent.KEY_DOWN, awaysFullScreen);
		}
		private function fulScnClose ():void {
			$.stage.removeEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, fullScreenFun);
			$.stage.removeEventListener(KeyboardEvent.KEY_DOWN, awaysFullScreen);
		}
		
		private function appStart ():void {
			
			Aorfuns.log("Core.appStart !! ------------- ");
			
			$.console.addEventListener(AorConsoleEvent.INPUTCOMMAND, comReceiveFun);
			
			
			//运行时是否隐藏鼠标
			if(String($.cfg.mouse.mouseHide).toLowerCase() == 'true' ? true : false){
				Mouse.hide();
			}
			
			//是否开启强制全屏检测
			if(String($.cfg.fullScreen.forceFullScreen).toLowerCase() == 'true' ? true : false){
				fulScnStart();
			}
			
			//$.stage.addEventListener(MouseEvent.CLICK, MsLogic_Click);
			
			
			if(String($.cfg.module.SocketManager).toLowerCase() == 'true' ? true : false){
				//连接服务器
//				$.socketManager.addEventListener(SocketManagerEvent.CONNECT,connectHandler);
//				$.socketManager.addEventListener(SocketManagerEvent.IO_ERROR,ioErrorHandler);
//				$.socketManager.addEventListener(SocketManagerEvent.SECURITY_ERROR,securityErrorHandler);
				$.socketManager.addEventListener(SocketManagerEvent.SOCKET_DATA,socketDataHandler);
//				$.socketManager.addEventListener(SocketManagerEvent.CLOSE,closeHandler);
				
				$.socketManager.StartConnect();
			}
			
			if(String($.cfg.module.ServerSocketManager).toLowerCase() == 'true' ? true : false){
				//创建服务器
//				$.socketServerManager.addEventListener(ServerSocketManagerEvent.MANAGER_CLOSE, ServerCloseHandle);
//				$.socketServerManager.addEventListener(ServerSocketManagerEvent.SOCKET_CONNECT, ServerSocketConnected);
//				$.socketServerManager.addEventListener(ServerSocketManagerEvent.SOCKET_DISCONNECTED,ServerDisconnected);
				$.socketServerManager.addEventListener(ServerSocketManagerEvent.SOCKET_RECEIVED,ServerReceived);
				$.socketServerManager.start();
			}
			
			Aorfuns.log("SocketManager = " + String($.cfg.module.SocketManager) + " , ServerSocketManager = " + String($.cfg.module.ServerSocketManager));
			
			//自动加载初始设置页面
			if($.firstLoadPage != null){
				loadPage($.firstLoadPage);
			}
			
			var $clear:DisplayObject = $.getChildByName("entryEcho_mc");
			if($clear){
				$.removeChild($clear);
			}
			
			Aorfuns.log("LogicManager.appStart Done !! ");
			
			_afterFunc();
			Aorfuns.delayCall(50,function ():void {
				_afterFunc = null;
			});
			
		}
		
		//------------------------------ -----------------------------------------
		//================ ServerSocketManager 监听 =================
		/*
		protected function ServerCloseHandle(e:ServerSocketManagerEvent):void {
			//	
		}
		
		protected function ServerSocketConnected(e:ServerSocketManagerEvent):void {
			//
		}
		
		protected function ServerDisconnected(e:ServerSocketManagerEvent):void {
			//
		}
		*/
		
		public var ServerReceivedCustom:Function;
		private var _moreComArr:Array,_comArr:Array;
		private function ServerReceived(e:ServerSocketManagerEvent):void {
			if(ServerReceivedCustom != null){
				ServerReceivedCustom(e);
			}else{
				//--------------   默认数据处理方式
				var $getString:String = ByteArrayParser.ByteArrayToString(e.data,$.ServerSocketEncode);
				
				//空数据处理
				if($getString == null) return;
				
				var check:String = $getString.substr(-1,1);
				if(check == "|"){
					$getString = $getString.substring(0,$getString.length - 1);
				}
				
				//空数据处理
				if($getString == "") return;
				
				if($getString.search("|") != -1){
					_moreComArr = $getString.split('|');
					var i:int,length:int = _moreComArr.length;
					for(i = 0; i < length; i++){
						
						//空白处理(去掉前后的空白)
						$getString = Aorfuns.trimPro($getString);
						
						//空数据处理
						if($getString == "") return;
						
						_comArr = _moreComArr[i].split(',');
						$.console.dispatchCommand(_comArr.join(' '));
					}
				}else{
					
					//空白处理(去掉前后的空白)
					$getString = Aorfuns.trimPro($getString);
					
					//空数据处理
					if($getString == "") return;
					
					_comArr = $getString.split(',');
					$.console.dispatchCommand(_comArr.join(' '));
				}
			}
		}
		
		//================ socketManager 监听 =================
		/*
		protected function closeHandler(e:SocketManagerEvent):void {
			Aorfuns.log(e.StringData);
		}
		
		protected function connectHandler(e:SocketManagerEvent):void {
			Aorfuns.log(e.StringData);
		}
		
		protected function ioErrorHandler(e:SocketManagerEvent):void {
			Aorfuns.log(e.StringData);
		}
		
		protected function securityErrorHandler(e:SocketManagerEvent):void {
			Aorfuns.log(e.StringData);
		}
		*/
		public var SocketReceivedCustom:Function;
		private var _moreComArrS:Array, _comArrS:Array;
		private function socketDataHandler(e:SocketManagerEvent):void {
			//Aorfuns.log("SocketManager.readResponse: " + e.StringData + ", $bytesAvailable =  " + e.bytesAvailable);

			if(SocketReceivedCustom != null){
				SocketReceivedCustom(e);
			}else{
				//--------------   默认数据处理方式
				var $getString:String = e.StringData;
				
				//空数据处理
				if($getString == null) return;
				
				var check:String = $getString.substr(-1,1);
				if(check == "|"){
					$getString = $getString.substring(0,$getString.length - 1);
				}
				
				if($getString.search("|") != -1){
					_moreComArrS = $getString.split('|');
					var i:int,length:int = _moreComArrS.length;
					for(i = 0; i < length; i++){
						
						//空白处理(去掉前后的空白)
						_moreComArrS[i] = Aorfuns.trimPro(_moreComArrS[i]);
						
						//空数据处理
						if(_moreComArrS[i] == "") return;
						
						if(_moreComArrS[i].search(",") != -1){
							_comArrS = _moreComArrS[i].split(',');
							$.console.dispatchCommand(_comArrS.join(' '));
						}else{
							$.console.dispatchCommand(_moreComArrS[i]);
						}
					}
				}else{
					
					//空白处理(去掉前后的空白)
					$getString = Aorfuns.trimPro($getString);
					
					//空数据处理
					if($getString == "") return;
					
					if($getString.search(",") != -1){
						_comArrS = $getString.split(',');
						$.console.dispatchCommand(_comArrS.join(' '));
					}else{
						$.console.dispatchCommand($getString);
					}
					
				} 
			}
		}
		//--------------------------------- listener ------------------------------
		/*
		private function MsLogic_Click (e:MouseEvent):void {
			//
		}*/
		
		//------------------------------ -----------------------------------------
		
		//---------------------------- core --------------------------------------
		private function awaysFullScreen(e:KeyboardEvent):void {
			if(e.keyCode==Keyboard.ESCAPE){
				if (String($.cfg.fullScreen.forceFullScreen).toLowerCase() == 'true' ? true : false ) {
					e.preventDefault();
				}else{
					fulScnClose();
				}
			}
		}
		private function fullScreenFun(e:FullScreenEvent):void {
			if(!e.fullScreen){
				$.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}
		
		
		private var _loadPageSpeed:Number = 1;
		public function get loadPageSpeed():Number {
			return _loadPageSpeed;
		}
		public function set loadPageSpeed(value:Number):void {
			_loadPageSpeed = value;
		}
		
		
		private var _currentPageCache:DisplayObject;
		public function get currentPage ():DisplayObject {
			return _currentPageCache;
		}
		
		
		public function loadPageClass ($class:Class, $motionType:String = "fi"):void {
			var $newPage:DisplayObject;
			try{
				$newPage = new $class ();
			}catch (err:Error){
				$.console.echo('LogicManger.loadPageClass : can not load this Page by "' + $class + '" Class.');
				return;
			}
			
			if(AorMotion.Instance == null){
				AorMotion.getInstance();
			}
			
			//Object($newPage).main = $;
			
			switch ($motionType){
				case 'ttr':
				case 'translateFormRight':
					AorMotion.Instance.translateFormRight ($.display,_currentPageCache,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'ttl':
				case 'translateFormLeft':
					AorMotion.Instance.translateFormLeft ($.display,_currentPageCache,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'ttt':
				case 'translateFormTop':
					AorMotion.Instance.translateFormTop ($.display,_currentPageCache,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'ttb':
				case 'translateFormBottom':
					AorMotion.Instance.translateFormBottom ($.display,_currentPageCache,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'fi':
				case 'fadein':
					AorMotion.Instance.fadeIN($.display,_currentPageCache,$newPage,_loadPageSpeed,Linear.easeIn,true, $.displayMask);
					break;
				case 'fbi':
				case 'fadeblackin':
					if(_currentPageCache){
						AorMotion.Instance.fadeBlackIN($.display,_currentPageCache,$newPage,_loadPageSpeed,Linear.easeNone,true, $.displayMask);
					}else{
						AorMotion.Instance.fadeIN($.display,_currentPageCache,$newPage,_loadPageSpeed,Linear.easeIn,true, $.displayMask);
					}
					break;
				default:
					if(_currentPageCache){
						AorMotion.Instance.fadeBlackIN($.display,_currentPageCache,$newPage,_loadPageSpeed,Linear.easeNone,true, $.displayMask);
					}else{
						AorMotion.Instance.fadeIN($.display,_currentPageCache,$newPage,_loadPageSpeed,Linear.easeIn,true, $.displayMask);
					}
			}
			_currentPageCache = $newPage;
			
		}
		
		public  function loadPage ($commandStr:String):void {
			
			var $comlist:Array = $commandStr.split(/ /g);
			var $pageIDStr:String = $comlist.shift();
			
			var $pageIDCheck:*,$pageID:int;
			if($pageIDStr == '0'){
				$pageID = 0;
			}else{
				$pageIDCheck = parseInt($pageIDStr);
				if($pageIDCheck){
					$pageID = int($pageIDCheck);
				}else{
					$pageID = -1;
				}
			}
			var $motionType:String = 'null';
			if($comlist.length > 0){
				$motionType = String($comlist.shift());
			}
			
			if($comlist.length > 0){
				_loadPageSpeed = Number($comlist[0]);
			}
			
			//Aorfuns.log("$comlist > " + $comlist + "  |  $pageIDStr > " + $pageIDStr  + "  |  $pageID > " + $pageID);
			
			var $newPage:DisplayObject;
			if($pageID == -1){
				try{
					$newPage = new (Aorfuns.getClass($pageIDStr)) ();
				}catch (err:Error){
					$.console.echo('LogicManger.loadPage : can not load this Page by "' + $pageIDStr + '" keyword.');
					return;
				}
			}else{
				try{
					$newPage = new (Aorfuns.getClass('page' + ValueFormatConver.numToStr($pageID,3))) ();
				}catch (err:Error){
					$.console.echo('LogicManger.loadPage : can not load this Page by "page' + ValueFormatConver.numToStr($pageID,3) + '" keyword.');
					return;
				}
			}
			
			if(AorMotion.Instance == null){
				AorMotion.getInstance();
			}
			
			var $oldPage:DisplayObject = _currentPageCache;
			
			switch ($motionType){
				case 'ttr':
				case 'translateFormRight':
					AorMotion.Instance.translateFormRight ($.display,$oldPage,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'ttl':
				case 'translateFormLeft':
					AorMotion.Instance.translateFormLeft ($.display,$oldPage,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'ttt':
				case 'translateFormTop':
					AorMotion.Instance.translateFormTop ($.display,$oldPage,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'ttb':
				case 'translateFormBottom':
					AorMotion.Instance.translateFormBottom ($.display,$oldPage,$newPage,_loadPageSpeed, Strong.easeOut, true, $.displayMask);
					break;
				case 'fi':
				case 'fadein':
					AorMotion.Instance.fadeIN($.display,$oldPage,$newPage,_loadPageSpeed,Linear.easeIn,true, $.displayMask);
					break;
				case 'fbi':
				case 'fadeblackin':
					if(_currentPageCache){
						AorMotion.Instance.fadeBlackIN($.display,$oldPage,$newPage,_loadPageSpeed,Linear.easeNone,true, $.displayMask);
					}else{
						AorMotion.Instance.fadeIN($.display,$oldPage,$newPage,_loadPageSpeed,Linear.easeIn,true, $.displayMask);
					}
					break;
				default:
					if(_currentPageCache){
						AorMotion.Instance.fadeBlackIN($.display,$oldPage,$newPage,_loadPageSpeed,Linear.easeNone,true, $.displayMask);
					}else{
						AorMotion.Instance.fadeIN($.display,$oldPage,$newPage,_loadPageSpeed,Linear.easeIn,true, $.displayMask);
					}
			}
			_currentPageCache = $newPage;
			$.console.nextCommand();
		}
		
		public var APPExitCustomFunc:Function;
		
		private function APPExitFunc (e:Event = null):void {
			if(APPExitCustomFunc != null){
				APPExitCustomFunc();
			}
		}
		
		//---------------------------- core -----------------------------------end
		
		
		
		
		//-------------------------------------------------------------------------------
		public var ConsoleRecevieCustom:Function;
		private function comReceiveFun(e:AorConsoleEvent):void {
			if(ConsoleRecevieCustom != null){
				ConsoleRecevieCustom(e);
			}else{
				var $comData:String = e.InputData;
				var $comArgs:Array = $comData.split(/ /g);
				$.commandManager.COMParse(AorCommander.decodingCMDSymbolINCOMList($comArgs));
			}
		}
		
		//===================================== tools 方法 ===================================
		
		/**
		 * 工具方法: 应用退出
		 */
		public function AppExit ():void {
			APPExitFunc();
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * 工具方法: 创建TracePanel
		 */
		public function createTracePanel (tracingData:Array, $x:Number = 0, $y:Number = 0, $contentObject:DisplayObjectContainer = null):void {
			
			var $tp:TracePanel = new TracePanel(tracingData);
			$tp.x = $x;
			$tp.y = $y;
			if($contentObject){
				$contentObject.addChild($tp);
			}else{
				$.addChild($tp);
			}
			
		}
		
	}
}class COMNullClass {}