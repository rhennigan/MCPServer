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

$$setOrSetDelayed = "Set"|"System`Set"|"SetDelayed"|"System`SetDelayed";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$maxLineLength = 200;
$maxFileLines  = 10000;

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
    (* Single-Argument Throw appearing without a surrounding Catch *)
    cp`CallNode[ cp`LeafNode[ Symbol, "Throw"|"System`Throw", _ ], { _ }, _ ] -> inspectSingleArgThrow,
    (* Single-Argument Return *)
    cp`CallNode[ cp`LeafNode[ Symbol, "Return"|"System`Return", _ ], { _ }, _ ] -> inspectReturn,
    (* Private Context Symbol *)
    cp`LeafNode[ Symbol, _String? privateContextQ, _ ] -> inspectPrivateContext,
    (* Global Symbol *)
    cp`LeafNode[ Symbol, _String? globalSymbolQ, _ ] -> inspectGlobalSymbol,
    (* Negated Date Object *)
    astPattern[ - $$yieldsDateObject ] -> inspectNegatedDateObject,
    (* ReadString with Character Encoding *)
    astPattern @ HoldPattern @ ReadString[ __, CharacterEncoding -> _String? StringQ, ___ ] ->
        inspectReadStringWithCharacterEncoding,
    (* Nothing as Value in Association *)
    astPattern @ HoldPattern @ Association[ ___, (Rule|RuleDelayed)[ _, Nothing ], ___ ] ->
        inspectNothingInAssociation,
    (* KeyExistsQ with List as Second Argument *)
    astPattern @ HoldPattern @ KeyExistsQ[ _, _List ] -> inspectKeyExistsQWithList,
    (* Definitions of the form `x /; cond := value` that need ordering checked *)
    astPattern @ HoldPattern[ Verbatim[ Condition ][ _Symbol, _ ] := _ ] ->
        inspectConditionalOwnValueOrdering,
    (* Definitions of the form `f[] /; cond := value` that need ordering checked *)
    astPattern @ HoldPattern[ Verbatim[ Condition ][ _Symbol[ ], _ ] := _ ] ->
        inspectConditionalDownValueOrdering
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
(* ::Subsection::Closed:: *)
(*inspectReadStringWithCharacterEncoding*)
inspectReadStringWithCharacterEncoding // beginDefinition;

inspectReadStringWithCharacterEncoding[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "ReadStringCharacterEncoding",
            $readStringWithCharacterEncodingHint,
            "Error",
            <| as, ConfidenceLevel -> 0.95 |>
        ]
    ];

inspectReadStringWithCharacterEncoding // endDefinition;

$readStringWithCharacterEncodingHint = "\
``ReadString`` does not support the ``CharacterEncoding`` option; \
use ``ByteArrayToString[ReadByteArray[source], encoding]`` instead";

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNothingInAssociation*)
inspectNothingInAssociation // beginDefinition;

inspectNothingInAssociation[ pos_, ast_ ] :=
    Enclose @ Module[ { node, children, nothingRules },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        children = ConfirmBy[ node[[ 2 ]], ListQ, "Children" ];
        nothingRules = Cases[ children, $$nothingValueRule ];
        inspectNothingRule /@ nothingRules
    ];

inspectNothingInAssociation // endDefinition;

$$nothingValueRule := $$nothingValueRule = astPattern[ (Rule|RuleDelayed)[ _, Nothing ] ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*inspectNothingRule*)
inspectNothingRule // beginDefinition;

inspectNothingRule[ cp`CallNode[ _, _, as_Association ] ] :=
    ci`InspectionObject[
        "NothingValueInAssociation",
        $nothingInAssociationHint,
        "Warning",
        <| as, ConfidenceLevel -> 0.9 |>
    ];

inspectNothingRule // endDefinition;

$nothingInAssociationHint = "\
``Nothing`` used as a value in an ``Association`` is not automatically removed; \
the key will map to the value ``Nothing``";

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectKeyExistsQWithList*)
inspectKeyExistsQWithList // beginDefinition;

inspectKeyExistsQWithList[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "KeyExistsQNestedKeyPath",
            $keyExistsQNestedKeyPathHint,
            "Warning",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];

inspectKeyExistsQWithList // endDefinition;

$keyExistsQNestedKeyPathHint = "\
``KeyExistsQ`` with a ``List`` as its second argument checks for a literal list key in the association, \
not a nested key path. If you intended a nested lookup, use ``!MissingQ[assoc[\"k1\", \"k2\", ...]]`` instead";

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectConditionalOwnValueOrdering*)
inspectConditionalOwnValueOrdering // beginDefinition;

