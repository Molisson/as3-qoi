package com.qoi {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public final class QOIDecoder {

		public static function decode( data: ByteArray, size: int, header: QOIHeader, channels: int ): BitmapData {

			const bytes: ByteArray = data;
			var header_magic: uint;
			var pixels: ByteArray = new ByteArray();
			var index: Vector.<QOIColor> = new Vector.<QOIColor>( 64, true );
			var pixel: QOIColor = new QOIColor( 0, 0, 0, 255 );
			var pixel_length: int;
			var chunks_length: int;
			var pixel_position: int = 0;
			var p: int = 0;
			var run: int = 0;

			const INDEX_LENGTH: int = 64;
			var i: int = INDEX_LENGTH;
			while ( --i > -1 ) {
				index[i] = new QOIColor( 0, 0, 0, 0 );
			}

			if (
				data === null || header === null ||
				( channels !== 0 && channels !== QOIChannels.RGB && channels !== QOIChannels.RGBA ) ||
				size < QOIHeader.SIZE + 8
			) {
				return null;
			}

			header_magic = QOIData.read( bytes, p );
			p += 4;
			header.width = QOIData.read( bytes, p );
			p += 4;
			header.height = QOIData.read( bytes, p );
			p += 4;
			header.channels = bytes[ p++ ];
			header.colorspace = bytes[ p++ ];

			if (
				header.width === 0 || header.height === 0 ||
				header.channels < QOIChannels.RGB || header.channels > QOIChannels.RGBA ||
				header.colorspace > QOIColorSpace.LINEAR ||
				header_magic !== QOIHeader.MAGIC_BYTES ||
				header.height >= QOIHeader.MAX_PIXELS / header.width
			) {
				return null;
			}

			if ( channels === 0 ) {
				channels = header.channels;
			}

			//  We can't use RGB channels here
			//  So we have to deal with Flash's limitations :(
			pixel_length = header.width * header.height * QOIChannels.RGBA; //  channels;
			pixels.length = pixel_length;

			if ( !pixels ) {
				return null;
			}

			chunks_length = size - 8;

			//  We can't use RGB channels here
			//  So we have to deal with Flash's limitations :(
			for ( ; pixel_position < pixel_length; pixel_position += QOIChannels.RGBA ) {
				if ( run > 0 ) {
					run--;
				}
				else if ( p < chunks_length ) {
					const b1: int = bytes[ p++ ];

					if ( b1 === QOIOp.RGB ) {
						pixel.red      = bytes[ p++ ];
						pixel.green    = bytes[ p++ ];
						pixel.blue     = bytes[ p++ ];
					}
					else if ( b1 === QOIOp.RGBA ) {
						pixel.red      = bytes[p++];
						pixel.green    = bytes[p++];
						pixel.blue     = bytes[p++];
						pixel.alpha    = bytes[p++];
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
						const b2: int = bytes[p++];
						const vg: int = ( b1 & 0x3f ) - 32;
						pixel.red   += vg - 8 + ( ( b2 >> 4 ) & 0x0f );
						pixel.green += vg;
						pixel.blue  += vg - 8 + (   b2        & 0x0f );
					}
					else if ( ( b1 & 0xc0 ) === QOIOp.RUN ) {
						run = ( b1 & 0x3f );
					}

					const pixel_clone: QOIColor = new QOIColor( pixel.red, pixel.green, pixel.blue, pixel.alpha );
					index[QOIColor.hash( pixel_clone ) & (INDEX_LENGTH - 1)] = pixel_clone;
				}

				if ( channels === QOIChannels.RGBA ) {
					pixels[pixel_position + 0] = pixel.alpha;
				}
				
				pixels[pixel_position + 1] = pixel.red;
				pixels[pixel_position + 2] = pixel.green;
				pixels[pixel_position + 3] = pixel.blue;

				//  This will not work because BitmapData uses ARGB, not RGBA.
				//  So we will need to convert it, like above.
				// pixels[pixel_position + 0] = pixel.red;
				// pixels[pixel_position + 1] = pixel.green;
				// pixels[pixel_position + 2] = pixel.blue;

				/* if ( channels === QOIChannels.RGBA ) {
					// pixels[pixel_position + 3] = pixel.alpha;
				} */
			}

			const bitmapData: BitmapData = new BitmapData( header.width, header.height, channels === 4 );
			bitmapData.setPixels( bitmapData.rect, pixels );

			return bitmapData;
		};
	};
};