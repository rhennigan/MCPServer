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
(*Object Creation*)
VerificationTest[
    name = StringJoin["TestServer_", CreateUUID[]];
    data = <|
        "Name" -> name,
        "LLMEvaluator" -> <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    |>;
    obj = MCPServerObject[data],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-BasicCreation@@Tests/MCPServerObject.wlt:27,1-37,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties and Accessors*)

VerificationTest[
    obj["Name"],
    name,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-GetName@@Tests/MCPServerObject.wlt:43,1-48,2"
]

VerificationTest[
    obj["Location"],
    _File? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetLocation@@Tests/MCPServerObject.wlt:50,1-55,2"
]

VerificationTest[
    obj["LLMConfiguration"],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetLLMConfiguration@@Tests/MCPServerObject.wlt:57,1-62,2"
]

VerificationTest[
    obj["Tools"],
    { _LLMTool },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetTools@@Tests/MCPServerObject.wlt:64,1-69,2"
]

VerificationTest[
    obj["ServerVersion"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetServerVersion@@Tests/MCPServerObject.wlt:71,1-76,2"
]

VerificationTest[
    obj["ObjectVersion"],
    _Integer? IntegerQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetObjectVersion@@Tests/MCPServerObject.wlt:78,1-83,2"
]

VerificationTest[
    obj["JSONConfiguration"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-GetJSONConfiguration@@Tests/MCPServerObject.wlt:85,1-90,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Retrieval by Name*)
VerificationTest[
    MCPServerObject @ name,
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-RetrieveByName@@Tests/MCPServerObject.wlt:95,1-100,2"
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
    TestID   -> "MCPServerObject-MultipleProperties@@Tests/MCPServerObject.wlt:105,1-115,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Built-in Servers*)
VerificationTest[
    builtInServer = MCPServerObject["WolframLanguage"],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-BuiltInServer@@Tests/MCPServerObject.wlt:120,1-125,2"
]

VerificationTest[
    builtInServer["Name"],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerName@@Tests/MCPServerObject.wlt:127,1-132,2"
]

VerificationTest[
    builtInServer["Location"],
    "BuiltIn",
    SameTest -> Equal,
    TestID   -> "MCPServerObject-BuiltInServerLocation@@Tests/MCPServerObject.wlt:134,1-139,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Objects Listing*)
VerificationTest[
    servers = MCPServerObjects[],
    { ___MCPServerObject? MCPServerObjectQ },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-ListAllServers@@Tests/MCPServerObject.wlt:144,1-149,2"
]

VerificationTest[
    Length[MCPServerObjects[]] > 0,
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-ConfirmServersExist@@Tests/MCPServerObject.wlt:151,1-156,2"
]

VerificationTest[
    MemberQ[MCPServerObjects["Wolfram*"], _MCPServerObject? MCPServerObjectQ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerObject-ListPatternServers@@Tests/MCPServerObject.wlt:158,1-163,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete Servers*)
VerificationTest[
    DeleteObject @ obj,
    Null,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-DeleteObject@@Tests/MCPServerObject.wlt:168,1-173,2"
]

VerificationTest[
    Quiet @ MCPServerObject @ name,
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-VerifyDeletion@@Tests/MCPServerObject.wlt:175,1-181,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    MCPServerObject[ "NonExistentServer" ],
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-NonExistentServer@@Tests/MCPServerObject.wlt:186,1-192,2"
]

VerificationTest[
    MCPServerObject[ { "Invalid", "Input" } ],
    _Failure,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidInput@@Tests/MCPServerObject.wlt:194,1-199,2"
]

VerificationTest[
    MCPServerObject[ <| "InvalidKey" -> "Value" |> ],
    _Failure,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-InvalidAssociation@@Tests/MCPServerObject.wlt:201,1-206,2"
]