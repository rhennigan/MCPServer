(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/YAML.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/YAML.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Helper Functions*)

(* Setup a temporary file to use for testing YAML I/O *)
testYAMLFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "yaml_test_", CreateUUID[ ], ".yaml" ] }
];

(* Clean up any test files that might be created *)
cleanupTestFiles = Function[ files,
    DeleteFile /@ Select[ Flatten[ { files } ], FileExistsQ ]
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*exportYAMLString -- Scalars*)
VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ "hello" ],
    "hello",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-PlainString@@Tests/YAML.wlt:38,1-43,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ "a: b" ],
    "\"a: b\"",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-StringWithColon@@Tests/YAML.wlt:45,1-50,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ "true" ],
    "\"true\"",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-LiteralLikeString@@Tests/YAML.wlt:52,1-57,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ "42" ],
    "\"42\"",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-NumericLikeString@@Tests/YAML.wlt:59,1-64,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ 42 ],
    "42",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-Integer@@Tests/YAML.wlt:66,1-71,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ True ],
    "true",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-True@@Tests/YAML.wlt:73,1-78,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ False ],
    "false",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-False@@Tests/YAML.wlt:80,1-85,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ Null ],
    "null",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-Null@@Tests/YAML.wlt:87,1-92,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*exportYAMLString -- Block Mappings*)
VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> 1 |> ],
    "a: 1",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-SingleKeyMapping@@Tests/YAML.wlt:97,1-102,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> 1, "b" -> "hello" |> ],
    "a: 1\nb: hello",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-TwoKeyMapping@@Tests/YAML.wlt:104,1-109,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> <| "b" -> 1 |> |> ],
    "a:\n  b: 1",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-NestedMapping@@Tests/YAML.wlt:111,1-116,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> <| "b" -> <| "c" -> "deep" |> |> |> ],
    "a:\n  b:\n    c: deep",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-DeeplyNestedMapping@@Tests/YAML.wlt:118,1-123,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| |> ],
    "{}",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-EmptyMapping@@Tests/YAML.wlt:125,1-130,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*exportYAMLString -- Sequences*)
VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ { "a", "b", "c" } ],
    "- a\n- b\n- c",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-BlockSequenceOfStrings@@Tests/YAML.wlt:135,1-140,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ {  } ],
    "[]",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-EmptySequence@@Tests/YAML.wlt:142,1-147,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "args" -> { "a", "b", "c" } |> ],
    "args: [a, b, c]",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-FlowSequenceUnderKey@@Tests/YAML.wlt:149,1-154,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "args" -> {  } |> ],
    "args: []",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-EmptyFlowSequenceUnderKey@@Tests/YAML.wlt:156,1-161,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*exportYAMLString -- Goose-Shaped Sample*)
