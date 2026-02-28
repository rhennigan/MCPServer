(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/ToolOptions.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/ToolOptions.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$defaultToolOptions*)
VerificationTest[
    Wolfram`MCPServer`Common`$defaultToolOptions,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DefaultToolOptions-IsAssociation@@Tests/ToolOptions.wlt:24,1-29,2"
]

VerificationTest[
    Sort @ Keys @ Wolfram`MCPServer`Common`$defaultToolOptions,
    { "WolframAlphaContext", "WolframContext", "WolframLanguageContext", "WolframLanguageEvaluator" },
    SameTest -> MatchQ,
    TestID   -> "DefaultToolOptions-Keys@@Tests/ToolOptions.wlt:31,1-36,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`$defaultToolOptions[ "WolframLanguageEvaluator" ],
    KeyValuePattern @ {
        "Method"            -> "Session",
        "ImageExportMethod" -> "None",
        "TimeConstraint"    -> 60
    },
    SameTest -> MatchQ,
    TestID   -> "DefaultToolOptions-WolframLanguageEvaluator@@Tests/ToolOptions.wlt:38,1-47,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`$defaultToolOptions[ "WolframLanguageContext" ],
    KeyValuePattern[ "MaxItems" -> 10 ],
    SameTest -> MatchQ,
    TestID   -> "DefaultToolOptions-WolframLanguageContext@@Tests/ToolOptions.wlt:49,1-54,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`$defaultToolOptions[ "WolframAlphaContext" ],
    KeyValuePattern @ {
        "MaxItems"                     -> Automatic,
        "IncludeWolframLanguageResults" -> Automatic
    },
    SameTest -> MatchQ,
    TestID   -> "DefaultToolOptions-WolframAlphaContext@@Tests/ToolOptions.wlt:56,1-64,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`$defaultToolOptions[ "WolframContext" ],
    KeyValuePattern @ {
        "WolframLanguageMaxItems" -> 10,
        "WolframAlphaMaxItems"    -> Automatic
    },
    SameTest -> MatchQ,
    TestID   -> "DefaultToolOptions-WolframContext@@Tests/ToolOptions.wlt:66,1-74,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*toolOptionValue*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$toolOptions = <||> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "Method" ]
    ],
    "Session",
    TestID -> "ToolOptionValue-FallbackToDefault@@Tests/ToolOptions.wlt:79,1-85,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$toolOptions = <||> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "TimeConstraint" ]
    ],
    60,
    TestID -> "ToolOptionValue-FallbackToDefault-TimeConstraint@@Tests/ToolOptions.wlt:87,1-93,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$toolOptions = <||> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageContext", "MaxItems" ]
    ],
    10,
    TestID -> "ToolOptionValue-FallbackToDefault-MaxItems@@Tests/ToolOptions.wlt:95,1-101,2"
]

VerificationTest[
    Block[
        { Wolfram`MCPServer`Common`$toolOptions = <| "WolframLanguageEvaluator" -> <| "Method" -> "Local" |> |> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "Method" ]
    ],
    "Local",
    TestID -> "ToolOptionValue-UserOverride@@Tests/ToolOptions.wlt:103,1-110,2"
]

VerificationTest[
    Block[
        { Wolfram`MCPServer`Common`$toolOptions = <| "WolframLanguageEvaluator" -> <| "Method" -> "Local" |> |> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "TimeConstraint" ]
    ],
    60,
    TestID -> "ToolOptionValue-UserOverridePartial-FallbackForOtherKeys@@Tests/ToolOptions.wlt:112,1-119,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$toolOptions = <||> },
        Wolfram`MCPServer`Common`toolOptionValue[ "NonexistentTool", "SomeOption" ]
    ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "ToolOptionValue-MissingTool@@Tests/ToolOptions.wlt:121,1-128,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$toolOptions = <||> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "NonexistentOption" ]
    ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "ToolOptionValue-MissingOption@@Tests/ToolOptions.wlt:130,1-137,2"
]

VerificationTest[
    Block[
        { Wolfram`MCPServer`Common`$toolOptions = <| "WolframLanguageEvaluator" -> <| "TimeConstraint" -> 120 |> |> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "TimeConstraint" ]
    ],
    120,
    TestID -> "ToolOptionValue-CustomTimeConstraint@@Tests/ToolOptions.wlt:139,1-146,2"
]

