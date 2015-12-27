//licensing::LincensBuilder
package licensing {
	
	import com.crypto.DES;
	
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	import org.air.AORFileWorker;
	import org.air.enu.RWLOCEnu;
	import org.basic.Aorfuns;
	import org.units.ByteArrayParser;
	import org.units.EncodeTypeEnu;

	public class LicensingCreater {
		
		private static var _des:DES;
		
		/***
		 * 这个方法有问题，导致语句不执行，且没有错误
		 */
		public static function initDES ($key:String):void {
			
			if(_des){
				_des = null;
			}
			
			var keyBytes:ByteArray = ByteArrayParser.StringToByteArray($key,EncodeTypeEnu.UNICODE);
			
			//Aorfuns.log("LicensingCreater.initDES :: keyBytes.length = " + keyBytes.length + " , keyBytes.position = " + keyBytes.position + " , $key = " + $key);
			if(keyBytes.length > 8){
				Aorfuns.log("LicensingCreater.initDES :: keyBytes.length > 8 !");
				throw new Error("LicensingCreater.initDES :: keyBytes.length > 8 !");
				return;
			}
			
			var $des:DES = new DES(keyBytes);
			_des = $des;
			
		}
		
		public static function decrypt (bytes:ByteArray):ByteArray {
			if(_des){
				return _des.decrypt(bytes);
			}
			return null;
		}
		
		public static function encrypt (bytes:ByteArray):ByteArray {
			if(_des){
				return _des.encrypt(bytes);
			}
			return null;
		}
		
		public static function initDESByBitmap ($bd:BitmapData):void {
			
		}
		
		public static function verifyLincense ($lm:LicenseModel):LicenseModel {
			
			if($lm){
			
				if($lm.applicationID != NativeApplication.nativeApplication.applicationID){
					return null;
				}
				
				if($lm.isUnlimted){
					return $lm;
				}else{
					
					var now:Date = new Date();
					if((now.time < $lm.minDate.time) || (now.time > $lm.maxDate.time)){
						return null;
					}
					
					if($lm.isInit){
						var newLess:Number = $lm.maxDate.time - now.time;
						newLess = ($lm.less > newLess ? newLess : $lm.less);
	
						return new LicenseModel($lm.applicationID,$lm.minDate,$lm.maxDate,newLess,$lm.isUnlimted);
						
					}else{
						if($lm.less < 0){
							return null;
						}else{
							return $lm;
						}
					}
				}
			} 
			return null;
		}
		
		//------------------------------------------- core -------------------------------------------------

		
		//------------------------------------------- core ----------------------------------------------end
		/**
		 * 创建Lincense ByteArray
		 */
		public static function createLincense ($applicationID:String,$minDateStr:String,$maxDateStr:String,$lessTime:Number,$umlimted:Boolean = false, $isInit:Boolean = false):ByteArray {
			
			if(_des){
			
				var da_min:Array = $minDateStr.split('-');
				var $minDate:Date = new Date(int(da_min[0]),int(da_min[1]) - 1,int(da_min[2]));
				var da_max:Array = $maxDateStr.split('-');
				var $maxDate:Date = new Date(int(da_max[0]),int(da_max[1]) - 1,int(da_max[2]));
				
				var $lm:LicenseModel = new LicenseModel($applicationID,$minDate,$maxDate,$lessTime,$umlimted,$isInit);
				
				return encrypt($lm.toByteArray());
			
			}
			
			throw new Error("DES not init yet.");
			
			return null;
		}
		
		/**
		 * 在指定path创建一个初始化LicenseFile
		 */
		public static function buildLicenseIntoFile ($lincenFilePath:String,$applicationID:String,$minDateStr:String,$maxDateStr:String,$lessTime:Number,$umlimted:Boolean = false, $isInit:Boolean = false,isMobile:Boolean = false):void {
			
			var $nb:ByteArray = createLincense($applicationID,$minDateStr,$maxDateStr,$lessTime,$umlimted,$isInit);
			
			AORFileWorker.writeBinaryFile($lincenFilePath,$nb,(isMobile ? RWLOCEnu.STORAGE : RWLOCEnu.APPLICATION));
			
			Aorfuns.log("LicensingBuilder.buildLicenseFile >> " + $lincenFilePath + " in " + (isMobile ? "STORAGE" : "APPLICATION") + " done !");
			
		}
		
	}
}