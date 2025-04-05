#!/usr/bin/env wolframscript

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$Messages = Streams[ "stderr" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*debugEcho*)
debugEcho // ClearAll;
debugEcho[ message_String ] := (WriteLine[ "stderr", message ]; message);
debugEcho[ expr_ ] := (WriteLine[ "stderr", ToString[ expr, InputForm ] ]; expr);

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*initialize*)
initialize // ClearAll;

initialize[ name_ ] :=
    If[ StringQ @ name, initialize[ name, PersistentSymbol[ "RickHennigan/MCPServer/Initialization/"<>name ] ] ];

initialize[ name_String, _Missing ] :=
    Null;

initialize[ name_String, (Hold|HoldComplete)[ eval_ ] ] := (
    debugEcho[ "Initializing " <> name <> ": \n" <> ToString[ Unevaluated @ eval, InputForm ] ];
    eval
);

initialize[ name_String, eval_ ] := (
    debugEcho[ "Initializing " <> name <> ": \n" <> ToString[ Unevaluated @ eval, InputForm ] ];
    ReleaseHold @ eval
);

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Custom Initialization*)

(* Global initialization: *)
initialize[ "Global" ];

(* Per-server initialization: *)
initialize[ Environment[ "MCP_SERVER_NAME" ] ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Load Current Paclet*)
PacletDirectoryLoad @ DirectoryName[ $InputFileName, 2 ];
Get[ "RickHennigan`MCPServer`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Start MCP Server*)
RickHennigan`MCPServer`StartMCPServer[ ]