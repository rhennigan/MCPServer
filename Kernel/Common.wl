(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Symbols defined elsewhere in the paclet*)
Get[ "Wolfram`MCPServer`CommonSymbols`" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Messages*)
Get[ "Wolfram`MCPServer`Messages`" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Begin Private Context*)
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$cloudNotebooks         := TrueQ @ CloudSystem`$CloudNotebooks;
$mxFlag                 := Wolfram`MCPServerInternal`$BuildingMX;
$resourceFunctionContext = "Wolfram`MCPServer`ResourceFunctions`";

$resourceVersions = <|
    "BinarySerializeWithDefinitions" -> "1.0.0",
    "ExportMarkdownString"           -> "1.0.0",
    "ImportMarkdownString"           -> "1.0.0",
    "ReplaceContext"                 -> "1.0.0",
    "MessageFailure"                 -> "1.0.1"
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
$debug           = True;
$failed          = False;
$inDef           = False;
$internalFailure = None;
$messageSymbol   = MCPServer;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*optimizeEnclosures*)
optimizeEnclosures // ClearAll;
optimizeEnclosures // Attributes = { HoldFirst };
optimizeEnclosures[ s_Symbol ] := DownValues[ s ] = expandThrowInternalFailures @ optimizeEnclosures0 @ DownValues @ s;

