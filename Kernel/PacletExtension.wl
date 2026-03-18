(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`PacletExtension`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

Needs[ "PacletTools`" -> "pt`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*pacletQualifiedNameQ*)
pacletQualifiedNameQ // beginDefinition;
pacletQualifiedNameQ[ name_String ] := StringContainsQ[ name, "/" ];
pacletQualifiedNameQ[ ___ ] := False;
pacletQualifiedNameQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*parsePacletQualifiedName*)
parsePacletQualifiedName // beginDefinition;

parsePacletQualifiedName[ name_String ] := Enclose[
    Module[ { parts },
        parts = ConfirmMatch[
            StringSplit[ name, "/" ],
            { _String, _String } | { _String, _String, _String },
            "Parts"
        ];
        parsePacletQualifiedName0 @ parts
    ],
    throwInternalFailure
];

parsePacletQualifiedName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parsePacletQualifiedName0*)
parsePacletQualifiedName0 // beginDefinition;

(* Two-segment: "PacletName/ItemName" *)
parsePacletQualifiedName0[ { pacletName_String, itemName_String } ] :=
    <| "PacletName" -> pacletName, "ItemName" -> itemName |>;

(* Three-segment: "PublisherID/PacletShortName/ItemName" *)
parsePacletQualifiedName0[ { publisherID_String, pacletShortName_String, itemName_String } ] :=
    <| "PacletName" -> publisherID <> "/" <> pacletShortName, "ItemName" -> itemName |>;

parsePacletQualifiedName0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findAgentToolsPaclets*)
findAgentToolsPaclets // beginDefinition;

findAgentToolsPaclets[ ] := Enclose[
    ConfirmMatch[ PacletFind[ All, <| "Extension" -> "AgentTools" |> ], { ___PacletObject }, "Result" ],
    throwInternalFailure
];

findAgentToolsPaclets // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findRemoteAgentToolsPaclets*)
findRemoteAgentToolsPaclets // beginDefinition;

findRemoteAgentToolsPaclets[ ] := findRemoteAgentToolsPaclets @ Automatic;

findRemoteAgentToolsPaclets[ updateSites: Automatic|True|False ] := Enclose[
    Catch @ Module[ { remotePaclets },
        remotePaclets = Quiet @ PacletFindRemote[ All, <| "Extension" -> "AgentTools" |>, UpdatePacletSites -> updateSites ];
        If[ ! MatchQ[ remotePaclets, { ___PacletObject } ], Throw @ { } ];
        ConfirmMatch[ remotePaclets, { ___PacletObject }, "Result" ]
    ],
    throwInternalFailure
];

findRemoteAgentToolsPaclets // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Session-Level Cache*)
$pacletDefinitionCache = <| |>;

clearPacletDefinitionCache // beginDefinition;
clearPacletDefinitionCache[ ] := $pacletDefinitionCache = <| |>;
clearPacletDefinitionCache // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getAgentToolsExtension*)
getAgentToolsExtension // beginDefinition;

getAgentToolsExtension[ paclet_PacletObject ] := Enclose[
    Module[ { extensions },
        extensions = Quiet @ pt`PacletExtensions[ paclet, "AgentTools" ];
        If[ ! MatchQ[ extensions, { __List } ], throwFailure[ "PacletExtensionNotFound", paclet[ "Name" ] ] ];
        First @ extensions
    ],
    throwInternalFailure
];

getAgentToolsExtension // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getAgentToolsExtensionData*)
getAgentToolsExtensionData // beginDefinition;

getAgentToolsExtensionData[ paclet_PacletObject ] := Enclose[
    Last @ ConfirmMatch[ getAgentToolsExtension @ paclet, { "AgentTools", _Association }, "Extension" ],
    throwInternalFailure
];

getAgentToolsExtensionData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getAgentToolsExtensionDirectory*)
getAgentToolsExtensionDirectory // beginDefinition;

getAgentToolsExtensionDirectory[ paclet_PacletObject ] := Enclose[
    Module[ { extension },
        extension = ConfirmMatch[ getAgentToolsExtension @ paclet, { "AgentTools", _Association }, "Extension" ];
        ConfirmBy[ pt`PacletExtensionDirectory[ paclet, extension ], StringQ, "Directory" ]
    ],
    throwInternalFailure
];

getAgentToolsExtensionDirectory // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractItemName*)
extractItemName // beginDefinition;
extractItemName[ name_String ] := name;
extractItemName[ { name_String, _String } ] := name;
extractItemName[ as_Association ] /; KeyExistsQ[ as, "Name" ] := as[ "Name" ];
extractItemName[ ___ ] := $Failed;
extractItemName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getAgentToolsDeclaredItems*)
getAgentToolsDeclaredItems // beginDefinition;

