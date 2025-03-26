(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`MCPServerObject`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

$ContextAliases[ "sp`" ] = "System`Private`";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$defaultCommandLineArguments = { "-run", "RickHennigan`MCPServer`StartMCPServer[]", "-noinit", "-noprompt" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCPServerObject*)
MCPServerObject // ClearAll;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Main Definition*)
MCPServerObject[ data_Association ]? sp`HoldNotValidQ := catchMine @ createMCPServerObject @ data;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*createMCPServerObject*)
createMCPServerObject // beginDefinition;

createMCPServerObject[ data_Association ] := Enclose[
    With[ { valid = validateMCPServerObjectData @ data },
        If[ AssociationQ @ valid,
            sp`HoldSetValid @ MCPServerObject @ valid,
            throwFailure[ "InvalidArguments", MCPServerObject, HoldForm @ MCPServerObject @ data ]
        ]
    ],
    throwInternalFailure
];

createMCPServerObject // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validateMCPServerObjectData*)
validateMCPServerObjectData // beginDefinition;
validateMCPServerObjectData[ data_Association? AssociationQ ] := data; (* TODO: validate the data *)
validateMCPServerObjectData[ _ ] := $Failed;
validateMCPServerObjectData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Get MCP Server by Name*)
MCPServerObject[ name_String ] := catchMine @ getMCPServerObjectByName @ name;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getMCPServerObjectByName*)
getMCPServerObjectByName // beginDefinition;

getMCPServerObjectByName[ name_String ] := Enclose[
    Module[ { dir, file, data },
        dir = ConfirmMatch[ mcpServerPath @ name, File[ _String ], "Directory" ];
        If[ ! DirectoryQ @ dir, throwFailure[ "MCPServerNotFound", name ] ];
        file = FileNameJoin @ { First @ dir, URLEncode @ name <> ".wxf" };
        If[ ! FileExistsQ @ file, throwFailure[ "MCPServerNotFound", name ] ];
        data = Developer`ReadWXFFile @ file;
        If[ ! AssociationQ @ data, throwFailure[ "MCPServerNotFound", name ] ];
        ConfirmBy[ MCPServerObject @ data, MCPServerObjectQ, "MCPServerObject" ]
    ],
    throwInternalFailure
];

getMCPServerObjectByName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Get MCP Server by Location*)
MCPServerObject[ location_File ] := catchMine @ getMCPServerObjectByLocation @ location;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getMCPServerObjectByLocation*)
getMCPServerObjectByLocation // beginDefinition;

getMCPServerObjectByLocation[ File[ dir_String? DirectoryQ ] ] :=
    getMCPServerObjectByLocation @ File @ FileNameJoin @ { dir, FileBaseName @ dir <> ".wxf" };

getMCPServerObjectByLocation[ File[ file_String ] ] := Enclose[
    Module[ { data },
        If[ ! FileExistsQ @ file, throwFailure[ "InvalidMCPServerFile", file ] ];
        data = Developer`ReadWXFFile @ file;
        If[ ! AssociationQ @ data, throwFailure[ "InvalidMCPServerFile", file ] ];
        ConfirmBy[ MCPServerObject @ data, MCPServerObjectQ, "MCPServerObject" ]
    ],
    throwInternalFailure
];

getMCPServerObjectByLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Flat*)
MCPServerObject[ obj_MCPServerObject? MCPServerObjectQ ] := obj;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties*)
(MCPServerObject[ data_Association ]? MCPServerObjectQ)[ prop_String ] :=
    catchTop[ getMCPServerObjectProperty[ data, prop ], MCPServerObject ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getMCPServerObjectProperty*)
getMCPServerObjectProperty // beginDefinition;

(* Special properties *)
getMCPServerObjectProperty[ data_Association, "LLMConfiguration" ] := makeLLMConfiguration @ data;
getMCPServerObjectProperty[ data_Association, "Tools" ] := makeLLMConfiguration[ data ][ "Tools" ];
getMCPServerObjectProperty[ data_Association, "JSONConfiguration" ] := makeJSONConfiguration @ data;

(* Standard properties *)
getMCPServerObjectProperty[ KeyValuePattern[ key_ -> value_ ], key_ ] := value;
getMCPServerObjectProperty[ KeyValuePattern[ "LLMEvaluator" -> KeyValuePattern[ prop_ -> value_ ] ], prop_ ] := value;

(* Unknown property *)
getMCPServerObjectProperty[ _, prop_ ] := Missing[ "UnknownProperty", prop ];
getMCPServerObjectProperty // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeJSONConfiguration*)
makeJSONConfiguration // beginDefinition;

