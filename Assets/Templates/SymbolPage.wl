(* ::Package:: *)

(* Symbol Page Documentation Template *)
(* Used by CreateSymbolPacletDocumentation *)

TemplateObject[
    Notebook[
        {
            (* Object Name and Usage Section *)
            Cell[
                CellGroupData[
                    TemplateExpression @ Flatten @ {
                        Cell[ TemplateSlot[ "SymbolName" ], "ObjectName", CellID -> RandomInteger @ { 1, 999999999 } ],
                        Cell[
                            TemplateSlot[ "UsageContent" ],
                            "Usage",
                            CellID -> RandomInteger @ { 1, 999999999 }
                        ],
                        TemplateSlot[ "NotesCells" ]
                    },
                    Open
                ]
            ],

            (* See Also Section *)
            Cell[
                CellGroupData[
                    {
                        Cell[
                            TextData @ {
                                "See Also",
                                Cell[
                                    BoxData @ TemplateBox[
                                        {
                                            "SeeAlso",
                                            Cell[
                                                BoxData @ FrameBox[
                                                    Cell[ "Insert links to any related reference (function) pages.", "MoreInfoText" ],
                                                    BaseStyle -> "IFrameBox"
                                                ],
                                                "MoreInfoTextOuter"
                                            ]
                                        },
                                        "MoreInfoOpenerButtonTemplate"
                                    ]
                                ]
                            },
                            "SeeAlsoSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            TemplateSlot[ "SeeAlsoContent" ],
                            "SeeAlso",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ]
                    },
                    Open
                ]
            ],

            (* Tech Notes Section *)
            Cell[
                CellGroupData[
                    TemplateExpression @ Flatten @ {
                        Cell[
                            TextData @ {
                                "Tech Notes",
                                Cell[
                                    BoxData @ TemplateBox[
                                        {
                                            "TechNotes",
                                            Cell[
                                                BoxData @ FrameBox[
                                                    Cell[ "Insert links to related tech notes.", "MoreInfoText" ],
                                                    BaseStyle -> "IFrameBox"
                                                ],
                                                "MoreInfoTextOuter"
                                            ]
                                        },
                                        "MoreInfoOpenerButtonTemplate"
                                    ]
                                ]
                            },
                            "TechNotesSection",
                            CellID -> RandomInteger @ { 1, 999999999 }
                        ],
                        TemplateSlot[ "TutorialsCells" ]
                    },
                    Open
                ]
            ],

            (* Related Guides Section *)
            Cell[
                CellGroupData[
                    TemplateExpression @ Flatten @ {
                        Cell[
                            "Related Guides",
                            "MoreAboutSection",
                            CellID -> RandomInteger @ { 1, 999999999 }
                        ],
                        TemplateSlot[ "MoreAboutCells" ]
                    },
                    Open
                ]
            ],

            (* Related Links Section *)
            Cell[
                CellGroupData[
                    TemplateExpression @ Flatten @ {
                        Cell[
                            TextData @ {
                                "Related Links",
                                Cell[
                                    BoxData @ TemplateBox[
                                        {
                                            "RelatedLinks",
                                            Cell[
                                                BoxData @ FrameBox[
                                                    Cell[ "Insert links to any related page, including web pages.", "MoreInfoText" ],
                                                    BaseStyle -> "IFrameBox"
                                                ],
                                                "MoreInfoTextOuter"
                                            ]
                                        },
                                        "MoreInfoOpenerButtonTemplate"
                                    ]
                                ]
                            },
                            "RelatedLinksSection",
                            CellID -> RandomInteger @ { 1, 999999999 }
                        ],
                        TemplateSlot[ "RelatedLinksCells" ]
                    },
                    Open
                ]
            ],

            (* Examples Initialization Section *)
            Cell[
                CellGroupData[
                    {
                        Cell[
                            TextData @ {
                                "Examples Initialization",
                                Cell[
                                    BoxData @ TemplateBox[
                                        {
                                            "ExamplesInitialization",
                                            Cell[
                                                BoxData @ FrameBox[
                                                    Cell[ "Input that is to be evaluated before any examples are run, e.g. Needs[\[Ellipsis]].", "MoreInfoText" ],
                                                    BaseStyle -> "IFrameBox"
                                                ],
                                                "MoreInfoTextOuter"
                                            ]
                                        },
                                        "MoreInfoOpenerButtonTemplate"
                                    ]
                                ]
                            },
                            "ExamplesInitializationSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            BoxData @ RowBox @ { "Needs", "[", TemplateExpression @ StringJoin[ "\"", TemplateSlot[ "Context" ], "\"" ], "]" },
                            "ExampleInitialization",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ]
                    },
                    Open
                ]
            ],

            (* Basic Examples Section *)
            Cell[
                CellGroupData[
                    TemplateExpression @ Flatten @ {
                        Cell[
                            BoxData @ InterpretationBox[
                                GridBox @ {
                                    {
                                        StyleBox[ RowBox @ { "Basic", " ", "Examples" }, "PrimaryExamplesSection" ],
                                        ButtonBox[
                                            RowBox @ { RowBox @ { "More", " ", "Examples" }, " ", "\[RightTriangle]" },
                                            BaseStyle   -> "ExtendedExamplesLink",
                                            ButtonData :> "ExtendedExamples"
                                        ]
                                    }
                                },
                                $Line = 0;
                            ],
                            "PrimaryExamplesSection",
                            CellID -> RandomInteger @ { 1, 999999999 }
                        ],
                        TemplateSlot[ "BasicExamplesCells" ]
                    },
                    Open
                ]
            ],

            (* Extended Examples Section *)
            Cell[
                CellGroupData[
                    {
                        Cell[
                            TextData @ {
                                "More Examples",
                                Cell[
                                    BoxData @ TemplateBox[
                                        {
                                            "MoreExamples",
                                            Cell[
                                                BoxData @ FrameBox[
                                                    Cell[ "Extended examples in standardized sections.", "MoreInfoText" ],
                                                    BaseStyle -> "IFrameBox"
                                                ],
                                                "MoreInfoTextOuter"
                                            ]
                                        },
                                        "MoreInfoOpenerButtonTemplate"
                                    ]
                                ]
                            },
                            "ExtendedExamplesSection",
                            CellTags -> "ExtendedExamples",
                            CellID   -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            BoxData @ InterpretationBox[ Cell[ "Scope", "ExampleSection" ], $Line = 0; ],
                            "ExampleSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            BoxData @ InterpretationBox[ Cell[ "Generalizations & Extensions", "ExampleSection" ], $Line = 0; ],
                            "ExampleSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            CellGroupData[
                                {
                                    Cell[
                                        BoxData @ InterpretationBox[ Cell[ "Options", "ExampleSection" ], $Line = 0; ],
                                        "ExampleSection",
                                        CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                                    ],
                                    Cell[
                                        BoxData @ InterpretationBox[ Cell[ "XXXX", "ExampleSubsection" ], $Line = 0; ],
                                        "ExampleSubsection",
                                        CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                                    ]
                                },
                                Open
                            ]
                        ],
                        Cell[
                            BoxData @ InterpretationBox[ Cell[ "Applications", "ExampleSection" ], $Line = 0; ],
                            "ExampleSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            BoxData @ InterpretationBox[ Cell[ "Properties & Relations", "ExampleSection" ], $Line = 0; ],
                            "ExampleSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            BoxData @ InterpretationBox[ Cell[ "Possible Issues", "ExampleSection" ], $Line = 0; ],
                            "ExampleSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            BoxData @ InterpretationBox[ Cell[ "Interactive Examples", "ExampleSection" ], $Line = 0; ],
                            "ExampleSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            BoxData @ InterpretationBox[ Cell[ "Neat Examples", "ExampleSection" ], $Line = 0; ],
                            "ExampleSection",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ]
                    },
                    Open
                ]
            ],

            (* Metadata Section *)
            Cell[
                CellGroupData[
                    {
                        Cell[ "Metadata", "MetadataSection", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                        Cell[
                            TextData @ {
                                "New in: ",
                                Cell[ TemplateSlot[ "NewInVersion" ], "HistoryData", CellTags -> "New" ],
                                " | Modified in: ",
                                Cell[ " ", "HistoryData", CellTags -> "Modified" ],
                                " | Obsolete in: ",
                                Cell[ " ", "HistoryData", CellTags -> "Obsolete" ]
                            },
                            "History",
                            CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                        ],
                        Cell[
                            CellGroupData[
                                {
                                    Cell[
                                        TextData @ {
                                            "Categorization",
                                            Cell[
                                                BoxData @ TemplateBox[
                                                    {
                                                        "Metadata",
                                                        Cell[
                                                            BoxData @ FrameBox[
                                                                Cell[ "Metadata such as page URI, context, and type of documentation page.", "MoreInfoText" ],
                                                                BaseStyle -> "IFrameBox"
                                                            ],
                                                            "MoreInfoTextOuter"
                                                        ]
                                                    },
                                                    "MoreInfoOpenerButtonTemplate"
                                                ]
                                            ]
                                        },
                                        "CategorizationSection",
                                        CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                                    ],
                                    Cell[ "Symbol", "Categorization", CellLabel -> "Entity Type", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                                    Cell[ TemplateSlot[ "PacletBase" ], "Categorization", CellLabel -> "Paclet Name", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                                    Cell[ TemplateSlot[ "Context" ], "Categorization", CellLabel -> "Context", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                                    Cell[
                                        TemplateExpression @ StringJoin[ TemplateSlot[ "PacletBase" ], "/ref/", TemplateSlot[ "SymbolName" ] ],
                                        "Categorization",
                                        CellLabel -> "URI",
                                        CellID    -> TemplateExpression @ RandomInteger @ { 1, 999999999 }
                                    ]
                                },
                                Closed
                            ]
                        ],
                        Cell[
                            CellGroupData[
                                TemplateExpression @ Flatten @ {
                                    Cell[ "Keywords", "KeywordsSection", CellID -> RandomInteger @ { 1, 999999999 } ],
                                    TemplateSlot[ "KeywordsCells" ]
                                },
                                Closed
                            ]
                        ],
                        Cell[
                            CellGroupData[
                                {
                                    Cell[ "Syntax Templates", "TemplatesSection", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                                    Cell[ BoxData[ "" ], "Template", CellLabel -> "Additional Function Template", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                                    Cell[ BoxData[ "" ], "Template", CellLabel -> "Arguments Pattern", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                                    Cell[ BoxData[ "" ], "Template", CellLabel -> "Local Variables", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ],
                                    Cell[ BoxData[ "" ], "Template", CellLabel -> "Color Equal Signs", CellID -> TemplateExpression @ RandomInteger @ { 1, 999999999 } ]
                                },
                                Closed
                            ]
                        ]
                    },
                    Open
                ]
            ]
        },
        TaggingRules -> <| "Paclet" -> TemplateSlot[ "PacletBase" ] |>,
        StyleDefinitions -> FrontEnd`FileName[ { "Wolfram" }, "FunctionPageStylesExt.nb", CharacterEncoding -> "UTF-8" ]
    ],
    CombinerFunction  -> Identity,
    InsertionFunction -> Identity
]
