# compression
This is a very simple compression program for text files that I wrote. It's based on my understanding of what LZ-compression is. I doubt it's going to be breaking any records for speed or efficiency, but it was a nice small project that I've been putting some time here and there into.

## Usage
`compression files` to compress files.
`compression -d files` to decompress files.
The -d flag can also be added in the middle of the arguments, for example
`compression file1 -d file2` will compress file1 and decompress file2.

## How it works
The program goes through the file byte by byte. When it finds a sequence of bytes similar to one that it has seen before, it creates a "pointer" back to the previous sequence.

A pointer consists of 16 bits. The first 10 bits are the distance to the start of the previous sequence, and the remaining 6 bits are the length of the matched sequence. A null byte is added before each pointer in the compressed file to indicate that the next two bytes are a pointer. This means that if the original file contains a null byte the file will not be possible to decompress.

