#!/usr/bin/env wolframscript

Quiet[
    PacletDirectoryLoad @ DirectoryName[ $InputFileName, 2 ];
    Get[ "RickHennigan`MCPServer`" ];
    RickHennigan`MCPServer`StartMCPServer[ ]
]