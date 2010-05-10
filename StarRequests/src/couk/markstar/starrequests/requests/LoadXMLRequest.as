package couk.markstar.starrequests.requests
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;
	
	public class LoadXMLRequest extends AbstractRequest
	{
		protected var _loader:URLLoader;
		protected var _url:String;
		
		public function LoadXMLRequest( url:String )
		{
			super();
			
			_url = url;
			_completedSignal = new Signal( XML );
			
			_loader = new URLLoader();
			_loader.addEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.addEventListener( Event.COMPLETE, completeListener );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorListener );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
		}
		
		override public function send():void
		{
			super.send();
			_loader.load( new URLRequest( _url ) );
		}
		
		override public function cleanup():void
		{
			_loader.removeEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.removeEventListener( Event.COMPLETE, completeListener );
			_loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorListener );
			_loader.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
			_loader = null;
			_url = null;
		
		}
		
		protected function progressListener( e:ProgressEvent ):void
		{
			_progressSignal.dispatch( e.bytesLoaded / e.bytesTotal );
		}
		
		protected function completeListener( e:Event ):void
		{
			_progressSignal.dispatch( 1 );
			
			// try..catch needed to check for valid XML.
			try
			{
				var xml:XML = new XML( e.currentTarget.data );
				_completedSignal.dispatch( xml );
			}
			catch( e:Error )
			{
				_failedSignal.dispatch( e.message.toString() );
			}
			attemptAutoCleanup();
		}
		
		protected function securityErrorListener( e:SecurityErrorEvent ):void
		{
			_failedSignal.dispatch( e.text );
			attemptAutoCleanup();
		}
		
		protected function ioErrorListener( e:IOErrorEvent ):void
		{
			_failedSignal.dispatch( e.text );
			attemptAutoCleanup();
		}
	}
}