(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/ValidateAgentToolsPacletExtension.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/ValidateAgentToolsPacletExtension.wlt:11,1-16,2"
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
    TestID   -> "Setup-ValidPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:28,1-35,2"
]

(* Load mock paclet with invalid extension keys *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletInvalidKeys" };
    $mockInvalidKeys = First @ PacletFind[ "MockMCPPacletInvalidKeys" ];
    $mockInvalidKeys[ "Name" ],
    "MockMCPPacletInvalidKeys",
    SameTest -> MatchQ,
    TestID   -> "Setup-InvalidKeysPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:38,1-45,2"
]

(* Load mock paclet with missing definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletMissingFiles" };
    $mockMissingFiles = First @ PacletFind[ "MockMCPPacletMissingFiles" ];
    $mockMissingFiles[ "Name" ],
    "MockMCPPacletMissingFiles",
    SameTest -> MatchQ,
    TestID   -> "Setup-MissingFilesPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:48,1-55,2"
]

(* Load mock paclet with bad definition file contents *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadContents" };
    $mockBadContents = First @ PacletFind[ "MockMCPPacletBadContents" ];
    $mockBadContents[ "Name" ],
    "MockMCPPacletBadContents",
    SameTest -> MatchQ,
    TestID   -> "Setup-BadContentsPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:58,1-65,2"
]

(* Load mock paclet with bad cross-references *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadCrossRef" };
    $mockBadCrossRef = First @ PacletFind[ "MockMCPPacletBadCrossRef" ];
    $mockBadCrossRef[ "Name" ],
    "MockMCPPacletBadCrossRef",
    SameTest -> MatchQ,
    TestID   -> "Setup-BadCrossRefPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:68,1-75,2"
]

(* Load mock paclet with invalid declarations *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletBadDecl" };
    $mockBadDecl = First @ PacletFind[ "MockMCPPacletBadDecl" ];
    $mockBadDecl[ "Name" ],
    "MockMCPPacletBadDecl",
    SameTest -> MatchQ,
    TestID   -> "Setup-BadDeclPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:78,1-85,2"
]

(* Load mock paclet with duplicate definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletDupFiles" };
    $mockDupFiles = First @ PacletFind[ "MockMCPPacletDupFiles" ];
    $mockDupFiles[ "Name" ],
    "MockMCPPacletDupFiles",
    SameTest -> MatchQ,
    TestID   -> "Setup-DupFilesPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:88,1-95,2"
]

(* Load mock paclet with no root directory *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletNoRoot" };
    $mockNoRoot = First @ PacletFind[ "MockMCPPacletNoRoot" ];
    $mockNoRoot[ "Name" ],
    "MockMCPPacletNoRoot",
    SameTest -> MatchQ,
    TestID   -> "Setup-NoRootPaclet@@Tests/ValidateAgentToolsPacletExtension.wlt:98,1-105,2"
]

(* Clear definition cache before validation tests *)
VerificationTest[
    Wolfram`AgentTools`Common`clearPacletDefinitionCache[ ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "Setup-ClearCache@@Tests/ValidateAgentToolsPacletExtension.wlt:108,1-113,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Valid Paclet*)

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockValid ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-ReturnsSuccess@@Tests/ValidateAgentToolsPacletExtension.wlt:119,1-124,2"
]

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockValid ][ "MCPServers" ],
    { "TestServer" },
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-MCPServers@@Tests/ValidateAgentToolsPacletExtension.wlt:126,1-131,2"
]

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockValid ][ "Tools" ],
    { "TestTool", "DescribedTool", "AssocTool", "LLMToolTest" },
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-Tools@@Tests/ValidateAgentToolsPacletExtension.wlt:133,1-138,2"
]

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockValid ][ "MCPPrompts" ],
    { "TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "ValidPaclet-MCPPrompts@@Tests/ValidateAgentToolsPacletExtension.wlt:140,1-145,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Extension Structure - Invalid Keys*)

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockInvalidKeys ],
    _Failure,
    { ValidateAgentToolsPacletExtension::InvalidAgentToolsPacletExtension },
    SameTest -> MatchQ,
    TestID   -> "InvalidKeys-ReturnsFailure@@Tests/ValidateAgentToolsPacletExtension.wlt:151,1-157,2"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockInvalidKeys ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "InvalidExtensionKeys" ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "InvalidKeys-HasInvalidKeysError@@Tests/ValidateAgentToolsPacletExtension.wlt:159,1-167,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Extension Structure - Invalid Declarations*)

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockBadDecl ],
    _Failure,
    { ValidateAgentToolsPacletExtension::InvalidAgentToolsPacletExtension },
    SameTest -> MatchQ,
    TestID   -> "BadDecl-ReturnsFailure@@Tests/ValidateAgentToolsPacletExtension.wlt:173,1-179,2"
]

VerificationTest[
    Module[ { result, declErrors },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockBadDecl ];
        declErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "InvalidDeclaration" & ];
        Length[ declErrors ] >= 1
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "BadDecl-HasInvalidDeclarations@@Tests/ValidateAgentToolsPacletExtension.wlt:181,1-190,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Extension Structure - No AgentTools Extension*)

VerificationTest[
    Module[ { nonMCPPaclet },
        nonMCPPaclet = First @ PacletFind[ "PacletTools" ];
        ValidateAgentToolsPacletExtension[ nonMCPPaclet ]
    ],
    _Failure,
    { ValidateAgentToolsPacletExtension::InvalidAgentToolsPacletExtension },
    SameTest -> MatchQ,
    TestID   -> "NoExtension-ReturnsFailure@@Tests/ValidateAgentToolsPacletExtension.wlt:196,1-205,2"
]

VerificationTest[
    Module[ { nonMCPPaclet, result },
        nonMCPPaclet = First @ PacletFind[ "PacletTools" ];
        result = Quiet @ ValidateAgentToolsPacletExtension[ nonMCPPaclet ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "NoAgentToolsExtension" ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "NoExtension-HasNoAgentToolsExtensionError@@Tests/ValidateAgentToolsPacletExtension.wlt:207,1-216,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Existence - Missing Root Directory*)

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockNoRoot ],
    _Failure,
    { ValidateAgentToolsPacletExtension::InvalidAgentToolsPacletExtension },
    SameTest -> MatchQ,
    TestID   -> "NoRoot-ReturnsFailure@@Tests/ValidateAgentToolsPacletExtension.wlt:222,1-228,2"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockNoRoot ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "MissingRootDirectory" ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "NoRoot-HasMissingRootError@@Tests/ValidateAgentToolsPacletExtension.wlt:230,1-238,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Existence - Missing Definition Files*)

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockMissingFiles ],
    _Failure,
    { ValidateAgentToolsPacletExtension::InvalidAgentToolsPacletExtension },
    SameTest -> MatchQ,
    TestID   -> "MissingFiles-ReturnsFailure@@Tests/ValidateAgentToolsPacletExtension.wlt:244,1-250,2"
]

VerificationTest[
    Module[ { result, missingErrors },
        GeneralUtilities`EnsureDirectory @ { $testResourceDirectory, "MockMCPPacletMissingFiles", "AgentTools" };
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockMissingFiles ];
        missingErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "MissingDefinitionFile" & ];
        Length[ missingErrors ]
    ],
    3,
    SameTest -> MatchQ,
    TestID   -> "MissingFiles-ThreeMissingFiles@@Tests/ValidateAgentToolsPacletExtension.wlt:252,1-262,2"
]

