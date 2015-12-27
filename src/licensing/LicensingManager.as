//licensing::LincensManager
package licensing {
	
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.air.AORFileWorker;
	import org.air.enu.RWLOCEnu;
	
	public class LicensingManager {
		/*
		public function PCLicensingManager() {
			
		}*/
		
		private static var _callbackFunc:Function;
		private static var _lockFunc:Function;
		
		private static var _lincenFilePath:String;
		private static var _lincense:LicenseModel;
		
		public static function get less ():Number {
			if(_lincense){
				return _lincense.less;
			}
			return 0;
		}

		public static function init ($lincenFilePath:String,$key:String,$callbackFunc:Function,$lockFunc:Function):void {
			_callbackFunc = $callbackFunc;
			_lockFunc = $lockFunc;
			
			LicensingCreater.initDES($key);
			
			_lincenFilePath = $lincenFilePath;
			
			//加载 lincenFile 
			var lincen:ByteArray;
			
			if(!AORFileWorker.exists(_lincenFilePath,RWLOCEnu.APPLICATION)){
				_lockFunc();
				return;
			}else{
				_lincense = LicensingCreater.verifyLincense(LicenseModel.init(AORFileWorker.readBinaryFile(_lincenFilePath, RWLOCEnu.APPLICATION)));
			}
			
			if(_lincense){
				startTimer();
				_callbackFunc();
			}else{
				_lockFunc();
			}
			
		}
		private static var _intervalTimer:Timer;
		
		private static var _runTime:int;
		private static function startTimer ():void {
			_runTime = getTimer();
			//_less = _less - _runTime;
			_lincense.updateLess(_runTime);
			
			makeFile();
			
			if(!_intervalTimer){
				_intervalTimer = new Timer(10000);
				_intervalTimer.addEventListener(TimerEvent.TIMER, intervalTimerDo);
				_intervalTimer.start();
			}
		}
		
		private static function stopTimer ():void {
			if(_intervalTimer){
				_intervalTimer.removeEventListener(TimerEvent.TIMER, intervalTimerDo);
				_intervalTimer.reset();
				_intervalTimer = null;
			}
		}
		
		private static function intervalTimerDo (e:TimerEvent):void {
			_lincense.updateLess(getTimer() - _runTime);
			_runTime = getTimer();
			
			makeFile();
			
			if(_lincense.less < 0){
				stopTimer();
				_lockFunc();
			}
			
		}
		
		private static function makeFile ():void {
			AORFileWorker.writeBinaryFile(_lincenFilePath,LicensingCreater.encrypt(_lincense.toByteArray()),RWLOCEnu.APPLICATION);
		}
		
		public static function info ():String {
			if(_lincense == null) return "can not find Lincese Data.";
			
			var out:String = "";
			if(_lincense.isUnlimted){
				out += "LicnsingType : Unlimted";
			}else{
				var days:int = _lincense.less / (1000 * 60 * 60 * 24);
				var hours:int = (_lincense.less % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60);
				var minutes:int = (_lincense.less % (1000 * 60 * 60)) / (1000 * 60);
				var seconds:int = (_lincense.less % (1000 * 60)) / 1000;
				out += "LicnsingType : limted , lessTime : " +  days + "days," + hours + "hours," + minutes + "minutes," + seconds + "seconds";
			}
			return out;
		}
		
		
		
	}
}