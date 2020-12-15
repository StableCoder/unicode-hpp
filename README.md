# UnicodeHPP

[![pipeline status](https://git.stabletec.com/utilities/unicode-hpp/badges/main/pipeline.svg)](https://git.stabletec.com/utilities/unicode-hpp/commits/main)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://git.stabletec.com/utilities/unicode-hpp/blob/main/LICENSE)

This program builds a quick Unicode header for use in C++11 or higher programs. It lists all unicode blocks, and their starting and ending code points.

Several pre-generated unicode block versions can be found in the generated_headers/ folder.

## Program Arguments:
#### -h, --help
	Help Blurb
#### -blocksize
	Also builds a function for listing each block's size.
#### -f &lt;filename>
	The input file to build the unicode block from.
	Must be an XML from Unicode org, such as from
	http://www.unicode.org/Public/9.0.0/ucdxml/ for 9.0.0
#### -o &lt;out_dir>
	This is the directory where the file unicode_blocks.hpp
	will be written to.

## Generated items (all in 'unicode' namespace)
#### enum class Block 
This enumerates all unicode blocks currently allocated
#### constexpr uint32_t getFirstCodePoint()
This denotes the starting code point for each unicode block.
#### constexpr uint32_t getLastCodePoint()
This denotes the last code point for each unicode block.
#### constexpr uint32_t getBlockSize() [optional]
This gives the size of the allocated code block.

### Used RapidXML from http://rapidxml.sourceforge.net/