makeJSONConfiguration[ data_Association ] := Enclose[
    Module[ { name, env, cmd, config, full },
        name = ConfirmBy[ data[ "Name" ], StringQ, "Name" ];
        env = <| "MCP_SERVER_NAME" -> name |>;
        cmd = ConfirmBy[ getWolframCommand @ $OperatingSystem, StringQ, "WolframCommand" ];
        config = <| "command" -> cmd, "args" -> $defaultCommandLineArguments, "env" -> env |>;
        full = <| "mcpServers" -> <| name -> config |> |>;
        ConfirmBy[ Developer`WriteRawJSONString @ full, StringQ, "JSONConfiguration" ]
    ],
    throwInternalFailure
];

makeJSONConfiguration // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getWolframCommand*)
getWolframCommand // beginDefinition;

getWolframCommand[ "Windows" ] := getWolframCommand[ "Windows", "wolfram.exe" ];
getWolframCommand[ os_String ] := getWolframCommand[ os, "wolfram" ];

getWolframCommand[ os_String, wolfram_String ] :=
    getWolframCommand[ os, wolfram, Quiet @ RunProcess @ { wolfram, "-version" } ];

getWolframCommand[ os_, wolfram_String, KeyValuePattern @ { "ExitCode" -> 0, "StandardOutput" -> v_String } ] :=
    If[ StringStartsQ[ v, DigitCharacter.. ~~ "." ~~ DigitCharacter.. ],
        "wolfram",
        FileNameJoin @ { $InstallationDirectory, wolfram }
    ];

getWolframCommand[ os_, wolfram_String, _ ] :=
    FileNameJoin @ { $InstallationDirectory, wolfram };

getWolframCommand // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeLLMConfiguration*)
makeLLMConfiguration // beginDefinition;
makeLLMConfiguration[ data_Association ] := makeLLMConfiguration[ data, convertStringTools @ data[ "LLMEvaluator" ] ];
makeLLMConfiguration[ _, evaluator_Association ] := LLMConfiguration @ evaluator;
makeLLMConfiguration // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertStringTools*)
convertStringTools // beginDefinition;

convertStringTools[ evaluator: KeyValuePattern[ "Tools" -> tools_ ] ] :=
    <| evaluator, "Tools" -> Map[ convertStringTools0, Flatten @ { tools } ] |>;

convertStringTools[ evaluator_ ] := evaluator;

convertStringTools // endDefinition;


convertStringTools0 // beginDefinition;
convertStringTools0[ name_String ] := Lookup[ Wolfram`Chatbook`$AvailableTools, name, name ];
convertStringTools0[ tool_ ] := tool;
convertStringTools0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*UpValues*)
MCPServerObject /: DeleteObject[ obj_MCPServerObject? MCPServerObjectQ ] := catchTop[
    deleteMCPServer @ obj,
    MCPServerObject
];

MCPServerObject /: LLMConfiguration[ obj_MCPServerObject? MCPServerObjectQ ] := catchTop[
    obj[ "LLMConfiguration" ],
    MCPServerObject
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*deleteMCPServer*)
deleteMCPServer // beginDefinition;

deleteMCPServer[ obj_ ] :=
    deleteMCPServer[ obj[ "Name" ], obj[ "Location" ] ];

deleteMCPServer[ name_, location_File ] := Enclose[
    If[ DirectoryQ @ location,
        ConfirmMatch[ DeleteDirectory[ location, DeleteContents -> True ], Null, "Delete" ];
        ConfirmAssert[ ! FileExistsQ @ location, "Verify" ];
        Null,
        throwFailure[ "MCPServerFileNotFound", name, location ]
    ],
    throwInternalFailure
];

deleteMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Formatting*)
MCPServerObject /: MakeBoxes[ obj_MCPServerObject? sp`HoldValidQ, fmt_ ] :=
    With[ { boxes = Quiet @ catchAlways @ makeMCPServerObjectBoxes[ obj, fmt ] },
        boxes /; MatchQ[ boxes, _InterpretationBox ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Handling*)
MCPServerObject[ args___ ]? sp`HoldNotValidQ := catchTop[
    throwFailure[
        "InvalidArguments",
        MCPServerObject,
        HoldForm @ MCPServerObject @ args
    ],
    MCPServerObject
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCPServerObjectQ*)
MCPServerObjectQ // beginDefinition;
MCPServerObjectQ[ obj_MCPServerObject ] := sp`HoldValidQ @ obj;
MCPServerObjectQ[ _ ] := False;
MCPServerObjectQ // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCPServerObjects*)
MCPServerObjects // beginDefinition;
MCPServerObjects[ ] := catchMine @ MCPServerObjects @ All;
MCPServerObjects[ pattern: All | _String? StringQ ] := catchMine @ getMatchingMCPServerObjects @ pattern;
MCPServerObjects // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getMatchingMCPServerObjects*)
getMatchingMCPServerObjects // beginDefinition;

getMatchingMCPServerObjects[ All ] :=
    getMatchingMCPServerObjects @ Select[ FileNames[ All, $storagePath ], DirectoryQ ];

getMatchingMCPServerObjects[ pattern_String? StringQ ] :=
    getMatchingMCPServerObjects @ Select[
        FileNames[ StringReplace[ URLEncode @ pattern, "%2A" -> "*", IgnoreCase -> True ], $storagePath ],
        DirectoryQ
    ];

getMatchingMCPServerObjects[ dirs: { ___String } ] :=
    Select[ Quiet @ catchTop @ MCPServerObject @ File[ # ] & /@ dirs, MCPServerObjectQ ];

getMatchingMCPServerObjects // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
