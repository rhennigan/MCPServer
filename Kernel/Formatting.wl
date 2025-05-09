(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`Formatting`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* TODO: show installations in formatted boxes *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Argument Patterns*)
$$llmTool = HoldPattern[ _LLMTool | _String? llmToolNameQ ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*llmToolNameQ*)
llmToolNameQ // beginDefinition;
llmToolNameQ[ name_String? StringQ ] := MemberQ[ Keys @ Wolfram`Chatbook`$AvailableTools, name ];
llmToolNameQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCPServerObject*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeMCPServerObjectBoxes*)
makeMCPServerObjectBoxes // beginDefinition;

makeMCPServerObjectBoxes[ obj_MCPServerObject, fmt_ ] :=
    BoxForm`ArrangeSummaryBox[
        MCPServerObject,
        obj,
        makeMCPServerIcon @ obj,
        makeSummaryRows @ obj,
        makeHiddenSummaryRows @ obj,
        fmt
    ];

makeMCPServerObjectBoxes // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeSummaryRows*)
makeSummaryRows // beginDefinition;

makeSummaryRows[ obj_ ] :=
    makeSummaryRows[ obj[ "Name" ], obj[ "Transport" ] ];

makeSummaryRows[ name_String, type_ ] :=
    Flatten @ {
        summaryItem[ "Name"     , name ],
        summaryItem[ "Transport", type ]
    };

makeSummaryRows // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeHiddenSummaryRows*)
makeHiddenSummaryRows // beginDefinition;

makeHiddenSummaryRows[ obj_ ] :=
    makeHiddenSummaryRows[ obj[ "Name" ], obj[ "Tools" ], obj[ "Location" ], obj[ "JSONConfiguration" ] ];

makeHiddenSummaryRows[ name_String, tools_List, location: _File | "BuiltIn", json_String ] :=
    Module[ { toolNames, copyJSONButton },
        toolNames = Select[ Cases[ tools, tool: $$llmTool :> toolName @ tool ], StringQ ];
        copyJSONButton = clickToCopy[ "{\[Ellipsis]}", json ];
        Flatten @ {
            summaryItem[ "JSON Configuration", copyJSONButton ],
            If[ Length @ toolNames > 0, summaryItem[ "Tool Names", Multicolumn[ toolNames, 5 ] ], Nothing ],
            summaryItem[ "Location", location ]
        }
    ];

makeHiddenSummaryRows // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toolName*)
toolName // beginDefinition;
toolName[ name_String ] := name;
toolName[ tool_LLMTool ] := tool[ "Name" ];
toolName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*summaryItem*)
summaryItem // beginDefinition;
summaryItem[ _, _Missing ] := Nothing;
summaryItem[ label_, value_ ] := { BoxForm`SummaryItem @ { niceLabel @ label, value } };
summaryItem // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*niceLabel*)
niceLabel // beginDefinition;
niceLabel[ label_String ] := StringJoin[ label, ": " ];
niceLabel // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Icons*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeMCPServerIcon*)
makeMCPServerIcon // beginDefinition;

(* TODO: move to assets *)
makeMCPServerIcon[ obj_ ] := Graphics[
    {
        Thickness[ 0.005979 ],
        Style[
            {
                JoinedCurve[
                    { { { 0, 2, 0 }, { 1, 3, 3 }, { 1, 3, 3 }, { 0, 1, 0 } } },
                    {
                        {
                            { 25., 97.147 },
                            { 92.882, 165.03 },
                            { 102.25, 174.4 },
                            { 117.45, 174.4 },
                            { 126.82, 165.03 },
                            { 136.2, 155.66 },
                            { 136.2, 140.46 },
                            { 126.82, 131.09 },
                            { 75.558, 79.823 }
                        }
                    },
                    CurveClosed -> { 0 }
                ]
            },
            CapForm[ "Round" ],
            JoinForm @ { "Miter", 1. },
            Thickness[ 0.071749 ]
        ],
        Style[
            {
                JoinedCurve[
                    { { { 0, 2, 0 }, { 1, 3, 3 }, { 0, 1, 0 }, { 1, 3, 3 }, { 0, 1, 0 }, { 1, 3, 3 }, { 0, 1, 0 } } },
                    {
                        {
                            { 76.265, 80.53 },
                            { 126.82, 131.09 },
                            { 136.2, 140.46 },
                            { 151.39, 140.46 },
                            { 160.76, 131.09 },
                            { 161.12, 130.73 },
                            { 170.49, 121.36 },
                            { 170.49, 106.17 },
                            { 161.12, 96.794 },
                            { 99.725, 35.4 },
                            { 96.601, 32.276 },
                            { 96.601, 27.211 },
                            { 99.725, 24.087 },
                            { 112.33, 11.48 }
                        }
                    },
                    CurveClosed -> { 0 }
                ]
            },
            CapForm[ "Round" ],
            JoinForm @ { "Miter", 1. },
            Thickness[ 0.071749 ]
        ],
        Style[
            {
                JoinedCurve[
                    { { { 0, 2, 0 }, { 1, 3, 3 }, { 1, 3, 3 }, { 0, 1, 0 } } },
                    {
                        {
                            { 109.85, 148.06 },
                            { 59.648, 97.854 },
                            { 50.276, 88.482 },
                            { 50.276, 73.286 },
                            { 59.648, 63.913 },
                            { 69.021, 54.541 },
                            { 84.217, 54.541 },
                            { 93.589, 63.913 },
                            { 143.79, 114.12 }
                        }
                    },
                    CurveClosed -> { 0 }
                ]
            },
            CapForm[ "Round" ],
            JoinForm @ { "Miter", 1. },
            Thickness[ 0.071749 ]
        ]
    },
    ImageSize -> 24
];

