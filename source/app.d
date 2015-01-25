import std.file;

int main(string[] argv) {
	for (int i = 1; i < argv.length; i++) {
		auto inb = cast(ubyte[]) read(argv[i]);
		auto outb = compress(inb);
		write(argv[i]~".comp", outb);
	}
	return 0;
}

ubyte[] compress(ubyte[] inb) pure {
	ubyte *map[255][];
	ubyte[] ret;
	for (int i = 0; i < inb.length; i++) {
		auto p = testPtr(map, &inb[i]);
		if (p[0] != 0) {
			ret ~= 0;
			ret ~= p[0]; 
			ret ~= p[1];
			i += p[1] & 0x3F;
		} else {
			ret ~= inb[i];
			map[inb[i]] ~= &inb[i];
		}
	}
	return ret;
}

ubyte[2] testPtr(ubyte*[][255] m, ubyte *b) pure {
	ubyte[2] longestMatch = [0,0];
	foreach (ubyte *ub; m[*b]) {
		const auto start = b;
		auto length = 0;
		while (*(ub++) == *(b++)) {
			if (ub == start)
				break;
			length++;
		}
		if (length > 3 && length > (longestMatch[1] & 0x3F) && length < 0x3F) {
			auto dist = b - ub;
			if (dist < 0x3FFF) {
				ushort result = cast(ushort)(dist << 6);
				result |= length;
				longestMatch[1] = result & 0xFF;
				longestMatch[0] = (result & 0xFF00) >> 8;
			}
		}
	}
	return longestMatch;
}