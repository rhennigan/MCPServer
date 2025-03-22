(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`Files`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$storagePath := FileNameJoin @ { $UserBaseDirectory, "ApplicationData", "RickHennigan", "MCPServer" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Server Files*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpServerPath*)
mcpServerPath // beginDefinition;
mcpServerPath[ name_String ] := File @ FileNameJoin @ { $storagePath, URLEncode @ name };
mcpServerPath[ obj_MCPServerObject? MCPServerObjectQ ] := obj[ "Location" ];
mcpServerPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpServerLogFile*)
mcpServerLogFile // beginDefinition;
mcpServerLogFile[ name_String ] := File @ FileNameJoin @ { First @ mcpServerPath @ name, "log.wl" };
mcpServerLogFile[ obj_MCPServerObject? MCPServerObjectQ ] := File @ FileNameJoin @ { First @ obj[ "Location" ], "log.wl" };
mcpServerLogFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
