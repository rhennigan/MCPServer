(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`DeployAgentTools`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

$ContextAliases[ "sp`" ] = "System`Private`";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$$deploymentMCP = KeyValuePattern @ {
    "ClientName" -> _String? StringQ | None,
    "Target"     -> _,
    "Server"     -> _String? StringQ,
    "ConfigFile" -> _File? fileQ,
    "Options"    -> _Association? AssociationQ
};

$$deploymentData = KeyValuePattern @ {
    "UUID"          -> _String? StringQ,
    "Version"       -> _Integer? IntegerQ,
    "Timestamp"     -> _DateObject,
    "PacletVersion" -> _String? StringQ,
    "CreatedBy"     -> _String? StringQ,
    "MCP"           -> $$deploymentMCP,
    "Skills"        -> _Association? AssociationQ,
    "Hooks"         -> _Association? AssociationQ,
    "Meta"          -> _Association? AssociationQ
};

$deploymentProperties = {
    "ClientName",
    "ConfigFile",
    "CreatedBy",
    "Data",
    "Hooks",
    "Location",
    "MCP",
    "Meta",
    "PacletVersion",
    "Properties",
    "Server",
    "Skills",
    "Target",
    "Timestamp",
    "UUID"
};

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*AgentToolsDeployment*)
Unprotect[ AgentToolsDeployment, AgentToolsDeployments, DeployAgentTools ];
ClearAll[ AgentToolsDeployment, AgentToolsDeployments, DeployAgentTools ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Main Definition*)
AgentToolsDeployment[ data_Association ]? sp`HoldNotValidQ :=
    catchTop[ createAgentToolsDeployment @ data, AgentToolsDeployment ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*createAgentToolsDeployment*)
createAgentToolsDeployment // beginDefinition;

createAgentToolsDeployment[ data_Association ] :=
    If[ MatchQ[ data, $$deploymentData ],
        sp`HoldSetValid @ AgentToolsDeployment @ data,
        throwFailure[ "InvalidDeploymentData", data ]
    ];

createAgentToolsDeployment // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Properties*)
(AgentToolsDeployment[ data_Association ]? sp`HoldValidQ)[ prop_String ] :=
    catchTop[ getDeploymentProperty[ data, prop ], AgentToolsDeployment ];

(AgentToolsDeployment[ data_Association ]? sp`HoldValidQ)[ prop1_String, prop2_String ] :=
    catchTop[ getDeploymentProperty[ data, prop1, prop2 ], AgentToolsDeployment ];

_AgentToolsDeployment[ invalid_ ] :=
    catchTop[ throwFailure[ "InvalidProperty", invalid ], AgentToolsDeployment ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getDeploymentProperty*)
getDeploymentProperty // beginDefinition;

(* Top-level keys *)
getDeploymentProperty[ data_Association, "UUID"          ] := data[ "UUID" ];
getDeploymentProperty[ data_Association, "Timestamp"     ] := data[ "Timestamp" ];
getDeploymentProperty[ data_Association, "PacletVersion" ] := data[ "PacletVersion" ];
getDeploymentProperty[ data_Association, "CreatedBy"     ] := data[ "CreatedBy" ];
getDeploymentProperty[ data_Association, "MCP"           ] := data[ "MCP" ];
getDeploymentProperty[ data_Association, "Skills"        ] := data[ "Skills" ];
getDeploymentProperty[ data_Association, "Hooks"         ] := data[ "Hooks" ];
getDeploymentProperty[ data_Association, "Meta"          ] := data[ "Meta" ];

(* MCP shortcut properties *)
getDeploymentProperty[ data_Association, "ClientName" ] := data[ "MCP", "ClientName" ];
getDeploymentProperty[ data_Association, "Target"     ] := data[ "MCP", "Target" ];
getDeploymentProperty[ data_Association, "Server"     ] := data[ "MCP", "Server" ];
getDeploymentProperty[ data_Association, "ConfigFile" ] := data[ "MCP", "ConfigFile" ];

(* Derived properties *)
getDeploymentProperty[ data_Association, "Data"       ] := data;
getDeploymentProperty[ data_Association, "Location"   ] := deploymentDirectory @ data[ "UUID" ];
getDeploymentProperty[ data_Association, "Properties" ] := $deploymentProperties;

(* Sub-association access *)
getDeploymentProperty[ data_Association, key_String, subKey_String ] := data[ key, subKey ];

(* Unknown property *)
getDeploymentProperty[ _, prop_ ] := Missing[ "UnknownProperty", prop ];

