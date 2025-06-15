package com.qoi {
    import flash.utils.ByteArray;

    public final class QOIHeader {
        public static const MAX_PIXELS: int = 4e8;
        public static const MAGIC_BYTES: uint = 0x716F6966;
        public static const SIZE: int = 14;

        public var width: uint;
        public var height: uint;
        public var channels: int;
        public var colorspace: int;

        public function QOIHeader( width: uint = 0, height: uint = 0, channels: uint = 0, colorspace: uint = 0 ) {
            this.width = width;
            this.height = height;
            this.channels = channels;
            this.colorspace = colorspace;
        };
    };
};