getAgentToolsDeclaredItems[ paclet_PacletObject, type_String ] := Enclose[
    Module[ { data, items },
        data = ConfirmBy[ getAgentToolsExtensionData @ paclet, AssociationQ, "Data" ];
        items = Lookup[ data, type, { } ];
        ConfirmMatch[ DeleteCases[ extractItemName /@ items, $Failed ], { ___String }, "Names" ]
    ],
    throwInternalFailure
];

getAgentToolsDeclaredItems // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findInstalledPaclet*)
findInstalledPaclet // beginDefinition;

findInstalledPaclet[ pacletName_String ] := Replace[
    PacletFind @ pacletName,
    { { paclet_PacletObject, ___ } :> paclet, _ :> $Failed }
];

findInstalledPaclet // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*loadFile*)
loadFile // beginDefinition;
loadFile[ file_String ] /; StringEndsQ[ file, ".mx"  ] := Import[ file, "MX" ];
loadFile[ file_String ] /; StringEndsQ[ file, ".wxf" ] := readWXFFile @ file;
loadFile[ file_String ] /; StringEndsQ[ file, ".wl"  ] := Get @ file;
loadFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findPerItemFile*)
$extensionPriority = <| "mx" -> 1, "wxf" -> 2, "wl" -> 3 |>;

findPerItemFile // beginDefinition;

