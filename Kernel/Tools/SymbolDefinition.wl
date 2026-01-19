(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`SymbolDefinition`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$defaultMaxLength         = 10000;
$readableFormTimeout      = 5;
$kernelFunctionString     = "<kernel function>";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Resource Functions*)
importResourceFunction[ readableForm, "ReadableForm" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$symbolDefinitionToolDescription = "\
Retrieves the definitions of one or more Wolfram Language symbols and returns them in a readable markdown format.
The tool generates clean, formatted definition strings by intelligently managing the context path to minimize \
fully qualified symbol names.

Use fully qualified symbol names (e.g., System`Plus, Wolfram`MCPServer`CreateMCPServer).
Multiple symbols can be requested by separating them with commas.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
$defaultMCPTools[ "SymbolDefinition" ] := LLMTool @ <|
    "Name"        -> "SymbolDefinition",
    "DisplayName" -> "Symbol Definition",
    "Description" -> $symbolDefinitionToolDescription,
    "Function"    -> getSymbolDefinition,
    "Parameters"  -> {
        "symbols" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The fully qualified symbol name (or multiple names, comma separated).",
            "Required"    -> True
        |>,
        "includeContextDetails" -> <|
            "Interpreter" -> "Boolean",
            "Help"        -> "Whether to include a JSON map showing which symbols belong to which contexts (default: false).",
            "Required"    -> False
        |>,
        "maxLength" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "Maximum character length for output before truncation (default: 10000).",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Main Entry Point*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getSymbolDefinition*)
getSymbolDefinition // beginDefinition;

getSymbolDefinition[ KeyValuePattern @ {
    "symbols"               -> symbols_String,
    "includeContextDetails" -> includeContextDetails: True | False : False,
    "maxLength"             -> maxLength_Integer : $defaultMaxLength
} ] := Enclose[
    Module[ { symbolNames, results, contextMap, contextSection, output },
        symbolNames = ConfirmMatch[ parseSymbolNames @ symbols, { __String }, "ParseSymbolNames" ];
        results     = processSymbol[ #, maxLength ] & /@ symbolNames;

        contextMap = If[ TrueQ @ includeContextDetails,
            generateContextMap @ Flatten[ #contextSymbols & /@ Select[ results, AssociationQ ] ],
            None
        ];

        contextSection = If[ contextMap =!= None && contextMap =!= "",
            "\n## Contexts\n\n```json\n" <> contextMap <> "\n```\n",
            ""
        ];

        output = StringRiffle[ #output & /@ results, "\n\n" ] <> contextSection;
        StringTrim @ output
    ],
    throwInternalFailure
];

getSymbolDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Input Parsing*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseSymbolNames*)
parseSymbolNames // beginDefinition;
parseSymbolNames[ input_String ] := StringTrim /@ StringSplit[ input, "," ];
parseSymbolNames // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Symbol Processing*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*processSymbol*)
processSymbol // beginDefinition;

processSymbol[ name_String, maxLength_Integer ] := Enclose[
    Module[ { valid, exists, shortName, locked, readProtected, definition, kernelDefs, allDefs, formatted, contextSymbols },

        (* Validate symbol name *)
        valid = validateSymbolName @ name;
        If[ ! valid,
            Return @ <|
                "output" -> formatError[ name, "Invalid symbol name \"" <> name <> "\"" ],
                "contextSymbols" -> {}
            |>
        ];

        (* Check if symbol exists *)
        exists = symbolExistsQ @ name;
        If[ ! exists,
            Return @ <|
                "output" -> formatError[ name, "Symbol \"" <> name <> "\" does not exist" ],
                "contextSymbols" -> {}
            |>
        ];

        shortName = Last @ StringSplit[ name, "`" ];

        (* Check for Locked + ReadProtected *)
        locked = isLockedQ @ name;
        readProtected = isReadProtectedQ @ name;

        If[ locked && readProtected,
            Return @ <|
                "output" -> formatError[ name, shortName <> " is `Locked` and `ReadProtected`" ],
                "contextSymbols" -> {}
            |>
        ];

        (* Extract definition *)
        definition = extractDefinition @ name;
        kernelDefs = getKernelCodeDefinitions @ name;
        allDefs    = Join[ definition, kernelDefs ];

        If[ allDefs === {} || allDefs === { Null },
            Return @ <|
                "output" -> "# " <> shortName <> "\n\nNo definitions found",
                "contextSymbols" -> {}
            |>
        ];

        (* Format the definition *)
        { formatted, contextSymbols } = formatDefinition[ name, allDefs, maxLength ];

        <|
            "output" -> "# " <> shortName <> "\n\n## Definition\n\n```wl\n" <> formatted <> "\n```",
            "contextSymbols" -> contextSymbols
        |>
    ],
    throwInternalFailure
];

