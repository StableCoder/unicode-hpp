/*
 *  MIT License
 *
 *  Copyright (c) 2017-2018 George Cave - gcave@stablecoder.ca
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 */

// RapidXML
#include <rapidxml-1.13/rapidxml.hpp>

// C++
#include <algorithm>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>
#include <locale>
#include <string>
#include <vector>

struct Unicode_block_data {
    std::string name;
    uint32_t start;
    uint32_t end;
};

const char *description_str =
    "/*  This header was auto-generated by the UnicodeHPP (Unicode C++ Header Generator)\n"
    " *  that is located at https://github.com/stablecoder/unicode-hpp or\n"
    " *  https://git.stabletec.com/utilities/unicode-hpp\n"
    " *\n"
    " *  Check for an updated version anytime, or state concerns/bugs.\n"
    " */\n";

const char *help_str =
    "This program builds a quick Unicode header for use in C++11 or\n"
    "higher programs. It lists all unicode blocks, and their starting\n"
    "and ending code points."
    "\nProgram Arguments:"
    "\n    -h, --help      : Help Blurb"
    "\n    -b, --blocksize : Also builds a function enumerating each block's size, rather"
    "\n                      than calculating it."
    "\n    -f <filename>   : The input file to build the unicode block from."
    "\n                      Must be an XML from Unicode org, such as from"
    "\n                      http://www.unicode.org/Public/9.0.0/ucdxml/ for 9.0.0"
    "\n    -o <out_dir>    : This is the directory where the file unicode_blocks_#.hpp"
    "\n                      will be written to.";

