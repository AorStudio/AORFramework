//entry::AORFWEntry
package entry {
	
	import com.air.net.ServerSocketManager;
	import com.console.AorConsole;
	import com.net.SocketManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	
	import UI.ContentMask;
	
	import logic.CommandManager;
	import logic.Core;
	
	import org.air.AORFileWorker;
	import org.air.AorAIRbase;
	import org.basic.Aorfuns;
	import org.resize.IReszieChild;
	import org.resize.ResizeHandle;
	import org.template.SpriteTemplate;
	
	/**
	 * AORFrameworkEntry
	 * 
	 */
	//[SWF(frameRate="60",height="1280",width="800",backgroundColor="0x000000")]
	public class AORFWEntry extends SpriteTemplate implements IReszieChild {
		
		public static var FrameworkVersion:String = "PC_1.20";
		
		private static var _main:AORFWEntry;
		/**
		 * 此静态属性提供AORFWEntry的全局调用
		 */
		public static function get $ ():AORFWEntry {
			return AORFWEntry._main;
		}
		
		public function AORFWEntry() {
			// constructor code
			super();
		}
		
		private var _displayMask:ContentMask;
		/**
		 * 组件: display显示层的显示遮罩
		 */
		public function get displayMask():ContentMask {
			return _displayMask;
		}
		
		private var _display:DisplayObjectContainer;
		/**
		 * 组件: 主要显示对象层
		 */
		public function get display():DisplayObjectContainer {
			return _display;
		}
		/**
		 * 组件: UI显示对象层(比display显示层级高) 废弃
		 */
		/*
		private var _UIdisplay:DisplayObjectContainer;
		public function get UIdisplay():DisplayObjectContainer	{
			return _UIdisplay;
		}*/
		
		//private var _topDisplay:DisplayObjectContainer;
		/**
		 * 组件: 顶级显示对象层(比display,UIdisplay显示层级都高) 废弃
		 */
		/*public function get topDisplay():DisplayObjectContainer {
			return _topDisplay;
		}*/
		
		private var _resizeHandle:ResizeHandle;
		/**
		 * 组件: ResizeHandle组件,(全局布局/定位)
		 */
		public function get resizeHandle():ResizeHandle {
			return _resizeHandle;
		}
		
		private var _console:AorConsole;
		/**
		 * 组件: console组件,(控制台,与CommandManager共同组成中间层)
		 */
		public function get console():AorConsole {
			return _console;
		}
		
		private var _socketManager:SocketManager;
		/**
		 * (可配置)组件: socketManager组件,(socket功能实现)
		 */
		public function get socketManager():SocketManager {
			return _socketManager;
		}
		/**
		 * (可配置)组件: ServerSocketManager组件,(socketServer功能实现)
		 */
		private var _socketServerManager:ServerSocketManager;
		public function get socketServerManager():ServerSocketManager {
			return _socketServerManager;
		}
		
		private var _commandManager:CommandManager;
		/**
		 * 组件:commandManager组件(中间层核心)
		 */
		public function get commandManager():CommandManager {
			return _commandManager;
		}
		
		private var _core:Core;
		public function get tools ():Core {
			return _core;
		}
		
		private var _cfg:XML;
		/**
		 * xml配置,(可扩展xml文件,单须保留必要字段信息)
		 */
		public function get cfg():XML {
			return _cfg;
		}
		
		private function initCfg ():void {
			
			_cfg = AORFileWorker.readXMLFile(_configPath);
			
			//Aorfuns.log(_cfg);
			
			if(_cfg == null){
				
				throw new Error("致命错误 > 无法读取appCfg.xml...")
				
			}
		}
		
		private var _bitmapDrawMode:Boolean = false;
		public function get bitmapDrawMode():Boolean {
			return _bitmapDrawMode;
		}
		public function set bitmapDrawMode(value:Boolean):void {
			if(_bitmapDrawMode == value) return;
			_bitmapDrawMode = value;
			BitmapDrawMode(_bitmapDrawMode);
		}
		
		private var _blackSprite:Sprite;
		
		override protected function init ():void {
			AORFWEntry._main = this;
			BS_Entry();
		}
		
		override protected function destructor():void {
			//do nothing.
		}
		
		private var _stage3DMode:Boolean = false;
		public function get stage3DMode():Boolean {
			return _stage3DMode;
		}
		public function set stage3DMode(value:Boolean):void {
			if(_stage3DMode == value) return;
			_stage3DMode = value;
			if(!_stage3DMode){
				if(_bitmapDrawMode){
					if(_displayBitmap){
						_displayBitmap.visible = true;
					}
					_blackSprite.visible = true;
				}else{
					_blackSprite.visible = true;
					//_display.visible = true;
				}
			}else{
				if(_bitmapDrawMode){
					if(_displayBitmap){
						_displayBitmap.visible = false;
					}
					_blackSprite.visible = false;
				}else{
					_blackSprite.visible = false;
					//_display.visible = false;
				}
			}
		}
		
		
		public function resizeHandleMothed ($w:Number = 1, $h:Number = 1, $type:String = 'default'):void {
			
			_blackSprite.width = $w;
			_blackSprite.height = $h;
			
			_displayMask.resizeHandleMothed($w,$h,$type);
			
			_display.x = ($w - _displayMask.width) * 0.5;
			_display.y = ($h - _displayMask.height) * 0.5;
			
			//_UIdisplay.x = _display.x;
			//_UIdisplay.y = _display.y;
			if(_bitmapDrawMode){
				
				if(!_displayBitmap) return;
				
				_displayBitmap.removeEventListener(Event.ENTER_FRAME, bitmapDrawLoop);
				removeChild(_displayBitmap);
				_displayBitmap.bitmapData.dispose();
				//var $oldbd:BitmapData = _displayBitmap.bitmapData.clone();
				
				
				
				_displayBitmap = new Bitmap(new BitmapData(_displayMask.width,_displayMask.height,true,0x000000),"auto",true);
				//_displayBitmap.bitmapData.copyPixels($oldbd,new Rectangle(0,0,$oldbd.width,$oldbd.height),new Point());
				addChildAt(_displayBitmap,1);
				_displayBitmap.addEventListener(Event.ENTER_FRAME, bitmapDrawLoop);
				
				//$oldbd.dispose();
				//$oldbd = null;
			}
			
		}
		
		private var _configPath:String = 'config/appCfg.xml';
		/**
		 * 用于设置config.xml的读取地址，默认为'config/appCfg.xml'
		 */
		public function get configPath():String {
			return _configPath;
		}
		public function set configPath(value:String):void {
			_configPath = value;
		}
		
		/**
		 * 获取当前装载的页面对象
		 */
		public function get currentPage ():DisplayObject {
			return _core.currentPage;
		}
		/**
		 * 获取当前装载的页面对象(Object形式)
		 */
		public function get cp ():Object {
			return _core.currentPage as Object;
		}
		
		private var _ServerSocketEncode:String;
		public function get ServerSocketEncode():String {
			return _ServerSocketEncode;
		}
		
		private var _socketEncode:String;
		public function get socketEncode():String {
			return _socketEncode;
		}
		
		public function get enabledFullScreenAways():Boolean {
			if(_core) return _core.enabledFullScreenAways;
			return false;
		}
		public function set enabledFullScreenAways(value:Boolean):void {
			if(_core) _core.enabledFullScreenAways = value;
		}
		
		private var _entryEcho:TextField;
		
		private var _displayBitmap:Bitmap;
		
		public function EntryStart ($pageClassName:String = null):void {
			
			_entryEcho = new TextField();
			_entryEcho.name = "entryEcho_mc";
			_entryEcho.width = stage.stageWidth;
			_entryEcho.height = stage.stageHeight;
			_entryEcho.wordWrap = true;
			_entryEcho.mouseEnabled = false;
			_entryEcho.text = "loading ....";
			addChild(_entryEcho);
			
			_entryEcho.text += 'OS : ' + Capabilities.os + '\n';
			
			initCfg();
			
			if(!_cfg){
				Aorfuns.log('Can not read appCfg.xml .. APP is shutdown!');
				_entryEcho.text = 'Can not read appCfg.xml .. APP is shutdown!';
				return;
			}
			
			if($pageClassName){
				_firstLoadPage = $pageClassName;
			}
			
			_entryEcho.text += "firstLoadPage is " + _firstLoadPage + "\n";
			
			_ServerSocketEncode = String(_cfg.network.server.encodeType);
			_socketEncode = String(_cfg.network.socket.encodeType);
			
			var $airBaseListener:AorAIRbase = AorAIRbase.getInstance(this);
			Aorfuns.log('\r\n' + $airBaseListener.checkNativeApplicationSupports());
			$airBaseListener.DeactivateFunc = BS_DeactivateFunc;
			$airBaseListener.ActivateFunc = BS_ActivateFunc;
			$airBaseListener.start();
			
			_resizeHandle = ResizeHandle.getInstance(this.stage, Number(_cfg.resize.min.width), Number(_cfg.resize.min.height), Number(_cfg.resize.max.width), Number(_cfg.resize.max.height));
			_resizeHandle.start();
			
			_entryEcho.text += "resizeHandle start!\n";
			
			_commandManager = CommandManager.getInstance(this);
			
			var $ip:String;
			var $port:uint;
			
			if((String(_cfg.module.SocketManager).toLowerCase() == 'true' ? true : false)){
				$ip = String(_cfg.network.socket.ip);
				$port = uint(_cfg.network.socket.port);
				_socketManager = new SocketManager( $ip,$port,_socketEncode);
			}
			
			if((String(_cfg.module.ServerSocketManager).toLowerCase() == 'true' ? true : false)){
				$ip = String(_cfg.network.server.ip);
				$port = uint(_cfg.network.server.port);
				var $checkTime:int = int(_cfg.network.server.checkClientTime);
				_socketServerManager = new ServerSocketManager($ip,$port,$checkTime,_ServerSocketEncode);
			}
			_blackSprite = new Sprite();
			_blackSprite.name = 'BBg_mc';
			Aorfuns.setDOCInteractvie(_blackSprite);
			_blackSprite.graphics.beginFill(0x000000,1);
			_blackSprite.graphics.drawRect(0,0,800,800);
			_blackSprite.graphics.endFill();
			addChild(_blackSprite);
			
			_display = new Sprite();
			_display.name = 'display_mc';
			Aorfuns.setDOCInteractvie(_display,false,false,true,true);
			addChild(_display);
			
			_displayMask = new ContentMask();
			_displayMask.name = '_displayMask_mc';
			Aorfuns.setDOCInteractvie(_displayMask);
			addChild(_displayMask);
			
			_display.mask = _displayMask;
			/*
			_UIdisplay = new Sprite();
			_UIdisplay.name = 'UIdisplay_mc';
			Aorfuns.setDOCInteractvie(_UIdisplay,false,false,true,true);
			addChild(_UIdisplay);
			*/
			/*
			_topDisplay = new Sprite();
			_topDisplay.name = 'topDisplay_mc';
			Aorfuns.setDOCInteractvie(_topDisplay,false,false,true,true);
			addChild(_topDisplay);
			*/
			
			addChild(_entryEcho);
			
			_resizeHandle.addResizeChild(this);
			
			_console = AorConsole.getInstance(true,true);
			addChild(_console);
			_resizeHandle.addResizeChild(_console);
			
			_core = Core.getInstance();
			
			//框架核心启动
			_core.start(AS_Init);
			
			//位图渲染模式
			//removeChild(_displayMask);
			//removeChild(_display);
			if(_bitmapDrawMode){
				BitmapDrawMode(_bitmapDrawMode);
			}
			
		}
		
		private function BitmapDrawMode ($switch:Boolean):void {
			if(!_display) return;
			if($switch){
				//_display.visible = false;
				removeChild(_display);
				_displayBitmap = new Bitmap(new BitmapData(_displayMask.width,_displayMask.height,true,0x000000),"auto",true);
				addChildAt(_displayBitmap,1);
				_displayBitmap.addEventListener(Event.ENTER_FRAME, bitmapDrawLoop);
			}else{
				//_display.visible = true;
				addChildAt(_display,1);
				_displayBitmap.removeEventListener(Event.ENTER_FRAME, bitmapDrawLoop);
				removeChild(_displayBitmap);
				_displayBitmap.bitmapData.dispose();
				_displayBitmap = null;
			}
		}
		
		private function bitmapDrawLoop (e:Event):void {
			_displayBitmap.bitmapData.draw(_display,null,null,null,new Rectangle(0,0,_displayBitmap.bitmapData.width,_displayBitmap.bitmapData.height),true);
		}
		
		private var _firstLoadPage:String;
		public function get firstLoadPage():String {
			return _firstLoadPage;
		}
		
		/**
		 * 框架执行初始化初始化之前的行为扩展
		 * 重要提示:如果此方法为被调用,则框架默认执行EntryStart方法初始化框架
		 */
		protected function BS_Entry():void {
			EntryStart();
		}
		
		/**
		 * 框架执行初始化初始化之后的行为扩展
		 */
		protected function AS_Init():void {
			//
		}
		
		/**
		 * 应用不在激活状态时会调用该方法 （IOS无效）
		 */
		protected function BS_DeactivateFunc():void {
			//Aorfuns.log ('This app is Deactivate !');
		}
		
		/**
		 * 应用从非激活状态切换回激活状态时调用（IOS无效）
		 */
		protected function BS_ActivateFunc():void {
			//Aorfuns.log ('This app is Activate  !');
		}
		
		/**
		 * 工具方法: 注册未在项目中引用的类,(防止Flash Builder在编译时未将这些动态类编译入应用)
		 * $UnreferencedClasses : 一个数组,表示一系列的Class的集合
		 */
		public function regisUnreferencedClasses ($UnreferencedClasses:Array):void {
			//注册未在项目中引用的类，防止Flash Builder在编译时未将这些动态类编译入应用。
			if($UnreferencedClasses){
				var $length:int = $UnreferencedClasses.length;
				for (var i:int = 0; i < $length; i++ ){
					$UnreferencedClasses[i];
				}
			}
		}
		
	}
	
}