processSymbol // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Symbol Validation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validateSymbolName*)
validateSymbolName // beginDefinition;
validateSymbolName[ name_String ] := Internal`SymbolNameQ[ name, True ];
validateSymbolName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*symbolExistsQ*)
symbolExistsQ // beginDefinition;

symbolExistsQ[ name_String ] := Module[ { context, short },
    { context, short } = splitSymbolName @ name;
    MemberQ[ Names[ context <> "*" ], name ]
];

symbolExistsQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*splitSymbolName*)
splitSymbolName // beginDefinition;

splitSymbolName[ name_String ] := Module[ { parts },
    parts = StringSplit[ name, "`" ];
    If[ Length @ parts === 1,
        { "Global`", First @ parts },
        { StringRiffle[ Most @ parts, "`" ] <> "`", Last @ parts }
    ]
];

splitSymbolName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Attribute Checking*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*isLockedQ*)
isLockedQ // beginDefinition;
isLockedQ[ name_String ] := MemberQ[ Attributes @ name, Locked ];
isLockedQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*isReadProtectedQ*)
isReadProtectedQ // beginDefinition;
isReadProtectedQ[ name_String ] := MemberQ[ Attributes @ name, ReadProtected ];
isReadProtectedQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definition Extraction*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractDefinition*)
extractDefinition // beginDefinition;

