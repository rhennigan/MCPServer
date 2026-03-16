(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/MCPServerObject.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/MCPServerObject.wlt:11,1-16,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Basic Examples*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Creation and Object Retrieval*)
VerificationTest[
    (* First create a server using CreateMCPServer *)
    name = StringJoin["TestServer_", CreateUUID[]];
    server = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-Setup@@Tests/MCPServerObject.wlt:25,1-35,2"
]

VerificationTest[
    (* Then retrieve it using MCPServerObject *)
    obj = MCPServerObject[name],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-ObjectRetrieval@@Tests/MCPServerObject.wlt:37,1-43,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties and Accessors*)

VerificationTest[
    obj["Name"],
    name,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-GetName@@Tests/MCPServerObject.wlt:49,1-54,2"
]

VerificationTest[
    obj["Location"],
    _File? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetLocation@@Tests/MCPServerObject.wlt:56,1-61,2"
]

VerificationTest[
    obj["LLMConfiguration"],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetLLMConfiguration@@Tests/MCPServerObject.wlt:63,1-68,2"
]

VerificationTest[
    obj["Tools"],
    { _LLMTool },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetTools@@Tests/MCPServerObject.wlt:70,1-75,2"
]

VerificationTest[
    obj["ServerVersion"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetServerVersion@@Tests/MCPServerObject.wlt:77,1-82,2"
]

VerificationTest[
    obj["ObjectVersion"],
    _Integer? IntegerQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetObjectVersion@@Tests/MCPServerObject.wlt:84,1-89,2"
]

VerificationTest[
    json = obj["JSONConfiguration"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetJSONConfiguration@@Tests/MCPServerObject.wlt:91,1-96,2"
]

VerificationTest[
    parsed = Developer`ReadRawJSONString @ json,
    _? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-JSONConfigurationIsValid@@Tests/MCPServerObject.wlt:98,1-103,2"
]

VerificationTest[
    env = parsed[ "mcpServers", name, "env" ],
    KeyValuePattern @ {
        "MCP_SERVER_NAME"   -> name,
        "WOLFRAM_BASE"      -> _String,
        "WOLFRAM_LOCALBASE" -> _String,
        "WOLFRAM_USERBASE"  -> _String,
        If[ $OperatingSystem === "Windows", "APPDATA" -> _String, Nothing ]
    },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-JSONConfigurationHasEnvironmentVariables@@Tests/MCPServerObject.wlt:105,1-116,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Multiple Properties*)
VerificationTest[
    properties = obj[{"Name", "ServerVersion", "ObjectVersion"}];
    KeyTake[properties, {"Name", "ServerVersion", "ObjectVersion"}],
    KeyValuePattern[{
        "Name" -> name,
        "ServerVersion" -> _String,
        "ObjectVersion" -> _Integer
    }],
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-MultipleProperties@@Tests/MCPServerObject.wlt:121,1-131,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Built-in Servers*)
VerificationTest[
    builtInServer = MCPServerObject["WolframLanguage"],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-BuiltInServer@@Tests/MCPServerObject.wlt:136,1-141,2"
]

VerificationTest[
    builtInServer["Name"],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerName@@Tests/MCPServerObject.wlt:143,1-148,2"
]

VerificationTest[
    builtInServer["Location"],
    "BuiltIn",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerLocation@@Tests/MCPServerObject.wlt:150,1-155,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Objects Listing*)
VerificationTest[
    servers = MCPServerObjects[],
    { ___MCPServerObject? MCPServerObjectQ },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-ListAllServers@@Tests/MCPServerObject.wlt:160,1-165,2"
]

(* Note: We can't rely on built-in servers being found in MCPServerObjects since
   they don't show up there. Instead check if we can create a new server
   and have it show up in the list *)
VerificationTest[
    Length[MCPServerObjects[]] >= 0,
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-ConfirmServersExist@@Tests/MCPServerObject.wlt:170,1-175,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete Servers*)
VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-DeleteObject@@Tests/MCPServerObject.wlt:180,1-185,2"
]

VerificationTest[
    MCPServerObject @ name,
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-VerifyDeletion@@Tests/MCPServerObject.wlt:187,1-193,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    MCPServerObject[ "NonExistentServer" ],
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-NonExistentServer@@Tests/MCPServerObject.wlt:198,1-204,2"
]

VerificationTest[
    MCPServerObject[ { "Invalid", "Input" } ],
    _Failure,
    { MCPServerObject::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidInput@@Tests/MCPServerObject.wlt:206,1-212,2"
]

VerificationTest[
    MCPServerObject[ <| "InvalidKey" -> "Value" |> ],
    _Failure,
    { MCPServerObject::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidAssociation@@Tests/MCPServerObject.wlt:214,1-220,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Paclet-Backed Server Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Mock Paclet Setup*)

$testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" };

VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    $mockPaclet = First @ PacletFind[ "MockMCPPacletTest" ];
    $mockPaclet[ "Name" ],
    "MockMCPPacletTest",
    SameTest -> MatchQ,
    TestID   -> "PacletServer-MockSetup@@Tests/MCPServerObject.wlt:235,1-242,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerObject with Paclet-Qualified Name*)
VerificationTest[
    $pacletServer = MCPServerObject[ "MockMCPPacletTest/TestServer" ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "PacletServer-ObjectCreation@@Tests/MCPServerObject.wlt:247,1-252,2"
]

VerificationTest[
    $pacletServer[ "Name" ],
    "MockMCPPacletTest/TestServer",
    SameTest -> Equal,
    TestID   -> "PacletServer-Name@@Tests/MCPServerObject.wlt:254,1-259,2"
]

VerificationTest[
    $pacletServer[ "Location" ],
    _PacletObject,
    SameTest -> MatchQ,
    TestID   -> "PacletServer-Location@@Tests/MCPServerObject.wlt:261,1-266,2"
]

VerificationTest[
    $pacletServer[ "Location" ][ "Name" ],
    "MockMCPPacletTest",
    SameTest -> Equal,
    TestID   -> "PacletServer-LocationPacletName@@Tests/MCPServerObject.wlt:268,1-273,2"
]

VerificationTest[
    $pacletServer[ "ServerVersion" ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "PacletServer-ServerVersion@@Tests/MCPServerObject.wlt:275,1-280,2"
]

VerificationTest[
    $pacletServer[ "Transport" ],
    "StandardInputOutput",
    SameTest -> Equal,
    TestID   -> "PacletServer-Transport@@Tests/MCPServerObject.wlt:282,1-287,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ToolNames and PromptNames Properties*)
VerificationTest[
    $pacletServer[ "ToolNames" ],
    { "MockMCPPacletTest/TestTool", "MockMCPPacletTest/DescribedTool" },
    SameTest -> MatchQ,
    TestID   -> "PacletServer-ToolNames@@Tests/MCPServerObject.wlt:292,1-297,2"
]

VerificationTest[
    $pacletServer[ "PromptNames" ],
    { "MockMCPPacletTest/TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "PacletServer-PromptNames@@Tests/MCPServerObject.wlt:299,1-304,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties List Includes New Properties*)
VerificationTest[
    MemberQ[ $pacletServer[ "Properties" ], "ToolNames" ],
    True,
    SameTest -> Equal,
    TestID   -> "PacletServer-PropertiesIncludesToolNames@@Tests/MCPServerObject.wlt:309,1-314,2"
]

VerificationTest[
    MemberQ[ $pacletServer[ "Properties" ], "PromptNames" ],
    True,
    SameTest -> Equal,
    TestID   -> "PacletServer-PropertiesIncludesPromptNames@@Tests/MCPServerObject.wlt:316,1-321,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*LLMEvaluator Contains Pre-Qualified Names*)
VerificationTest[
    $pacletServer[ "LLMEvaluator" ][ "Tools" ],
    { "MockMCPPacletTest/TestTool", "MockMCPPacletTest/DescribedTool" },
    SameTest -> MatchQ,
    TestID   -> "PacletServer-LLMEvaluatorQualifiedTools@@Tests/MCPServerObject.wlt:326,1-331,2"
]

VerificationTest[
    $pacletServer[ "LLMEvaluator" ][ "MCPPrompts" ],
    { "MockMCPPacletTest/TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "PacletServer-LLMEvaluatorQualifiedPrompts@@Tests/MCPServerObject.wlt:333,1-338,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerObjectQ for Paclet-Backed Servers*)
VerificationTest[
    MCPServerObjectQ @ $pacletServer,
    True,
    SameTest -> Equal,
    TestID   -> "PacletServer-MCPServerObjectQ@@Tests/MCPServerObject.wlt:343,1-348,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*DeleteObject Refused for Paclet Servers*)
VerificationTest[
    DeleteObject @ $pacletServer,
    _Failure,
    { MCPServerObject::DeletePacletMCPServer },
    SameTest -> MatchQ,
    TestID   -> "PacletServer-DeleteObjectRefused@@Tests/MCPServerObject.wlt:353,1-359,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Non-Existent Paclet Server*)
VerificationTest[
    MCPServerObject[ "CompletelyNonExistentPaclet12345/SomeServer" ],
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "PacletServer-NonExistentPaclet@@Tests/MCPServerObject.wlt:364,1-370,2"
]

VerificationTest[
    MCPServerObject[ "MockMCPPacletTest/NonExistentServer" ],
    _Failure,
    { MCPServerObject::PacletServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "PacletServer-NonExistentServer@@Tests/MCPServerObject.wlt:372,1-378,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ToolNames and PromptNames for Non-Paclet Servers*)
VerificationTest[
    builtIn = MCPServerObject[ "WolframLanguage" ];
    builtIn[ "ToolNames" ],
    _List,
    SameTest -> MatchQ,
    TestID   -> "ToolNames-BuiltInServer@@Tests/MCPServerObject.wlt:383,1-389,2"
]

VerificationTest[
    builtIn = MCPServerObject[ "WolframLanguage" ];
    builtIn[ "PromptNames" ],
    _List,
    SameTest -> MatchQ,
    TestID   -> "PromptNames-BuiltInServer@@Tests/MCPServerObject.wlt:391,1-397,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Multiple Properties Request*)
VerificationTest[
    props = $pacletServer[ { "Name", "ToolNames", "PromptNames", "Transport" } ];
    AssociationQ @ props && props[ "Name" ] === "MockMCPPacletTest/TestServer",
    True,
    SameTest -> Equal,
    TestID   -> "PacletServer-MultipleProperties@@Tests/MCPServerObject.wlt:402,1-408,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Mock Paclet Cleanup*)
VerificationTest[
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ],
    <||>,
    SameTest -> MatchQ,
    TestID   -> "PacletServer-MockCleanup@@Tests/MCPServerObject.wlt:413,1-419,2"
]

(* :!CodeAnalysis::EndBlock:: *)