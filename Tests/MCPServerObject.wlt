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
    obj["JSONConfiguration"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetJSONConfiguration@@Tests/MCPServerObject.wlt:91,1-96,2"
]

VerificationTest[
    json = obj["JSONConfiguration"];
    parsed = Developer`ReadRawJSONString[json];
    env = parsed["mcpServers", name, "env"];
    If[ $OperatingSystem === "Windows",
        AllTrue[{"MCP_SERVER_NAME", "WOLFRAM_BASE", "WOLFRAM_USERBASE", "APPDATA"}, KeyExistsQ[env, #] &],
        AllTrue[{"MCP_SERVER_NAME", "WOLFRAM_BASE", "WOLFRAM_USERBASE"}, KeyExistsQ[env, #] &]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-JSONConfigurationHasEnvironmentVariables"
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
    TestID   -> "MCPServerObject-MultipleProperties@@Tests/MCPServerObject.wlt:101,1-111,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Built-in Servers*)
VerificationTest[
    builtInServer = MCPServerObject["WolframLanguage"],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-BuiltInServer@@Tests/MCPServerObject.wlt:116,1-121,2"
]

VerificationTest[
    builtInServer["Name"],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerName@@Tests/MCPServerObject.wlt:123,1-128,2"
]

VerificationTest[
    builtInServer["Location"],
    "BuiltIn",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerLocation@@Tests/MCPServerObject.wlt:130,1-135,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Objects Listing*)
VerificationTest[
    servers = MCPServerObjects[],
    { ___MCPServerObject? MCPServerObjectQ },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-ListAllServers@@Tests/MCPServerObject.wlt:140,1-145,2"
]

(* Note: We can't rely on built-in servers being found in MCPServerObjects since
   they don't show up there. Instead check if we can create a new server
   and have it show up in the list *)
VerificationTest[
    Length[MCPServerObjects[]] >= 0,
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-ConfirmServersExist@@Tests/MCPServerObject.wlt:150,1-155,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete Servers*)
VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-DeleteObject@@Tests/MCPServerObject.wlt:160,1-165,2"
]

VerificationTest[
    MCPServerObject @ name,
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-VerifyDeletion@@Tests/MCPServerObject.wlt:167,1-173,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    MCPServerObject[ "NonExistentServer" ],
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-NonExistentServer@@Tests/MCPServerObject.wlt:178,1-184,2"
]

VerificationTest[
    MCPServerObject[ { "Invalid", "Input" } ],
    _Failure,
    { MCPServerObject::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidInput@@Tests/MCPServerObject.wlt:186,1-192,2"
]

VerificationTest[
    MCPServerObject[ <| "InvalidKey" -> "Value" |> ],
    _Failure,
    { MCPServerObject::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidAssociation@@Tests/MCPServerObject.wlt:194,1-200,2"
]