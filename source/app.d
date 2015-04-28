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
		if (p[1] != 0) {
			ret ~= 0;
			ret ~= p[0]; 
			ret ~= p[1];
			i += (p[1] & 0x3F) - 1;
		} else {
			ret ~= inb[i];
			map[inb[i]] ~= &inb[i];
		}
	}
	stdio.write(ret);
	return ret;
}

//Takes a ubyte pointer and a an array of ubyte pointer slices (a "map"), then finds the longest
//sequence where the ubytes pointed to in the map match the ubytes pointed to by b
//Returns an array of two ubytes. The 6 lowest bits in the second element is the length of the match
//And the remaining bits are the distance between the match and the given byte.
ubyte[2] testPtr(ubyte*[][255] m, ubyte *b) {
	ubyte[2] longestMatch = [0,0];
	foreach (ubyte *ub; m[*b]) {
		const auto start = b;
		auto length = 0;
		while (*ub++ == *b++) {	
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
	auto c = 0;
	for (int i = 0; i < inb.length; i++) {
		if (inb[i] == 0) {
			const ushort dist = (inb[i+2] >> 6) | (inb[i+1] << 2);
			const auto length = inb[i+2] & 0x3F;
			const auto startl = c-dist;
			for (int j = startl; j < startl+length; j++) {
				ret ~= ret[j];
				c++;
			}
			c++;
			i += 2;
		} else {
			ret ~= inb[i];
			c++;
		}
	}
	return ret;
}