package licensing {
	import flash.utils.ByteArray;
	
	import org.math.ValueFormatConver;
	import org.units.ByteArrayParser;
	import org.units.EncodeTypeEnu;

	public class LicenseModel {
		
		public static function init (lincense:ByteArray):LicenseModel {
			try{
				var lincenBytes:ByteArray = LicensingCreater.decrypt(lincense);
				var lincenStr:String = ByteArrayParser.ByteArrayToString(lincenBytes,EncodeTypeEnu.UNICODE);
				if(lincenStr && lincenStr != ""){
					var lincenArray:Array = lincenStr.split('@');
					if(lincenArray.length == 6){
						
						var da_min:Array = String(lincenArray[1]).split('-');
						var $minDate:Date = new Date(int(da_min[0]),int(da_min[1]) - 1,int(da_min[2]));
						var da_max:Array = String(lincenArray[2]).split('-');
						var $maxDate:Date = new Date(int(da_max[0]),int(da_max[1]) - 1,int(da_max[2]));
						
						return new LicenseModel(String(lincenArray[0]),$minDate,$maxDate,Number(String(lincenArray[4]).split('=')[1]),(lincenArray[5] == "#unlimted#" ? true : false),(lincenArray[3] == "itsINIT" ? true : false));
					}
				}
			}catch(e:Error){
				trace("LicenseModel.init Error :: 解析出错。");
			}
			return null;
		}
		
		/*
		*	lincenFile 包装结构： 
		*						applicationID@
		* 						2015-07-23@
		*						2015-07-26@
		*						itsINIT@ / itsNormal@
		*						less=123432123543312@
		*						#unlimted# / ##
		*/
		
		public function LicenseModel($applicationID:String,$minDate:Date,$maxDate:Date,$lessTime:Number,$umlimted:Boolean = false, $isInit:Boolean = false) {
			_applicationID = $applicationID;
			_minDate = $minDate;
			_maxDate = $maxDate;
			_less = $lessTime;
			_isUnlimted = $umlimted;
			_isInit = $isInit;
		}
		
		private var _applicationID:String;
		public function get applicationID():String {
			return _applicationID;
		}
		
		private var _minDate:Date;
		public function get minDate():Date {
			return _minDate;
		}
		
		private var _maxDate:Date;
		public function get maxDate():Date {
			return _maxDate;
		}

		private var _isInit:Boolean;
		public function get isInit():Boolean {
			return _isInit;
		}

		private var _isUnlimted:Boolean;
		public function get isUnlimted():Boolean {
			return _isUnlimted;
		}

		private var _less:Number;
		public function get less():Number {
			return _less;
		}
		public function updateLess (subNum:Number):void {
			if(subNum <= 0) return;
			_less = _less - subNum;
		}
		
		public function toString ():String {
			var $s:String = _applicationID + "@";
			$s += _minDate.fullYear + "-" + ValueFormatConver.numToStr(_minDate.month + 1,2) + "-" + _minDate.date + "@";
			$s += _maxDate.fullYear + "-" + ValueFormatConver.numToStr(_maxDate.month + 1,2) + "-" + _maxDate.date + "@";
			$s += (_isInit ? "itsINIT" : "itsNormal") + "@";
			$s += "less=" + _less.toString() + "@";
			$s += (_isUnlimted ? "#unlimted#" : "##");
			return $s;
		}
		
		public function toByteArray ():ByteArray {
			return ByteArrayParser.StringToByteArray(toString(),EncodeTypeEnu.UNICODE);
		}
		
	}
}