#!/usr/bin/env wolframscript

PacletDirectoryLoad @ DirectoryName[ $InputFileName, 2 ];
Get[ "RickHennigan`MCPServer`" ];
RickHennigan`MCPServer`StartMCPServer[ ]