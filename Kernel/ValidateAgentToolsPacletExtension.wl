(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`ValidateAgentToolsPacletExtension`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

Needs[ "PacletTools`" -> "pt`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$validExtensionKeys = { "Root", "MCPServers", "Tools", "MCPPrompts" };

$$declarationItem = _String | { _String, _String } | _Association? (KeyExistsQ[ #, "Name" ] &);

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*ValidateAgentToolsPacletExtension*)
ValidateAgentToolsPacletExtension // beginDefinition;

ValidateAgentToolsPacletExtension[ paclet_PacletObject? PacletObjectQ ] :=
    catchMine @ validateAgentToolsPacletExtension @ paclet;

ValidateAgentToolsPacletExtension[ spec_ ] :=
    catchMine @ With[ { paclet = Quiet @ PacletObject @ spec },
        If[ PacletObjectQ @ paclet,
            validateAgentToolsPacletExtension @ paclet,
            throwFailure[ "InvalidPacletSpecification", spec ]
        ]
    ];

ValidateAgentToolsPacletExtension // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*validateAgentToolsPacletExtension*)
validateAgentToolsPacletExtension // beginDefinition;

validateAgentToolsPacletExtension[ paclet_PacletObject ] := Enclose[
    Catch @ Module[ { structureResult, extensionData, structureErrors, root, rootErrors,
              servers, tools, prompts, fileErrors, contentErrors, crossRefErrors, allErrors },

        (* 1. Extension structure *)
        structureResult = validateExtensionStructure @ paclet;
        extensionData   = structureResult[ "Data" ];
        structureErrors = structureResult[ "Errors" ];

        If[ ! AssociationQ @ extensionData,
            Throw @ buildFailure[ paclet, structureErrors ]
        ];

        (* 2. File existence *)
        root = tryGetExtensionDirectory @ paclet;
        rootErrors = If[ ! StringQ @ root,
            { <| "Type" -> "MissingRootDirectory", "Message" -> "Root directory does not exist." |> },
            { }
        ];

        servers = getAgentToolsDeclaredItems[ paclet, "MCPServers" ];
        tools   = getAgentToolsDeclaredItems[ paclet, "Tools"      ];
        prompts = getAgentToolsDeclaredItems[ paclet, "MCPPrompts" ];

        fileErrors = If[ StringQ @ root,
            Join[
                checkFileExistence[ root, "MCPServers", servers ],
                checkFileExistence[ root, "Tools"     , tools   ],
                checkFileExistence[ root, "MCPPrompts", prompts ]
            ],
            { }
        ];

        (* 3. File contents *)
        contentErrors = If[ StringQ @ root,
            Join[
                checkFileContents[ paclet, "MCPServers", servers ],
                checkFileContents[ paclet, "Tools"     , tools   ],
                checkFileContents[ paclet, "MCPPrompts", prompts ]
            ],
            { }
        ];

        (* 4. Cross-references *)
        crossRefErrors = If[ StringQ @ root,
            checkCrossReferences[ paclet, servers, tools, prompts ],
            { }
        ];

        allErrors = Join[ structureErrors, rootErrors, fileErrors, contentErrors, crossRefErrors ];

        If[ Length @ allErrors > 0,
            buildFailure[ paclet, allErrors ],
            Success[ "ValidAgentToolsPacletExtension", <|
                "MCPServers" -> servers,
                "Tools"      -> tools,
                "MCPPrompts" -> prompts
            |> ]
        ]
    ],
    throwInternalFailure
];

validateAgentToolsPacletExtension // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*tryGetExtensionDirectory*)
tryGetExtensionDirectory // beginDefinition;

tryGetExtensionDirectory[ paclet_PacletObject ] :=
    Module[ { root },
        root = Quiet @ catchAlways @ getAgentToolsExtensionDirectory @ paclet;
        If[ StringQ @ root && DirectoryQ @ root,
            root,
            $Failed
        ]
    ];

tryGetExtensionDirectory // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*validateExtensionStructure*)
validateExtensionStructure // beginDefinition;

validateExtensionStructure[ paclet_PacletObject ] :=
    Catch @ Module[ { errors, extensions, extension, data, invalidKeys },

        errors = { };

        (* Check that the paclet has an AgentTools extension *)
        Needs[ "PacletTools`" -> None ];
        extensions = Quiet @ pt`PacletExtensions[ paclet, "AgentTools" ];
        If[ ! MatchQ[ extensions, { __List } ],
            Throw @ <| "Data" -> $Failed, "Errors" -> {
                <| "Type" -> "NoAgentToolsExtension", "Message" -> "PacletInfo does not contain an \"AgentTools\" extension." |>
            } |>
        ];

        extension = First @ extensions;
        If[ ! MatchQ[ extension, { "AgentTools", _Association } ],
            Throw @ <| "Data" -> $Failed, "Errors" -> {
                <| "Type" -> "MalformedExtension", "Message" -> "AgentTools extension has unexpected format." |>
            } |>
        ];

        data = Last @ extension;

        (* Check for invalid keys *)
        invalidKeys = Complement[ Keys @ data, $validExtensionKeys ];
        If[ Length @ invalidKeys > 0,
            AppendTo[ errors, <|
                "Type"    -> "InvalidExtensionKeys",
                "Keys"    -> invalidKeys,
                "Message" -> "Unknown extension keys: " <> StringRiffle[ ToString /@ invalidKeys, ", " ] <> "."
            |> ]
        ];

        (* Check each declared item uses a valid form *)
        Scan[
            Function[ type,
                Module[ { items },
                    items = Lookup[ data, type, { } ];
                    If[ ListQ @ items,
                        MapIndexed[
                            Function[ { item, pos },
                                If[ ! MatchQ[ item, $$declarationItem ],
                                    AppendTo[ errors, <|
                                        "Type"     -> "InvalidDeclaration",
                                        "ItemType" -> type,
                                        "Position" -> First @ pos,
                                        "Message"  -> "Invalid declaration form at position " <> ToString @ First @ pos <> " in \"" <> type <> "\"."
                                    |> ]
                                ]
                            ],
                            items
                        ]
                    ]
                ]
            ],
            { "MCPServers", "Tools", "MCPPrompts" }
        ];

        <| "Data" -> data, "Errors" -> errors |>
    ];

validateExtensionStructure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*checkFileExistence*)
checkFileExistence // beginDefinition;

checkFileExistence[ root_String, type_String, names_List ] :=
    Join @@ (checkItemFileExistence[ root, type, # ] & /@ names);

checkFileExistence // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkItemFileExistence*)
checkItemFileExistence // beginDefinition;

checkItemFileExistence[ root_String, type_String, name_String ] :=
    Module[ { dir, perItemFiles, hasCombined, errors },

        errors = { };

        dir = FileNameJoin @ { root, type };
        perItemFiles = If[ DirectoryQ @ dir, FileNames[ { name<>".mx", name<>".wxf", name<>".wl" }, dir ], { } ];

        hasCombined = StringQ @ findCombinedFile[ root, type ];

        If[ Length @ perItemFiles > 1,
            AppendTo[ errors, <|
                "Type"     -> "DuplicateDefinitionFiles",
                "Item"     -> name,
                "ItemType" -> type,
                "Files"    -> perItemFiles,
                "Message"  -> "Multiple definition files for " <> type <> " \"" <> name <> "\": " <> StringRiffle[ FileNameTake /@ perItemFiles, ", " ] <> "."
            |> ]
        ];

        If[ Length @ perItemFiles === 0 && ! hasCombined,
            AppendTo[ errors, <|
                "Type"         -> "MissingDefinitionFile",
                "Item"         -> name,
                "ItemType"     -> type,
                "ExpectedPath" -> FileNameJoin @ { root, type, name <> ".wl" },
                "Message"      -> "Missing definition file for " <> type <> " \"" <> name <> "\"."
            |> ]
        ];

        errors
    ];

checkItemFileExistence // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*checkFileContents*)
checkFileContents // beginDefinition;

checkFileContents[ paclet_PacletObject, type_String, names_List ] :=
    Join @@ (checkItemFileContents[ paclet, type, # ] & /@ names);

checkFileContents // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkItemFileContents*)
checkItemFileContents // beginDefinition;

checkItemFileContents[ paclet_PacletObject, type_String, name_String ] :=
    Catch @ Module[ { data },
        data = Quiet @ loadPacletDefinitionFile[ paclet, type, name ];
        (* LLMTool expressions are valid tool definitions that need no further checking *)
        If[ type === "Tools" && MatchQ[ data, _LLMTool ], Throw @ { } ];
        If[ ! AssociationQ @ data,
            Throw @ { <| "Type" -> "InvalidDefinitionContents", "Item" -> name, "ItemType" -> type,
                     "Message" -> "Definition file for " <> type <> " \"" <> name <> "\" did not evaluate to a valid Association." |> }
        ];
        Switch[ type,
            "MCPServers", checkServerDefinition[ name, data ],
            "Tools"     , checkToolDefinition[ name, data ],
            "MCPPrompts", checkPromptDefinition[ name, data ],
            _           , { }
        ]
    ];

checkItemFileContents // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkServerDefinition*)
checkServerDefinition // beginDefinition;

checkServerDefinition[ name_String, data_Association ] :=
    If[ ! KeyExistsQ[ data, "LLMEvaluator" ],
        { <| "Type" -> "InvalidServerDefinition", "Item" -> name,
             "Message" -> "Server definition \"" <> name <> "\" is missing required key \"LLMEvaluator\"." |> },
        { }
    ];

checkServerDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkToolDefinition*)
$requiredToolKeys = { "Name", "Function", "Parameters" };

checkToolDefinition // beginDefinition;

checkToolDefinition[ name_String, data_Association ] :=
    Module[ { missing },
        missing = Select[ $requiredToolKeys, ! KeyExistsQ[ data, # ] & ];
        If[ Length @ missing > 0,
            { <| "Type" -> "InvalidToolDefinition", "Item" -> name, "MissingKeys" -> missing,
                 "Message" -> "Tool definition \"" <> name <> "\" is missing required keys: " <> StringRiffle[ missing, ", " ] <> "." |> },
            { }
        ]
    ];

checkToolDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkPromptDefinition*)
checkPromptDefinition // beginDefinition;

checkPromptDefinition[ name_String, data_Association ] :=
    If[ ! KeyExistsQ[ data, "Name" ],
        { <| "Type" -> "InvalidPromptDefinition", "Item" -> name,
             "Message" -> "Prompt definition \"" <> name <> "\" is missing required key \"Name\"." |> },
        { }
    ];

checkPromptDefinition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*checkCrossReferences*)
checkCrossReferences // beginDefinition;

checkCrossReferences[ paclet_PacletObject, servers_List, tools_List, prompts_List ] :=
    Join @@ (checkServerCrossReferences[ paclet, #, tools, prompts ] & /@ servers);

checkCrossReferences // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*checkServerCrossReferences*)
checkServerCrossReferences // beginDefinition;

checkServerCrossReferences[ paclet_PacletObject, serverName_String, tools_List, prompts_List ] :=
    Catch @ Module[ { data, evaluator, referencedTools, referencedPrompts, toolErrors, promptErrors },
        data = Quiet @ loadPacletDefinitionFile[ paclet, "MCPServers", serverName ];
        If[ ! AssociationQ @ data, Throw @ { } ];

        evaluator = Lookup[ data, "LLMEvaluator", <| |> ];
        If[ ! AssociationQ @ evaluator, Throw @ { } ];

        referencedTools = Lookup[ evaluator, "Tools", { } ];
        toolErrors = If[ ListQ @ referencedTools,
            Cases[
                referencedTools,
                toolRef_String /; ! validCrossReference[ toolRef, tools ] :>
                    <| "Type" -> "InvalidToolReference", "Server" -> serverName, "Tool" -> toolRef,
                       "Message" -> "Server \"" <> serverName <> "\" references tool \"" <> toolRef <> "\" which is not declared in this paclet and is not a fully qualified name." |>
            ],
            { }
        ];

        referencedPrompts = Lookup[ evaluator, "MCPPrompts", { } ];
        promptErrors = If[ ListQ @ referencedPrompts,
            Cases[
                referencedPrompts,
                promptRef_String /; ! validCrossReference[ promptRef, prompts ] :>
                    <| "Type" -> "InvalidPromptReference", "Server" -> serverName, "Prompt" -> promptRef,
                       "Message" -> "Server \"" <> serverName <> "\" references prompt \"" <> promptRef <> "\" which is not declared in this paclet and is not a fully qualified name." |>
            ],
            { }
        ];

        Join[ toolErrors, promptErrors ]
    ];

checkServerCrossReferences // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validCrossReference*)
validCrossReference // beginDefinition;
validCrossReference[ name_String, declared_List ] := MemberQ[ declared, name ] || pacletQualifiedNameQ @ name;
validCrossReference // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*buildFailure*)
buildFailure // beginDefinition;

buildFailure[ paclet_PacletObject, errors_List ] :=
    Module[ { firstMessage },
        firstMessage = If[ Length @ errors > 0, errors[[ 1, "Message" ]], "Unknown error." ];
        messagePrint[ "InvalidAgentToolsPacletExtension", paclet[ "Name" ], firstMessage ];
        Failure[ "InvalidAgentToolsPacletExtension", <| "Errors" -> errors |> ]
    ];

buildFailure // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
