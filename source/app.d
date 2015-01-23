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
	ubyte *map[][255];
	ubyte[] ret;
	for (int i = 0; i < inb.length; i++) {
		auto p = testPtr(map, &inb[i]);
		if (p[0] != 0) {
			ret ~= 0;
			ret ~= p[0]; 
			ret ~= p[1];
		} else {
			
		}
	}
	return ret;
}

ubyte[2] testPtr(ubyte*[255][] m, ubyte *b) pure {
	ubyte[2] longestMatch = [0,0];
	foreach (ubyte *ub; m[*b]) {
		auto length = 0;
		while (*(ub++) == *(b++)) {
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