package com.qoi {
	public final class QOIColor {
		public var red: int;
		public var green: int;
		public var blue: int;
		public var alpha: int;

		public function QOIColor( red: int, green: int, blue: int, alpha: int ) {
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