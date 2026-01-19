(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    If[ ! TrueQ @ Wolfram`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ { DirectoryName[ $TestFileName ], "Common.wl" }
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/SymbolDefinition.wlt:7,1-14,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/SymbolDefinition.wlt:16,1-21,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`Tools`SymbolDefinition`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadPrivateContext@@Tests/SymbolDefinition.wlt:23,1-28,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Registration*)
VerificationTest[
    $symbolDefinitionTool = $DefaultMCPTools[ "SymbolDefinition" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "GetTool@@Tests/SymbolDefinition.wlt:33,1-38,2"
]

VerificationTest[
    $symbolDefinitionTool[ "Name" ],
    "SymbolDefinition",
    SameTest -> SameQ,
    TestID   -> "ToolName@@Tests/SymbolDefinition.wlt:40,1-45,2"
]

VerificationTest[
    StringQ @ $symbolDefinitionTool[ "Description" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolDescription@@Tests/SymbolDefinition.wlt:47,1-52,2"
]

VerificationTest[
    ListQ @ $symbolDefinitionTool[ "Parameters" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolParameters@@Tests/SymbolDefinition.wlt:54,1-59,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Input Parsing*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseSymbolNames*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`parseSymbolNames[ "System`Plus" ],
    { "System`Plus" },
    SameTest -> MatchQ,
    TestID   -> "ParseSingleSymbol@@Tests/SymbolDefinition.wlt:68,1-73,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`parseSymbolNames[ "System`Plus, System`Times, System`Map" ],
    { "System`Plus", "System`Times", "System`Map" },
    SameTest -> MatchQ,
    TestID   -> "ParseMultipleSymbols@@Tests/SymbolDefinition.wlt:75,1-80,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`parseSymbolNames[ "  System`Plus  ,  System`Times  " ],
    { "System`Plus", "System`Times" },
    SameTest -> MatchQ,
    TestID   -> "ParseWhitespaceHandling@@Tests/SymbolDefinition.wlt:82,1-87,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`parseSymbolNames[ "" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "ParseEmptyInput@@Tests/SymbolDefinition.wlt:89,1-94,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Symbol Validation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validateSymbolName*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "MySymbol" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ValidateSimpleName@@Tests/SymbolDefinition.wlt:103,1-108,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "System`Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ValidateQualifiedName@@Tests/SymbolDefinition.wlt:110,1-115,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "My`Context`Symbol" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ValidateDeepContext@@Tests/SymbolDefinition.wlt:117,1-122,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "Invalid!Symbol" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ValidateInvalidChars@@Tests/SymbolDefinition.wlt:124,1-129,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "123Invalid" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ValidateStartsWithNumber@@Tests/SymbolDefinition.wlt:131,1-136,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*symbolExistsQ*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`symbolExistsQ[ "System`Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExistsSystemSymbol@@Tests/SymbolDefinition.wlt:141,1-146,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`symbolExistsQ[ "NonExistentContext12345`NonExistentSymbol67890" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExistsNonexistent@@Tests/SymbolDefinition.wlt:148,1-153,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*splitSymbolName*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`splitSymbolName[ "System`Plus" ],
    { "System`", "Plus" },
    SameTest -> MatchQ,
    TestID   -> "SplitName-Simple@@Tests/SymbolDefinition.wlt:158,1-163,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`splitSymbolName[ "My`Deep`Context`Symbol" ],
    { "My`Deep`Context`", "Symbol" },
    SameTest -> MatchQ,
    TestID   -> "SplitName-Deep@@Tests/SymbolDefinition.wlt:165,1-170,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`splitSymbolName[ "UnqualifiedSymbol" ],
    { "Global`", "UnqualifiedSymbol" },
    SameTest -> MatchQ,
    TestID   -> "SplitName-Unqualified@@Tests/SymbolDefinition.wlt:172,1-177,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Attribute Checking*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*isReadProtectedQ*)
VerificationTest[
    (* AASTriangle is ReadProtected *)
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`isReadProtectedQ[ "System`AASTriangle" ],
    True,
    SameTest -> SameQ,
    TestID   -> "IsReadProtected-AASTriangle@@Tests/SymbolDefinition.wlt:186,1-192,2"
]

VerificationTest[
    (* List is not ReadProtected *)
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`isReadProtectedQ[ "System`List" ],
    False,
    SameTest -> SameQ,
    TestID   -> "IsReadProtected-List@@Tests/SymbolDefinition.wlt:194,1-200,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*isLockedQ*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`isLockedQ[ "System`Plus" ],
    False,
    SameTest -> SameQ,
    TestID   -> "IsLocked-Plus@@Tests/SymbolDefinition.wlt:205,1-210,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definition Extraction*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractDefinition*)
VerificationTest[
    $subtractDef = Wolfram`MCPServer`Tools`SymbolDefinition`Private`extractDefinition[ "System`Subtract" ],
    { ___ },
    SameTest -> MatchQ,
    TestID   -> "ExtractSubtract@@Tests/SymbolDefinition.wlt:219,1-224,2"
]

VerificationTest[
    Length[ $subtractDef ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractSubtractNonEmpty@@Tests/SymbolDefinition.wlt:226,1-231,2"
]

VerificationTest[
    MatchQ[
        Quiet @ Wolfram`MCPServer`Tools`SymbolDefinition`Private`extractDefinition[ "System`Map" ],
        { ___ }
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractMap@@Tests/SymbolDefinition.wlt:233,1-241,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`extractDefinition[ "NonExistent12345`Symbol" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "ExtractNonexistent@@Tests/SymbolDefinition.wlt:243,1-248,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Kernel Code Detection*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getKernelCodeDefinitions*)
VerificationTest[
    $plusKernelDefs = Wolfram`MCPServer`Tools`SymbolDefinition`Private`getKernelCodeDefinitions[ "System`Plus" ],
    { __HoldForm },
    SameTest -> MatchQ,
    TestID   -> "KernelCode-Plus@@Tests/SymbolDefinition.wlt:257,1-262,2"
]

VerificationTest[
    MemberQ[
        $plusKernelDefs,
        HoldForm[ Plus[___] := _ ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "KernelCode-PlusHasDownCode@@Tests/SymbolDefinition.wlt:264,1-272,2"
]

VerificationTest[
    $timesKernelDefs = Wolfram`MCPServer`Tools`SymbolDefinition`Private`getKernelCodeDefinitions[ "System`Times" ],
    { __HoldForm },
    SameTest -> MatchQ,
    TestID   -> "KernelCode-Times@@Tests/SymbolDefinition.wlt:274,1-279,2"
]

VerificationTest[
    (* Paclet symbols have no kernel code *)
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`getKernelCodeDefinitions[ "Wolfram`MCPServer`CreateMCPServer" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "KernelCode-PacletSymbolEmpty@@Tests/SymbolDefinition.wlt:281,1-287,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Context Analysis*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractSymbolsFromDefinition*)
VerificationTest[
    (* Note: List is also extracted as it's the head of the expression *)
    $testSymbols = Wolfram`MCPServer`Tools`SymbolDefinition`Private`extractSymbolsFromDefinition[
        { Plus, Times, Map }
    ],
    { HoldForm[ List ], HoldForm[ Plus ], HoldForm[ Times ], HoldForm[ Map ] },
    SameTest -> MatchQ,
    TestID   -> "ExtractSymbols@@Tests/SymbolDefinition.wlt:296,1-304,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getContextsFromSymbols*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`getContextsFromSymbols[
        { HoldForm[ Plus ], HoldForm[ Times ], HoldForm[ Map ] }
    ],
    { "System`" },
    SameTest -> MatchQ,
    TestID   -> "GetContexts@@Tests/SymbolDefinition.wlt:309,1-316,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*buildOptimalContextPath*)
VerificationTest[
    $optimalPath = Wolfram`MCPServer`Tools`SymbolDefinition`Private`buildOptimalContextPath[
        { "MyContext`", "AnotherContext`" }
    ],
    _List? (MemberQ[ #, "System`" ] && MemberQ[ #, "Global`" ] &),
    SameTest -> MatchQ,
    TestID   -> "BuildContextPath@@Tests/SymbolDefinition.wlt:321,1-328,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateContextMap*)
VerificationTest[
    $contextMap = Wolfram`MCPServer`Tools`SymbolDefinition`Private`generateContextMap[
        { HoldForm[ Plus ], HoldForm[ Times ] }
    ],
    _String? (StringContainsQ[ #, "System`" ] &),
    SameTest -> MatchQ,
    TestID   -> "GenerateContextMap@@Tests/SymbolDefinition.wlt:333,1-340,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`generateContextMap[ {} ],
    "",
    SameTest -> SameQ,
    TestID   -> "GenerateContextMapEmpty@@Tests/SymbolDefinition.wlt:342,1-347,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Truncation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*truncateIfNeeded*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`truncateIfNeeded[ "Short string", 1000 ],
    "Short string",
    SameTest -> SameQ,
    TestID   -> "Truncate-NoTruncation@@Tests/SymbolDefinition.wlt:356,1-361,2"
]

VerificationTest[
    $truncated = Wolfram`MCPServer`Tools`SymbolDefinition`Private`truncateIfNeeded[
        StringJoin @ Table[ "x", 500 ],
        100
    ],
    _String? (StringContainsQ[ #, "truncated" ] &),
    SameTest -> MatchQ,
    TestID   -> "Truncate-Applied@@Tests/SymbolDefinition.wlt:363,1-371,2"
]

VerificationTest[
    StringContainsQ[ $truncated, "100/500" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Truncate-ShowsCharCount@@Tests/SymbolDefinition.wlt:373,1-378,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Error Formatting*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatError*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`formatError[ "System`Plus", "Test error message" ],
    "# Plus\n\nError: Test error message",
    SameTest -> SameQ,
    TestID   -> "FormatError-Simple@@Tests/SymbolDefinition.wlt:387,1-392,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`formatError[ "My`Context`Symbol", "Another error" ],
    "# Symbol\n\nError: Another error",
    SameTest -> SameQ,
    TestID   -> "FormatError-Qualified@@Tests/SymbolDefinition.wlt:394,1-399,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Basic Examples*)
VerificationTest[
    (* Quiet suppresses harmless messages about protected symbols during readableForm *)
    $symbolDefResult1 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Plus" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "BasicSystemSymbol@@Tests/SymbolDefinition.wlt:404,1-410,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "# Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsHeader@@Tests/SymbolDefinition.wlt:412,1-417,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "## Definition" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsDefinitionSection@@Tests/SymbolDefinition.wlt:419,1-424,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsCodeBlock@@Tests/SymbolDefinition.wlt:426,1-431,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "<kernel function>" ],
    True,
    SameTest -> SameQ,
    TestID   -> "KernelCodeDetected@@Tests/SymbolDefinition.wlt:433,1-438,2"
]

VerificationTest[
    (* Attributes are shown as a list like {Flat, Listable, ...} *)
    StringContainsQ[ $symbolDefResult1, "Flat" ] && StringContainsQ[ $symbolDefResult1, "Protected" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsAttributes@@Tests/SymbolDefinition.wlt:440,1-446,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Unqualified Symbol Names*)

(* Test that unqualified symbol names work through the full tool *)
VerificationTest[
    $unqualifiedResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Plus" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "UnqualifiedSymbol-Plus@@Tests/SymbolDefinition.wlt:453,1-458,2"
]

VerificationTest[
    StringContainsQ[ $unqualifiedResult, "# Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnqualifiedSymbol-ContainsHeader@@Tests/SymbolDefinition.wlt:460,1-465,2"
]

VerificationTest[
    StringContainsQ[ $unqualifiedResult, "## Definition" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnqualifiedSymbol-ContainsDefinition@@Tests/SymbolDefinition.wlt:467,1-472,2"
]

(* Test that unqualified symbol name resolves to the correct symbol *)
VerificationTest[
    StringContainsQ[ $unqualifiedResult, "<kernel function>" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnqualifiedSymbol-KernelFunction@@Tests/SymbolDefinition.wlt:475,1-480,2"
]

(* Test mixed qualified and unqualified symbol names *)
VerificationTest[
    $mixedQualifiedResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Plus, System`Times" |> ],
    _String? (StringContainsQ[ #, "# Plus" ] && StringContainsQ[ #, "# Times" ] &),
    SameTest -> MatchQ,
    TestID   -> "UnqualifiedSymbol-MixedWithQualified@@Tests/SymbolDefinition.wlt:483,1-488,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Multiple Symbols*)
VerificationTest[
    $symbolDefResult2 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Plus, System`Times" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MultipleSymbols@@Tests/SymbolDefinition.wlt:493,1-498,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult2, "# Plus" ] && StringContainsQ[ $symbolDefResult2, "# Times" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MultipleSymbolsHeaders@@Tests/SymbolDefinition.wlt:500,1-505,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Context Details*)
VerificationTest[
    $symbolDefResult3 = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Map",
        "includeContextDetails" -> True
    |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WithContextDetails@@Tests/SymbolDefinition.wlt:510,1-518,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult3, "## Contexts" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContextsSection@@Tests/SymbolDefinition.wlt:520,1-525,2"
]

VerificationTest[
    $noContextResult = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Plus",
        "includeContextDetails" -> False
    |> ],
    _String? (! StringContainsQ[ #, "## Contexts" ] &),
    SameTest -> MatchQ,
    TestID   -> "NoContextDetails@@Tests/SymbolDefinition.wlt:527,1-535,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Error Cases*)
VerificationTest[
    $symbolDefResult4 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "NonExistent`Symbol12345" |> ],
    _String? (StringContainsQ[ #, "does not exist" ] &),
    SameTest -> MatchQ,
    TestID   -> "NonexistentSymbol@@Tests/SymbolDefinition.wlt:540,1-545,2"
]

VerificationTest[
    $symbolDefResult5 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Invalid!Symbol@Name" |> ],
    _String? (StringContainsQ[ #, "Invalid symbol name" ] &),
    SameTest -> MatchQ,
    TestID   -> "InvalidSymbolName@@Tests/SymbolDefinition.wlt:547,1-552,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Truncation*)
VerificationTest[
    (* Use a very small maxLength to ensure truncation *)
    $symbolDefResult6 = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Table",
        "maxLength" -> 20
    |> ],
    _String? (StringContainsQ[ #, "truncated" ] &),
    SameTest -> MatchQ,
    TestID   -> "Truncation@@Tests/SymbolDefinition.wlt:557,1-566,2"
]

VerificationTest[
    $customLengthResult = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Table",
        "maxLength" -> 50
    |> ],
    _String? (StringContainsQ[ #, "truncated" ] &),
    SameTest -> MatchQ,
    TestID   -> "CustomMaxLength@@Tests/SymbolDefinition.wlt:568,1-576,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Evaluation Leak Prevention*)

(* Test that extractDefinition does not evaluate the RHS of definitions *)
VerificationTest[
    Module[ { counter },
        counter = 0;
        Wolfram`MCPServerTests`$evalLeakTestSymbol1 := (counter++; "result");
        Wolfram`MCPServer`Tools`SymbolDefinition`Private`extractDefinition[
            "Wolfram`MCPServerTests`$evalLeakTestSymbol1"
        ];
        (* counter should still be 0 if no evaluation leak occurred *)
        counter
    ],
    0,
    SameTest -> SameQ,
    TestID   -> "EvaluationLeak-ExtractDefinition@@Tests/SymbolDefinition.wlt:583,1-596,2"
]

(* Test that the full tool does not cause evaluation leaks *)
VerificationTest[
    Module[ { counter },
        counter = 0;
        Wolfram`MCPServerTests`$evalLeakTestSymbol2 := (counter++; "result");
        Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Wolfram`MCPServerTests`$evalLeakTestSymbol2" |> ];
        (* counter should still be 0 if no evaluation leak occurred *)
        counter
    ],
    0,
    SameTest -> SameQ,
    TestID   -> "EvaluationLeak-FullTool@@Tests/SymbolDefinition.wlt:599,1-610,2"
]

(* Test that definitions with side effects are captured correctly without executing them *)
VerificationTest[
    Module[ { result },
        Wolfram`MCPServerTests`$evalLeakTestSymbol3 := Echo["This should NOT print!"];
        result = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Wolfram`MCPServerTests`$evalLeakTestSymbol3" |> ];
        StringContainsQ[ result, "Echo" ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "EvaluationLeak-CapturesDefinition@@Tests/SymbolDefinition.wlt:613,1-622,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes Display*)

(* Test that attributes are displayed properly with Attributes[symbol] = ... format *)
VerificationTest[
    $tableResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Table" |> ],
    _String? (StringContainsQ[ #, "Attributes" ] &),
    SameTest -> MatchQ,
    TestID   -> "AttributesDisplay-ContainsAttributes@@Tests/SymbolDefinition.wlt:629,1-634,2"
]

VerificationTest[
    (* The output should show attributes in a proper assignment form, not just a bare list *)
    (* ReadableForm uses // notation: Table // Attributes = {...} *)
    StringContainsQ[ $tableResult, "Attributes" ] && StringContainsQ[ $tableResult, "HoldAll" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AttributesDisplay-ProperFormat@@Tests/SymbolDefinition.wlt:636,1-643,2"
]

VerificationTest[
    (* Verify that Protected attribute is shown *)
    StringContainsQ[ $tableResult, "Protected" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AttributesDisplay-ShowsProtected@@Tests/SymbolDefinition.wlt:645,1-651,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests*)
VerificationTest[
    $subtractResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Subtract" |> ],
    _String? (StringContainsQ[ #, "# Subtract" ] && StringContainsQ[ #, "## Definition" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-Subtract@@Tests/SymbolDefinition.wlt:656,1-661,2"
]

VerificationTest[
    (* Subtract should show either WL patterns or kernel function indicator *)
    StringContainsQ[ $subtractResult, "x_" ] ||
    StringContainsQ[ $subtractResult, "y_" ] ||
    StringContainsQ[ $subtractResult, "<kernel function>" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SubtractHasDefinition@@Tests/SymbolDefinition.wlt:663,1-671,2"
]

VerificationTest[
    $pacletResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Wolfram`MCPServer`CreateMCPServer" |> ],
    _String? (StringContainsQ[ #, "# CreateMCPServer" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-PacletSymbol@@Tests/SymbolDefinition.wlt:673,1-678,2"
]

VerificationTest[
    (* Use addEnclosureTags which is actually in the Private` context *)
    $privateResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Wolfram`MCPServer`Common`Private`addEnclosureTags" |> ],
    _String? (StringContainsQ[ #, "# addEnclosureTags" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-PrivateSymbol@@Tests/SymbolDefinition.wlt:680,1-686,2"
]

VerificationTest[
    $mixedResult = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Plus, NonExistent12345`BadSymbol, Invalid!Name"
    |> ],
    _String? (
        StringContainsQ[ #, "# Plus" ] &&
        StringContainsQ[ #, "does not exist" ] &&
        StringContainsQ[ #, "Invalid symbol name" ] &
    ),
    SameTest -> MatchQ,
    TestID   -> "Integration-MixedSymbols@@Tests/SymbolDefinition.wlt:688,1-699,2"
]

VerificationTest[
    $contextResult = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Plus, System`Map",
        "includeContextDetails" -> True
    |> ],
    _String? (StringContainsQ[ #, "## Contexts" ] && StringContainsQ[ #, "System`" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-ContextDetails@@Tests/SymbolDefinition.wlt:701,1-709,2"
]

(* :!CodeAnalysis::EndBlock:: *)