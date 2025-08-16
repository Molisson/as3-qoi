package com.qoi {
	public final class QOIColor {
		public var red: uint;
		public var green: uint;
		public var blue: uint;
		public var alpha: uint;

		public function QOIColor( red: uint, green: uint, blue: uint, alpha: uint ) {
			this.red = red;
			this.green = green;
			this.blue = blue;
			this.alpha = alpha;
		};

		public static function hash( color: QOIColor ): int {
			return color.red * 3 + color.green * 5 + color.blue * 7 + color.alpha * 11;
		};
	};
};