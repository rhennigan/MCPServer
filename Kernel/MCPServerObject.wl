(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`MCPServerObject`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

$ContextAliases[ "cb`" ] = "Wolfram`Chatbook`";
$ContextAliases[ "sp`" ] = "System`Private`";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$defaultCommandLineArguments = {
    "-run",
    "PacletSymbol[\"RickHennigan/MCPServer\",\"RickHennigan`MCPServer`StartMCPServer\"][]",
    "-noinit",
    "-noprompt"
};

$$transport = "StandardInputOutput" | "HTTP" | "ServerSentEvents";

$$metadata = KeyValuePattern @ {
    "LLMEvaluator"  -> _Association? AssociationQ,
    "Location"      -> _File? fileQ | "BuiltIn",
    "Name"          -> _String? StringQ,
    "ObjectVersion" -> _Integer? IntegerQ,
    "ServerVersion" -> _String? StringQ,
    "Transport"     -> $$transport
};

$defaultMetadata := <|
    "LLMEvaluator"  -> Automatic,
    "Name"          -> CreateUUID[ ],
    "ObjectVersion" -> $objectVersion,
    "ServerVersion" -> $serverVersion,
    "Transport"     -> "StandardInputOutput"
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCPServerObject*)
MCPServerObject // ClearAll;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Main Definition*)
MCPServerObject[ data_Association ]? sp`HoldNotValidQ :=
    catchTop[ createMCPServerObject @ data, MCPServerObject ];

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

validateMCPServerObjectData[ data_Association? AssociationQ ] :=
    Module[ { valid, combined },
        valid = Association @ KeyValueMap[ #1 -> validateMCPServerObjectData0[ #1, #2 ] &, data ];
        combined = <| $defaultMetadata, valid |>;
        If[ MatchQ[ combined, $$metadata ], combined, $Failed ]
    ];

validateMCPServerObjectData[ _ ] :=
    $Failed;

validateMCPServerObjectData // endDefinition;


validateMCPServerObjectData0 // beginDefinition;
validateMCPServerObjectData0[ "LLMEvaluator", config_ ] := validateLLMEvaluator @ config;
validateMCPServerObjectData0[ key_String, value_ ] := value;
validateMCPServerObjectData0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validateLLMEvaluator*)
validateLLMEvaluator // beginDefinition;

validateLLMEvaluator[ Automatic ] :=
    validateLLMEvaluator @ $LLMEvaluator;

validateLLMEvaluator[ HoldPattern @ LLMConfiguration[ config_ ] ] :=
    validateLLMEvaluator @ config;

validateLLMEvaluator[ config_Association? AssociationQ ] :=
    Association @ KeyValueMap[ #1 -> validateLLMEvaluator0[ #1, #2 ] &, config ];

validateLLMEvaluator // endDefinition;


validateLLMEvaluator0 // beginDefinition;
validateLLMEvaluator0[ "Tools", tools_ ] := validateTools @ tools;
validateLLMEvaluator0[ key_String, value_ ] := value;
validateLLMEvaluator0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validateTools*)
validateTools // beginDefinition;

validateTools[ tool_LLMTool ] := validateTools @ { tool };
validateTools[ tool_String  ] := validateTools @ { tool };

validateTools[ tools_List ] :=
    With[ { v = validateTool /@ Flatten @ { tools } },
        Flatten @ { tools } /; MatchQ[ v, { ___LLMTool } ]
    ];

validateTools[ tools_ ] :=
    throwFailure[ "InvalidToolsSpecification", tools ];

validateTools // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validateTool*)
validateTool // beginDefinition;
validateTool[ tool_LLMTool ] := tool;
validateTool[ tool_String ] := convertStringTools @ tool;
validateTool[ tool_TemplateObject ] := TemplateApply @ tool;
validateTool[ other_ ] := throwFailure[ "InvalidToolSpecification", other ];
validateTool // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Get MCP Server by Name*)
MCPServerObject[ name_String ] := catchMine @ getMCPServerObjectByName @ name;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getMCPServerObjectByName*)
getMCPServerObjectByName // beginDefinition;

getMCPServerObjectByName[ name_String ] := Enclose[
    Catch @ Module[ { file, data },
        file = ConfirmBy[ mcpServerFile @ name, fileQ, "File" ];
        If[ ! FileExistsQ @ file, Throw @ checkBuiltInMCPServer @ name ];
        data = readMetadataFile @ file;
        If[ ! AssociationQ @ data, throwFailure[ "MCPServerNotFound", name ] ];
        ConfirmBy[ MCPServerObject @ data, MCPServerObjectQ, "MCPServerObject" ]
    ],
    throwInternalFailure
];

getMCPServerObjectByName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkBuiltInMCPServer*)
checkBuiltInMCPServer // beginDefinition;

checkBuiltInMCPServer[ name_String ] :=
    With[ { server = $DefaultMCPServers[ name ] },
        If[ MCPServerObjectQ @ server,
            server,
            throwFailure[ "MCPServerNotFound", name ]
        ]
    ];

checkBuiltInMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Get MCP Server by Location*)
MCPServerObject[ location_File ] := catchMine @ getMCPServerObjectByLocation @ location;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getMCPServerObjectByLocation*)
getMCPServerObjectByLocation // beginDefinition;

getMCPServerObjectByLocation[ dir_File? directoryQ ] :=
    getMCPServerObjectByLocation @ fileNameJoin[ dir, "Metadata.wxf" ];

getMCPServerObjectByLocation[ file_File ] := Enclose[
    Module[ { data },
        data = ConfirmBy[ readMetadataFile @ file, validMetadataQ, "Metadata" ];
        ConfirmBy[ MCPServerObject @ data, MCPServerObjectQ, "MCPServerObject" ]
    ],
    throwInternalFailure
];

getMCPServerObjectByLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*readMetadataFile*)
readMetadataFile // beginDefinition;

(* TODO: This should check the object version and update if necessary *)
readMetadataFile[ file_File ] := Enclose[
    Module[ { data },
        If[ ! FileExistsQ @ file, throwFailure[ "InvalidMCPServerFile", file ] ];
        data = Developer`ReadWXFFile @ ExpandFileName @ file;
        If[ ! validMetadataQ @ data, throwFailure[ "InvalidMCPServerFile", file ] ];
        data
    ],
    throwInternalFailure
];

readMetadataFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validMetadataQ*)
validMetadataQ // beginDefinition;
validMetadataQ[ $$metadata ] := True;
validMetadataQ[ _ ] := False;
validMetadataQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Flat*)
MCPServerObject[ obj_MCPServerObject ] := catchMine[
    If[ MCPServerObjectQ @ obj,
        obj,
        throwFailure[ "DeletedMCPServerObject", obj[ "Name" ] ]
    ]
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*ensureMCPServerExists*)
ensureMCPServerExists // beginDefinition;

ensureMCPServerExists[ obj_MCPServerObject ] :=
    If[ MCPServerObjectQ @ obj,
        obj,
        throwFailure[ "DeletedMCPServerObject", obj[ "Name" ] ]
    ];

ensureMCPServerExists // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties*)
MCPServerObject[ KeyValuePattern[ prop_ -> value_ ] ][ prop_String ] :=
    value;

(MCPServerObject[ data_Association ]? MCPServerObjectQ)[ prop: _String | { ___String } ] :=
    catchTop[ getMCPServerObjectProperty[ data, prop ], MCPServerObject ];

(obj_MCPServerObject)[ prop: _String | { ___String } ] :=
    catchTop[ getMCPServerObjectProperty[ ensureMCPServerExists @ obj, prop ], MCPServerObject ];

_MCPServerObject[ invalid_ ] :=
    catchTop[ throwFailure[ "InvalidProperty", invalid ], MCPServerObject ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getMCPServerObjectProperty*)
getMCPServerObjectProperty // beginDefinition;

getMCPServerObjectProperty[ MCPServerObject[ data_Association ], prop_ ] :=
    getMCPServerObjectProperty[ data, prop ];

(* Special properties *)
getMCPServerObjectProperty[ data_Association, "Data"              ] := data;
getMCPServerObjectProperty[ data_Association, "LLMConfiguration"  ] := makeLLMConfiguration @ data;
getMCPServerObjectProperty[ data_Association, "PromptData"        ] := getPromptData @ data;
getMCPServerObjectProperty[ data_Association, "Tools"             ] := getToolList @ data;
getMCPServerObjectProperty[ data_Association, "JSONConfiguration" ] := makeJSONConfiguration @ data;
getMCPServerObjectProperty[ data_Association, "Installations"     ] := getInstallations @ data;
getMCPServerObjectProperty[ data_Association, "Properties"        ] := getProperties @ data;

(* Standard properties *)
getMCPServerObjectProperty[ KeyValuePattern[ key_ -> value_ ], key_ ] := value;
getMCPServerObjectProperty[ KeyValuePattern[ "LLMEvaluator" -> KeyValuePattern[ prop_ -> value_ ] ], prop_ ] := value;

(* Property list *)
getMCPServerObjectProperty[ data_Association, props: { ___String } ] :=
    AssociationMap[ getMCPServerObjectProperty[ data, # ] &, props ];

(* Unknown property *)
getMCPServerObjectProperty[ _, prop_ ] := Missing[ "UnknownProperty", prop ];
getMCPServerObjectProperty // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getProperties*)
getProperties // beginDefinition;
getProperties[ data_Association ] := Union[ Keys @ data, Keys @ data[ "LLMEvaluator" ], $specialProperties ];
getProperties // endDefinition;

$specialProperties = {
    "Data",
    "Installations",
    "JSONConfiguration",
    "LLMConfiguration",
    "PromptData",
    "Properties",
    "Tools"
};

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getInstallations*)
getInstallations // beginDefinition;

getInstallations[ data_Association ] := Enclose[
    ConfirmMatch[ mcpServerInstallations @ data, { ___? fileQ }, "Installations" ],
    throwInternalFailure
];

getInstallations // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getPromptData*)
getPromptData // beginDefinition;
getPromptData[ as_Association ] := getPromptData[ as, as[ "LLMEvaluator", "PromptData" ] ];
getPromptData[ as_, prompts: { ___Association } ] := prompts;
getPromptData[ as_, prompts_ ] := { };
getPromptData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getToolList*)
getToolList // beginDefinition;