findPerItemFile[ root_String, type_String, name_String ] :=
    Module[ { dir, files },
        dir = FileNameJoin @ { root, type };
        files = FileNames[ { name <> ".mx", name <> ".wxf", name <> ".wl" }, dir ];
        If[ Length @ files > 0,
            First @ SortBy[ files, Lookup[ $extensionPriority, FileExtension[ # ], 99 ] & ],
            $Failed
        ]
    ];

findPerItemFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findCombinedFile*)
findCombinedFile // beginDefinition;

findCombinedFile[ root_String, type_String ] :=
    Module[ { files },
        files = FileNames[ { type <> ".mx", type <> ".wxf", type <> ".wl" }, root ];
        If[ Length @ files > 0,
            First @ SortBy[ files, Lookup[ $extensionPriority, FileExtension[ # ], 99 ] & ],
            $Failed
        ]
    ];

findCombinedFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*loadPacletDefinitionFile*)
loadPacletDefinitionFile // beginDefinition;

loadPacletDefinitionFile[ paclet_PacletObject, type_String, name_String ] := Enclose[
    Catch @ Module[ { cacheKey, cached, root, perItemFile, combinedFile, data, result },
        (* Check cache *)
        cacheKey = { paclet[ "Name" ], paclet[ "Version" ], type, name };
        cached = $pacletDefinitionCache[ cacheKey ];
        If[ AssociationQ @ cached, Throw @ cached ];

        (* Get root directory *)
        root = ConfirmBy[ getAgentToolsExtensionDirectory @ paclet, StringQ, "Root" ];

        (* Try per-item file first *)
        perItemFile = findPerItemFile[ root, type, name ];
        If[ StringQ @ perItemFile,
            result = loadFile @ perItemFile;
            If[ AssociationQ @ result, $pacletDefinitionCache[ cacheKey ] = result ];
            Throw @ result
        ];

        (* Fall back to combined file *)
        combinedFile = findCombinedFile[ root, type ];
        If[ StringQ @ combinedFile,
            data = loadFile @ combinedFile;
            If[ AssociationQ @ data,
                result = Lookup[ data, name, $Failed ];
                If[ AssociationQ @ result, $pacletDefinitionCache[ cacheKey ] = result ];
                Throw @ result
            ]
        ];

        $Failed
    ],
    throwInternalFailure
];

loadPacletDefinitionFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*qualifyName*)
qualifyName // beginDefinition;

qualifyName[ name_String, pacletName_String ] :=
    If[ StringContainsQ[ name, "/" ], name, pacletName <> "/" <> name ];

qualifyName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*qualifyNamesInLLMEvaluator*)
qualifyNamesInLLMEvaluator // beginDefinition;

qualifyNamesInLLMEvaluator[ evaluator_Association, pacletName_String ] :=
    Module[ { result = evaluator },
        If[ KeyExistsQ[ result, "Tools" ] && ListQ @ result[ "Tools" ],
            result[ "Tools" ] = qualifyName[ #, pacletName ] & /@ result[ "Tools" ]
        ];
        If[ KeyExistsQ[ result, "MCPPrompts" ] && ListQ @ result[ "MCPPrompts" ],
            result[ "MCPPrompts" ] = qualifyName[ #, pacletName ] & /@ result[ "MCPPrompts" ]
        ];
        result
    ];

qualifyNamesInLLMEvaluator // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletTool*)
resolvePacletTool // beginDefinition;

resolvePacletTool[ qualifiedName_String ] := Enclose[
    Module[ { parsed, pacletName, itemName, paclet, declaredTools },
        parsed = ConfirmBy[ parsePacletQualifiedName @ qualifiedName, AssociationQ, "Parse" ];
        pacletName = parsed[ "PacletName" ];
        itemName = parsed[ "ItemName" ];

        paclet = findInstalledPaclet @ pacletName;
        If[ ! MatchQ[ paclet, _PacletObject ],
            With[ { pn = pacletName }, throwFailure[ "PacletNotInstalled", pn, HoldForm @ PacletInstall @ pn ] ]
        ];

        declaredTools = getAgentToolsDeclaredItems[ paclet, "Tools" ];
        If[ ! MemberQ[ declaredTools, itemName ],
            throwFailure[ "PacletToolNotFound", itemName, pacletName ]
        ];

        ConfirmBy[
            loadPacletDefinitionFile[ paclet, "Tools", itemName ],
            AssociationQ,
            "Definition"
        ]
    ],
    throwInternalFailure
];

resolvePacletTool // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletServer*)
resolvePacletServer // beginDefinition;

resolvePacletServer[ qualifiedName_String ] := Enclose[
    Module[ { parsed, pacletName, itemName, paclet, declaredServers, definition },
        parsed = ConfirmBy[ parsePacletQualifiedName @ qualifiedName, AssociationQ, "Parse" ];
        pacletName = parsed[ "PacletName" ];
        itemName = parsed[ "ItemName" ];

        paclet = findInstalledPaclet @ pacletName;
        If[ ! MatchQ[ paclet, _PacletObject ],
            With[ { pn = pacletName }, throwFailure[ "PacletNotInstalled", pn, HoldForm @ PacletInstall @ pn ] ]
        ];

        declaredServers = getAgentToolsDeclaredItems[ paclet, "MCPServers" ];
        If[ ! MemberQ[ declaredServers, itemName ],
            throwFailure[ "PacletServerNotFound", itemName, pacletName ]
        ];

        definition = ConfirmBy[
            loadPacletDefinitionFile[ paclet, "MCPServers", itemName ],
            AssociationQ,
            "Definition"
        ];

        (* Pre-qualify short names in LLMEvaluator *)
        If[ KeyExistsQ[ definition, "LLMEvaluator" ] && AssociationQ @ definition[ "LLMEvaluator" ],
            definition[ "LLMEvaluator" ] = qualifyNamesInLLMEvaluator[ definition[ "LLMEvaluator" ], pacletName ]
        ];

        definition
    ],
    throwInternalFailure
];

resolvePacletServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletPrompt*)
resolvePacletPrompt // beginDefinition;

resolvePacletPrompt[ qualifiedName_String ] := Enclose[
    Module[ { parsed, pacletName, itemName, paclet, declaredPrompts },
        parsed = ConfirmBy[ parsePacletQualifiedName @ qualifiedName, AssociationQ, "Parse" ];
        pacletName = parsed[ "PacletName" ];
        itemName = parsed[ "ItemName" ];

        paclet = findInstalledPaclet @ pacletName;
        If[ ! MatchQ[ paclet, _PacletObject ],
            With[ { pn = pacletName }, throwFailure[ "PacletNotInstalled", pn, HoldForm @ PacletInstall @ pn ] ]
        ];

        declaredPrompts = getAgentToolsDeclaredItems[ paclet, "MCPPrompts" ];
        If[ ! MemberQ[ declaredPrompts, itemName ],
            throwFailure[ "PacletPromptNotFound", itemName, pacletName ]
        ];

        ConfirmBy[
            loadPacletDefinitionFile[ paclet, "MCPPrompts", itemName ],
            AssociationQ,
            "Definition"
        ]
    ],
    throwInternalFailure
];

resolvePacletPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*ensurePacletForInstall*)
ensurePacletForInstall // beginDefinition;

ensurePacletForInstall[ qualifiedName_String ] := Enclose[
    Catch @ Module[ { parsed, pacletName, paclet },
        parsed = ConfirmBy[ parsePacletQualifiedName @ qualifiedName, AssociationQ, "Parse" ];
        pacletName = parsed[ "PacletName" ];

        (* Already installed? *)
        paclet = findInstalledPaclet @ pacletName;
        If[ MatchQ[ paclet, _PacletObject ], Throw @ paclet ];

        (* Try to install *)
        paclet = Quiet @ PacletInstall @ pacletName;
        If[ MatchQ[ paclet, _PacletObject ], Throw @ paclet ];

        With[ { pn = pacletName },
            throwFailure[ "PacletNotInstalled", pn, HoldForm @ PacletInstall @ pn ]
        ]
    ],
    throwInternalFailure
];

ensurePacletForInstall // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