optimizeEnclosures0 // ClearAll;
optimizeEnclosures0[ expr_ ] :=
    ReplaceAll[
        expr,
        HoldPattern[ e: Enclose[ _ ] | Enclose[ _, _ ] ] :>
            With[ { new = addEnclosureTags[ e, $ConditionHold ] },
                RuleCondition[ new, True ]
            ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*expandThrowInternalFailures*)
expandThrowInternalFailures // ClearAll;

expandThrowInternalFailures[ expr_ ] :=
    ReplaceAll[
        expr,
        HoldPattern[ Verbatim[ HoldPattern ][ lhs_ ] :> rhs_ ] /;
            ! FreeQ[ HoldComplete @ rhs, HoldPattern @ Enclose[ _, throwInternalFailure, $enclosure ] ] :>
                ReplaceAll[
                    HoldPattern[ e$: lhs ] :> rhs,
                    HoldPattern @ Enclose[ eval_, throwInternalFailure, $enclosure ] :>
                        Module[ { eh = HoldComplete @ e$ }, Enclose[ eval, internalFailureFunction @ eh, $enclosure ] ]
                ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*internalFailureFunction*)
internalFailureFunction // ClearAll;
internalFailureFunction // Attributes = { HoldAllComplete };
internalFailureFunction[ held_ ][ args___ ] := Replace[ held, HoldComplete[ e_ ] :> throwInternalFailure[ e, args ] ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*addEnclosureTags*)
addEnclosureTags // ClearAll;
addEnclosureTags // Attributes = { HoldFirst };

addEnclosureTags[ Enclose[ expr_ ], wrapper_ ] :=
    addEnclosureTags[ Enclose[ expr, #1 & ], wrapper ];

addEnclosureTags[ Enclose[ expr_, func_ ], wrapper_ ] :=
    Module[ { held, replaced },
        held = HoldComplete @ expr;
        replaced = held /. $enclosureTagRules;
        Replace[ replaced, HoldComplete[ e_ ] :> wrapper @ Enclose[ e, func, $enclosure ] ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$enclosureTagRules*)
$enclosureTagRules // ClearAll;
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::NoSurroundingEnclose:: *)
$enclosureTagRules := $enclosureTagRules = Dispatch @ {
    expr_Enclose                                      :> expr,

    HoldPattern @ Confirm[ expr_ ]                    :> Confirm[ expr, Null, $enclosure ],
    HoldPattern @ Confirm[ expr_, info_ ]             :> Confirm[ expr, info, $enclosure ],

    HoldPattern @ ConfirmBy[ expr_, f_ ]              :> ConfirmBy[ expr, f, Null, $enclosure ],
    HoldPattern @ ConfirmBy[ expr_, f_, info_ ]       :> ConfirmBy[ expr, f, info, $enclosure ],

    HoldPattern @ ConfirmMatch[ expr_, patt_ ]        :> ConfirmMatch[ expr, patt, Null, $enclosure ],
    HoldPattern @ ConfirmMatch[ expr_, patt_, info_ ] :> ConfirmMatch[ expr, patt, info, $enclosure ],

    HoldPattern @ ConfirmQuiet[ expr_ ]               :> ConfirmQuiet[ expr, All, Null, $enclosure ],
    HoldPattern @ ConfirmQuiet[ expr_, patt_ ]        :> ConfirmQuiet[ expr, patt, Null, $enclosure ],
    HoldPattern @ ConfirmQuiet[ expr_, patt_, info_ ] :> ConfirmQuiet[ expr, patt, info, $enclosure ],

    HoldPattern @ ConfirmAssert[ expr_ ]              :> ConfirmAssert[ expr, Null, $enclosure ],
    HoldPattern @ ConfirmAssert[ expr_, info_ ]       :> ConfirmAssert[ expr, info, $enclosure ]
};
(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*beginDefinition*)
beginDefinition // ClearAll;
beginDefinition // Attributes = { HoldFirst };
beginDefinition::Unfinished =
"Starting definition for `1` without ending the current one.";

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
beginDefinition[ s_Symbol ] /; $debug && $inDef :=
    WithCleanup[
        $inDef = False
        ,
        Print @ TemplateApply[ beginDefinition::Unfinished, HoldForm @ s ];
        beginDefinition @ s
        ,
        $inDef = True
    ];
(* :!CodeAnalysis::EndBlock:: *)

beginDefinition[ s_Symbol ] := WithCleanup[ Unprotect @ s; ClearAll @ s, $inDef = True ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*appendFallthroughError*)
appendFallthroughError // ClearAll;
appendFallthroughError // Attributes = { HoldFirst };

appendFallthroughError[ s_Symbol, values: DownValues|UpValues ] :=
    Module[ { block = Internal`InheritedBlock, before, after },
        block[ { s },
            before = values @ s;
            appendFallthroughError0[ s, values ];
            after = values @ s;
        ];

        If[ TrueQ[ Length @ after > Length @ before ],
            values[ s ] = after,
            values[ s ]
        ]
    ];

appendFallthroughError0 // ClearAll;
appendFallthroughError0[ s_Symbol, OwnValues  ] := e: HoldPattern @ s               := throwInternalFailure @ e;
appendFallthroughError0[ s_Symbol, DownValues ] := e: HoldPattern @ s[ ___ ]        := throwInternalFailure @ e;
appendFallthroughError0[ s_Symbol, UpValues   ] := e: HoldPattern @ s[ ___ ][ ___ ] := throwInternalFailure @ e;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*appendExportedFallthroughError*)
appendExportedFallthroughError // ClearAll;
appendExportedFallthroughError // Attributes = { HoldFirst };

appendExportedFallthroughError[ s_Symbol ] :=
    Module[ { block = Internal`InheritedBlock, before, after },
        block[ { s },
            before = DownValues @ s;
            appendExportedFallthroughError0 @ s;
            after = DownValues @ s;
        ];

        If[ TrueQ[ Length @ after > Length @ before ],
            DownValues[ s ] = after,
            DownValues[ s ]
        ]
    ];

appendExportedFallthroughError0 // ClearAll;
appendExportedFallthroughError0[ f_Symbol ] := f[ a___ ] :=
    catchTop[ throwFailure[ "InvalidArguments", f, HoldForm @ f @ a ], f ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*endDefinition*)
endDefinition // beginDefinition;
endDefinition // Attributes = { HoldFirst };

endDefinition[ s_Symbol ] := endDefinition[ s, DownValues ];

endDefinition[ s_Symbol, None ] := $inDef = False;

endDefinition[ s_Symbol, values: DownValues|UpValues ] :=
    WithCleanup[
        optimizeEnclosures @ s;
        appendFallthroughError[ s, values ],
        $inDef = False
    ];

endDefinition[ s_Symbol, list_List ] := (endDefinition[ s, #1 ] &) /@ list;

endDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*endExportedDefinition*)
endExportedDefinition // beginDefinition;
endExportedDefinition // Attributes = { HoldFirst };

endExportedDefinition[ s_Symbol ] :=
    WithCleanup[
        optimizeEnclosures @ s;
        appendExportedFallthroughError @ s,
        $inDef = False
    ];

endExportedDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Resource Functions*)
importResourceFunction // beginDefinition;
importResourceFunction::failure = "[ERROR] Failed to import resource function `1`. Aborting MX build.";
importResourceFunction // Attributes = { HoldFirst };

importResourceFunction[ name_String ] :=
    importResourceFunction[ None, name ];

importResourceFunction[ symbol_Symbol, name_String ] :=
    importResourceFunction[ symbol, name, Lookup[ $resourceVersions, name ] ];

importResourceFunction[ symbol_Symbol, name_String, version_ ] /; $mxFlag := Enclose[
    Block[ { PrintTemporary },
        Module[ { sourceContext, targetContext, definition, replaced, inlined, newSymbol },

            ConfirmAssert @ StringQ @ version;
            sourceContext = ConfirmBy[ ResourceFunction[ name, "Context", ResourceVersion -> version ], StringQ ];
            targetContext = $resourceFunctionContext<>name<>"`";
            definition    = ConfirmMatch[ ResourceFunction[ name, "DefinitionList" ], _Language`DefinitionList ];

            replaced = ConfirmMatch[
                ResourceFunction[ "ReplaceContext", ResourceVersion -> $resourceVersions[ "ReplaceContext" ] ][
                    definition,
                    sourceContext -> targetContext
                ],
                _Language`DefinitionList
            ];

            inlined = ConfirmMatch[ inlineDependentResourceFunctions @ replaced, _Language`DefinitionList ];

            $importedResourceFunctions[ name ] = version;
            KeyDropFrom[ $dependentResourceFunctions, Keys @ $importedResourceFunctions ];

            ConfirmMatch[ Language`ExtendedFullDefinition[ ] = inlined, _Language`DefinitionList ];

            newSymbol = ConfirmMatch[ Symbol[ targetContext<>name ], _Symbol? AtomQ ];

            importResourceFunction[ symbol, name, version ] =
                If[ Unevaluated @ symbol === None,
                    newSymbol,
                    ConfirmMatch[ symbol = newSymbol, newSymbol ]
                ]
        ]
    ],
    (Message[ importResourceFunction::failure, name ]; Abort[ ]) &
];

importResourceFunction[ symbol: Except[ None, _Symbol ], name_String, version_String ] :=
    symbol := symbol = Block[ { PrintTemporary }, ResourceFunction[ name, "Function", ResourceVersion -> version ] ];

importResourceFunction // endDefinition;

$importedResourceFunctions = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*importDependentResourceFunctions*)
importDependentResourceFunctions // beginDefinition;

importDependentResourceFunctions[ ] :=
    importDependentResourceFunctions @ Keys @ $dependentResourceFunctions;

importDependentResourceFunctions[ { } ] :=
    Null;

importDependentResourceFunctions[ names: { __String } ] := (
    importResourceFunction /@ names;
    KeyDropFrom[ $dependentResourceFunctions, names ];
    importDependentResourceFunctions @ Keys @ $dependentResourceFunctions
);

importDependentResourceFunctions // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inlineDependentResourceFunctions*)
inlineDependentResourceFunctions // beginDefinition;

inlineDependentResourceFunctions[ definition_ ] := ReplaceAll[
    definition,
    {
        HoldPattern @ ResourceFunction[ name_String, OptionsPattern[ ] ] :> RuleCondition[
            $dependentResourceFunctions[ name ] = True;
            Symbol[ $resourceFunctionContext<>name<>"`"<>name ]
        ],
        HoldPattern @ ResourceFunction[ name_String, "Function", OptionsPattern[ ] ] :> RuleCondition[
            $dependentResourceFunctions[ name ] = True;
            Symbol[ $resourceFunctionContext<>name<>"`"<>name ]
        ]
    }
];

inlineDependentResourceFunctions // endDefinition;


$dependentResourceFunctions = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Error Handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*catchTopAs*)
catchTopAs // beginDefinition;
catchTopAs[ sym_Symbol ] := Function[ eval, catchTop[ eval, sym ], { HoldAllComplete } ];
catchTopAs // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*catchTop*)
catchTop // beginDefinition;
catchTop // Attributes = { HoldFirst };

catchTop[ eval_ ] := catchTop[ eval, MCPServer ];

catchTop[ eval_, sym_Symbol ] :=
    Block[
        {
            $messageSymbol = Replace[ $messageSymbol, MCPServer -> sym ],
            $catching      = True,
            $failed        = False,
            catchTop       = # &,
            catchTopAs     = (#1 &) &
        },
        Catch[ eval, $catchTopTag ]
    ];

catchTop // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*catchAlways*)
catchAlways // beginDefinition;
catchAlways // Attributes = { HoldFirst };
catchAlways[ eval_ ] := catchAlways[ eval, MCPServer ];
catchAlways[ eval_, sym_Symbol ] := Catch[ catchTop[ eval, sym ], $catchTopTag ];
catchAlways // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*catchMine*)
catchMine // beginDefinition;
catchMine // Attributes = { HoldFirst };
catchMine /: HoldPattern[ f_Symbol[ args___ ] := catchMine[ rhs_ ] ] := f[ args ] := catchTop[ rhs, f ];
catchMine[ eval_ ] := catchTop @ eval;
catchMine // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*throwTop*)
throwTop // beginDefinition;
throwTop[ expr_ ] := If[ TrueQ @ $catching, Throw[ Unevaluated @ expr, $catchTopTag ], expr ];
throwTop // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*throwFailure*)
throwFailure // beginDefinition;
throwFailure // Attributes = { HoldFirst };

throwFailure[ msg_, args___ ] :=
    With[ { failure = messageFailure[ msg, args ] },
        If[ TrueQ @ $catching,
            Throw[ failure, $catchTopTag ],
            failure
        ]
    ];

throwFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*messageFailure*)
messageFailure // Attributes = { HoldFirst };

(* messageFailure[ "Internal"|MCPServer::Internal, args___ ] := (
    General::MCPServerInternal = MCPServer::Internal;
    messageFailure[ General::MCPServerInternal, args ]
); *)

messageFailure[ t_String, args___ ] :=
    With[ { s = $messageSymbol },
        If[ StringQ @ MessageName[ s, t ],
            messageFailure[ MessageName[ s, t ], args ],
            If[ StringQ @ MessageName[ MCPServer, t ],
                blockProtected[ { s }, MessageName[ s, t ] = MessageName[ MCPServer, t ] ];
                messageFailure[ MessageName[ s, t ], args ],
                throwInternalFailure @ messageFailure[ t, args ]
            ]
        ]
    ];

messageFailure[ args___ ] :=
    Module[ { quiet, message },
        quiet   = If[ TrueQ @ $failed, Quiet, Identity ];
        message = messageFailure0;
        WithCleanup[
            StackInhibit @ promoteSourceInfo @ convertCloudFailure @ quiet @ message @ args,
            If[ TrueQ @ $catching, $failed = True ]
        ]
    ];

(* https://resources.wolframcloud.com/FunctionRepository/resources/MessageFailure *)
importResourceFunction[ messageFailure0, "MessageFailure" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertCloudFailure*)
convertCloudFailure // beginDefinition;

convertCloudFailure[ Failure[
    "MCPServer::Internal",
    as: KeyValuePattern @ { "MessageParameters" :> { Hyperlink[ _, url_ ], params___ } }
] ] /; $CloudEvaluation :=
    Failure[
        "MCPServer::Internal",
        Association[
            as,
            "MessageParameters" -> { "", params },
            "Link"              -> Hyperlink[ "Report this issue \[RightGuillemet]", url ]
        ]
    ];

convertCloudFailure[ failure_ ] :=
    failure;

convertCloudFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*promoteSourceInfo*)
promoteSourceInfo // beginDefinition;

promoteSourceInfo[ Failure[
    "MCPServer::Internal",
    as: KeyValuePattern[ "MessageParameters" :> { _, KeyValuePattern[ "Information" -> info_String ] } ]
] ] := Failure[ "MCPServer::Internal", <| as, "Source" -> info |> ];

promoteSourceInfo[ failure_ ] := failure;

promoteSourceInfo // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*messagePrint*)
messagePrint // Attributes = { HoldFirst };
messagePrint[ args___ ] := WithCleanup[ $failed = False, messageFailure @ args, $failed = False ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*blockProtected*)
blockProtected // beginDefinition;
blockProtected // Attributes = { HoldAll };
blockProtected[ { s___Symbol }, eval_ ] := Module[ { p }, WithCleanup[ p = Unprotect @ s, eval, Protect @@ p ] ];
blockProtected[ s_Symbol, eval_ ] := blockProtected[ { s }, eval ];
blockProtected // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*throwInternalFailure*)
throwInternalFailure // beginDefinition;
throwInternalFailure // Attributes = { HoldFirst };

throwInternalFailure[ HoldForm[ eval_ ], a___ ] := throwInternalFailure[ eval, a ];

throwInternalFailure[ eval_, a___ ] :=
    Block[ { $internalFailure = $lastInternalFailure = makeInternalFailureData[ eval, a ] },
        throwFailure[ MCPServer::Internal, $bugReportLink, $internalFailure ]
    ];

throwInternalFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeInternalFailureData*)
makeInternalFailureData // Attributes = { HoldFirst };

makeInternalFailureData[ eval_, Failure[ tag_, as_Association ], args___ ] :=
    StackInhibit @ Module[ { $stack = Stack[ _ ] },
        DeleteMissing @ <|
            "Evaluation"  :> eval,
            KeyTake[ as, $priorityFailureKeys ],
            "Stack"       :> $stack,
            "Failure"     -> Failure[ tag, Association[ KeyDrop[ as, $priorityFailureKeys ], as ] ],
            "Arguments"   -> { args }
        |>
    ];

makeInternalFailureData[ eval_, args___ ] :=
    StackInhibit @ Module[ { $stack = Stack[ _ ] },
        <|
            "Evaluation" :> eval,
            "Stack"      :> $stack,
            "Arguments"  -> { args }
        |>
    ];

$priorityFailureKeys = { "Information", "ConfirmationType", "Expression", "Function", "Pattern", "Test" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Bug Report Link Generation*)

$issuesURL = "https://github.com/rhennigan/MCPServer/issues/new";

$maxBugReportURLSize = 7000;
(*
    RFC 7230 recommends clients support 8000: https://www.rfc-editor.org/rfc/rfc7230#section-3.1.1
    Long bug report links might not work in old versions of IE,
    but using IE these days should probably be considered user error.
*)

$maxPartLength = 500;

$thisPaclet    := PacletObject[ "Wolfram/MCPServer" ];
$pacletVersion := $thisPaclet[ "Version" ];
$debugData     := debugData @ $thisPaclet[ "PacletInfo" ];
$settingsData  := $settings;
$releaseID     := $releaseID = getReleaseID @ $thisPaclet;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getReleaseID*)
getReleaseID[ paclet_PacletObject ] :=
    getReleaseID[ paclet, paclet[ "ReleaseID" ] ];

getReleaseID[ paclet_PacletObject, "$RELEASE_ID$" | "None" | Except[ _String ] ] :=
    getReleaseID0 @ paclet[ "Location" ];

getReleaseID[ paclet_, id_String ] := id;


getReleaseID0[ dir_? DirectoryQ ] :=
    Module[ { stdOut, id },
        stdOut = Quiet @ RunProcess[ { "git", "rev-parse", "HEAD" }, "StandardOutput", ProcessDirectory -> dir ];
        id = If[ StringQ @ stdOut, StringTrim @ stdOut, "" ];
        If[ StringMatchQ[ id, Repeated[ HexadecimalCharacter, { 40 } ] ],
            id,
            "None"
        ]
    ];

getReleaseID0[ ___ ] := "None";

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*debugData*)
debugData // beginDefinition;

debugData[ as_Association? AssociationQ ] := <|
    KeyTake[ as, { "Name", "Version" } ],
    "ReleaseID"             -> $releaseID,
    "EvaluationEnvironment" -> $EvaluationEnvironment,
    "FrontEndVersion"       -> $frontEndVersion,
    "KernelVersion"         -> SystemInformation[ "Kernel", "Version" ],
    "SystemID"              -> $SystemID,
    "Notebooks"             -> $Notebooks,
    "DynamicEvaluation"     -> $DynamicEvaluation,
    "SynchronousEvaluation" -> $SynchronousEvaluation,
    "TaskEvaluation"        -> MatchQ[ $CurrentTask, _TaskObject ]
|>;

debugData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$bugReportLink*)
$bugReportLink := Hyperlink[
    "Report this issue \[RightGuillemet]",
    trimURL @ URLBuild[ $issuesURL, { "title" -> "Insert Title Here", "labels" -> "bug", "body" -> bugReportBody[ ] } ]
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*bugReportBody*)
bugReportBody[ ] := bugReportBody @ $thisPaclet[ "PacletInfo" ];

