(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/ValidateMCPPacletExtension.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/ValidateMCPPacletExtension.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Mock Paclet Setup*)

$testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" };

(* Load existing valid mock paclet *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    $mockValid = First @ PacletFind[ "MockMCPPacletTest" ];
    $mockValid[ "Name" ],
    "MockMCPPacletTest",
    SameTest -> MatchQ,
    TestID   -> "Setup-ValidPaclet@@Tests/ValidateMCPPacletExtension.wlt:28,1-35,2"
]

(* Load mock paclet with invalid extension keys *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletInvalidKeys" };
    $mockInvalidKeys = First @ PacletFind[ "MockMCPPacletInvalidKeys" ];
    $mockInvalidKeys[ "Name" ],
    "MockMCPPacletInvalidKeys",
    SameTest -> MatchQ,
    TestID   -> "Setup-InvalidKeysPaclet@@Tests/ValidateMCPPacletExtension.wlt:38,1-45,2"
]

(* Load mock paclet with missing definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletMissingFiles" };
    $mockMissingFiles = First @ PacletFind[ "MockMCPPacletMissingFiles" ];
    $mockMissingFiles[ "Name" ],
    "MockMCPPacletMissingFiles",
    SameTest -> MatchQ,
    TestID   -> "Setup-MissingFilesPaclet@@Tests/ValidateMCPPacletExtension.wlt:48,1-55,2"
]

(* Load mock paclet with bad definition file contents *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadContents" };
    $mockBadContents = First @ PacletFind[ "MockMCPPacletBadContents" ];
    $mockBadContents[ "Name" ],
    "MockMCPPacletBadContents",
    SameTest -> MatchQ,
    TestID   -> "Setup-BadContentsPaclet@@Tests/ValidateMCPPacletExtension.wlt:58,1-65,2"
]

(* Load mock paclet with bad cross-references *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadCrossRef" };
    $mockBadCrossRef = First @ PacletFind[ "MockMCPPacletBadCrossRef" ];
    $mockBadCrossRef[ "Name" ],
    "MockMCPPacletBadCrossRef",
    SameTest -> MatchQ,
    TestID   -> "Setup-BadCrossRefPaclet@@Tests/ValidateMCPPacletExtension.wlt:68,1-75,2"
]

(* Load mock paclet with invalid declarations *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadDecl" };
    $mockBadDecl = First @ PacletFind[ "MockMCPPacletBadDecl" ];
    $mockBadDecl[ "Name" ],
    "MockMCPPacletBadDecl",
    SameTest -> MatchQ,
    TestID   -> "Setup-BadDeclPaclet@@Tests/ValidateMCPPacletExtension.wlt:78,1-85,2"
]

(* Load mock paclet with duplicate definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletDupFiles" };
    $mockDupFiles = First @ PacletFind[ "MockMCPPacletDupFiles" ];
    $mockDupFiles[ "Name" ],
    "MockMCPPacletDupFiles",
    SameTest -> MatchQ,
    TestID   -> "Setup-DupFilesPaclet@@Tests/ValidateMCPPacletExtension.wlt:88,1-95,2"
]

(* Load mock paclet with no root directory *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletNoRoot" };
    $mockNoRoot = First @ PacletFind[ "MockMCPPacletNoRoot" ];
    $mockNoRoot[ "Name" ],
    "MockMCPPacletNoRoot",
    SameTest -> MatchQ,
    TestID   -> "Setup-NoRootPaclet@@Tests/ValidateMCPPacletExtension.wlt:98,1-105,2"
]

(* Clear definition cache before validation tests *)
VerificationTest[
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ],
    <||>,
    SameTest -> MatchQ,
    TestID   -> "Setup-ClearCache@@Tests/ValidateMCPPacletExtension.wlt:108,1-113,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Valid Paclet*)