getToolList[ as_Association ] := Enclose[
    ConfirmMatch[
        toLLMTools @ as[ "LLMEvaluator" ][ "Tools" ],
        { ___LLMTool },
        "GetToolList"
    ],
    throwInternalFailure
];

getToolList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toLLMTools*)
toLLMTools // beginDefinition;

toLLMTools[ _Missing ] := { };

toLLMTools[ tools_ ] := Replace[
    convertStringTools @ Flatten @ { tools },
    t_TemplateObject :> TemplateApply @ t,
    { 1 }
];

toLLMTools // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeJSONConfiguration*)
makeJSONConfiguration // beginDefinition;

makeJSONConfiguration[ data_Association ] := Enclose[
    Module[ { name, env, cmd, config, full },
        name = ConfirmBy[ data[ "Name" ], StringQ, "Name" ];
        env = <| "MCP_SERVER_NAME" -> name |>;
        cmd = ConfirmBy[ getWolframCommand @ $OperatingSystem, StringQ, "WolframCommand" ];
        config = <| "type" -> "stdio", "command" -> cmd, "args" -> $defaultCommandLineArguments, "env" -> env |>;
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
    FileNameJoin @ { $InstallationDirectory, If[ os === "MacOSX", "MacOS", Nothing ], wolfram };

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

convertStringTools[ as: KeyValuePattern[ "Tools" -> tools_ ] ] :=
    <| as, "Tools" -> convertStringTools @ Flatten @ { tools } |>;

convertStringTools[ tools_List ] :=
    convertStringTools0 /@ Flatten @ { tools };

convertStringTools[ tool_String ] :=
    convertStringTools0 @ tool;

convertStringTools[ other_ ] :=
    other;

convertStringTools // endDefinition;


convertStringTools0 // beginDefinition;
convertStringTools0[ name_String ] /; KeyExistsQ[ $DefaultMCPTools, name ] := $DefaultMCPTools[ name ];
convertStringTools0[ name_String ] := Lookup[ cb`$AvailableTools, name, tryResourceTool @ name ];
convertStringTools0[ template_TemplateObject ] := TemplateApply @ template;
convertStringTools0[ tool_ ] := tool;
convertStringTools0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*tryResourceTool*)
tryResourceTool // beginDefinition;
tryResourceTool[ name_String ] := tryResourceTool[ name, Quiet @ Block[ { PrintTemporary }, LLMResourceTool @ name ] ];
tryResourceTool[ name_String, tool_TemplateObject ] := tryResourceTool[ name, Quiet @ TemplateApply @ tool ];
tryResourceTool[ name_String, tool_LLMTool ] := tool;
tryResourceTool[ name_String, other_ ] := throwFailure[ "ToolNameNotFound", name ];
tryResourceTool // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*UpValues*)
MCPServerObject /: DeleteObject[ obj_MCPServerObject ] := catchTop[
    deleteMCPServer @ ensureMCPServerExists @ obj,
    MCPServerObject
];

MCPServerObject /: LLMConfiguration[ obj_MCPServerObject ] := catchTop[
    ensureMCPServerExists[ obj ][ "LLMConfiguration" ],
    MCPServerObject
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*deleteMCPServer*)
deleteMCPServer // beginDefinition;

deleteMCPServer[ obj_ ] := (
    UninstallMCPServer @ obj;
    deleteMCPServer[ obj[ "Name" ], obj[ "Location" ] ]
);

deleteMCPServer[ name_, "BuiltIn" ] :=
    throwFailure[ "DeleteBuiltInMCPServer", name ];

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
MCPServerObjectQ[ obj_MCPServerObject ] := sp`HoldValidQ @ obj && mcpServerExistsQ @ obj;
MCPServerObjectQ[ _ ] := False;
MCPServerObjectQ // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpServerExistsQ*)
mcpServerExistsQ // beginDefinition;
mcpServerExistsQ[ HoldPattern @ MCPServerObject[ as_Association ] ] := mcpServerExistsQ[ as, as[ "Location" ] ];
mcpServerExistsQ[ as_, "BuiltIn" ] := True;
mcpServerExistsQ[ as_, location_File ] := FileExistsQ @ location;
mcpServerExistsQ // endDefinition;

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
    Select[ Quiet @ catchAlways @ MCPServerObject @ File[ # ] & /@ dirs, MCPServerObjectQ ];

getMatchingMCPServerObjects // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