bugReportBody[ as_Association? AssociationQ ] :=
    Module[ { debugData, stack, settings, internalFailure, bugReportText, file, data },

        debugData        = $debugData;
        stack            = $bugReportStack;
        settings         = $settings;
        internalFailure  = $internalFailure;

        bugReportText = TemplateApply[
            $bugReportBodyTemplate,
            TemplateVerbatim /@ <|
                "DebugData"       -> associationMarkdown @ debugData,
                "Stack"           -> stack,
                "Settings"        -> associationMarkdown @ takeRelevantSettings @ settings,
                "InternalFailure" -> markdownCodeBlock @ internalFailure,
                "SourceLink"      -> sourceLink @ internalFailure
            |>
        ];

        data = <|
            "ReportText"      -> bugReportText,
            "PacletInfo"      -> as,
            "DebugData"       -> debugData,
            "Stack"           -> stack,
            "Settings"        -> settings,
            "InternalFailure" -> internalFailure
        |>;

        file = File @ Export[
            FileNameJoin @ { $UserBaseDirectory, "Logs", "MCPServer", "LastInternalFailureData.mx" },
            data,
            "MX"
        ];

        WithCleanup[
            Unprotect[ $LastMCPServerFailure, $LastMCPServerFailureText ]
            ,
            $LastMCPServerFailure     = file;
            $LastMCPServerFailureText = bugReportText;
            ,
            Protect[ $LastMCPServerFailure, $LastMCPServerFailureText ]
        ];

        bugReportText
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*takeRelevantSettings*)
takeRelevantSettings // beginDefinition;
takeRelevantSettings[ settings_Association ] := KeyDrop[ settings, $droppedSettingsKeys ];
takeRelevantSettings // endDefinition;