VerificationTest[
    ValidateMCPPacletExtension[ $mockValid ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-ReturnsSuccess@@Tests/ValidateMCPPacletExtension.wlt:119,1-124,2"
]

VerificationTest[
    ValidateMCPPacletExtension[ $mockValid ][ "Servers" ],
    { "TestServer" },
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-Servers@@Tests/ValidateMCPPacletExtension.wlt:126,1-131,2"
]

VerificationTest[
    ValidateMCPPacletExtension[ $mockValid ][ "Tools" ],
    { "TestTool", "DescribedTool", "AssocTool" },
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-Tools@@Tests/ValidateMCPPacletExtension.wlt:133,1-138,2"
]

VerificationTest[
    ValidateMCPPacletExtension[ $mockValid ][ "Prompts" ],
    { "TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-Prompts@@Tests/ValidateMCPPacletExtension.wlt:140,1-145,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Extension Structure — Invalid Keys*)

VerificationTest[
    ValidateMCPPacletExtension[ $mockInvalidKeys ],
    _Failure,
    { ValidateMCPPacletExtension::InvalidMCPPacletExtension },
    SameTest -> MatchQ,
    TestID   -"InvalidKeys-ReturnsFailure@@Tests/ValidateMCPPacletExtension.wlt:151,1-157,2"e"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateMCPPacletExtension[ $mockInvalidKeys ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "InvalidExtensionKeys" ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -"InvalidKeys-HasInvalidKeysError@@Tests/ValidateMCPPacletExtension.wlt:159,1-167,2"r"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Extension Structure — Invalid Declarations*)

VerificationTest[
    ValidateMCPPacletExtension[ $mockBadDecl ],
    _Failure,
    { ValidateMCPPacletExtension::InvalidMCPPacletExtension },
    SameTest -> MatchQ,
    TestID  "BadDecl-ReturnsFailure@@Tests/ValidateMCPPacletExtension.wlt:173,1-179,2"ure"
]

VerificationTest[
    Module[ { result, declErrors },
        result = Quiet @ ValidateMCPPacletExtension[ $mockBadDecl ];
        declErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "InvalidDeclaration" & ];
        Length[ declErrors ] >= 1
    ],
    True,
    SameTest -> MatchQ,
    TestID  "BadDecl-HasInvalidDeclarations@@Tests/ValidateMCPPacletExtension.wlt:181,1-190,2"ons"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Extension Structure — No MCP Extension*)

VerificationTest[
    Module[ { nonMCPPaclet },
        nonMCPPaclet = First @ PacletFind[ "PacletTools" ];
        ValidateMCPPacletExtension[ nonMCPPaclet ]
    ],
    _Failure,
    { ValidateMCPPacletExtension::InvalidMCPPacletExtension },
    SameTest -> MatchQ,
    TestID"NoExtension-ReturnsFailure@@Tests/ValidateMCPPacletExtension.wlt:196,1-205,2"ilure"
]

VerificationTest[
    Module[ { nonMCPPaclet, result },
        nonMCPPaclet = First @ PacletFind[ "PacletTools" ];
        result = Quiet @ ValidateMCPPacletExtension[ nonMCPPaclet ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "NoMCPExtension" ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID"NoExtension-HasNoMCPExtensionError@@Tests/ValidateMCPPacletExtension.wlt:207,1-216,2"Error"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Existence — Missing Root Directory*)

VerificationTest[
    ValidateMCPPacletExtension[ $mockNoRoot ],
    _Failure,
    { ValidateMCPPacletExtension::InvalidMCPPacletExtension },
    SameTest -> MatchQ,
    Test"NoRoot-ReturnsFailure@@Tests/ValidateMCPPacletExtension.wlt:222,1-228,2"Failure"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateMCPPacletExtension[ $mockNoRoot ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "MissingRootDirectory" ] ]
    ],
    True,
    SameTest -> MatchQ,
    Test"NoRoot-HasMissingRootError@@Tests/ValidateMCPPacletExtension.wlt:230,1-238,2"otError"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Existence — Missing Definition Files*)

VerificationTest[
    ValidateMCPPacletExtension[ $mockMissingFiles ],
    _Failure,
    { ValidateMCPPacletExtension::InvalidMCPPacletExtension },
    SameTest -> MatchQ,
    Te"MissingFiles-ReturnsFailure@@Tests/ValidateMCPPacletExtension.wlt:244,1-250,2"nsFailure"
]

VerificationTest[
    Module[ { result, missingErrors },
        result = Quiet @ ValidateMCPPacletExtension[ $mockMissingFiles ];
        missingErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "MissingDefinitionFile" & ];
        Length[ missingErrors ]
    ],
    3,
    SameTest -> MatchQ,
    Te"MissingFiles-ThreeMissingFiles@@Tests/ValidateMCPPacletExtension.wlt:252,1-261,2"singFiles"
]

VerificationTest[
    Module[ { result, missingErrors },
        result = Quiet @ ValidateMCPPacletExtension[ $mockMissingFiles ];
        missingErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "MissingDefinitionFile" & ];
        Sort @ Lookup[ missingErrors, "Item" ]
    ],
    { "MissingPrompt", "MissingServer", "MissingTool" },
    SameTest -> MatchQ,
    Te"MissingFiles-CorrectItems@@Tests/ValidateMCPPacletExtension.wlt:263,1-272,2"rectItems"
]

VerificationTest[
    Module[ { result, missingErrors },
        result = Quiet @ ValidateMCPPacletExtension[ $mockMissingFiles ];
        missingErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "MissingDefinitionFile" & ];
        AllTrue[ missingErrors, KeyExistsQ[ #, "ExpectedPath" ] & ]
    ],
    True,
    SameTest -> MatchQ,
    Te"MissingFiles-HasExpectedPaths@@Tests/ValidateMCPPacletExtension.wlt:274,1-283,2"ctedPaths"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Existence — Duplicate Definition Files*)

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateMCPPacletExtension[ $mockDupFiles ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "DuplicateDefinitionFiles" ] ]
    ],
    True,
    SameTest -> MatchQ,
    "DupFiles-HasDuplicateWarning@@Tests/ValidateMCPPacletExtension.wlt:289,1-297,2"cateWarning"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Contents — Bad Tool Definition*)

VerificationTest[
    ValidateMCPPacletExtension[ $mockBadContents ],
    _Failure,
    { ValidateMCPPacletExtension::InvalidMCPPacletExtension },
    SameTest -> MatchQ,
  "BadContents-ReturnsFailure@@Tests/ValidateMCPPacletExtension.wlt:303,1-309,2"eturnsFailure"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateMCPPacletExtension[ $mockBadContents ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidDefinitionContents", "Item" -> "BadTool" } ] ]
    ],
    True,
    SameTest -> MatchQ,
  "BadContents-BadToolDetected@@Tests/ValidateMCPPacletExtension.wlt:311,1-319,2"dToolDetected"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateMCPPacletExtension[ $mockBadContents ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidToolDefinition", "Item" -> "IncompleteTool" } ] ]
    ],
    True,
    SameTest -> MatchQ,
  "BadContents-IncompleteToolDetected@@Tests/ValidateMCPPacletExtension.wlt:321,1-329,2"eToolDetected"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cross-References — Invalid References*)

