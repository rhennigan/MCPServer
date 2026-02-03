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
    cp`CallNode[ cp`LeafNode[ Symbol, "Throw"|"System`Throw", _ ], { _ }, _ ] -> inspectSingleArgThrow,
    cp`CallNode[ cp`LeafNode[ Symbol, "Return"|"System`Return", _ ], { _ }, _ ] -> inspectReturn,
    cp`LeafNode[ Symbol, _String? privateContextQ, _ ] -> inspectPrivateContext,
    cp`LeafNode[ Symbol, _String? globalSymbolQ, _ ] -> inspectGlobalSymbol,
    astPattern[ - $$yieldsDateObject ] -> inspectNegatedDateObject
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
    ] -> inspectFixMeComment
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectSingleArgThrow*)
inspectSingleArgThrow // beginDefinition;

inspectSingleArgThrow[ pos_, ast_ ] := Catch[
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

inspectSingleArgThrow // endDefinition;

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
(*inspectReturn*)
inspectReturn // beginDefinition;

inspectReturn[ pos_, ast_ ] :=
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

inspectReturn // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectPrivateContext*)
inspectPrivateContext // beginDefinition;

(* Skip matches inside AST metadata (e.g., "Definitions" key) to avoid duplicate issues *)
inspectPrivateContext[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };

inspectPrivateContext[ pos_, ast_ ] :=
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

inspectPrivateContext // endDefinition;

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
(*inspectGlobalSymbol*)
inspectGlobalSymbol // beginDefinition;

(* Skip matches inside AST metadata (e.g., "Definitions" key) to avoid duplicate issues *)
inspectGlobalSymbol[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };

inspectGlobalSymbol[ pos_, ast_ ] :=
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

inspectGlobalSymbol // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*globalSymbolQ*)
globalSymbolQ // beginDefinition;
globalSymbolQ[ name_String ] := StringStartsQ[ name, "Global`" ];
globalSymbolQ[ ___ ] := False;
globalSymbolQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectFixMeComment*)
inspectFixMeComment // beginDefinition;

inspectFixMeComment[ pos_, ast_ ] :=
    Enclose @ Module[ { node, comment, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        comment = StringTrim @ StringTrim[ ConfirmBy[ node[[ 2 ]], StringQ, "Comment" ], { "(*", "*)" } ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[ "FixMeComment", comment, "Warning", <| as, ConfidenceLevel -> 0.9 |> ]
    ];

inspectFixMeComment // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject*)
inspectNegatedDateObject // beginDefinition;

inspectNegatedDateObject[ pos_, ast_ ] :=
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

inspectNegatedDateObject // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $customAbstractRules;
];

End[ ];
EndPackage[ ];