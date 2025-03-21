(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`Files`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$storagePath := FileNameJoin @ { ExpandFileName @ LocalObject @ $LocalBase, "RickHennigan", "MCPServer" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Storage Path*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpServerPath*)
mcpServerPath // beginDefinition;
mcpServerPath[ name_String ] := File @ FileNameJoin @ { $storagePath, URLEncode @ name };
mcpServerPath[ obj_MCPServerObject? MCPServerObjectQ ] := obj[ "Location" ];
mcpServerPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