(* Settings that we don't need in debug data: *)
$droppedSettingsKeys = { };

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*sourceLink*)
sourceLink[ KeyValuePattern[ "Information" -> info_String ] ] := sourceLink @ info;
sourceLink[ info_String ] := sourceLink @ StringSplit[ info, "@@" ];
sourceLink[ { tag_String, source_String } ] := sourceLink @ { tag, StringSplit[ source, ":" ] };
sourceLink[ { tag_String, { file_String, pos_String } } ] := sourceLink @ { tag, file, StringSplit[ pos, "-" ] };

sourceLink[ { tag_String, file_String, { lc1_String, lc2_String } } ] :=
    sourceLink @ { tag, file, StringSplit[ lc1, "," ], StringSplit[ lc2, "," ] };

sourceLink[ { tag_String, file_String, { l1_String, c1_String }, { l2_String, c2_String } } ] :=
    Module[ { id },
        id = Replace[ $releaseID, { "$RELEASE_ID$" | "None" | Except[ _String ] -> "main" } ];
        "\n\nhttps://github.com/rhennigan/MCPServer/blob/"<>id<>"/"<>file<>"#L"<>l1<>"-L"<>l2
    ];

sourceLink[ ___ ] := "";

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$bugReportBodyTemplate*)
$bugReportBodyTemplate = StringTemplate[ "\
Describe the issue in detail here. Attach any relevant screenshots or files. \
The section below was automatically generated. \
Remove any information that you do not wish to include in the report.\
\
%%SourceLink%%

<details>
<summary>Debug Data</summary>

%%DebugData%%

## Settings

%%Settings%%

## Failure Data

%%InternalFailure%%

## Stack Data
```
%%Stack%%
```

</details>",
Delimiters -> "%%"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$frontEndVersion*)
$frontEndVersion :=
    If[ TrueQ @ $cloudNotebooks,
        StringJoin[ "Cloud: ", ToString @ $CloudVersion ],
        StringJoin[ "Desktop: ", ToString @ UsingFrontEnd @ SystemInformation[ "FrontEnd", "Version" ] ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$bugReportStack*)
$bugReportStack := StringRiffle[
    Reverse @ Replace[
        DeleteAdjacentDuplicates @ Cases[
            Stack[ _ ],
            HoldForm[ (s_Symbol) | (s_Symbol)[ ___ ] | (s_Symbol)[ ___ ][ ___ ] ] /;
                AtomQ @ Unevaluated @ s && StringStartsQ[ Context @ s, "Wolfram`MCPServer`" ] :>
                    SymbolName @ Unevaluated @ s
        ],
        { a___, "throwInternalFailure", ___ } :> { a, "throwInternalFailure" }
    ],
    "\n"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*$settings*)
$settings = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*trimURL*)
trimURL[ url_String ] := trimURL[ url, $maxBugReportURLSize ];

