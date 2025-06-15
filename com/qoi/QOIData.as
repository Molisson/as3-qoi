package com.qoi {
	import flash.utils.ByteArray;

	public final class QOIData {
		public static function write( bytes: ByteArray, p: int, v: uint ): void {
			bytes[p + 0] = (0xff000000 & v) >> 24;
			bytes[p + 1] = (0x00ff0000 & v) >> 16;
			bytes[p + 2] = (0x0000ff00 & v) >> 8;
			bytes[p + 3] = (0x000000ff & v);
		};

		public static function read( bytes: ByteArray, p: int ): uint {
			const a: uint = bytes[p + 0];
			const b: uint = bytes[p + 1];
			const c: uint = bytes[p + 2];
			const d: uint = bytes[p + 3];
			return a << 24 | b << 16 | c << 8 | d;
		};
	};
};