int main(int argc, const char **argv) {
    std::string input_file = "";
    std::string output_dir = "./";
    bool include_block_size = false;

    // Run through the args
    for (int idx = 0; idx < argc; ++idx) {
        if (strcmp(argv[idx], "--help") == 0 || strcmp(argv[idx], "-h") == 0) {
            // Spit out the help
            std::cout << help_str << std::endl;
            return 0;
        }
        if (strcmp(argv[idx], "--blocksize") == 0 || strcmp(argv[idx], "-b") == 0) {
            include_block_size = true;
        }
        if (strcmp(argv[idx], "-f") == 0) {
            if (idx + 1 <= argc) {
                input_file = argv[idx + 1];
            }
        }
        if (strcmp(argv[idx], "-o") == 0) {
            if (idx + 1 <= argc) {
                output_dir = argv[idx + 1];
            }
        }
    }

    if (input_file == "") {
        std::cerr << "Error: No input file given. Type --help for help." << std::endl;
        return 1;
    }

    // In order to parse a file, we need to load the whole thing into memory.
    std::ifstream in_file(input_file.c_str(), std::ifstream::in);
    if (!in_file.is_open()) {
        std::cerr << "Error: Failed to open file " << input_file << std::endl;
        return 1;
    }
    // Seek to the end.
    in_file.seekg(0, std::ifstream::end);
    // Tell us how many chars to set aside.
    std::size_t fileSize = in_file.tellg();

    // Create a buffer large enough to hold the whole file.
    char *unicode_file = new char[fileSize];

    // Seek back the beginning
    in_file.seekg(0, std::ifstream::beg);

    // Read in the file.
    in_file.read(unicode_file, fileSize);

    // We're done with the raw file now.
    in_file.close();

    // Begin the XML parsing.
    rapidxml::xml_document<> unicode_doc;
    unicode_doc.parse<0>(unicode_file);

    // Only base-level node should be <ucd>
    rapidxml::xml_node<> *ucdNode = unicode_doc.first_node("ucd");
    if (ucdNode == nullptr) {
        std::cerr << "Error: No <ucd> base-level tag found. Invalid Unicode Block XML file."
                  << std::endl;
        return 1;
    }

    /// Get the Unicode Version
    std::string unicode_vers = "";
    rapidxml::xml_node<> *descriptionNode = ucdNode->first_node("description");
    unicode_vers = descriptionNode->value();

    std::cout << "Parsing Unicode Version " << unicode_vers << std::endl;

    // Format the version number
    std::replace(unicode_vers.begin(), unicode_vers.end(), '.', '_');
    unicode_vers = unicode_vers.substr(unicode_vers.find_last_of(' ') + 1);

    // Search for Blocks
    rapidxml::xml_node<> *blockNode = ucdNode->first_node("blocks");
    if (blockNode == nullptr) {
        std::cerr << "Error: No Unicode Blocks described in file." << std::endl;
        return 1;
    }

    /// Collect Block Data
    std::vector<Unicode_block_data> unicode_blocks;

    rapidxml::xml_node<> *block_data_node = blockNode->first_node();
    while (true) {
        Unicode_block_data data;
        data.name = block_data_node->first_attribute("name")->value();
        data.start = strtol(block_data_node->first_attribute("first-cp")->value(), NULL, 16);
        data.end = strtol(block_data_node->first_attribute("last-cp")->value(), NULL, 16);

        unicode_blocks.push_back(data);

        if (block_data_node != blockNode->last_node()) {
            block_data_node = block_data_node->next_sibling();
        } else {
            break;
        }
    }

    // All done, free the file data.
    delete[] unicode_file;

    /// Write Header
    // Now we proceed forward.
    if (output_dir[output_dir.size() - 1] != '/' && output_dir[output_dir.size() - 1] != '\\') {
        output_dir += '/';
    }

    std::ofstream out_file(output_dir + "unicode_blocks_" + unicode_vers + ".hpp",
                           std::ofstream::out);
    if (!out_file.is_open()) {
        std::cerr << "Error: Failed to open header for writing: " << output_dir << "unicode_blocks_"
                  << unicode_vers << ".hpp";
        return 1;
    }

    // First, write the license disclaimer.
    out_file << description_str;

    // Next, the definition lines.
    out_file << "\n\n#ifndef UNICODE_BLOCKS_HPP\n"
             << "#define UNICODE_BLOCKS_HPP" << std::endl;

    // Headers
    out_file << "\n#include <cstdint>";

    // namespace
    out_file << "\n\nnamespace unicode {";

    // Set the Unicode Version String
    out_file << "\n\n// The Unicode Version this is based on.\nconst char* version_str = \""
             << unicode_vers << "\";";

    // Set the Unicode Block Enums
    out_file << "\n\nenum class Block : uint32_t {";
    for (auto iter = unicode_blocks.begin(); iter != unicode_blocks.end(); ++iter) {
        // For each block, replace spaces and dashes with underscores.
        std::replace(iter->name.begin(), iter->name.end(), ' ', '_');
        std::replace(iter->name.begin(), iter->name.end(), '-', '_');

        // Now, write the enum name out.
        out_file << "\n    " << iter->name << ',';
    }
    out_file << "\n};";

    // Now we build the unicode block start function
    out_file << std::hex << std::uppercase;
    out_file << "\n\nconstexpr uint32_t getFirstCodePoint(Block unicode_block) {";
    out_file << "\n    switch(unicode_block) {";
    for (auto iter = unicode_blocks.begin(); iter != unicode_blocks.end(); ++iter) {
        out_file << "\n        case Block::" << iter->name << " :";
        out_file << "\n            return 0x" << iter->start << ';';
    }
    out_file << "\n    }";
    out_file << "\n}";

    // Now we build the Unicode block end function
    out_file << "\n\nconstexpr uint32_t getLastCodePoint(Block unicode_block) {";
    out_file << "\n    switch(unicode_block) {";
    for (auto iter = unicode_blocks.begin(); iter != unicode_blocks.end(); ++iter) {
        out_file << "\n        case Block::" << iter->name << " :";
        out_file << "\n            return 0x" << iter->end << ';';
    }
    out_file << "\n    }";
    out_file << "\n}";

    if (include_block_size) {
        // Only add block size enumeration if requested.
        out_file << std::dec;
        out_file << "\n\nconstexpr uint32_t getBlockSize(Block unicode_block) {";
        out_file << "\n    switch(unicode_block) {";
        for (auto iter = unicode_blocks.begin(); iter != unicode_blocks.end(); ++iter) {
            out_file << "\n        case Block::" << iter->name << " :";
            out_file << "\n            return " << (iter->end - iter->start + 1) << ';';
        }
        out_file << "\n    }";
        out_file << "\n}";
    } else {
        // just give the basic calculating function instead.
        out_file << "\n\nconstexpr uint32_t getBlockSize(Block unicode_block) {";
        out_file
            << "\n    return getLastCodePoint(unicode_block) - getFirstCodePoint(unicode_block);";
        out_file << "\n}";
    }

    // End namespace
    out_file << "\n\n};";

    // The #endif statement
    out_file << "\n\n\n#endif // UNICODE_BLOCKS_HPP";

    // Close the file.
    out_file.close();

    std::cout << "";

    return 0;
}
