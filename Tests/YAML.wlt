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

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ 3.14 ],
    "3.14",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-RealSimple@@Tests/YAML.wlt:94,1-99,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ 1.5*^20 ],
    "1.5e20",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-RealLargeExponent@@Tests/YAML.wlt:101,1-106,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ 1.0*^-10 ],
    "1.0e-10",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-RealSmallExponent@@Tests/YAML.wlt:108,1-113,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ 100. ],
    "1.0e2",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-RealWholeNumber@@Tests/YAML.wlt:115,1-120,2"
]

VerificationTest[
    Module[ { yaml, parsed },
        yaml = Wolfram`AgentTools`Common`exportYAMLString[ 1.5*^20 ];
        parsed = Wolfram`AgentTools`Common`importYAMLString[ "x: " <> yaml ];
        parsed[ "x" ] == 1.5*^20
    ],
    True,
    SameTest -> Equal,
    TestID   -> "RoundTrip-RealLargeExponent@@Tests/YAML.wlt:122,1-131,2"
]

VerificationTest[
    Module[ { yaml, parsed },
        yaml = Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> 1.5*^20, "b" -> 1.0*^-10, "c" -> 100., "d" -> 3.14 |> ];
        parsed = Wolfram`AgentTools`Common`importYAMLString @ yaml;
        parsed[ "a" ] == 1.5*^20 && parsed[ "b" ] == 1.0*^-10 && parsed[ "c" ] == 100. && parsed[ "d" ] == 3.14
    ],
    True,
    SameTest -> Equal,
    TestID   -> "RoundTrip-RealsInMapping@@Tests/YAML.wlt:133,1-142,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*exportYAMLString -- Block Mappings*)
VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> 1 |> ],
    "a: 1",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-SingleKeyMapping@@Tests/YAML.wlt:147,1-152,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> 1, "b" -> "hello" |> ],
    "a: 1\nb: hello",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-TwoKeyMapping@@Tests/YAML.wlt:154,1-159,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> <| "b" -> 1 |> |> ],
    "a:\n  b: 1",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-NestedMapping@@Tests/YAML.wlt:161,1-166,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "a" -> <| "b" -> <| "c" -> "deep" |> |> |> ],
    "a:\n  b:\n    c: deep",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-DeeplyNestedMapping@@Tests/YAML.wlt:168,1-173,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| |> ],
    "{}",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-EmptyMapping@@Tests/YAML.wlt:175,1-180,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*exportYAMLString -- Sequences*)
VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ { "a", "b", "c" } ],
    "- a\n- b\n- c",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-BlockSequenceOfStrings@@Tests/YAML.wlt:185,1-190,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ {  } ],
    "[]",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-EmptySequence@@Tests/YAML.wlt:192,1-197,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "args" -> { "a", "b", "c" } |> ],
    "args: [a, b, c]",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-FlowSequenceUnderKey@@Tests/YAML.wlt:199,1-204,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`exportYAMLString[ <| "args" -> {  } |> ],
    "args: []",
    SameTest -> Equal,
    TestID   -> "ExportYAMLString-EmptyFlowSequenceUnderKey@@Tests/YAML.wlt:206,1-211,2"
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
    TestID   -> "ExportYAMLString-GooseShapedSample@@Tests/YAML.wlt:216,1-239,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Scalars*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: hello" ],
    <| "a" -> "hello" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-PlainString@@Tests/YAML.wlt:244,1-249,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 42" ],
    <| "a" -> 42 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Integer@@Tests/YAML.wlt:251,1-256,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 3.14" ],
    <| "a" -> 3.14 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Real@@Tests/YAML.wlt:258,1-263,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: -2.5e3" ],
    <| "a" -> -2500.0 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-RealWithExponent@@Tests/YAML.wlt:265,1-270,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 1e3" ],
    <| "a" -> 1000.0 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-RealExponentOnly@@Tests/YAML.wlt:272,1-277,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: -2E10" ],
    <| "a" -> -2.0*^10 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-RealExponentOnlyCapitalE@@Tests/YAML.wlt:279,1-284,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 5e-2" ],
    <| "a" -> 0.05 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-RealExponentOnlyNegativeExp@@Tests/YAML.wlt:286,1-291,2"
]