extractDefinition[ name_String ] := Module[ { sym, defString, held },
    sym = ToExpression[ name, InputForm, HoldComplete ];
    If[ ! MatchQ[ sym, HoldComplete[ _Symbol ] ],
        Return @ {}
    ];

    defString = Replace[
        sym,
        HoldComplete[ s_Symbol ] :>
            Internal`InheritedBlock[ { s },
                ClearAttributes[ s, ReadProtected ];
                ToString[ Definition @ s, InputForm ]
            ]
    ];

    If[ defString === "Null" || defString === "",
        {},
        held = Quiet @ ToExpression[ defString, InputForm, HoldComplete ];
        If[ MatchQ[ held, HoldComplete[ ___ ] ],
            DeleteCases[ List @@ held, Null ],
            {}
        ]
    ]
];

extractDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Kernel Code Detection*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getKernelCodeDefinitions*)
getKernelCodeDefinitions // beginDefinition;

getKernelCodeDefinitions[ name_String ] := Module[ { sym, defs },
    sym = ToExpression[ name, InputForm, HoldComplete ];
    If[ ! MatchQ[ sym, HoldComplete[ _Symbol ] ],
        Return @ {}
    ];

    defs = {};

    Replace[
        sym,
        HoldComplete[ s_Symbol ] :> (
            If[ TrueQ @ System`Private`HasDownCodeQ @ s,
                AppendTo[ defs, HoldForm[ s[___] := $kernelFunctionString ] ]
            ];
            If[ TrueQ @ System`Private`HasOwnCodeQ @ s,
                AppendTo[ defs, HoldForm[ s := $kernelFunctionString ] ]
            ];
            If[ TrueQ @ System`Private`HasSubCodeQ @ s,
                AppendTo[ defs, HoldForm[ s[___][___] := $kernelFunctionString ] ]
            ];
            If[ TrueQ @ System`Private`HasUpCodeQ @ s,
                AppendTo[ defs, HoldForm[ _[___, s, ___] := $kernelFunctionString ] ]
            ];
            If[ TrueQ @ System`Private`HasPrintCodeQ @ s,
                AppendTo[ defs, HoldForm[ Format[s, _] := $kernelFunctionString ] ]
            ];
        )
    ];

    defs
];

getKernelCodeDefinitions // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Context Analysis*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractSymbolsFromDefinition*)
extractSymbolsFromDefinition // beginDefinition;

extractSymbolsFromDefinition[ defs_List ] := Module[ { symbols },
    symbols = Cases[
        defs,
        s_Symbol /; AtomQ @ Unevaluated @ s :> HoldForm @ s,
        { 0, Infinity },
        Heads -> True
    ];
    DeleteDuplicates @ symbols
];

extractSymbolsFromDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getContextsFromSymbols*)
getContextsFromSymbols // beginDefinition;

getContextsFromSymbols[ symbols: { ___HoldForm } ] :=
    DeleteDuplicates @ Cases[
        symbols,
        HoldForm[ s_Symbol ] :> Context @ Unevaluated @ s
    ];

getContextsFromSymbols // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*buildOptimalContextPath*)
buildOptimalContextPath // beginDefinition;

buildOptimalContextPath[ contexts_List ] :=
    Reverse @ DeleteDuplicates @ Join[ { "Global`", "System`" }, contexts ];

buildOptimalContextPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateContextMap*)
generateContextMap // beginDefinition;

generateContextMap[ symbols: { ___HoldForm } ] := Module[ { grouped, jsonParts },
    If[ symbols === {}, Return @ "" ];

    grouped = GroupBy[
        symbols,
        (Replace[ #, HoldForm[ s_Symbol ] :> Context @ Unevaluated @ s ] &),
        (Replace[ #, HoldForm[ s_Symbol ] :> SymbolName @ Unevaluated @ s, { 1 } ] &)
    ];

    jsonParts = KeyValueMap[
        Function[ { ctx, names },
            "  \"" <> ctx <> "\": [" <> StringRiffle[ ("\"" <> # <> "\"") & /@ Sort @ DeleteDuplicates @ names, ", " ] <> "]"
        ],
        grouped
    ];

    "{\n" <> StringRiffle[ jsonParts, ",\n" ] <> "\n}"
];

generateContextMap // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Formatting*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatDefinition*)
formatDefinition // beginDefinition;

formatDefinition[ name_String, defs_List, maxLength_Integer ] := Module[
    { symbols, contexts, cPath, symbolContext, formatted, truncated },

    symbols       = extractSymbolsFromDefinition @ defs;
    contexts      = getContextsFromSymbols @ symbols;
    cPath         = buildOptimalContextPath @ contexts;
    symbolContext = First @ splitSymbolName @ name;

    formatted = formatDefinitionReadable[ defs, cPath, symbolContext ];

    If[ formatted === $TimedOut || ! StringQ @ formatted,
        formatted = formatDefinitionFallback[ defs, cPath, symbolContext ]
    ];

    truncated = truncateIfNeeded[ formatted, maxLength ];
    { truncated, symbols }
];

formatDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatDefinitionReadable*)
formatDefinitionReadable // beginDefinition;

formatDefinitionReadable[ defs_List, cPath_List, symbolContext_String ] :=
    TimeConstrained[
        Block[ { $ContextPath = cPath, $Context = symbolContext },
            StringRiffle[
                formatSingleDefinition /@ defs,
                "\n\n"
            ]
        ],
        $readableFormTimeout
    ];

formatDefinitionReadable // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatSingleDefinition*)
formatSingleDefinition // beginDefinition;

formatSingleDefinition[ HoldForm[ expr_ ] ] :=
    ToString[ readableForm @ Unevaluated @ expr, CharacterEncoding -> "UTF-8" ];

formatSingleDefinition[ expr_ ] :=
    ToString[ readableForm @ Unevaluated @ expr, CharacterEncoding -> "UTF-8" ];

formatSingleDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatDefinitionFallback*)
formatDefinitionFallback // beginDefinition;

formatDefinitionFallback[ defs_List, cPath_List, symbolContext_String ] :=
    Block[ { $ContextPath = cPath, $Context = symbolContext },
        StringRiffle[
            (ToString[ #, InputForm ] &) /@ defs,
            "\n\n"
        ]
    ];

formatDefinitionFallback // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Truncation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*truncateIfNeeded*)
truncateIfNeeded // beginDefinition;

truncateIfNeeded[ str_String, maxLength_Integer ] /; StringLength @ str <= maxLength := str;

truncateIfNeeded[ str_String, maxLength_Integer ] := Module[ { total },
    total = StringLength @ str;
    StringTake[ str, maxLength ] <> "\n... [truncated, showing " <> ToString @ maxLength <> "/" <> ToString @ total <> " characters]"
];

truncateIfNeeded // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Error Formatting*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatError*)
formatError // beginDefinition;

formatError[ name_String, message_String ] := Module[ { shortName },
    shortName = Last @ StringSplit[ name, "`" ];
    "# " <> shortName <> "\n\nError: " <> message
];

formatError // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