VerificationTest[
    Module[ { yaml },
        yaml = Wolfram`AgentTools`Common`exportYAMLString[ <|
            "extensions" -> <|
                "Wolfram" -> <|
                    "name"    -> "Wolfram",
                    "cmd"     -> "/path/to/wolfram",
                    "args"    -> { "-run", "test" },
                    "enabled" -> True,
                    "envs"    -> <| "K" -> "V" |>,
                    "type"    -> "stdio",
                    "timeout" -> 300
                |>
            |>
        |> ];
        AllTrue[
            { "extensions:", "cmd:", "enabled: true", "type: stdio", "timeout: 300" },
            StringContainsQ[ yaml, # ] &
        ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-GooseShapedSample@@Tests/YAML.wlt:166,1-189,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Scalars*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: hello" ],
    <| "a" -> "hello" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-PlainString@@Tests/YAML.wlt:194,1-199,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 42" ],
    <| "a" -> 42 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Integer@@Tests/YAML.wlt:201,1-206,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 3.14" ],
    <| "a" -> 3.14 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Real@@Tests/YAML.wlt:208,1-213,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: -2.5e3" ],
    <| "a" -> -2500.0 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-RealWithExponent@@Tests/YAML.wlt:215,1-220,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: true\nb: false" ],
    <| "a" -> True, "b" -> False |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Booleans@@Tests/YAML.wlt:222,1-227,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: null\nb: ~" ],
    <| "a" -> Null, "b" -> Null |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Null@@Tests/YAML.wlt:229,1-234,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: \"hello world\"" ],
    <| "a" -> "hello world" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-DoubleQuotedString@@Tests/YAML.wlt:236,1-241,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: \"line1\\nline2\\ttab\"" ],
    <| "a" -> "line1\nline2\ttab" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-DoubleQuotedEscapes@@Tests/YAML.wlt:243,1-248,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 'it''s'" ],
    <| "a" -> "it's" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-SingleQuotedEscape@@Tests/YAML.wlt:250,1-255,2"
]

VerificationTest[
    (* Quoted "true" stays a string, not a boolean *)
    Wolfram`AgentTools`Common`importYAMLString[ "a: \"true\"" ],
    <| "a" -> "true" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-QuotedLiteralLooksLikeBoolean@@Tests/YAML.wlt:257,1-263,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Block Mappings*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 1\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-TwoKeyMapping@@Tests/YAML.wlt:268,1-273,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a:\n  b: deep" ],
    <| "a" -> <| "b" -> "deep" |> |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-NestedMapping@@Tests/YAML.wlt:275,1-280,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a:\n    b:\n        c: very-deep\n    d: shallow" ],
    <| "a" -> <| "b" -> <| "c" -> "very-deep" |>, "d" -> "shallow" |> |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-FourSpaceIndent@@Tests/YAML.wlt:282,1-287,2"
]

VerificationTest[
    (* Quoted key with a colon-bearing value *)
    Wolfram`AgentTools`Common`importYAMLString[ "\"MCP_SERVER_NAME\": \"foo:bar\"" ],
    <| "MCP_SERVER_NAME" -> "foo:bar" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-QuotedKeyColonValue@@Tests/YAML.wlt:289,1-295,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Block Sequences*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args:\n  - one\n  - two\n  - three" ],
    <| "args" -> { "one", "two", "three" } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-BlockSequence@@Tests/YAML.wlt:300,1-305,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Flow Sequences*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args: [1, 2, 3]" ],
    <| "args" -> { 1, 2, 3 } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-NumericFlowSequence@@Tests/YAML.wlt:310,1-315,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args: [a, 'b, c', d]" ],
    <| "args" -> { "a", "b, c", "d" } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-FlowSequenceQuotedComma@@Tests/YAML.wlt:317,1-322,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args: []" ],
    <| "args" -> {  } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-EmptyFlowSequence@@Tests/YAML.wlt:324,1-329,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Comments and Blank Lines*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "# header comment\na: 1\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-LeadingComment@@Tests/YAML.wlt:334,1-339,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 1 # trailing comment\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-TrailingComment@@Tests/YAML.wlt:341,1-346,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 1\n\n\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-BlankLines@@Tests/YAML.wlt:348,1-353,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "" ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Empty@@Tests/YAML.wlt:355,1-360,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Round-Trip Tests*)
VerificationTest[
    Module[ { data, yaml, parsed },
        data = <| "a" -> 1, "b" -> "hello", "c" -> True, "d" -> Null |>;
        yaml = Wolfram`AgentTools`Common`exportYAMLString @ data;
        parsed = Wolfram`AgentTools`Common`importYAMLString @ yaml;
        parsed === data
    ],
    True,
    SameTest -> Equal,
    TestID   -> "RoundTrip-FlatMapping@@Tests/YAML.wlt:365,1-375,2"
]

VerificationTest[
    Module[ { data, yaml, parsed },
        data = <|
            "extensions" -> <|
                "Wolfram" -> <|
                    "name"    -> "Wolfram",
                    "cmd"     -> "/path/to/wolfram",
                    "args"    -> { "-run", "test", "-noinit" },
                    "enabled" -> True,
                    "envs"    -> <|
                        "MCP_SERVER_NAME" -> "WolframLanguage",
                        "WOLFRAM_BASE"    -> "/path/to/base"
                    |>,
                    "type"    -> "stdio",
                    "timeout" -> 300
                |>
            |>
        |>;
        yaml = Wolfram`AgentTools`Common`exportYAMLString @ data;
        parsed = Wolfram`AgentTools`Common`importYAMLString @ yaml;
        parsed === data
    ],
    True,
    SameTest -> Equal,
    TestID   -> "RoundTrip-GooseShaped@@Tests/YAML.wlt:377,1-402,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAML / exportYAML (File Variants)*)
VerificationTest[
    Module[ { file, data },
        file = testYAMLFile[ ];
        data = <| "extensions" -> <| "Foo" -> <| "cmd" -> "x", "enabled" -> True |> |> |>;
        Wolfram`AgentTools`Common`exportYAML[ file, data ];
        FileExistsQ[ file ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "ExportYAML-CreatesFile@@Tests/YAML.wlt:407,1-417,2"
]

VerificationTest[
    Module[ { file, data, parsed },
        file = testYAMLFile[ ];
        data = <| "extensions" -> <| "Foo" -> <| "cmd" -> "x", "enabled" -> True |> |> |>;
        Wolfram`AgentTools`Common`exportYAML[ file, data ];
        parsed = Wolfram`AgentTools`Common`importYAML[ file ];
        cleanupTestFiles[ file ];
        parsed === data
    ],
    True,
    SameTest -> Equal,
    TestID   -> "ExportYAML-ImportYAML-RoundTrip@@Tests/YAML.wlt:419,1-431,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAML[
        File @ FileNameJoin @ { $TemporaryDirectory, "yaml_nonexistent_" <> CreateUUID[ ] <> ".yaml" }
    ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ImportYAML-MissingFile@@Tests/YAML.wlt:433,1-440,2"
]

VerificationTest[
    Module[ { file },
        file = testYAMLFile[ ];
        Module[ { stream },
            stream = OpenWrite @ First @ file;
            Close @ stream
        ];
        With[ { result = Wolfram`AgentTools`Common`importYAML @ file },
            cleanupTestFiles[ file ];
            result
        ]
    ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ImportYAML-EmptyFile@@Tests/YAML.wlt:442,1-457,2"
]

(* :!CodeAnalysis::EndBlock:: *)
