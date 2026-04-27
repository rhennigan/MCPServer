(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`MCPRoots`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Session State*)
$clientSupportsRoots = False;
$mcpRoot             = None;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*onClientInitialized*)
onClientInitialized // beginDefinition;

onClientInitialized[ _ ] :=
    If[ TrueQ @ $clientSupportsRoots,
        sendClientRequest[ "roots/list", <| |>, handleRootsListResponse ]
    ];

onClientInitialized // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*onRootsListChanged*)
onRootsListChanged // beginDefinition;

onRootsListChanged[ _ ] :=
    If[ TrueQ @ $clientSupportsRoots,
        sendClientRequest[ "roots/list", <| |>, handleRootsListResponse ]
    ];

onRootsListChanged // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*handleRootsListResponse*)
handleRootsListResponse // beginDefinition;

handleRootsListResponse[ request_, response_Association ] :=
    Catch @ Module[ { roots, root },
        If[ KeyExistsQ[ response, "error" ],
            writeLog[ "RootsListError" -> response[ "error" ] ];
            Throw @ Null
        ];
        roots = response[ "result", "roots" ];
        root  = pickFirstValidRoot @ roots;
        If[ StringQ @ root,
            applyMCPRoot @ root,
            writeLog[ "RootsListEmptyOrInvalid" -> roots ]
        ]
    ];

handleRootsListResponse // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*pickFirstValidRoot*)
pickFirstValidRoot // beginDefinition;

pickFirstValidRoot[ roots_List ] :=
    SelectFirst[
        rootURIToPath /@ Cases[ roots, KeyValuePattern[ "uri" -> uri_String ] :> uri ],
        StringQ[ # ] && DirectoryQ[ # ] &,
        None
    ];

pickFirstValidRoot[ _ ] := None;

pickFirstValidRoot // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*rootURIToPath*)
rootURIToPath // beginDefinition;
rootURIToPath[ uri_String /; StringStartsQ[ uri, "file://" ] ] := ExpandFileName @ LocalObject @ uri;
rootURIToPath[ _ ] := None;
rootURIToPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*applyMCPRoot*)
applyMCPRoot // beginDefinition;

applyMCPRoot[ root_String ] := (
    $mcpRoot = root;
    SetDirectory @ root;
    If[ toolOptionValue[ "WolframLanguageEvaluator", "Method" ] === "Local",
        useEvaluatorKernel @ SetDirectory @ root
    ];
    writeLog[ "RootApplied" -> root ];
);

applyMCPRoot // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $clientSupportsRoots = False;
    $mcpRoot             = None;
];

End[ ];
EndPackage[ ];
