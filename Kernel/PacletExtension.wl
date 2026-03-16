(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`PacletExtension`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

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
(*findMCPPaclets*)
findMCPPaclets // beginDefinition;

findMCPPaclets[ ] := Enclose[
    Module[ { paclets },
        Needs[ "PacletTools`" ];
        paclets = PacletFind[ ];
        ConfirmMatch[
            Select[ paclets, mcpPacletQ ],
            { ___PacletObject },
            "Result"
        ]
    ],
    throwInternalFailure
];

findMCPPaclets // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpPacletQ*)
mcpPacletQ // beginDefinition;

mcpPacletQ[ paclet_PacletObject ] :=
    mcpPacletQ[ paclet, Quiet @ PacletTools`PacletExtensions[ paclet, "MCP" ] ];

mcpPacletQ[ _PacletObject, extensions_List ] :=
    Length[ extensions ] > 0;

mcpPacletQ[ _PacletObject, _ ] := False;

mcpPacletQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