(* Skip matches inside AST metadata (e.g., "Definitions" key) to avoid duplicate issues *)
inspectConditionalOwnValueOrdering[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };

inspectConditionalOwnValueOrdering[ pos_, ast_ ] :=
    Enclose @ Module[ { node, name, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        name = ConfirmBy[ node[[ 2, 1, 2, 1, 2 ]], StringQ, "Name" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        If[ hasUnconditionalOwnValueQ[ ast, name ],
            ci`InspectionObject[
                "UnreachableConditionalDefinition",
                unreachableConditionalHint @ name,
                "Warning",
                <| as, ConfidenceLevel -> 0.9 |>
            ],
            { }
        ]
    ];

inspectConditionalOwnValueOrdering // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*hasUnconditionalOwnValueQ*)
hasUnconditionalOwnValueQ // beginDefinition;

hasUnconditionalOwnValueQ[ ast_, name_String ] :=
    MemberQ[
        ast,
        cp`CallNode[
            cp`LeafNode[ Symbol, $$setOrSetDelayed, _ ],
            { cp`LeafNode[ Symbol, name, _ ], _ },
            _
        ],
        Infinity
    ];

hasUnconditionalOwnValueQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectConditionalDownValueOrdering*)
inspectConditionalDownValueOrdering // beginDefinition;

(* Skip matches inside AST metadata (e.g., "Definitions" key) to avoid duplicate issues *)
inspectConditionalDownValueOrdering[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };

inspectConditionalDownValueOrdering[ pos_, ast_ ] :=
    Enclose @ Module[ { node, name, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        name = ConfirmBy[ node[[ 2, 1, 2, 1, 1, 2 ]], StringQ, "Name" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        If[ hasUnconditionalDownValue[ ast, name ],
            ci`InspectionObject[
                "UnreachableConditionalDefinition",
                unreachableConditionalHint @ name,
                "Warning",
                <| as, ConfidenceLevel -> 0.9 |>
            ],
            { }
        ]
    ];

inspectConditionalDownValueOrdering // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*hasUnconditionalDownValue*)
hasUnconditionalDownValue // beginDefinition;

hasUnconditionalDownValue[ ast_, name_String ] :=
    MemberQ[
        ast,
        cp`CallNode[
            cp`LeafNode[ Symbol, $$setOrSetDelayed, _ ],
            { cp`CallNode[ cp`LeafNode[ Symbol, name, _ ], { }, _ ], _ },
            _
        ],
        Infinity
    ];

hasUnconditionalDownValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*unreachableConditionalHint*)
unreachableConditionalHint // beginDefinition;

unreachableConditionalHint[ name0_String ] :=
    Module[ { name },
        name = Last @ StringSplit[ name0, "`" ];
        "This conditional definition of ``" <> name <>
        "`` is likely unreachable since other unconditional definitions override it"
    ];

unreachableConditionalHint // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Text-Level Inspections*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*textLevelInspections*)
textLevelInspections // beginDefinition;

textLevelInspections[ code_String ] :=
    Module[ { lines },
        lines = StringSplit[ code, "\n", All ];
        Flatten @ {
            inspectLineLengths @ lines,
            inspectFileLength @ lines
        }
    ];

textLevelInspections // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectLineLengths*)
inspectLineLengths // beginDefinition;

inspectLineLengths[ lines_List ] := MapIndexed[
    Function[
        { line, idx },
        With[ { len = StringLength @ line },
            If[ len > $maxLineLength,
                ci`InspectionObject[
                    "ExcessiveLineLength",
                    StringJoin[
                        "Line is ",
                        ToString @ len,
                        " characters long (maximum recommended: ",
                        ToString @ $maxLineLength,
                        ")"
                    ],
                    "Formatting",
                    <|
                        cp`Source -> { { First @ idx, $maxLineLength + 1 }, { First @ idx, len } },
                        ConfidenceLevel -> 0.95
                    |>
                ],
                Nothing
            ]
        ]
    ],
    lines
];

inspectLineLengths // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectFileLength*)
inspectFileLength // beginDefinition;

inspectFileLength[ lines_List ] /; Length @ lines > $maxFileLines :=
    ci`InspectionObject[
        "ExcessiveFileLength",
        "File is " <> ToString @ Length @ lines <> " lines long (maximum recommended: " <> ToString @ $maxFileLines <> ")",
        "Formatting",
        <| cp`Source -> { { 1, 1 }, { Length @ lines, Max[ StringLength /@ lines, 1 ] } }, ConfidenceLevel -> 0.95 |>
    ];

inspectFileLength[ _List ] := { };

inspectFileLength // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $customAbstractRules;
];

End[ ];
EndPackage[ ];