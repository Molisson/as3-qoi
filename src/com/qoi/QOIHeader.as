package com.qoi {

    public final class QOIHeader {
        public static const MAX_PIXELS: int = 4e8;
        public static const MAGIC_BYTES: uint = 0x716F6966;
        public static const SIZE: int = 14;

        public var width: uint;
        public var height: uint;
        public var channels: int;
        public var colorspace: int;
    };
};