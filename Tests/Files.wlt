(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/Files.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/Files.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*ensureFilePath*)

VerificationTest[
    Wolfram`MCPServer`Common`catchTop[
        Wolfram`MCPServer`Common`ensureFilePath[ FileNameJoin @ { $TemporaryDirectory, "ensureFilePath_test.txt" } ]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-AbsolutePath-GH#108@@Tests/Files.wlt:25,1-32,2"
]

VerificationTest[
    WithCleanup[
        SetDirectory[ $TemporaryDirectory ],
        Wolfram`MCPServer`Common`catchTop[
            Wolfram`MCPServer`Common`ensureFilePath[ "ensureFilePath_relative_test.txt" ]
        ],
        ResetDirectory[]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-RelativePath-GH#108@@Tests/Files.wlt:34,1-45,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop[
        Wolfram`MCPServer`Common`ensureFilePath[ File[ FileNameJoin @ { $TemporaryDirectory, "ensureFilePath_wrapped_test.txt" } ] ]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-FileWrapper-GH#108@@Tests/Files.wlt:47,1-54,2"
]

VerificationTest[
    WithCleanup[
        SetDirectory[ $TemporaryDirectory ],
        Wolfram`MCPServer`Common`catchTop[
            Wolfram`MCPServer`Common`ensureFilePath[ File[ "ensureFilePath_relative_wrapped_test.txt" ] ]
        ],
        ResetDirectory[]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-FileWrapper-RelativePath-GH#108@@Tests/Files.wlt:56,1-67,2"
]

(* :!CodeAnalysis::EndBlock:: *)