trimURL[ url_String, limit_Integer ] /; StringLength @ url <= limit := url;

trimURL[ url_String, limit_Integer ] :=
    Module[ { sp, bt, nl, before, after, base, take },
        sp     = ("+"|"%20")...;
        bt     = URLEncode[ "```" ];
        nl     = (URLEncode[ "\r\n" ] | URLEncode[ "\n" ])...;
        before = Longest[ "%23%23"~~sp~~"Failure"~~sp~~"Data"~~nl~~bt~~nl ];
        after  = Longest[ nl~~bt~~nl~~"%3C%2Fdetails%3E" ];
        base   = StringLength @ StringReplace[ url, a: before ~~ ___ ~~ b: after :> a <> "\n" <> b ];
        take   = UpTo @ Max[ limit - base, 80 ];

        With[ { t = take },
            StringReplace[
                StringReplace[ url, a: before ~~ b__ ~~ c: after :> a <> StringTake[ b, t ] <> "\n" <> c ],
                "%%0A" | ("%"~~HexadecimalCharacter~~"%0A") :> "%0A"
            ]
        ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*associationMarkdown*)
associationMarkdown[ data_Association? AssociationQ ] := StringJoin[
    "| Property | Value |\n| --- | --- |\n",
    StringRiffle[
        KeyValueMap[
            Function[
                { k, v },
                StringJoin @ StringJoin[
                    "| ",
                    ToString @ ToString[ Unevaluated @ k, CharacterEncoding -> "UTF-8" ],
                    " | ``",
                    escapePipes @ truncatePartString @ ToString[
                        Unevaluated @ v,
                        InputForm,
                        CharacterEncoding -> "UTF-8"
                    ],
                    "`` |"
                ],
                HoldAllComplete
            ],
            data
        ],
        "\n"
    ]
];

associationMarkdown[ rules___ ] := With[ { as = Association @ rules }, associationMarkdown @ as /; AssociationQ @ as ];
associationMarkdown[ other_   ] := markdownCodeBlock @ other;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*markdownCodeBlock*)
markdownCodeBlock[ as_Association? AssociationQ ] :=
    "```\n<|\n" <> StringRiffle[ ruleToString /@ Normal[ as, Association ], ",\n" ] <> "\n|>\n```\n";

