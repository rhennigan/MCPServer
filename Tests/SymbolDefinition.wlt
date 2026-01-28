(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/SymbolDefinition.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/SymbolDefinition.wlt:14,1-19,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`Tools`SymbolDefinition`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadPrivateContext@@Tests/SymbolDefinition.wlt:21,1-26,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Registration*)
VerificationTest[
    $symbolDefinitionTool = $DefaultMCPTools[ "SymbolDefinition" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "GetTool@@Tests/SymbolDefinition.wlt:31,1-36,2"
]

VerificationTest[
    $symbolDefinitionTool[ "Name" ],
    "SymbolDefinition",
    SameTest -> SameQ,
    TestID   -> "ToolName@@Tests/SymbolDefinition.wlt:38,1-43,2"
]

VerificationTest[
    StringQ @ $symbolDefinitionTool[ "Description" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolDescription@@Tests/SymbolDefinition.wlt:45,1-50,2"
]

VerificationTest[
    ListQ @ $symbolDefinitionTool[ "Parameters" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolParameters@@Tests/SymbolDefinition.wlt:52,1-57,2"
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
    TestID   -> "ParseSingleSymbol@@Tests/SymbolDefinition.wlt:66,1-71,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`parseSymbolNames[ "System`Plus, System`Times, System`Map" ],
    { "System`Plus", "System`Times", "System`Map" },
    SameTest -> MatchQ,
    TestID   -> "ParseMultipleSymbols@@Tests/SymbolDefinition.wlt:73,1-78,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`parseSymbolNames[ "  System`Plus  ,  System`Times  " ],
    { "System`Plus", "System`Times" },
    SameTest -> MatchQ,
    TestID   -> "ParseWhitespaceHandling@@Tests/SymbolDefinition.wlt:80,1-85,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`parseSymbolNames[ "" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "ParseEmptyInput@@Tests/SymbolDefinition.wlt:87,1-92,2"
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
    TestID   -> "ValidateSimpleName@@Tests/SymbolDefinition.wlt:101,1-106,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "System`Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ValidateQualifiedName@@Tests/SymbolDefinition.wlt:108,1-113,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "My`Context`Symbol" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ValidateDeepContext@@Tests/SymbolDefinition.wlt:115,1-120,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "Invalid!Symbol" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ValidateInvalidChars@@Tests/SymbolDefinition.wlt:122,1-127,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`validateSymbolName[ "123Invalid" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ValidateStartsWithNumber@@Tests/SymbolDefinition.wlt:129,1-134,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*symbolExistsQ*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`symbolExistsQ[ "System`Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExistsSystemSymbol@@Tests/SymbolDefinition.wlt:139,1-144,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`symbolExistsQ[ "NonExistentContext12345`NonExistentSymbol67890" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExistsNonexistent@@Tests/SymbolDefinition.wlt:146,1-151,2"
]

(* Performance test: symbolExistsQ should be fast *)
VerificationTest[
    (* This should complete in under 0.01 seconds if using NameQ *)
    First @ AbsoluteTiming[ Wolfram`MCPServer`Tools`SymbolDefinition`Private`symbolExistsQ[ "System`Plus" ] ] < 0.01,
    True,
    SameTest -> SameQ,
    TestID   -> "ExistsPerformance"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*splitSymbolName*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`splitSymbolName[ "System`Plus" ],
    { "System`", "Plus" },
    SameTest -> MatchQ,
    TestID   -> "SplitName-Simple@@Tests/SymbolDefinition.wlt:156,1-161,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`splitSymbolName[ "My`Deep`Context`Symbol" ],
    { "My`Deep`Context`", "Symbol" },
    SameTest -> MatchQ,
    TestID   -> "SplitName-Deep@@Tests/SymbolDefinition.wlt:163,1-168,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`splitSymbolName[ "UnqualifiedSymbol" ],
    { "Global`", "UnqualifiedSymbol" },
    SameTest -> MatchQ,
    TestID   -> "SplitName-Unqualified@@Tests/SymbolDefinition.wlt:170,1-175,2"
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
    TestID   -> "IsReadProtected-AASTriangle@@Tests/SymbolDefinition.wlt:184,1-190,2"
]

VerificationTest[
    (* List is not ReadProtected *)
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`isReadProtectedQ[ "System`List" ],
    False,
    SameTest -> SameQ,
    TestID   -> "IsReadProtected-List@@Tests/SymbolDefinition.wlt:192,1-198,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*isLockedQ*)
VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`isLockedQ[ "System`Plus" ],
    False,
    SameTest -> SameQ,
    TestID   -> "IsLocked-Plus@@Tests/SymbolDefinition.wlt:203,1-208,2"
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
    TestID   -> "ExtractSubtract@@Tests/SymbolDefinition.wlt:217,1-222,2"
]

VerificationTest[
    Length[ $subtractDef ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractSubtractNonEmpty@@Tests/SymbolDefinition.wlt:224,1-229,2"
]

VerificationTest[
    MatchQ[
        Quiet @ Wolfram`MCPServer`Tools`SymbolDefinition`Private`extractDefinition[ "System`Map" ],
        { ___ }
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractMap@@Tests/SymbolDefinition.wlt:231,1-239,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`extractDefinition[ "NonExistent12345`Symbol" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "ExtractNonexistent@@Tests/SymbolDefinition.wlt:241,1-246,2"
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
    TestID   -> "KernelCode-Plus@@Tests/SymbolDefinition.wlt:255,1-260,2"
]

VerificationTest[
    MemberQ[
        $plusKernelDefs,
        HoldForm[ Plus[___] := _ ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "KernelCode-PlusHasDownCode@@Tests/SymbolDefinition.wlt:262,1-270,2"
]

VerificationTest[
    $timesKernelDefs = Wolfram`MCPServer`Tools`SymbolDefinition`Private`getKernelCodeDefinitions[ "System`Times" ],
    { __HoldForm },
    SameTest -> MatchQ,
    TestID   -> "KernelCode-Times@@Tests/SymbolDefinition.wlt:272,1-277,2"
]

VerificationTest[
    (* Paclet symbols have no kernel code *)
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`getKernelCodeDefinitions[ "Wolfram`MCPServer`CreateMCPServer" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "KernelCode-PacletSymbolEmpty@@Tests/SymbolDefinition.wlt:279,1-285,2"
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
    TestID   -> "ExtractSymbols@@Tests/SymbolDefinition.wlt:294,1-302,2"
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
    TestID   -> "GetContexts@@Tests/SymbolDefinition.wlt:307,1-314,2"
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
    TestID   -> "BuildContextPath@@Tests/SymbolDefinition.wlt:319,1-326,2"
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
    TestID   -> "GenerateContextMap@@Tests/SymbolDefinition.wlt:331,1-338,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`generateContextMap[ {} ],
    "",
    SameTest -> SameQ,
    TestID   -> "GenerateContextMapEmpty@@Tests/SymbolDefinition.wlt:340,1-345,2"
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
    TestID   -> "Truncate-NoTruncation@@Tests/SymbolDefinition.wlt:354,1-359,2"
]

VerificationTest[
    $truncated = Wolfram`MCPServer`Tools`SymbolDefinition`Private`truncateIfNeeded[
        StringJoin @ Table[ "x", 500 ],
        100
    ],
    _String? (StringContainsQ[ #, "truncated" ] &),
    SameTest -> MatchQ,
    TestID   -> "Truncate-Applied@@Tests/SymbolDefinition.wlt:361,1-369,2"
]

VerificationTest[
    StringContainsQ[ $truncated, "100/500" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Truncate-ShowsCharCount@@Tests/SymbolDefinition.wlt:371,1-376,2"
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
    TestID   -> "FormatError-Simple@@Tests/SymbolDefinition.wlt:385,1-390,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`formatError[ "My`Context`Symbol", "Another error" ],
    "# Symbol\n\nError: Another error",
    SameTest -> SameQ,
    TestID   -> "FormatError-Qualified@@Tests/SymbolDefinition.wlt:392,1-397,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Basic Examples*)
VerificationTest[
    (* Quiet suppresses harmless messages about protected symbols during readableForm *)
    $symbolDefResult1 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Plus" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "BasicSystemSymbol@@Tests/SymbolDefinition.wlt:402,1-408,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "# Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsHeader@@Tests/SymbolDefinition.wlt:410,1-415,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "## Definition" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsDefinitionSection@@Tests/SymbolDefinition.wlt:417,1-422,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsCodeBlock@@Tests/SymbolDefinition.wlt:424,1-429,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult1, "<kernel function>" ],
    True,
    SameTest -> SameQ,
    TestID   -> "KernelCodeDetected@@Tests/SymbolDefinition.wlt:431,1-436,2"
]

VerificationTest[
    (* Attributes are shown as a list like {Flat, Listable, ...} *)
    StringContainsQ[ $symbolDefResult1, "Flat" ] && StringContainsQ[ $symbolDefResult1, "Protected" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContainsAttributes@@Tests/SymbolDefinition.wlt:438,1-444,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Unqualified Symbol Names*)

(* Test that unqualified symbol names work through the full tool *)
VerificationTest[
    $unqualifiedResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Plus" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "UnqualifiedSymbol-Plus@@Tests/SymbolDefinition.wlt:451,1-456,2"
]

VerificationTest[
    StringContainsQ[ $unqualifiedResult, "# Plus" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnqualifiedSymbol-ContainsHeader@@Tests/SymbolDefinition.wlt:458,1-463,2"
]

VerificationTest[
    StringContainsQ[ $unqualifiedResult, "## Definition" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnqualifiedSymbol-ContainsDefinition@@Tests/SymbolDefinition.wlt:465,1-470,2"
]

(* Test that unqualified symbol name resolves to the correct symbol *)
VerificationTest[
    StringContainsQ[ $unqualifiedResult, "<kernel function>" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnqualifiedSymbol-KernelFunction@@Tests/SymbolDefinition.wlt:473,1-478,2"
]

(* Test mixed qualified and unqualified symbol names *)
VerificationTest[
    $mixedQualifiedResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Plus, System`Times" |> ],
    _String? (StringContainsQ[ #, "# Plus" ] && StringContainsQ[ #, "# Times" ] &),
    SameTest -> MatchQ,
    TestID   -> "UnqualifiedSymbol-MixedWithQualified@@Tests/SymbolDefinition.wlt:481,1-486,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Multiple Symbols*)
VerificationTest[
    $symbolDefResult2 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Plus, System`Times" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MultipleSymbols@@Tests/SymbolDefinition.wlt:491,1-496,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult2, "# Plus" ] && StringContainsQ[ $symbolDefResult2, "# Times" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MultipleSymbolsHeaders@@Tests/SymbolDefinition.wlt:498,1-503,2"
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
    TestID   -> "WithContextDetails@@Tests/SymbolDefinition.wlt:508,1-516,2"
]

VerificationTest[
    StringContainsQ[ $symbolDefResult3, "## Contexts" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ContextsSection@@Tests/SymbolDefinition.wlt:518,1-523,2"
]

VerificationTest[
    $noContextResult = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Plus",
        "includeContextDetails" -> False
    |> ],
    _String? (! StringContainsQ[ #, "## Contexts" ] &),
    SameTest -> MatchQ,
    TestID   -> "NoContextDetails@@Tests/SymbolDefinition.wlt:525,1-533,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Error Cases*)
VerificationTest[
    $symbolDefResult4 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "NonExistent`Symbol12345" |> ],
    _String? (StringContainsQ[ #, "does not exist" ] &),
    SameTest -> MatchQ,
    TestID   -> "NonexistentSymbol@@Tests/SymbolDefinition.wlt:538,1-543,2"
]

VerificationTest[
    $symbolDefResult5 = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Invalid!Symbol@Name" |> ],
    _String? (StringContainsQ[ #, "Invalid symbol name" ] &),
    SameTest -> MatchQ,
    TestID   -> "InvalidSymbolName@@Tests/SymbolDefinition.wlt:545,1-550,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Did You Mean Suggestions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*findSuggestions*)
VerificationTest[
    MemberQ[
        Wolfram`MCPServer`Tools`SymbolDefinition`Private`findSuggestions[ "BadContext`Plus" ],
        "System`Plus"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FindSuggestions-Plus@@Tests/SymbolDefinition.wlt:559,1-567,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`SymbolDefinition`Private`findSuggestions[ "Nonexistent`NonexistentSymbol98765" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "FindSuggestions-NoMatch@@Tests/SymbolDefinition.wlt:569,1-574,2"
]

VerificationTest[
    (* Should return fully qualified names *)
    AllTrue[
        Wolfram`MCPServer`Tools`SymbolDefinition`Private`findSuggestions[ "Bad`Map" ],
        StringContainsQ[ #, "`" ] &
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FindSuggestions-FullyQualified@@Tests/SymbolDefinition.wlt:576,1-585,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tool Integration*)
VerificationTest[
    $didYouMeanResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "BadContext`Plus" |> ],
    _String? (
        StringContainsQ[ #, "Did you mean one of the following symbols?" ] &&
        StringContainsQ[ #, "```wl" ] &&
        StringContainsQ[ #, "System`Plus" ] &
    ),
    SameTest -> MatchQ,
    TestID   -> "DidYouMean-ShowsSuggestion@@Tests/SymbolDefinition.wlt:590,1-599,2"
]

VerificationTest[
    $noSuggestionResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Nonexistent`NoSuchSymbol98765" |> ],
    _String? (StringContainsQ[ #, "does not exist" ] && ! StringContainsQ[ #, "Did you mean" ] &),
    SameTest -> MatchQ,
    TestID   -> "DidYouMean-NoSuggestionWhenNoMatch@@Tests/SymbolDefinition.wlt:601,1-606,2"
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
    TestID   -> "Truncation@@Tests/SymbolDefinition.wlt:611,1-620,2"
]

VerificationTest[
    $customLengthResult = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Table",
        "maxLength" -> 50
    |> ],
    _String? (StringContainsQ[ #, "truncated" ] &),
    SameTest -> MatchQ,
    TestID   -> "CustomMaxLength@@Tests/SymbolDefinition.wlt:622,1-630,2"
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
    TestID   -> "EvaluationLeak-ExtractDefinition@@Tests/SymbolDefinition.wlt:637,1-650,2"
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
    TestID   -> "EvaluationLeak-FullTool@@Tests/SymbolDefinition.wlt:653,1-664,2"
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
    TestID   -> "EvaluationLeak-CapturesDefinition@@Tests/SymbolDefinition.wlt:667,1-676,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Attributes Display*)

(* Test that attributes are displayed properly with Attributes[symbol] = ... format *)
VerificationTest[
    $tableResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Table" |> ],
    _String? (StringContainsQ[ #, "Attributes" ] &),
    SameTest -> MatchQ,
    TestID   -> "AttributesDisplay-ContainsAttributes@@Tests/SymbolDefinition.wlt:683,1-688,2"
]

VerificationTest[
    (* The output should show attributes in a proper assignment form, not just a bare list *)
    (* ReadableForm uses // notation: Table // Attributes = {...} *)
    StringContainsQ[ $tableResult, "Attributes" ] && StringContainsQ[ $tableResult, "HoldAll" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AttributesDisplay-ProperFormat@@Tests/SymbolDefinition.wlt:690,1-697,2"
]

VerificationTest[
    (* Verify that Protected attribute is shown *)
    StringContainsQ[ $tableResult, "Protected" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AttributesDisplay-ShowsProtected@@Tests/SymbolDefinition.wlt:699,1-705,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests*)
VerificationTest[
    $subtractResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "System`Subtract" |> ],
    _String? (StringContainsQ[ #, "# Subtract" ] && StringContainsQ[ #, "## Definition" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-Subtract@@Tests/SymbolDefinition.wlt:710,1-715,2"
]

VerificationTest[
    (* Subtract should show either WL patterns or kernel function indicator *)
    StringContainsQ[ $subtractResult, "x_" ] ||
    StringContainsQ[ $subtractResult, "y_" ] ||
    StringContainsQ[ $subtractResult, "<kernel function>" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SubtractHasDefinition@@Tests/SymbolDefinition.wlt:717,1-725,2"
]

VerificationTest[
    $pacletResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Wolfram`MCPServer`CreateMCPServer" |> ],
    _String? (StringContainsQ[ #, "# CreateMCPServer" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-PacletSymbol@@Tests/SymbolDefinition.wlt:727,1-732,2"
]

VerificationTest[
    (* Use addEnclosureTags which is actually in the Private` context *)
    $privateResult = Quiet @ $symbolDefinitionTool[ <| "symbols" -> "Wolfram`MCPServer`Common`Private`addEnclosureTags" |> ],
    _String? (StringContainsQ[ #, "# addEnclosureTags" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-PrivateSymbol@@Tests/SymbolDefinition.wlt:734,1-740,2"
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
    TestID   -> "Integration-MixedSymbols@@Tests/SymbolDefinition.wlt:742,1-753,2"
]

VerificationTest[
    $contextResult = Quiet @ $symbolDefinitionTool[ <|
        "symbols" -> "System`Plus, System`Map",
        "includeContextDetails" -> True
    |> ],
    _String? (StringContainsQ[ #, "## Contexts" ] && StringContainsQ[ #, "System`" ] &),
    SameTest -> MatchQ,
    TestID   -> "Integration-ContextDetails@@Tests/SymbolDefinition.wlt:755,1-763,2"
]

(* :!CodeAnalysis::EndBlock:: *)