makeMCPServerIcon // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Utilities*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clickToCopy*)
clickToCopy[ label_, content_String ] :=
    RawBoxes @ clickToCopyBoxes[ ToBoxes @ label, content ];

clickToCopy[ label_, content_ ] :=
    RawBoxes @ clickToCopyBoxes[
        ToBoxes @ label,
        RawBoxes @ MakeBoxes @ content
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clickToCopyBoxes*)
clickToCopyBoxes[ label_, content_ ] :=
    TagBox[
        DynamicModuleBox[
            { $CellContext`boxObj, $CellContext`cellObj },
            TagBox[
                TagBox[
                    ButtonBox[
                        TagBox[
                            label,
                            BoxForm`Undeploy,
                            DefaultBaseStyle -> { Deployed -> False }
                        ],
                        ButtonFunction :> {
                            CopyToClipboard @ content,
                            NotebookDelete @ $CellContext`cellObj,
                            FrontEndExecute @ FrontEnd`AttachCell[
                                $CellContext`boxObj,
                                Cell @ BoxData @ TemplateBox[
                                    { "Copied" },
                                    "ClickToCopyTooltip"
                                ],
                                { 1, { Center, Bottom } },
                                { Center, Top },
                                "ClosingActions" -> {
                                    "ParentChanged",
                                    "MouseExit"
                                }
                            ]
                        },
                        Evaluator -> Automatic,
                        Appearance -> {
                            "Default" -> None,
                            "Hover" ->
                                FrontEnd`FileName[
                                    { "Typeset", "ClickToCopy" },
                                    "Hover.9.png"
                                ],
                            "Pressed" ->
                                FrontEnd`FileName[
                                    { "Typeset", "ClickToCopy" },
                                    "Pressed.9.png"
                                ]
                        },
                        BaseStyle -> { },
                        DefaultBaseStyle -> { },
                        BaselinePosition -> Baseline,
                        FrameMargins -> 2,
                        Method -> "Preemptive"
                    ],
                    EventHandlerTag @ {
                        "MouseEntered" :> (
                            $CellContext`cellObj =
                                MathLink`CallFrontEnd @ FrontEnd`AttachCell[
                                    $CellContext`boxObj,
                                    Cell @ BoxData @ TemplateBox[
                                        { "Copy" },
                                        "ClickToCopyTooltip"
                                    ],
                                    { 1, { Center, Bottom } },
                                    { Center, Top },
                                    "ClosingActions" -> { "ParentChanged" }
                                ]
                            ),
                        "MouseExited" :> NotebookDelete @ $CellContext`cellObj,
                        PassEventsDown -> True,
                        Method -> "Preemptive",
                        PassEventsUp -> True
                    }
                ],
                MouseAppearanceTag[ "LinkHand" ]
            ],
            Initialization :> ($CellContext`boxObj = EvaluationBox[ ]),
            DynamicModuleValues :> { },
            UnsavedVariables :> { $CellContext`boxObj, $CellContext`cellObj },
            BaseStyle -> { Editable -> False }
        ],
        Deploy,
        DefaultBaseStyle -> "Deploy"
    ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
