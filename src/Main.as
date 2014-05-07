package 
{
	import com.adobe.images.PNGEncoder;
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Andrew Efimenko @floxgames
	 */
	public class Main extends Sprite 
	{
		
		private var sizes:Array = [16, 29, 32, 36, 40, 48, 50, 57, 58, 72, 76, 80, 100,114, 120, 128, 144, 152, 512, 1024];
		private var fileToLoad:FileReference;
		private var mLoader:Loader;
		private var sprites:Array = [];
		private var btns:Array = [];
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			fileToLoad = new FileReference();
			fileToLoad.addEventListener(Event.SELECT, onFileSelected);
			fileToLoad.browse();
		}
		
		public function onFileSelected(event:Event):void
		{
			trace("onFileSelected");
			fileToLoad.addEventListener(Event.COMPLETE, onFileLoaded);
			fileToLoad.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			fileToLoad.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			fileToLoad.load();
		}

	    private function progressHandler(event:ProgressEvent):void
		{
			var file:FileReference = FileReference(event.target);
			var percentLoaded:Number=event.bytesLoaded/event.bytesTotal*100;
			trace("loaded: "+percentLoaded+"%");
		}

		public function onFileLoaded(event:Event):void
		{
			var fileReference:FileReference=event.target as FileReference;
			var data:ByteArray=fileReference["data"];
			trace("File loaded");
			mLoader=new Loader();
			mLoader.loadBytes(data);
			mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
		}
		
		public function onFileLoadError(event:Event):void
		{
			trace("File load error");
		}   

		public function onLoaderComplete(event:Event):void
		{
			addChild(mLoader);
			mLoader.x = 200;
			var fileToIco:DisplayObjectContainer = mLoader;
			
			var i:int = 0;
			for each(var s:int in sizes)
			{
				var spr:Sprite = new Sprite();
				var bitm2:Bitmap = new Bitmap(makeSize(fileToIco, s));
				spr.addChild(bitm2);
				spr.graphics.lineStyle(1, 0xFF0000);
				spr.graphics.drawRect(0, 0, spr.width, spr.height);
				spr.x = i * 100;
				var btn:PushButton = addButton(spr, s);
				btn.y = i * btn.height;
				i++;
			}
		}
		
		private function addButton(spr:Sprite, size:int):PushButton 
		{
			var btn:PushButton = new PushButton(this, 0, 0, "icon " + size + "x" + size, onClicks);
			sprites.push(spr);
			btns.push(btn);
			return btn;
		}
		
		private function onClicks(e:Event):void
		{
			var file:FileReference = new FileReference();
			var ind:int = btns.indexOf(e.currentTarget);
			var bmp:BitmapData = ((sprites[ind] as Sprite).getChildAt(0) as Bitmap).bitmapData;
			file.save(PNGEncoder.encode(bmp), "ico_"+sizes[ind] + "x" + sizes[ind] + ".png");
		}
		
		private function makeSize(bitmap:DisplayObjectContainer, size:int):BitmapData
		{
			var result:BitmapData = new BitmapData(size, size, true, 0x00000000);
			var m:Matrix = new Matrix();
			if(bitmap.width < bitmap.height)
				m.scale(size / bitmap.height, size / bitmap.height);
			else
				m.scale(size / bitmap.width, size / bitmap.width);
			result.draw(bitmap, m, null, null, null, true);
			return result;
		}
		
	}
}