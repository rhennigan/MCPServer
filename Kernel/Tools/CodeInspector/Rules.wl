(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`CodeInspector`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];
Needs[ "CodeInspector`" -> "ci`"   ];
Needs[ "CodeParser`"    -> "cp`"   ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$holdingSymbols = { "Hold", "HoldForm", "HoldComplete", "HoldCompleteForm" };
$$holdingSymbol = Alternatives @@ Flatten @ { "System`" <> # & /@ $holdingSymbols, $holdingSymbols };

$$yieldsDateObject = HoldPattern @ Alternatives[
    _CurrentDate,
    _DateObject,
    _DatePlus,
    _FileDate,
    _NextDate,
    _PreviousDate,
    _RandomDate,
    Now,
    Today,
    Tomorrow,
    Yesterday
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*AST Pattern Helper*)
importResourceFunction[ astPattern, "ASTPattern" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Abstract Rules*)
$abstractRules := $abstractRules = <|
    CodeInspector`AbstractRules`$DefaultAbstractRules,
    $customAbstractRules
|>;

$customAbstractRules := $customAbstractRules = <|
    cp`CallNode[ cp`LeafNode[ Symbol, "Throw"|"System`Throw", _ ], { _ }, _ ] -> scanSingleArgThrow,
    cp`CallNode[ cp`LeafNode[ Symbol, "Return"|"System`Return", _ ], { _ }, _ ] -> scanReturn,
    cp`LeafNode[ Symbol, _String? privateContextQ, _ ] -> scanPrivateContext,
    cp`LeafNode[ Symbol, _String? globalSymbolQ, _ ] -> scanGlobalSymbol,
    astPattern[ - $$yieldsDateObject ] -> scanNegatedDateObject
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Aggregate Rules*)
$aggregateRules := $aggregateRules = <|
    CodeInspector`AggregateRules`$DefaultAggregateRules
    (* Add any additional aggregate rules here *)
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Concrete Rules*)
$concreteRules := $concreteRules = <|
    CodeInspector`ConcreteRules`$DefaultConcreteRules,
    cp`LeafNode[
        Token`Comment,
        _String? (StringStartsQ[ "(*"~~WhitespaceCharacter...~~"FIXME:" ]),
        _
    ] -> scanFixMeComment
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanSingleArgThrow*)
scanSingleArgThrow // beginDefinition;

scanSingleArgThrow[ pos_, ast_ ] := Catch[
    Replace[
        Fold[ walkASTForCatch, ast, pos ],
        {
            cp`CallNode[ cp`LeafNode[ Symbol, "Throw"|"System`Throw", _ ], _, as_Association ] :>
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

scanSingleArgThrow // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*walkASTForCatch*)
walkASTForCatch // beginDefinition;

walkASTForCatch[ cp`CallNode[ cp`LeafNode[ Symbol, "Catch"|"System`Catch"|$$holdingSymbol, _ ], { _ }, _ ], _ ] :=
    Throw[ { }, $tag ];

walkASTForCatch[ ast_, pos_ ] :=
    Extract[ ast, pos ];

walkASTForCatch // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanReturn*)
scanReturn // beginDefinition;

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

scanReturn // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanPrivateContext*)
scanPrivateContext // beginDefinition;

(* Skip matches inside AST metadata (e.g., "Definitions" key) to avoid duplicate issues *)
scanPrivateContext[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };

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

scanPrivateContext // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*privateContextQ*)
privateContextQ // beginDefinition;
privateContextQ[ name_String ] /; StringStartsQ[ name, "System`Private`" ] := False;
privateContextQ[ name_String ] := StringContainsQ[ name, __ ~~ ("`Private`"|"`PackagePrivate`") ];
privateContextQ[ ___ ] := False;
privateContextQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanGlobalSymbol*)
scanGlobalSymbol // beginDefinition;

(* Skip matches inside AST metadata (e.g., "Definitions" key) to avoid duplicate issues *)
scanGlobalSymbol[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };

scanGlobalSymbol[ pos_, ast_ ] :=
    Enclose @ Module[ { node, name, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        name = ConfirmBy[ node[[ 2 ]], StringQ, "Name" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "GlobalSymbol",
            "The symbol ``" <> name <> "`` is in the global context",
            "Warning",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];

scanGlobalSymbol // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*globalSymbolQ*)
globalSymbolQ // beginDefinition;
globalSymbolQ[ name_String ] := StringStartsQ[ name, "Global`" ];
globalSymbolQ[ ___ ] := False;
globalSymbolQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanFixMeComment*)
scanFixMeComment // beginDefinition;

scanFixMeComment[ pos_, ast_ ] :=
    Enclose @ Module[ { node, comment, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        comment = StringTrim @ StringTrim[ ConfirmBy[ node[[ 2 ]], StringQ, "Comment" ], { "(*", "*)" } ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[ "FixMeComment", comment, "Warning", <| as, ConfidenceLevel -> 0.9 |> ]
    ];

scanFixMeComment // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*scanNegatedDateObject*)
scanNegatedDateObject // beginDefinition;

scanNegatedDateObject[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "NegatedDateObject",
            "Negating a ``DateObject`` does not produce a meaningful result",
            "Error",
            <| as, ConfidenceLevel -> 0.95 |>
        ]
    ];

scanNegatedDateObject // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $customAbstractRules;
];

End[ ];
EndPackage[ ];