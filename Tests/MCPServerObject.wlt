(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    If[ ! TrueQ @ RickHennigan`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ { DirectoryName[ $TestFileName ], "Common.wl" }
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/MCPServerObject.wlt:4,1-11,2"
]

VerificationTest[
    Needs[ "RickHennigan`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/MCPServerObject.wlt:13,1-18,2"
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
    TestID   -> "MCPServerObject-Setup@@Tests/MCPServerObject.wlt:27,1-37,2"
]

VerificationTest[
    (* Then retrieve it using MCPServerObject *)
    obj = MCPServerObject[name],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-ObjectRetrieval@@Tests/MCPServerObject.wlt:39,1-45,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties and Accessors*)

VerificationTest[
    obj["Name"],
    name,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-GetName@@Tests/MCPServerObject.wlt:51,1-56,2"
]

VerificationTest[
    obj["Location"],
    _File? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetLocation@@Tests/MCPServerObject.wlt:58,1-63,2"
]

VerificationTest[
    obj["LLMConfiguration"],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetLLMConfiguration@@Tests/MCPServerObject.wlt:65,1-70,2"
]

VerificationTest[
    obj["Tools"],
    { _LLMTool },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetTools@@Tests/MCPServerObject.wlt:72,1-77,2"
]

VerificationTest[
    obj["ServerVersion"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetServerVersion@@Tests/MCPServerObject.wlt:79,1-84,2"
]

VerificationTest[
    obj["ObjectVersion"],
    _Integer? IntegerQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetObjectVersion@@Tests/MCPServerObject.wlt:86,1-91,2"
]

VerificationTest[
    obj["JSONConfiguration"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetJSONConfiguration@@Tests/MCPServerObject.wlt:93,1-98,2"
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
    TestID   -> "MCPServerObject-MultipleProperties@@Tests/MCPServerObject.wlt:103,1-113,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Built-in Servers*)
VerificationTest[
    builtInServer = MCPServerObject["WolframLanguage"],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-BuiltInServer@@Tests/MCPServerObject.wlt:118,1-123,2"
]

VerificationTest[
    builtInServer["Name"],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerName@@Tests/MCPServerObject.wlt:125,1-130,2"
]

VerificationTest[
    builtInServer["Location"],
    "BuiltIn",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerLocation@@Tests/MCPServerObject.wlt:132,1-137,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Objects Listing*)
VerificationTest[
    servers = MCPServerObjects[],
    { ___MCPServerObject? MCPServerObjectQ },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-ListAllServers@@Tests/MCPServerObject.wlt:142,1-147,2"
]

VerificationTest[
    Length[MCPServerObjects[]] > 0,
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-ConfirmServersExist@@Tests/MCPServerObject.wlt:149,1-154,2"
]

VerificationTest[
    MemberQ[MCPServerObjects["Wolfram*"], _MCPServerObject? MCPServerObjectQ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-ListPatternServers@@Tests/MCPServerObject.wlt:156,1-161,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete Servers*)
VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-DeleteObject@@Tests/MCPServerObject.wlt:166,1-171,2"
]

VerificationTest[
    MCPServerObject @ name,
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-VerifyDeletion@@Tests/MCPServerObject.wlt:173,1-179,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    MCPServerObject[ "NonExistentServer" ],
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-NonExistentServer@@Tests/MCPServerObject.wlt:184,1-190,2"
]

VerificationTest[
    MCPServerObject[ { "Invalid", "Input" } ],
    _Failure,
    { MCPServerObject::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidInput@@Tests/MCPServerObject.wlt:192,1-198,2"
]

VerificationTest[
    MCPServerObject[ <| "InvalidKey" -> "Value" |> ],
    _Failure,
    { PatternTest::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidAssociation@@Tests/MCPServerObject.wlt:200,1-206,2"
]