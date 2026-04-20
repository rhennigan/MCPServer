(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`UIResources`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)

(* Mapping of tool names to their associated UI resource URIs *)
$toolUIAssociations = <|
    "NotebookViewer"           -> "ui://wolfram/notebook-viewer",
    "MCPAppsTest"              -> "ui://wolfram/mcp-apps-test",
    "WolframLanguageEvaluator" -> "ui://wolfram/evaluator-viewer",
    (* The WolframAlpha tool does not have a text-only fallback app view, so we make it conditional *)
    "WolframAlpha" :> If[ $deployCloudNotebooks, "ui://wolfram/wolframalpha-viewer", None ]
|>;

$deployedNotebookRoot  = "AgentTools/Notebooks";
$deployCloudNotebooks := $deployCloudNotebooks = $CloudConnected; (* must be connected to deploy notebooks *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cloud Notebooks*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*deployCloudNotebookForMCPApp*)
deployCloudNotebookForMCPApp // beginDefinition;

deployCloudNotebookForMCPApp[ nb_Notebook, identifier_ ] := Enclose[
    Module[ { hash, target, deployed },

        (* This should be true if this function is being called: *)
        ConfirmAssert[ $deployCloudNotebooks, "DeployCloudNotebooksAssert" ];

        hash = ConfirmBy[ Hash[ Unevaluated @ identifier, Automatic, "HexString" ], StringQ, "Hash" ];

        target = ConfirmMatch[
            FileNameJoin @ {
                CloudObject[ $deployedNotebookRoot, Permissions -> { "All" -> { "Read", "Interact" } } ],
                hash <> ".nb"
            },
            _CloudObject,
            "Target"
        ];

        deployed = CloudDeploy[
            nb,
            target,
            AppearanceElements -> None,
            AutoRemove         -> True,
            IconRules          -> { },
            Permissions        -> { "All" -> { "Read", "Interact" } }
        ];

        If[ MatchQ[ deployed, _CloudObject ],
            ConfirmBy[ First @ deployed, StringQ, "Result" ],
            (* If deploying failed, disable cloud notebook deployment for the remainder of the session: *)
            $deployCloudNotebooks = False;
            $Failed
        ]
    ],
    throwInternalFailure
];

deployCloudNotebookForMCPApp // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCP Integration Helpers*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clientSupportsUIQ*)
clientSupportsUIQ // beginDefinition;

clientSupportsUIQ[ msg_Association ] :=
    ! MissingQ @ msg[ "params", "capabilities", "extensions", "io.modelcontextprotocol/ui" ];

clientSupportsUIQ[ _ ] := False;

clientSupportsUIQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpAppsEnabledQ*)
mcpAppsEnabledQ // beginDefinition;

mcpAppsEnabledQ[ ] :=
    With[ { val = Environment[ "MCP_APPS_ENABLED" ] },
        ! StringQ[ val ] || ! StringMatchQ[ val, "false", IgnoreCase -> True ]
    ];

mcpAppsEnabledQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*initializeUIResources*)
initializeUIResources // beginDefinition;

initializeUIResources[ ] := Enclose[
    Module[ { assetsDir, htmlFiles },
        assetsDir = ConfirmBy[
            PacletObject[ "Wolfram/AgentTools" ][ "AssetLocation", "Apps" ],
            DirectoryQ,
            "AssetsDir"
        ];
        htmlFiles = FileNames[ "*.html", assetsDir ];
        $uiResourceRegistry = Association[
            loadUIResource /@ htmlFiles
        ];
        debugPrint[ "Loaded " <> ToString[ Length @ htmlFiles ] <> " UI resources" ];
    ],
    (
        (* Graceful fallback: no UI resources. Log the error but do not fail startup. *)
        writeError[ "Failed to load UI app assets. MCP Apps will be disabled." ];
        $uiResourceRegistry = <| |>
    ) &
];

initializeUIResources // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*loadUIResource*)
loadUIResource // beginDefinition;

loadUIResource[ htmlFile_String ] := Enclose[
    Module[ { baseName, uri, html, metaFile, meta },
        baseName = FileBaseName @ htmlFile;
        uri = "ui://wolfram/" <> baseName;
        html = ConfirmBy[ ByteArrayToString @ ReadByteArray @ htmlFile, StringQ, "HTML" ];
        metaFile = FileNameJoin[ { DirectoryName @ htmlFile, baseName <> ".json" } ];
        meta = If[ FileExistsQ @ metaFile,
            Quiet @ Developer`ReadRawJSONString @ ByteArrayToString @ ReadByteArray @ metaFile,
            <| |>
        ];
        uri -> <|
            "uri"      -> uri,
            "name"     -> baseName,
            "mimeType" -> "text/html;profile=mcp-app",
            "html"     -> html,
            "meta"     -> Replace[ meta, Except[ _Association ] :> <| |> ]
        |>
    ],
    throwInternalFailure
];

loadUIResource // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*listUIResources*)
listUIResources // beginDefinition;

listUIResources[ ] :=
    If[ TrueQ @ $clientSupportsUI,
        KeyValueMap[
            Function[ { uri, data },
                <|
                    "uri"         -> uri,
                    "name"        -> data[ "name" ],
                    "description" -> Lookup[ data, "description", "" ],
                    "mimeType"    -> data[ "mimeType" ]
                |>
            ],
            $uiResourceRegistry
        ],
        { }
    ];

listUIResources // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readUIResource*)
readUIResource // beginDefinition;

readUIResource[ msg_Association, req_ ] := Enclose[
    Module[ { uri, resource },
        uri = ConfirmBy[ msg[[ "params", "uri" ]], StringQ, "URI" ];
        resource = Lookup[ $uiResourceRegistry, uri, Missing[ "NotFound" ] ];
        If[ MissingQ @ resource,
            throwFailure[ "UIResourceNotFound", uri ],
            <| "contents" -> {
                <|
                    "uri"      -> resource[ "uri" ],
                    "mimeType" -> resource[ "mimeType" ],
                    "text"     -> resource[ "html" ],
                    "_meta"    -> resource[ "meta" ]
                |>
            } |>
        ]
    ],
    throwInternalFailure
];

readUIResource // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toolUIMetadata*)
toolUIMetadata // beginDefinition;

toolUIMetadata[ toolName_String ] :=
    If[ TrueQ @ $clientSupportsUI,
        toolUIMetadata[ toolName, Lookup[ $toolUIAssociations, toolName, None ] ],
        { }
    ];

toolUIMetadata[ toolName_String, uri_String ] :=
    { "_meta" -> <| "ui" -> <| "resourceUri" -> uri, "visibility" -> { "model", "app" } |> |> };

toolUIMetadata[ toolName_String, None ] := { };

toolUIMetadata // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*withToolUIMetadata*)
withToolUIMetadata // beginDefinition;

withToolUIMetadata[ tools_List ] :=
    Map[
        Function[ tool, Join[ tool, Association @ toolUIMetadata[ tool[ "name" ] ] ] ],
        tools
    ];

withToolUIMetadata // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