VerificationTest[
    Block[
        { Wolfram`MCPServer`Common`$toolOptions = <| "WolframLanguageContext" -> <| "MaxItems" -> 5 |> |> },
        Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageContext", "MaxItems" ]
    ],
    5,
    TestID -> "ToolOptionValue-CustomMaxItems@@Tests/ToolOptions.wlt:148,1-155,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*parseToolOptions*)
VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions[ $Failed ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "ParseToolOptions-Failed@@Tests/ToolOptions.wlt:160,1-165,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions[ $Failed ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "ParseToolOptions-FailedReturnsAssociation@@Tests/ToolOptions.wlt:167,1-172,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions[ "" ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "ParseToolOptions-EmptyString@@Tests/ToolOptions.wlt:174,1-179,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions[ "invalid json" ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "ParseToolOptions-InvalidJSON@@Tests/ToolOptions.wlt:181,1-186,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions[
        "{\"WolframLanguageEvaluator\":{\"Method\":\"Local\"}}"
    ],
    KeyValuePattern[ "WolframLanguageEvaluator" -> KeyValuePattern[ "Method" -> "Local" ] ],
    SameTest -> MatchQ,
    TestID   -> "ParseToolOptions-ValidJSON@@Tests/ToolOptions.wlt:188,1-195,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Serialization Round-Trip*)
VerificationTest[
    Module[ { opts, json, parsed },
        opts = <| "WolframLanguageEvaluator" -> <| "Method" -> "Local", "TimeConstraint" -> 120 |> |>;
        json = Developer`WriteRawJSONString[ opts, "Compact" -> True ];
        parsed = Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions @ json;
        Block[ { Wolfram`MCPServer`Common`$toolOptions = parsed },
            Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "Method" ]
        ]
    ],
    "Local",
    TestID -> "RoundTrip-MethodPreserved@@Tests/ToolOptions.wlt:200,1-211,2"
]

VerificationTest[
    Module[ { opts, json, parsed },
        opts = <| "WolframLanguageEvaluator" -> <| "Method" -> "Local", "TimeConstraint" -> 120 |> |>;
        json = Developer`WriteRawJSONString[ opts, "Compact" -> True ];
        parsed = Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions @ json;
        Block[ { Wolfram`MCPServer`Common`$toolOptions = parsed },
            Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "TimeConstraint" ]
        ]
    ],
    120,
    TestID -> "RoundTrip-TimeConstraintPreserved@@Tests/ToolOptions.wlt:213,1-224,2"
]

VerificationTest[
    Module[ { opts, json, parsed },
        opts = <| "WolframLanguageContext" -> <| "MaxItems" -> 5 |> |>;
        json = Developer`WriteRawJSONString[ opts, "Compact" -> True ];
        parsed = Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions @ json;
        Block[ { Wolfram`MCPServer`Common`$toolOptions = parsed },
            Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageContext", "MaxItems" ]
        ]
    ],
    5,
    TestID -> "RoundTrip-MaxItemsPreserved@@Tests/ToolOptions.wlt:226,1-237,2"
]

VerificationTest[
    Module[ { opts, json, parsed },
        opts = <|
            "WolframLanguageEvaluator" -> <| "Method" -> "Local" |>,
            "WolframLanguageContext"   -> <| "MaxItems" -> 20 |>
        |>;
        json = Developer`WriteRawJSONString[ opts, "Compact" -> True ];
        parsed = Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions @ json;
        Block[ { Wolfram`MCPServer`Common`$toolOptions = parsed },
            {
                Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "Method" ],
                Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageContext", "MaxItems" ],
                (* Unset options fall back to defaults *)
                Wolfram`MCPServer`Common`toolOptionValue[ "WolframLanguageEvaluator", "ImageExportMethod" ]
            }
        ]
    ],
    { "Local", 20, "None" },
    TestID -> "RoundTrip-MultipleToolsPreserved@@Tests/ToolOptions.wlt:239,1-258,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Legacy Environment Variable Migration*)
VerificationTest[
    Block[ { $Environment },
        $Environment = <||>;
        SetEnvironment[ "WOLFRAM_LANGUAGE_EVALUATOR_METHOD" -> "Local" ];
        Module[ { parsed },
            parsed = Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions[ $Failed ];
            parsed[ "WolframLanguageEvaluator", "Method" ]
        ]
    ],
    "Local",
    TestID -> "LegacyMigration-MethodEnvVar@@Tests/ToolOptions.wlt:263,1-274,2"
]

VerificationTest[
    Block[ { $Environment },
        $Environment = <||>;
        SetEnvironment[ "WOLFRAM_LANGUAGE_EVALUATOR_IMAGE_EXPORT_METHOD" -> "Cloud" ];
        Module[ { parsed },
            parsed = Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions[ $Failed ];
            parsed[ "WolframLanguageEvaluator", "ImageExportMethod" ]
        ]
    ],
    "Cloud",
    TestID -> "LegacyMigration-ImageExportMethodEnvVar@@Tests/ToolOptions.wlt:276,1-287,2"
]

VerificationTest[
    Block[ { $Environment },
        $Environment = <||>;
        SetEnvironment[ "WOLFRAM_LANGUAGE_EVALUATOR_METHOD" -> "Local" ];
        Module[ { json, parsed },
            (* MCP_TOOL_OPTIONS takes priority over legacy env var *)
            json = "{\"WolframLanguageEvaluator\":{\"Method\":\"Session\"}}";
            parsed = Wolfram`MCPServer`StartMCPServer`Private`parseToolOptions @ json;
            parsed[ "WolframLanguageEvaluator", "Method" ]
        ]
    ],
    "Session",
    TestID -> "LegacyMigration-ToolOptionsHasPriority@@Tests/ToolOptions.wlt:289,1-302,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*InstallMCPServer with ToolOptions*)
VerificationTest[
    Module[ { configFile, name, server, result, data, env },
        configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_test_toolopts_", CreateUUID[], ".json" ] };
        name = StringJoin[ "TestServer_ToolOpts_", CreateUUID[] ];
        server = CreateMCPServer[
            name,
            LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
        ];
        result = InstallMCPServer[
            configFile, server,
            "ToolOptions" -> <| "WolframLanguageEvaluator" -> <| "Method" -> "Local" |> |>,
            "VerifyLLMKit" -> False
        ];
        data = Developer`ReadRawJSONString @ ReadString @ First @ configFile;
        env = data[ "mcpServers", name, "env" ];
        Quiet @ DeleteFile @ First @ configFile;
        KeyExistsQ[ env, "MCP_TOOL_OPTIONS" ]
    ],
    True,
    TestID -> "InstallMCPServer-ToolOptionsEnvVarExists@@Tests/ToolOptions.wlt:307,1-327,2"
]

VerificationTest[
    Module[ { configFile, name, server, result, data, env, toolOpts },
        configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_test_toolopts2_", CreateUUID[], ".json" ] };
        name = StringJoin[ "TestServer_ToolOpts2_", CreateUUID[] ];
        server = CreateMCPServer[
            name,
            LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
        ];
        result = InstallMCPServer[
            configFile, server,
            "ToolOptions" -> <| "WolframLanguageEvaluator" -> <| "Method" -> "Local", "TimeConstraint" -> 120 |> |>,
            "VerifyLLMKit" -> False
        ];
        data = Developer`ReadRawJSONString @ ReadString @ First @ configFile;
        env = data[ "mcpServers", name, "env" ];
        toolOpts = Developer`ReadRawJSONString @ env[ "MCP_TOOL_OPTIONS" ];
        Quiet @ DeleteFile @ First @ configFile;
        toolOpts[ "WolframLanguageEvaluator" ]
    ],
    KeyValuePattern @ { "Method" -> "Local", "TimeConstraint" -> 120 },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-ToolOptionsRoundTrip@@Tests/ToolOptions.wlt:329,1-351,2"
]

VerificationTest[
    Module[ { configFile, name, server, result, data, env },
        configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_test_toolopts3_", CreateUUID[], ".json" ] };
        name = StringJoin[ "TestServer_ToolOpts3_", CreateUUID[] ];
        server = CreateMCPServer[
            name,
            LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
        ];
        result = InstallMCPServer[
            configFile, server,
            "ToolOptions" -> <||>,
            "VerifyLLMKit" -> False
        ];
        data = Developer`ReadRawJSONString @ ReadString @ First @ configFile;
        env = data[ "mcpServers", name, "env" ];
        Quiet @ DeleteFile @ First @ configFile;
        KeyExistsQ[ env, "MCP_TOOL_OPTIONS" ]
    ],
    False,
    TestID -> "InstallMCPServer-EmptyToolOptionsNoEnvVar@@Tests/ToolOptions.wlt:353,1-373,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*validateToolOptions*)
VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`validateToolOptions[ <| |>, MCPServerObject[ "Wolfram" ] ],
    <| |>,
    TestID -> "ValidateToolOptions-Empty@@Tests/ToolOptions.wlt:378,1-382,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`validateToolOptions[
        <| "WolframLanguageEvaluator" -> <| "Method" -> "Local" |> |>,
        MCPServerObject[ "Wolfram" ]
    ],
    KeyValuePattern[ "WolframLanguageEvaluator" -> KeyValuePattern[ "Method" -> "Local" ] ],
    SameTest -> MatchQ,
    TestID   -> "ValidateToolOptions-ValidOptions@@Tests/ToolOptions.wlt:384,1-392,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`validateToolOptions[ "not an association", MCPServerObject[ "Wolfram" ] ],
    <| |>,
    { MCPServer::InvalidToolOptions },
    SameTest -> MatchQ,
    TestID   -> "ValidateToolOptions-InvalidType@@Tests/ToolOptions.wlt:394,1-400,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`validateToolOptions[
        <| "NonexistentTool" -> <| "Foo" -> "Bar" |> |>,
        MCPServerObject[ "Wolfram" ]
    ],
    KeyValuePattern[ "NonexistentTool" -> KeyValuePattern[ "Foo" -> "Bar" ] ],
    { MCPServer::UnrecognizedToolOption },
    SameTest -> MatchQ,
    TestID   -> "ValidateToolOptions-UnrecognizedToolName@@Tests/ToolOptions.wlt:402,1-411,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`validateToolOptions[
        <| "WolframLanguageEvaluator" -> <| "NonexistentOption" -> "value" |> |>,
        MCPServerObject[ "Wolfram" ]
    ],
    KeyValuePattern[ "WolframLanguageEvaluator" -> KeyValuePattern[ "NonexistentOption" -> "value" ] ],
    { MCPServer::UnrecognizedToolOptionName },
    SameTest -> MatchQ,
    TestID   -> "ValidateToolOptions-UnrecognizedOptionName@@Tests/ToolOptions.wlt:413,1-422,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$toolOptions Initialization*)
VerificationTest[
    Wolfram`MCPServer`Common`$toolOptions,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "ToolOptionsInitialized@@Tests/ToolOptions.wlt:427,1-432,2"
]

(* :!CodeAnalysis::EndBlock:: *)
