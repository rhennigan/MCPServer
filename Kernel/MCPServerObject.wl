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
$$prompt  = HoldPattern[ _String | _TemplateObject | _LLMPromptGenerator ];
$$llmTool = HoldPattern[ _LLMTool | _String? llmToolNameQ ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*llmToolNameQ*)
llmToolNameQ // beginDefinition;
llmToolNameQ[ name_String? StringQ ] := MemberQ[ Keys @ Wolfram`Chatbook`$AvailableTools, name ];
llmToolNameQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Messages*)
MCPServer::MCPServerFileNotFound = "MCPServerObject file not found for MCPServer named \"`1`\".";
MCPServer::MCPServerNotFound     = "No MCPServerObject found for name \"`1`\".";
MCPServer::InvalidMCPServerFile  = "Invalid MCPServerObject file: \"`1`\".";

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
(*Properties*)
(MCPServerObject[ data_Association ]? MCPServerObjectQ)[ prop_String ] :=
    catchTop[ getMCPServerObjectProperty[ data, prop ], MCPServerObject ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getMCPServerObjectProperty*)
getMCPServerObjectProperty // beginDefinition;
getMCPServerObjectProperty[ KeyValuePattern[ key_ -> value_ ], key_ ] := value;
getMCPServerObjectProperty[ KeyValuePattern[ "LLMEvaluator" -> KeyValuePattern[ prop_ -> value_ ] ], prop_ ] := value;
getMCPServerObjectProperty[ data_Association, "LLMConfiguration" ] := makeLLMConfiguration @ data;
getMCPServerObjectProperty[ _, prop_ ] := Missing[ "UnknownProperty", prop ];
getMCPServerObjectProperty // endDefinition;

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
    With[
        {
            boxes = Quiet @ catchAlways @ BoxForm`ArrangeSummaryBox[
                MCPServerObject,
                obj,
                makeMCPServerIcon @ obj,
                makeSummaryRows @ obj,
                makeHiddenSummaryRows @ obj,
                fmt
            ]
        },
        boxes /; MatchQ[ boxes, _InterpretationBox ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeSummaryRows*)
makeSummaryRows // beginDefinition;

makeSummaryRows[ obj_ ] :=
    makeSummaryRows[ obj[ "Name" ], obj[ "LLMEvaluator" ], obj[ "Location" ] ];

makeSummaryRows[ name_String, evaluator_Association, location_File ] :=
    Module[ { toolCount, promptCount },
        toolCount = Count[ Flatten @ { evaluator[ "Tools"   ] }, $$llmTool ];
        promptCount = Count[ Flatten @ { evaluator[ "Prompts" ] }, $$prompt ];
        Flatten @ {
            summaryItem[ "Name", name ],
            If[ toolCount   > 0, summaryItem[ "Tools"  , toolCount   ], Nothing ],
            If[ promptCount > 0, summaryItem[ "Prompts", promptCount ], Nothing ]
        }
    ];

makeSummaryRows // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeHiddenSummaryRows*)
makeHiddenSummaryRows // beginDefinition;

makeHiddenSummaryRows[ obj_ ] :=
    makeHiddenSummaryRows[ obj[ "Name" ], obj[ "LLMEvaluator" ], obj[ "Location" ] ];

makeHiddenSummaryRows[ name_String, evaluator_Association, location_File ] :=
    Module[ { toolNames },
        toolNames = Select[ Cases[ Flatten @ { evaluator[ "Tools" ] }, tool: $$llmTool :> toolName @ tool ], StringQ ];
        Flatten @ {
            If[ Length @ toolNames > 0, summaryItem[ "Tool Names", Multicolumn[ toolNames, 5 ] ], Nothing ],
            summaryItem[ "Location", location ]
            (* TODO: add a click-to-copy JSON button *)
        }
];

makeHiddenSummaryRows // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toolName*)
toolName // beginDefinition;
toolName[ name_String ] := name;
toolName[ tool_LLMTool ] := tool[ "Name" ];
toolName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*summaryItem*)
summaryItem // beginDefinition;
summaryItem[ _, _Missing ] := Nothing;
summaryItem[ label_, value_ ] := { BoxForm`SummaryItem @ { niceLabel @ label, value } };
summaryItem // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*niceLabel*)
niceLabel // beginDefinition;
niceLabel[ label_String ] := StringJoin[ label, ": " ];
niceLabel // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeMCPServerIcon*)
makeMCPServerIcon // beginDefinition;

(* TODO: move to assets *)
makeMCPServerIcon[ obj_ ] := Graphics[
    {
        Thickness[ 0.005979 ],
        Style[
            {
                JoinedCurve[
                    { { { 0, 2, 0 }, { 1, 3, 3 }, { 1, 3, 3 }, { 0, 1, 0 } } },
                    {
                        {
                            { 25., 97.147 },
                            { 92.882, 165.03 },
                            { 102.25, 174.4 },
                            { 117.45, 174.4 },
                            { 126.82, 165.03 },
                            { 136.2, 155.66 },
                            { 136.2, 140.46 },
                            { 126.82, 131.09 },
                            { 75.558, 79.823 }
                        }
                    },
                    CurveClosed -> { 0 }
                ]
            },
            CapForm[ "Round" ],
            JoinForm @ { "Miter", 1. },
            Thickness[ 0.071749 ]
        ],
        Style[
            {
                JoinedCurve[
                    { { { 0, 2, 0 }, { 1, 3, 3 }, { 0, 1, 0 }, { 1, 3, 3 }, { 0, 1, 0 }, { 1, 3, 3 }, { 0, 1, 0 } } },
                    {
                        {
                            { 76.265, 80.53 },
                            { 126.82, 131.09 },
                            { 136.2, 140.46 },
                            { 151.39, 140.46 },
                            { 160.76, 131.09 },
                            { 161.12, 130.73 },
                            { 170.49, 121.36 },
                            { 170.49, 106.17 },
                            { 161.12, 96.794 },
                            { 99.725, 35.4 },
                            { 96.601, 32.276 },
                            { 96.601, 27.211 },
                            { 99.725, 24.087 },
                            { 112.33, 11.48 }
                        }
                    },
                    CurveClosed -> { 0 }
                ]
            },
            CapForm[ "Round" ],
            JoinForm @ { "Miter", 1. },
            Thickness[ 0.071749 ]
        ],
        Style[
            {
                JoinedCurve[
                    { { { 0, 2, 0 }, { 1, 3, 3 }, { 1, 3, 3 }, { 0, 1, 0 } } },
                    {
                        {
                            { 109.85, 148.06 },
                            { 59.648, 97.854 },
                            { 50.276, 88.482 },
                            { 50.276, 73.286 },
                            { 59.648, 63.913 },
                            { 69.021, 54.541 },
                            { 84.217, 54.541 },
                            { 93.589, 63.913 },
                            { 143.79, 114.12 }
                        }
                    },
                    CurveClosed -> { 0 }
                ]
            },
            CapForm[ "Round" ],
            JoinForm @ { "Miter", 1. },
            Thickness[ 0.071749 ]
        ]
    },
    ImageSize -> 24
];

makeMCPServerIcon // endDefinition;

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
