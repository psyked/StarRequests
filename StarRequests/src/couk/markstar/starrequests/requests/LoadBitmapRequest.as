package couk.markstar.starrequests.requests
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import org.osflash.signals.Signal;
	
	public class LoadBitmapRequest extends AbstractRequest
	{
		protected var _loader:Loader;
		protected var _url:String;
		
		public function LoadBitmapRequest( url:String )
		{
			super();
			
			_url = url;
			_completedSignal = new Signal( Bitmap );
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeListener );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
		}
		
		override public function send():void
		{
			super.send();
			_loader.load( new URLRequest( _url ) );
		}
		
		override public function cleanup():void
		{
			_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, completeListener );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
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
			
			_completedSignal.dispatch( Bitmap( _loader.content ) );
			
			attemptAutoCleanup();
		}
		
		protected function ioErrorListener( e:IOErrorEvent ):void
		{
			_failedSignal.dispatch( e.text );
			attemptAutoCleanup();
		}
	}
}