VerificationTest[
    Head @ Lookup[ Wolfram`AgentTools`Common`importYAMLString[ "a: 1e3" ], "a" ],
    Real,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-RealExponentOnlyHead@@Tests/YAML.wlt:293,1-298,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: true\nb: false" ],
    <| "a" -> True, "b" -> False |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Booleans@@Tests/YAML.wlt:300,1-305,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: null\nb: ~" ],
    <| "a" -> Null, "b" -> Null |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Null@@Tests/YAML.wlt:307,1-312,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: \"hello world\"" ],
    <| "a" -> "hello world" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-DoubleQuotedString@@Tests/YAML.wlt:314,1-319,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: \"line1\\nline2\\ttab\"" ],
    <| "a" -> "line1\nline2\ttab" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-DoubleQuotedEscapes@@Tests/YAML.wlt:321,1-326,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 'it''s'" ],
    <| "a" -> "it's" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-SingleQuotedEscape@@Tests/YAML.wlt:328,1-333,2"
]

VerificationTest[
    (* Quoted "true" stays a string, not a boolean *)
    Wolfram`AgentTools`Common`importYAMLString[ "a: \"true\"" ],
    <| "a" -> "true" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-QuotedLiteralLooksLikeBoolean@@Tests/YAML.wlt:335,1-341,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Block Mappings*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 1\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-TwoKeyMapping@@Tests/YAML.wlt:346,1-351,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a:\n  b: deep" ],
    <| "a" -> <| "b" -> "deep" |> |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-NestedMapping@@Tests/YAML.wlt:353,1-358,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a:\n    b:\n        c: very-deep\n    d: shallow" ],
    <| "a" -> <| "b" -> <| "c" -> "very-deep" |>, "d" -> "shallow" |> |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-FourSpaceIndent@@Tests/YAML.wlt:360,1-365,2"
]

VerificationTest[
    (* Quoted key with a colon-bearing value *)
    Wolfram`AgentTools`Common`importYAMLString[ "\"MCP_SERVER_NAME\": \"foo:bar\"" ],
    <| "MCP_SERVER_NAME" -> "foo:bar" |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-QuotedKeyColonValue@@Tests/YAML.wlt:367,1-373,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Block Sequences*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args:\n  - one\n  - two\n  - three" ],
    <| "args" -> { "one", "two", "three" } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-BlockSequence@@Tests/YAML.wlt:378,1-383,2"
]

(* Inline mapping items: "- key: value" *)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "items:\n  - name: Alice\n    age: 30\n  - name: Bob\n    age: 25" ],
    <| "items" -> { <| "name" -> "Alice", "age" -> 30 |>, <| "name" -> "Bob", "age" -> 25 |> } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-InlineSequenceMapping@@Tests/YAML.wlt:386,1-391,2"
]

(* Quoted scalars containing colons must NOT be parsed as inline mappings *)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "- \"a: b\"\n- \"c: d\"" ],
    { "a: b", "c: d" },
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-QuotedScalarsWithColons@@Tests/YAML.wlt:394,1-399,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Flow Sequences*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args: [1, 2, 3]" ],
    <| "args" -> { 1, 2, 3 } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-NumericFlowSequence@@Tests/YAML.wlt:404,1-409,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args: [a, 'b, c', d]" ],
    <| "args" -> { "a", "b, c", "d" } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-FlowSequenceQuotedComma@@Tests/YAML.wlt:411,1-416,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "args: []" ],
    <| "args" -> {  } |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-EmptyFlowSequence@@Tests/YAML.wlt:418,1-423,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*importYAMLString -- Comments and Blank Lines*)
VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "# header comment\na: 1\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-LeadingComment@@Tests/YAML.wlt:428,1-433,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 1 # trailing comment\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-TrailingComment@@Tests/YAML.wlt:435,1-440,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "a: 1\n\n\nb: 2" ],
    <| "a" -> 1, "b" -> 2 |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-BlankLines@@Tests/YAML.wlt:442,1-447,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAMLString[ "" ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-Empty@@Tests/YAML.wlt:449,1-454,2"
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
    TestID   -> "RoundTrip-FlatMapping@@Tests/YAML.wlt:459,1-469,2"
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
    TestID   -> "RoundTrip-GooseShaped@@Tests/YAML.wlt:471,1-496,2"
]

(* Sequence of multi-key associations must round-trip cleanly. *)
VerificationTest[
    Module[ { data, yaml, parsed },
        data = <|
            "items" -> {
                <| "name" -> "Alice", "age" -> 30 |>,
                <| "name" -> "Bob",   "age" -> 25 |>
            }
        |>;
        yaml = Wolfram`AgentTools`Common`exportYAMLString @ data;
        parsed = Wolfram`AgentTools`Common`importYAMLString @ yaml;
        parsed === data
    ],
    True,
    SameTest -> Equal,
    TestID   -> "RoundTrip-SequenceOfMultiKeyAssociations@@Tests/YAML.wlt:499,1-514,2"
]

(* Sequence item whose value is itself a nested mapping. *)
VerificationTest[
    Module[ { data, yaml, parsed },
        data = <|
            "items" -> {
                <| "name" -> "Alice", "config" -> <| "key" -> "value" |> |>
            }
        |>;
        yaml = Wolfram`AgentTools`Common`exportYAMLString @ data;
        parsed = Wolfram`AgentTools`Common`importYAMLString @ yaml;
        parsed === data
    ],
    True,
    SameTest -> Equal,
    TestID   -> "RoundTrip-SequenceItemWithNestedMapping@@Tests/YAML.wlt:517,1-531,2"
]

(* Top-level sequence of associations. *)
VerificationTest[
    Module[ { data, yaml, parsed },
        data = {
            <| "name" -> "Alice", "age" -> 30 |>,
            <| "name" -> "Bob",   "age" -> 25 |>
        };
        yaml = Wolfram`AgentTools`Common`exportYAMLString @ data;
        parsed = Wolfram`AgentTools`Common`importYAMLString @ yaml;
        parsed === data
    ],
    True,
    SameTest -> Equal,
    TestID   -> "RoundTrip-TopLevelSequenceOfAssociations@@Tests/YAML.wlt:534,1-547,2"
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
    TestID   -> "ExportYAML-CreatesFile@@Tests/YAML.wlt:552,1-562,2"
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
    TestID   -> "ExportYAML-ImportYAML-RoundTrip@@Tests/YAML.wlt:564,1-576,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`importYAML[
        File @ FileNameJoin @ { $TemporaryDirectory, "yaml_nonexistent_" <> CreateUUID[ ] <> ".yaml" }
    ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ImportYAML-MissingFile@@Tests/YAML.wlt:578,1-585,2"
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
    TestID   -> "ImportYAML-EmptyFile@@Tests/YAML.wlt:587,1-602,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Parse Error File Reporting*)
VerificationTest[
    Module[ { file, result, params, expandedPath },
        file = testYAMLFile[ ];
        Module[ { stream },
            stream = OpenWrite @ First @ file;
            WriteString[ stream, "a:\n  b: 1\n   c: 2\n" ]; (* malformed indentation *)
            Close @ stream
        ];
        expandedPath = ExpandFileName @ First @ file;
        result = Wolfram`AgentTools`Common`catchAlways @
            Wolfram`AgentTools`Common`importYAML @ file;
        params = If[ MatchQ[ result, _Failure ], result[ "MessageParameters" ], { } ];
        cleanupTestFiles[ file ];
        MatchQ[ result, _Failure ] && First[ params, "" ] === expandedPath
    ],
    True,
    { AgentTools::InvalidYAMLFormat },
    SameTest -> Equal,
    TestID   -> "ImportYAML-ParseErrorReportsFilePath@@Tests/YAML.wlt:607,1-626,2"
]

VerificationTest[
    Module[ { result, params },
        result = Wolfram`AgentTools`Common`catchAlways @
            Wolfram`AgentTools`Common`importYAMLString[ "a:\n  b: 1\n   c: 2\n" ];
        params = If[ MatchQ[ result, _Failure ], result[ "MessageParameters" ], { } ];
        MatchQ[ result, _Failure ] && First[ params, "" ] === "<input>"
    ],
    True,
    { AgentTools::InvalidYAMLFormat },
    SameTest -> Equal,
    TestID   -> "ImportYAMLString-ParseErrorReportsInputLabel@@Tests/YAML.wlt:628,1-639,2"
]

(* Trailing content (e.g. a top-level sequence after a mapping) must surface
   as an error rather than being silently dropped. *)
VerificationTest[
    Wolfram`AgentTools`Common`catchAlways @
        Wolfram`AgentTools`Common`importYAMLString[ "a: 1\nb: 2\n- one\n- two" ],
    _Failure,
    { AgentTools::InvalidYAMLFormat },
    SameTest -> MatchQ,
    TestID   -> "ImportYAMLString-TrailingSequenceAfterMapping@@Tests/YAML.wlt:643,1-650,2"
]

(* :!CodeAnalysis::EndBlock:: *)