getDeploymentProperty // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Validation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*agentToolsDeploymentQ*)
agentToolsDeploymentQ // beginDefinition;
agentToolsDeploymentQ[ dep_AgentToolsDeployment ] := sp`HoldValidQ @ dep;
agentToolsDeploymentQ[ _ ] := False;
agentToolsDeploymentQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*UpValues*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*DeleteObject*)
AgentToolsDeployment /: DeleteObject[ dep_AgentToolsDeployment ] := catchTop[
    deleteDeployment @ ensureDeploymentExists @ dep,
    AgentToolsDeployment
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*ensureDeploymentExists*)
ensureDeploymentExists // beginDefinition;

ensureDeploymentExists[ dep_AgentToolsDeployment? agentToolsDeploymentQ ] :=
    Module[ { uuid, dir },
        uuid = dep[ "UUID" ];
        dir = deploymentDirectory @ uuid;
        If[ DirectoryQ @ dir,
            dep,
            throwFailure[ "DeploymentNotFound", uuid ]
        ]
    ];

ensureDeploymentExists // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*deleteDeployment*)
deleteDeployment // beginDefinition;

deleteDeployment[ dep_AgentToolsDeployment ] := Enclose[
    Module[ { options, uuid, dir },

        (* Uninstall MCP server config, tolerating already-removed cases *)
        options = FilterRules[
            Normal @ dep[ "MCP", "Options" ],
            Options @ UninstallMCPServer
        ];
        catchAlways @ UninstallMCPServer[ dep[ "ConfigFile" ], dep[ "Server" ], Sequence @@ options ];

        (* Remove deployment directory *)
        uuid = ConfirmBy[ dep[ "UUID" ], StringQ, "UUID" ];
        dir = ConfirmBy[ deploymentDirectory @ uuid, fileQ, "Directory" ];
        If[ DirectoryQ @ dir,
            ConfirmMatch[ DeleteDirectory[ dir, DeleteContents -> True ], Null, "Delete" ];
            ConfirmAssert[ ! FileExistsQ @ dir, "Verify" ]
        ];

        Null
    ],
    throwInternalFailure
];

deleteDeployment // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Formatting*)
AgentToolsDeployment /: MakeBoxes[ dep_AgentToolsDeployment? sp`HoldValidQ, fmt_ ] :=
    With[ { boxes = Quiet @ catchAlways @ makeDeploymentBoxes[ dep, fmt ] },
        boxes /; MatchQ[ boxes, _InterpretationBox ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeDeploymentBoxes*)
makeDeploymentBoxes // beginDefinition;

makeDeploymentBoxes[ dep_AgentToolsDeployment, fmt_ ] :=
    BoxForm`ArrangeSummaryBox[
        AgentToolsDeployment,
        dep,
        None,
        makeDeploymentSummaryRows @ dep,
        makeDeploymentHiddenRows @ dep,
        fmt
    ];

makeDeploymentBoxes // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeDeploymentSummaryRows*)
makeDeploymentSummaryRows // beginDefinition;

makeDeploymentSummaryRows[ dep_ ] := Flatten @ {
    deploymentSummaryItem[ "Target", dep[ "Target" ] ],
    deploymentSummaryItem[ "Server", dep[ "Server" ] ]
};

makeDeploymentSummaryRows // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeDeploymentHiddenRows*)
makeDeploymentHiddenRows // beginDefinition;

makeDeploymentHiddenRows[ dep_ ] := Flatten @ {
    deploymentSummaryItem[ "UUID"      , dep[ "UUID" ] ],
    deploymentSummaryItem[ "ConfigFile", dep[ "ConfigFile" ] ],
    deploymentSummaryItem[ "Timestamp" , dep[ "Timestamp" ] ]
};

makeDeploymentHiddenRows // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*deploymentSummaryItem*)
deploymentSummaryItem // beginDefinition;
deploymentSummaryItem[ _, _Missing ] := Nothing;
deploymentSummaryItem[ label_String, value_ ] := { BoxForm`SummaryItem @ { label <> ": ", value } };
deploymentSummaryItem // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Handling*)
AgentToolsDeployment[ args___ ]? sp`HoldNotValidQ := catchTop[
    throwFailure[
        "InvalidDeploymentData",
        HoldForm @ AgentToolsDeployment @ args
    ],
    AgentToolsDeployment
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Helper Functions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*deploymentDirectory*)
deploymentDirectory // beginDefinition;

deploymentDirectory[ uuid_String ] :=
    With[ { dirs = FileNames[ All, $deploymentsPath ] },
        SelectFirst[
            Flatten @ Map[ FileNames[ uuid, # ] &, dirs ],
            DirectoryQ,
            fileNameJoin[ $deploymentsPath, "Unknown", uuid ]
        ]
    ];

deploymentDirectory // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
