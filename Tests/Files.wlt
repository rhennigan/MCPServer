(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/Files.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
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
    Wolfram`AgentTools`Common`catchTop[
        Wolfram`AgentTools`Common`ensureFilePath[ FileNameJoin @ { $TemporaryDirectory, "ensureFilePath_test.txt" } ]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-AbsolutePath-GH#108@@Tests/Files.wlt:25,1-32,2"
]

VerificationTest[
    WithCleanup[
        SetDirectory[ $TemporaryDirectory ],
        Wolfram`AgentTools`Common`catchTop[
            Wolfram`AgentTools`Common`ensureFilePath[ "ensureFilePath_relative_test.txt" ]
        ],
        ResetDirectory[]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-RelativePath-GH#108@@Tests/Files.wlt:34,1-45,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchTop[
        Wolfram`AgentTools`Common`ensureFilePath[ File[ FileNameJoin @ { $TemporaryDirectory, "ensureFilePath_wrapped_test.txt" } ] ]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-FileWrapper-GH#108@@Tests/Files.wlt:47,1-54,2"
]

VerificationTest[
    WithCleanup[
        SetDirectory[ $TemporaryDirectory ],
        Wolfram`AgentTools`Common`catchTop[
            Wolfram`AgentTools`Common`ensureFilePath[ File[ "ensureFilePath_relative_wrapped_test.txt" ] ]
        ],
        ResetDirectory[]
    ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "EnsureFilePath-FileWrapper-RelativePath-GH#108@@Tests/Files.wlt:56,1-67,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Global Settings*)
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* Machine-wide settings live in a single WXF association directly under $rootPath (see docs/usage-data.md) *)
VerificationTest[
    withTemporaryRoot[
        Wolfram`AgentTools`Common`$globalSettingsFile ===
            FileNameJoin @ { Wolfram`AgentTools`Common`$rootPath, "GlobalSettings.wxf" }
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "GlobalSettings-FileLocation@@Tests/Files.wlt:78,1-86,2"
]

(* Nothing has been set yet: reading gives no settings and creates nothing *)
VerificationTest[
    withTemporaryRoot @ {
        Wolfram`AgentTools`Common`readGlobalSettings[ ],
        Wolfram`AgentTools`Common`getGlobalSetting[ "Anything" ],
        Wolfram`AgentTools`Common`getGlobalSetting[ "Anything", "default" ],
        FileExistsQ @ Wolfram`AgentTools`Common`$globalSettingsFile,
        DirectoryQ @ Wolfram`AgentTools`Common`$rootPath
    },
    { <| |>, Missing[ "KeyAbsent", "Anything" ], "default", False, False },
    SameTest -> SameQ,
    TestID   -> "GlobalSettings-Unset@@Tests/Files.wlt:89,1-100,2"
]

(* Setting a value creates the file (and its directory) and returns the value *)
VerificationTest[
    withTemporaryRoot @ {
        Wolfram`AgentTools`Common`setGlobalSetting[ "A", 1 ],
        FileExistsQ @ Wolfram`AgentTools`Common`$globalSettingsFile,
        Developer`ReadWXFFile @ Wolfram`AgentTools`Common`$globalSettingsFile,
        Wolfram`AgentTools`Common`getGlobalSetting[ "A" ],
        Wolfram`AgentTools`Common`getGlobalSetting[ "A", "default" ],
        Wolfram`AgentTools`Common`readGlobalSettings[ ]
    },
    { 1, True, <| "A" -> 1 |>, 1, 1, <| "A" -> 1 |> },
    SameTest -> SameQ,
    TestID   -> "GlobalSettings-SetAndGet@@Tests/Files.wlt:103,1-115,2"
]

(* New values are merged into the existing settings, so setting one never loses another *)
VerificationTest[
    withTemporaryRoot @ (
        Wolfram`AgentTools`Common`setGlobalSetting[ "A", 1 ];
        Wolfram`AgentTools`Common`setGlobalSetting[ "B", { "x", "y" } ];
        Wolfram`AgentTools`Common`setGlobalSetting[ "A", False ];
        Wolfram`AgentTools`Common`readGlobalSettings[ ]
    ),
    <| "A" -> False, "B" -> { "x", "y" } |>,
    SameTest -> SameQ,
    TestID   -> "GlobalSettings-Merge@@Tests/Files.wlt:118,1-128,2"
]

(* A file that cannot be read, or that does not hold an association, counts as no settings and is replaced by the
   next write *)
VerificationTest[
    withTemporaryRoot @ Module[ { file, text, list, written },
        file = Wolfram`AgentTools`Common`$globalSettingsFile;
        CreateDirectory @ Wolfram`AgentTools`Common`$rootPath;
        Export[ file, "not a WXF file", "Text" ];
        text = Wolfram`AgentTools`Common`readGlobalSettings[ ];
        Developer`WriteWXFFile[ file, { 1, 2, 3 } ];
        list = Wolfram`AgentTools`Common`readGlobalSettings[ ];
        Wolfram`AgentTools`Common`setGlobalSetting[ "A", 1 ];
        written = Wolfram`AgentTools`Common`readGlobalSettings[ ];
        { text, list, written }
    ],
    { <| |>, <| |>, <| "A" -> 1 |> },
    SameTest -> SameQ,
    TestID   -> "GlobalSettings-Unreadable@@Tests/Files.wlt:132,1-147,2"
]

(* :!CodeAnalysis::EndBlock:: *)
