package {
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import com.qoi.QOIDecoder;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;

	public final class Main extends Sprite {

		public function Main(): void {
			super();

			this.mouseChildren = false;
			this.mouseEnabled = false;

			const sample_qoi: ByteArray = new sample();

			const bitmapData: BitmapData = QOIDecoder.decode( sample_qoi );

			const bitmap: Bitmap = new Bitmap( bitmapData, PixelSnapping.AUTO, true );
			bitmap.x = bitmap.width >> 2;
			bitmap.y = bitmap.height >> 1;

			this.addChild( bitmap );
		};
	};
}