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
    "WolframAlpha"             -> "ui://wolfram/wolframalpha-viewer",
    "WolframLanguageEvaluator" -> "ui://wolfram/evaluator-viewer"
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*clientSupportsUIQ*)
clientSupportsUIQ // beginDefinition;

clientSupportsUIQ[ msg_Association ] :=
    ! MissingQ @ msg[ "params", "capabilities", "extensions", "io.modelcontextprotocol/ui" ];

clientSupportsUIQ[ _ ] := False;

clientSupportsUIQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*mcpAppsEnabledQ*)
mcpAppsEnabledQ // beginDefinition;

mcpAppsEnabledQ[ ] :=
    With[ { val = Environment[ "MCP_APPS_ENABLED" ] },
        ! StringQ[ val ] || ! StringMatchQ[ val, "false", IgnoreCase -> True ]
    ];

mcpAppsEnabledQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
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
(* ::Section::Closed:: *)
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
(* ::Section::Closed:: *)
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
(* ::Section::Closed:: *)
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
(* ::Section::Closed:: *)
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
