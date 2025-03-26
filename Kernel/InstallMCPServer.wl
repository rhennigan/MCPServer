(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`InstallMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*InstallMCPServer*)
InstallMCPServer // beginDefinition;
InstallMCPServer // Options = { };

InstallMCPServer[ target_File, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ With[ { obj = MCPServerObject @ server },
        If[ MCPServerObjectQ @ obj,
            installMCPServer[ target, obj ],
            obj
        ]
    ];

InstallMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*installMCPServer*)
installMCPServer // beginDefinition;

installMCPServer[ target0_File, obj_MCPServerObject ] := Enclose[
    Module[ { target, name, json, data, server, existing },
        target = ConfirmBy[ ExpandFileName @ target0, StringQ, "Target" ];
        GeneralUtilities`EnsureDirectory @ DirectoryName @ target;
        name = ConfirmBy[ obj[ "Name" ], StringQ, "Name" ];
        json = ConfirmBy[ obj[ "JSONConfiguration" ], StringQ, "JSONConfiguration" ];
        data = ConfirmBy[ Developer`ReadRawJSONString @ json, AssociationQ, "JSONConfiguration" ];
        server = data[ "mcpServers", name ];
        existing = ConfirmBy[ readExistingMCPConfig @ target, AssociationQ, "Existing" ];
        existing[ "mcpServers", name ] = server;
        ConfirmBy[ Developer`WriteRawJSONFile[ target, existing ], FileExistsQ, "Export" ];
        ConfirmAssert[ Developer`ReadRawJSONFile @ target === existing, "Export" ];
        File @ target
    ],
    throwInternalFailure
];

installMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readExistingMCPConfig*)
readExistingMCPConfig // beginDefinition;

readExistingMCPConfig[ file_ ] := Enclose[
    Catch @ Module[ { data },
        If[ ! FileExistsQ @ file, Throw @ <| "mcpServers" -> <| |> |> ];
        data = Developer`ReadRawJSONFile @ file;
        If[ ! MatchQ[ data, KeyValuePattern[ "mcpServers" -> _Association ] ],
            throwFailure[ "InvalidMCPConfiguration", file ]
        ];
        data
    ],
    throwInternalFailure
];

readExistingMCPConfig // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