markdownCodeBlock[ expr_ ] := StringJoin[
    "```\n",
    StringTake[ ToString[ expr, InputForm, PageWidth -> $maxPartLength ], UpTo @ $maxBugReportURLSize ],
    "\n```\n"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*ruleToString*)
ruleToString[ a_ -> b_ ] := StringJoin[
    "  ",
    ToString[ Unevaluated @ a, InputForm ],
    " -> ",
    truncatePartString @ ToString[ Unevaluated @ b, InputForm ]
];

ruleToString[ a_ :> b_ ] := StringJoin[
    "  ",
    ToString[ Unevaluated @ a, InputForm ],
    " :> ",
    truncatePartString @ ToString[ Unevaluated @ b, InputForm ]
];

ruleToString[ other_ ] := truncatePartString @ ToString[ Unevaluated @ other, InputForm ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*truncatePartString*)
truncatePartString[ string_ ] := truncatePartString[ string, $maxPartLength ];

truncatePartString[ string_String, max_Integer ] :=
    If[ StringLength @ string > max, StringTake[ string, UpTo @ max ] <> "...", string ];

truncatePartString[ other_, max_Integer ] := truncatePartString[ ToString[ Unevaluated @ other, InputForm ], max ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*escapePipes*)
escapePipes[ string_String ] := StringReplace[ string, "|" -> "\\|" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MX Build Utilities*)
$mxInitializations := $mxInitializations = Internal`Bag[ ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*addToMXInitialization*)
addToMXInitialization // beginDefinition;
addToMXInitialization // Attributes = { HoldAllComplete };
addToMXInitialization[ ] := Null;
addToMXInitialization[ Null ] := Null;
addToMXInitialization[ eval___ ] /; $mxFlag := Internal`StuffBag[ $mxInitializations, HoldComplete @ eval ];
addToMXInitialization[ ___ ] := Null;
addToMXInitialization // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mxInitialize*)
mxInitialize // beginDefinition;
mxInitialize // Attributes = { HoldAllComplete };

mxInitialize[ eval___ ] :=
    If[ TrueQ @ $mxFlag,
        addToMXInitialization @ eval;
        ReleaseHold @ Internal`BagPart[ $mxInitializations, All ];
    ];

mxInitialize // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $debug = False;
    $releaseID;
    importDependentResourceFunctions[ ];
];

End[ ];
EndPackage[ ];
