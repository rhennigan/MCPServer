BeginPackage[ "Wolfram`MCPServerScripts`" ];

Needs[ "CodeInspector`" -> "ci`" ];
Needs[ "CodeParser`"    -> "cp`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$inGitHub := $inGitHub = StringQ @ Environment[ "GITHUB_ACTIONS" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules*)

$$ws = cp`LeafNode[ Whitespace, __ ]...;
$$symbolAtSymbol = cp`BinaryNode[ cp`BinaryAt, { cp`LeafNode[ Symbol, _, _ ], $$ws, cp`LeafNode[ Token`At, __ ], $$ws, cp`LeafNode[ Symbol, _, _ ] }, _ ];
$$badSymbolMapPrecedence = cp`BinaryNode[ Map, { $$symbolAtSymbol, $$ws, cp`LeafNode[ Token`SlashAt, __ ], $$ws, _cp`LeafNode | _cp`CallNode }, _ ];

CodeInspector`AbstractRules`$DefaultAbstractRules = <|
    CodeInspector`AbstractRules`$DefaultAbstractRules,
    cp`CallNode[ cp`LeafNode[ Symbol, "Throw", _ ], { _ }, _ ] -> scanSingleArgThrow,
    CodeParser`CallNode[ CodeParser`LeafNode[ Symbol, "Return"|"System`Return", _ ], _, _ ] -> scanReturn,
    cp`LeafNode[ Symbol, _String? privateContextQ, _ ] -> scanPrivateContext,
    cp`LeafNode[ Symbol, _String? globalSymbolQ, _ ] -> scanGlobalSymbol
|>;

CodeInspector`ConcreteRules`$DefaultConcreteRules = <|
    CodeInspector`ConcreteRules`$DefaultConcreteRules,
    cp`LeafNode[
        Token`Comment,
        _String? (StringStartsQ[ "(*"~~WhitespaceCharacter...~~"FIXME:" ]),
        _
    ] -> scanFixMeComment,
    $$badSymbolMapPrecedence -> scanAmbiguousMapSyntax
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanSingleArgThrow*)
scanSingleArgThrow // ClearAll;
scanSingleArgThrow[ pos_, ast_ ] := Catch[
    Replace[
        Fold[ walkASTForCatch, ast, pos ],
        {
            cp`CallNode[ cp`LeafNode[ Symbol, "Throw", _ ], _, as_Association ] :>
                ci`InspectionObject[
                    "NoSurroundingCatch",
                    "``Throw`` has no tag or surrounding ``Catch``",
                    "Error",
                    <| as, ConfidenceLevel -> 0.9 |>
                ],
            ___ :> { }
        }
    ],
    $tag
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*walkASTForCatch*)
walkASTForCatch // ClearAll;

walkASTForCatch[ cp`CallNode[ cp`LeafNode[ Symbol, "Catch"|"Hold"|"HoldForm"|"HoldComplete", _ ], { _ }, _ ], _ ] :=
    Throw[ { }, $tag ];

walkASTForCatch[ ast_, pos_ ] :=
    Extract[ ast, pos ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanReturn*)
scanReturn // ClearAll;
scanReturn[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "ReturnAmbiguous",
            "The return point of ``Return`` is ambiguous, consider using ``Catch``/``Throw`` instead",
            "Warning",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanPrivateContext*)
scanPrivateContext // ClearAll;
scanPrivateContext[ pos_, ast_ ] :=
    Enclose @ Module[ { node, name, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        name = ConfirmBy[ node[[ 2 ]], StringQ, "Name" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "PrivateContextSymbol",
            "The symbol ``" <> name <> "`` is in a private context",
            "Warning",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*privateContextQ*)
privateContextQ // ClearAll;
privateContextQ[ name_String ] /; StringStartsQ[ name, "System`Private`" ] := False;
privateContextQ[ name_String ] := StringContainsQ[ name, __ ~~ ("`Private`"|"`PackagePrivate`") ];
privateContextQ[ ___ ] := False;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanGlobalSymbol*)
scanGlobalSymbol // ClearAll;
scanGlobalSymbol[ pos_, ast_ ] :=
    Enclose @ Module[ { node, name, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        name = ConfirmBy[ node[[ 2 ]], StringQ, "Name" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "GlobalSymbol",
            "The symbol ``" <> name <> "`` is in the global context",
            "Error",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*globalSymbolQ*)
globalSymbolQ // ClearAll;
globalSymbolQ[ name_String ] := StringStartsQ[ name, "Global`" ];
globalSymbolQ[ ___ ] := False;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanFixMeComment*)
scanFixMeComment // ClearAll;

scanFixMeComment[ pos_, ast_ ] /; $inGitHub :=
    Enclose @ Module[ { node, comment, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        comment = StringTrim @ StringTrim[ ConfirmBy[ node[[ 2 ]], StringQ, "Comment" ], { "(*", "*)" } ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[ "FixMeComment", comment, "Remark", <| as, ConfidenceLevel -> 0.9 |> ]
    ];

scanFixMeComment[ pos_, ast_ ] := { };

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanAmbiguousMapSyntax*)
scanAmbiguousMapSyntax // ClearAll;

scanAmbiguousMapSyntax[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as, fNode, gNode, xNode },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];

        fNode = ConfirmMatch[ node[[ 2, 1, 2, 1 ]], _[ _, _, __ ], "FNode" ];
        gNode = ConfirmMatch[ node[[ 2, 1, 2, 5 ]], _[ _, _, __ ], "GNode" ];
        xNode = ConfirmMatch[ node[[ 2, 5 ]], _[ _, _, __ ], "XNode" ];

        With[ {
            fStr = cp`ToSourceCharacterString @ fNode,
            gStr = cp`ToSourceCharacterString @ gNode,
            xStr = cp`ToSourceCharacterString @ xNode
        },
            ci`InspectionObject[
                "AmbiguousMapSyntax",
                "``" <> fStr <> " @ " <> gStr <> " /@ " <> xStr <> "`` is parsed as ``Map[" <> fStr <> "[" <> gStr <> "], " <> xStr <> "]``. \
Suggestions: ``" <> fStr <> "[" <> gStr <> " /@ " <> xStr <> "]`` or ``" <> fStr <> "[" <> gStr <> "] /@ " <> xStr <> "``.",
                "Warning",
                <| as, ConfidenceLevel -> 0.95 |>
            ]
        ]
    ];

EndPackage[ ];