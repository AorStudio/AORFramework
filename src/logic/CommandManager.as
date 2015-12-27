package logic {
	
	import com.command.AorCommander;
	//import com.command.CmdUnit;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	//import flash.utils.describeType;
	
	import entry.AORFWEntry;
	
	import org.basic.Aorfuns;
	
	public class CommandManager extends EventDispatcher {
		
		private static var Instance:CommandManager;
		
		public function get $ ():AORFWEntry {
			return AORFWEntry.$;
		}
		
		private var _commander:AorCommander;
		
		public function CommandManager ($null:DMNullClass = null,target:IEventDispatcher=null) {
			super(target);
			if ($null == null) {
				throw new Error("You cannot instantiate this class directly, please use the static getInstance method.");
				return;
			}//end fun
			_commander = AorCommander.getInstance();
			_commander.addCommandsByReflection(new FrameworkCmds());
		}
		
		/**
		 * 单件实例化
		 */
		public static function getInstance (target:IEventDispatcher=null):CommandManager {
			if (CommandManager.Instance == null) {
				CommandManager.Instance = new CommandManager(new DMNullClass(), target);
			}//end if
			return CommandManager.Instance;
		}//end fun
		
		public function destructor ():void {
			_commander.destructor();
			_commander = null;
		}
		
		/**
		 * 添加一条命令
		 */
		public function addCommand ($alias:String,$comFun:Function, $comTarget:Object = null,$doc:String = "_no_more_info_"):Boolean {
			return _commander.addCommand($alias,$comFun,$comTarget,$doc);
		}
		/**
		 * 删除一条命令
		 */
		public function removeCommand ($alias:String):Boolean {
			return _commander.removeCommand($alias);
		}
		
		/**
		 * 通过对象反射添加命令
		 */
		public function addCommandsByReflection ($Object:Object):void {
			_commander.addCommandsByReflection($Object);
		}
		
		/**
		 * 通过对象反射删除命令
		 */
		public function removeCommandsByReflection ($Object:Object):void {
			_commander.removeCommandsByReflection($Object);
		}
		
		public function COMParse ($comArgs:Array):void {
			if($comArgs == null || $comArgs.length == 0 ){
				$.console.echo('LogicManager.COMParse : no command input !');
				$.console.nextCommand();
				return;
			}
			
			var $alias:String = $comArgs.shift();
			if(!_commander.ExecuteCommand($alias,$comArgs)){
				Aorfuns.log("CommandManager > can not find this command: " + $alias + "\t<inputData:" + $alias + " " + $comArgs.join(" ") + ">");
			}
		}
	}
}
class DMNullClass {}