package com.qoi {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public final class QOIDecoder {

		private static const INDEX_LENGTH: int = 64;

		private static function decodePixels( bytes: ByteArray, header: QOIHeader, index: Vector.<QOIColor>, pixels: ByteArray, size: uint ): void {
			var pixel: QOIColor;
			var pixel_clone: QOIColor;

			var pixel_position: int = 0;
			var pixel_length: int = pixels.length;
			var channels: int = header.channels;
			var chunks_length: int = size - 8;
			var position: uint = bytes.position;
			var run: uint = 0;
			var b1: uint = 0;
			var b2: uint = 0;
			var vg: uint = 0;

			//  RGB or RGBA -> ARGB
			for ( ; pixel_position < pixel_length; pixel_position += QOIChannels.RGBA ) {
				if ( run > 0 ) {
					run--;
				}
				else if ( position < chunks_length ) {
					b1 = bytes.readUnsignedByte();

					if ( b1 === QOIOp.RGB ) {
						pixel.red      = bytes.readUnsignedByte();
						pixel.green    = bytes.readUnsignedByte();
						pixel.blue     = bytes.readUnsignedByte();
					}
					else if ( b1 === QOIOp.RGBA ) {
						pixel.red      = bytes.readUnsignedByte();
						pixel.green    = bytes.readUnsignedByte();
						pixel.blue     = bytes.readUnsignedByte();
						pixel.alpha    = bytes.readUnsignedByte();
					}
					else if ( ( b1 & 0xc0 ) === QOIOp.INDEX ) {
						pixel = index[b1];
					}
					else if ( ( b1 & 0xc0 ) === QOIOp.DIFF ) {
						pixel.red   += ( ( b1 >> 4 )  & 0x03 ) - 2;
						pixel.green += ( ( b1 >> 2 )  & 0x03 ) - 2;
						pixel.blue  += (   b1         & 0x03 ) - 2;
					}
					else if ( ( b1 & 0xc0 ) === QOIOp.LUMA ) {
						b2 = bytes.readUnsignedByte();
						vg = ( b1 & 0x3f ) - 32;
						pixel.red   += vg - 8 + ( ( b2 >> 4 ) & 0x0f );
						pixel.green += vg;
						pixel.blue  += vg - 8 + (   b2        & 0x0f );
					}
					else if ( ( b1 & 0xc0 ) === QOIOp.RUN ) {
						run = ( b1 & 0x3f );
					}

					pixel_clone = new QOIColor( pixel.red, pixel.green, pixel.blue, pixel.alpha );
					index[QOIColor.hash( pixel_clone ) & (INDEX_LENGTH - 1)] = pixel_clone;
					
					position = bytes.position;
				}

				if ( channels === QOIChannels.RGBA ) {
					pixels[pixel_position + 0] = pixel.alpha;
				}
				
				pixels[pixel_position + 1] = pixel.red;
				pixels[pixel_position + 2] = pixel.green;
				pixels[pixel_position + 3] = pixel.blue;
			};
		};

		public static function decode( bytes: ByteArray ): BitmapData {

			const size: uint = bytes.length;
			const header: QOIHeader = new QOIHeader();
			var header_magic: uint = 0;
			var pixels: ByteArray = new ByteArray();
			var index: Vector.<QOIColor> = new Vector.<QOIColor>( INDEX_LENGTH, true );

			var i: int = INDEX_LENGTH;
			while ( --i > -1 ) {
				index[i] = new QOIColor( 0, 0, 0, 0 );
			}

			if (
				bytes === null ||
				size < QOIHeader.SIZE + 8
			) {
				return null;
			}

			header_magic = bytes.readUnsignedInt();
			header.width = bytes.readUnsignedInt();
			header.height = bytes.readUnsignedInt();
			header.channels = bytes.readByte();
			header.colorspace = bytes.readByte();

			if (
				header.width === 0 || header.height === 0 ||
				header.channels < QOIChannels.RGB || header.channels > QOIChannels.RGBA ||
				header.colorspace > QOIColorSpace.LINEAR ||
				header_magic !== QOIHeader.MAGIC_BYTES ||
				header.height >= QOIHeader.MAX_PIXELS / header.width
			) {
				return null;
			}

			//  RGB or RGBA -> ARGB
			pixels.length = header.width * header.height * QOIChannels.RGBA;

			if ( !pixels ) {
				return null;
			}

			QOIDecoder.decodePixels( bytes, header, index, pixels, size );

			const bitmapData: BitmapData = new BitmapData( header.width, header.height, header.channels === 4 );
			bitmapData.setPixels( bitmapData.rect, pixels );

			return bitmapData;
		};
	};
};