VerificationTest[
    ValidateMCPPacletExtension[ $mockBadCrossRef ],
    _Failure,
    { ValidateMCPPacletExtension::InvalidMCPPacletExtension },
    SameTest -> MatchQ,
"BadCrossRef-ReturnsFailure@@Tests/ValidateMCPPacletExtension.wlt:335,1-341,2"-ReturnsFailure"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateMCPPacletExtension[ $mockBadCrossRef ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidToolReference", "Tool" -> "UndeclaredTool" } ] ]
    ],
    True,
    SameTest -> MatchQ,
"BadCrossRef-UndeclaredToolDetected@@Tests/ValidateMCPPacletExtension.wlt:343,1-351,2"redToolDetected"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateMCPPacletExtension[ $mockBadCrossRef ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidPromptReference", "Prompt" -> "UndeclaredPrompt" } ] ]
    ],
    True,
    SameTest -> MatchQ,
"BadCrossRef-UndeclaredPromptDetected@@Tests/ValidateMCPPacletExtension.wlt:353,1-361,2"dPromptDetected"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cross-References — Valid Short Names*)

VerificationTest[
    MatchQ[ ValidateMCPPacletExtension[ $mockValid ], _Success ],
    True,
    SameTest -> MatchQ"CrossRef-ShortNamesValid@@Tests/ValidateMCPPacletExtension.wlt:367,1-372,2"f-ShortNamesValid"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Mock Paclet Cleanup*)
VerificationTest[
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletInvalidKeys" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletMissingFiles" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadContents" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadCrossRef" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadDecl" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletDupFiles" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletNoRoot" };
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ],
    <||>,
    SameTest -> MatchQ"Cleanup@@Tests/ValidateMCPPacletExtension.wlt:377,1-390,2"tID   -> "Cleanup"
]

(* :!CodeAnalysis::EndBlock:: *)