VerificationTest[
    Module[ { result, missingErrors },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockMissingFiles ];
        missingErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "MissingDefinitionFile" & ];
        Sort @ Lookup[ missingErrors, "Item" ]
    ],
    { "MissingPrompt", "MissingServer", "MissingTool" },
    SameTest -> MatchQ,
    TestID   -> "MissingFiles-CorrectItems@@Tests/ValidateAgentToolsPacletExtension.wlt:264,1-273,2"
]

VerificationTest[
    Module[ { result, missingErrors },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockMissingFiles ];
        missingErrors = Select[ result[[ "Errors" ]], #[ "Type" ] === "MissingDefinitionFile" & ];
        AllTrue[ missingErrors, KeyExistsQ[ #, "ExpectedPath" ] & ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "MissingFiles-HasExpectedPaths@@Tests/ValidateAgentToolsPacletExtension.wlt:275,1-284,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Existence - Duplicate Definition Files*)

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockDupFiles ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ "Type" -> "DuplicateDefinitionFiles" ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "DupFiles-HasDuplicateWarning@@Tests/ValidateAgentToolsPacletExtension.wlt:290,1-298,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*File Contents - Bad Tool Definition*)

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockBadContents ],
    _Failure,
    { ValidateAgentToolsPacletExtension::InvalidAgentToolsPacletExtension },
    SameTest -> MatchQ,
    TestID   -> "BadContents-ReturnsFailure@@Tests/ValidateAgentToolsPacletExtension.wlt:304,1-310,2"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockBadContents ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidDefinitionContents", "Item" -> "BadTool" } ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "BadContents-BadToolDetected@@Tests/ValidateAgentToolsPacletExtension.wlt:312,1-320,2"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockBadContents ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidToolDefinition", "Item" -> "IncompleteTool" } ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "BadContents-IncompleteToolDetected@@Tests/ValidateAgentToolsPacletExtension.wlt:322,1-330,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cross-References - Invalid References*)

VerificationTest[
    ValidateAgentToolsPacletExtension[ $mockBadCrossRef ],
    _Failure,
    { ValidateAgentToolsPacletExtension::InvalidAgentToolsPacletExtension },
    SameTest -> MatchQ,
    TestID   -> "BadCrossRef-ReturnsFailure@@Tests/ValidateAgentToolsPacletExtension.wlt:336,1-342,2"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockBadCrossRef ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidToolReference", "Tool" -> "UndeclaredTool" } ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "BadCrossRef-UndeclaredToolDetected@@Tests/ValidateAgentToolsPacletExtension.wlt:344,1-352,2"
]

VerificationTest[
    Module[ { result },
        result = Quiet @ ValidateAgentToolsPacletExtension[ $mockBadCrossRef ];
        MemberQ[ result[[ "Errors" ]], KeyValuePattern[ { "Type" -> "InvalidPromptReference", "Prompt" -> "UndeclaredPrompt" } ] ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "BadCrossRef-UndeclaredPromptDetected@@Tests/ValidateAgentToolsPacletExtension.wlt:354,1-362,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cross-References - Valid Short Names*)

VerificationTest[
    MatchQ[ ValidateAgentToolsPacletExtension[ $mockValid ], _Success ],
    True,
    SameTest -> MatchQ,
    TestID   -> "CrossRef-ShortNamesValid@@Tests/ValidateAgentToolsPacletExtension.wlt:368,1-373,2"
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
    Wolfram`AgentTools`Common`clearPacletDefinitionCache[ ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "Cleanup@@Tests/ValidateAgentToolsPacletExtension.wlt:378,1-391,2"
]

(* :!CodeAnalysis::EndBlock:: *)
