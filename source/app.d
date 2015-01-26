import file = std.file;
import stdio = std.stdio;

int main(string[] argv) {
	if (argv[1] == "decompress") {
		for (int i = 2; i < argv.length; i++) {
			auto inb = cast(ubyte[]) file.read(argv[i]);
			auto outb = decompress(inb);
			file.write(argv[i]~".decomp", outb);
		}
	} else {
		for (int i = 1; i < argv.length; i++) {
			auto inb = cast(ubyte[]) file.read(argv[i]);
			auto outb = compress(inb);
			file.write(argv[i]~".comp", outb);
		}
	}
	return 0;
}

ubyte[] compress(ubyte[] inb) {
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

ubyte[2] testPtr(ubyte*[][255] m, ubyte *b) {
	ubyte[2] longestMatch = [0,0];
	foreach (ubyte *ub; m[*b]) {
		const auto start = b;
		auto length = 0;
		while (*ub++ == *b++) {
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

ubyte[] decompress(ubyte[] inb) {
	ubyte[] ret;
	for (int i = 0; i < inb.length; i++) {
		if (inb[i] == 0) {
			const ushort dist = (inb[i+2] >> 6) | (inb[i+1] << 2);
			stdio.writef("%d", dist);
			const auto length = inb[i+2] & 0x3F;
			const auto startl = i-dist;
			stdio.writef("%d", startl);
			for (int j = startl; j < startl+length; j++) {
				ret ~= inb[j];
			}
		} else {
			ret ~= inb[i];
		}
	}
	return ret;
}