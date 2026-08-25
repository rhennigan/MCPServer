(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/PreferencesContent.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/PreferencesContent.wlt:11,1-16,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreatePreferencesContent*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Smoke test*)
VerificationTest[
    CreatePreferencesContent[ ],
    Deploy[ _Pane ],
    SameTest -> MatchQ,
    TestID   -> "CreatePreferencesContent-SmokeTest@@Tests/PreferencesContent.wlt:25,1-30,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Arguments*)
VerificationTest[
    CreatePreferencesContent[ "bogus" ],
    _Failure,
    { CreatePreferencesContent::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "CreatePreferencesContent-InvalidArguments@@Tests/PreferencesContent.wlt:35,1-41,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Usage Data Opt-Out*)
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* Without a front end there is no stored setting, which means the default: usage data is shared and deployments
   made from the panel get no extra options. *)
VerificationTest[
    Wolfram`AgentTools`PreferencesContent`Private`usageDataOptOutQ[ ],
    False,
    SameTest -> SameQ,
    TestID   -> "PreferencesContent-UsageDataOptOutQ-Default@@Tests/PreferencesContent.wlt:51,1-56,2"
]

VerificationTest[
    Wolfram`AgentTools`PreferencesContent`Private`usageDataDeployOptions[ ],
    { },
    SameTest -> SameQ,
    TestID   -> "PreferencesContent-UsageDataDeployOptions-Default@@Tests/PreferencesContent.wlt:58,1-63,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`PreferencesContent`Private`usageDataOptOutQ = True & },
        Wolfram`AgentTools`PreferencesContent`Private`usageDataDeployOptions[ ]
    ],
    { "SubmitUsageData" -> False },
    SameTest -> SameQ,
    TestID   -> "PreferencesContent-UsageDataDeployOptions-OptedOut@@Tests/PreferencesContent.wlt:65,1-72,2"
]

(* Re-deploying an existing deployment applies the current setting and keeps the deployment's other options *)
VerificationTest[
    Module[ { configFile, dep, optedOut, env1, options, optedIn, env2 },
        configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "usage_prefs_", CreateUUID[], ".json" ] };
        dep = DeployAgentTools[ configFile, "Wolfram", "ApplicationName" -> "ClaudeCode", "EnableMCPApps" -> False, "VerifyLLMKit" -> False ];

        optedOut = Block[ { Wolfram`AgentTools`PreferencesContent`Private`usageDataOptOutQ = True & },
            Wolfram`AgentTools`PreferencesContent`Private`redeployForUsageData @ dep
        ];
        env1 = Developer`ReadRawJSONString[ ReadString @ First @ configFile ][ "mcpServers", "Wolfram", "env" ];
        options = Normal @ optedOut[ "MCP", "Options" ];

        optedIn = Block[ { Wolfram`AgentTools`PreferencesContent`Private`usageDataOptOutQ = False & },
            Wolfram`AgentTools`PreferencesContent`Private`redeployForUsageData @ optedOut
        ];
        env2 = Developer`ReadRawJSONString[ ReadString @ First @ configFile ][ "mcpServers", "Wolfram", "env" ];

        DeleteObject[ optedIn ];
        Quiet @ DeleteFile @ First @ configFile;

        {
            Head @ optedOut,
            Lookup[ env1, "SUBMIT_USAGE_DATA", Missing[ "Absent" ] ],
            Lookup[ env1, "MCP_APPS_ENABLED", Missing[ "Absent" ] ],
            MemberQ[ options, "EnableMCPApps" -> False ],
            MemberQ[ options, "SubmitUsageData" -> False ],
            Head @ optedIn,
            Lookup[ env2, "SUBMIT_USAGE_DATA", Missing[ "Absent" ] ],
            Lookup[ env2, "MCP_APPS_ENABLED", Missing[ "Absent" ] ]
        }
    ],
    { AgentToolsDeployment, "false", "false", True, True, AgentToolsDeployment, Missing[ "Absent" ], "false" },
    SameTest -> SameQ,
    TestID   -> "PreferencesContent-RedeployForUsageData@@Tests/PreferencesContent.wlt:75,1-108,2"
]

(* :!CodeAnalysis::EndBlock:: *)
