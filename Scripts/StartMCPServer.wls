#!/usr/bin/env wolframscript

$Messages = Streams[ "stderr" ];
PacletDirectoryLoad @ DirectoryName[ $InputFileName, 2 ];
Get[ "RickHennigan`MCPServer`" ];
RickHennigan`MCPServer`StartMCPServer[ ]