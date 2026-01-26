(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`PacletDocumentation`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cell Generation Functions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateUsageContent*)
generateUsageContent // beginDefinition;

generateUsageContent[ symbolName_String, pacletBase_String, usageCases_List ] := Enclose[
    Module[ { usageElements },
        usageElements = ConfirmMatch[
            Flatten @ Riffle[
                generateSingleUsageContent[ symbolName, pacletBase, # ] & /@ usageCases,
                { "\n", Cell[ "   ", "ModInfo" ] }
            ],
            { __ },
            "UsageElements"
        ];
        TextData @ Flatten @ { Cell[ "   ", "ModInfo" ], usageElements }
    ],
    throwInternalFailure
];

generateUsageContent // endDefinition;

generateSingleUsageContent // beginDefinition;

generateSingleUsageContent[ symbolName_String, pacletBase_String, usageCase_Association ] := Enclose[
    Module[ { syntax, description, syntaxCell, descriptionParts },
        syntax      = ConfirmBy[ usageCase[ "syntax" ], StringQ, "Syntax" ];
        description = ConfirmBy[ usageCase[ "description" ], StringQ, "Description" ];

        syntaxCell = Cell[
            BoxData @ RowBox @ {
                ButtonBox[
                    symbolName,
                    BaseStyle  -> "Link",
                    ButtonData -> "paclet:" <> pacletBase <> "/ref/" <> symbolName
                ],
                StringReplace[ syntax, symbolName -> "" ]
            },
            "InlineFormula"
        ];

        descriptionParts = formatDescriptionText @ description;

        Flatten @ { syntaxCell, " \[LineSeparator]", descriptionParts }
    ],
    throwInternalFailure
];

generateSingleUsageContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatDescriptionText*)
formatDescriptionText // beginDefinition;

(* Convert *italic* markers to inline formula cells for variable names *)
(* Returns a list of strings and Cells for TextData *)
formatDescriptionText[ text_String ] /; StringContainsQ[ text, "*" ] :=
    StringSplit[ text, "*" ~~ var: Except[ "*" ].. ~~ "*" :> Cell[ BoxData @ StyleBox[ var, "TI" ], "InlineFormula" ] ];

formatDescriptionText[ text_String ] := { text };

formatDescriptionText // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateNotesCells*)
generateNotesCells // beginDefinition;

generateNotesCells[ "" ] := { Cell[ "XXXX", "Notes", CellID -> generateCellID[ ] ] };

generateNotesCells[ notesMarkdown_String ] := Enclose[
    Module[ { notebook, cells, notesCells },
        (* Use importMarkdownString to parse the markdown *)
        notebook = ConfirmMatch[
            importMarkdownString[ notesMarkdown, "Notebook" ],
            _Notebook,
            "NotebookImport"
        ];

        (* Extract cells from the notebook *)
        cells = First @ notebook;

        (* Convert imported cells to Notes cells *)
        notesCells = Flatten @ Map[ convertToNoteCell, cells ];

        If[ Length @ notesCells === 0,
            { Cell[ "XXXX", "Notes", CellID -> generateCellID[ ] ] },
            notesCells
        ]
    ],
    throwInternalFailure
];

generateNotesCells // endDefinition;

convertToNoteCell // beginDefinition;

(* Convert Text cells to Notes cells *)
convertToNoteCell[ Cell[ content_, "Text", ___ ] ] :=
    { Cell[ content, "Notes", CellID -> generateCellID[ ] ] };

(* Convert Item/ItemParagraph to Notes cells *)
convertToNoteCell[ Cell[ content_, "Item" | "ItemParagraph", ___ ] ] :=
    { Cell[ content, "Notes", CellID -> generateCellID[ ] ] };

(* Handle CellGroupData (e.g., from tables) *)
convertToNoteCell[ Cell[ CellGroupData[ groupCells_List, _ ] ] ] :=
    Flatten @ Map[ convertToNoteCell, groupCells ];

(* Handle tables - keep them as-is but change to Notes style if needed *)
convertToNoteCell[ cell: Cell[ BoxData[ GridBox[ ___ ] ], ___, ___ ] ] :=
    { cell };

(* Skip headers and other structural cells *)
convertToNoteCell[ Cell[ _, "Section" | "Subsection" | "Subsubsection", ___ ] ] := { };

(* Default: try to convert to Notes *)
convertToNoteCell[ Cell[ content_, style_, opts___ ] ] :=
    { Cell[ content, "Notes", CellID -> generateCellID[ ] ] };

convertToNoteCell[ _ ] := { };

convertToNoteCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateSeeAlsoContent*)
generateSeeAlsoContent // beginDefinition;

generateSeeAlsoContent[ pacletBase_String, { } ] :=
    TextData @ {
        Cell[
            BoxData @ TagBox[ FrameBox[ "\"XXXX\"" ], "FunctionPlaceholder" ],
            "InlineSeeAlsoFunction",
            TaggingRules -> { "PageType" -> "Function" }
        ]
    };

generateSeeAlsoContent[ pacletBase_String, symbols_List ] :=
    TextData @ Riffle[
        Cell[
            BoxData @ ButtonBox[
                #,
                BaseStyle  -> "Link",
                ButtonData -> "paclet:" <> pacletBase <> "/ref/" <> #
            ],
            "InlineSeeAlsoFunction",
            TaggingRules -> { "PageType" -> "Function" }
        ] & /@ symbols,
        StyleBox[ " \[FilledVerySmallSquare] ", "InlineSeparator" ]
    ];

generateSeeAlsoContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateTutorialsCells*)
generateTutorialsCells // beginDefinition;

generateTutorialsCells[ { } ] := { Cell[ "XXXX", "Tutorials", CellID -> generateCellID[ ] ] };

generateTutorialsCells[ tutorials_List ] :=
    generateTutorialCell /@ tutorials;

generateTutorialsCells // endDefinition;

generateTutorialCell // beginDefinition;

generateTutorialCell[ link_Association ] := Cell[
    TextData @ {
        ButtonBox[
            link[ "label" ],
            BaseStyle  -> "Link",
            ButtonData -> link[ "url" ]
        ]
    },
    "Tutorials",
    CellID -> generateCellID[ ]
];

generateTutorialCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateMoreAboutCells*)
generateMoreAboutCells // beginDefinition;

generateMoreAboutCells[ { } ] := { Cell[ "XXXX", "MoreAbout", CellID -> generateCellID[ ] ] };

generateMoreAboutCells[ guides_List ] :=
    generateMoreAboutCell /@ guides;

generateMoreAboutCells // endDefinition;

generateMoreAboutCell // beginDefinition;

generateMoreAboutCell[ link_Association ] := Cell[
    TextData @ {
        ButtonBox[
            link[ "label" ],
            BaseStyle  -> "Link",
            ButtonData -> link[ "url" ]
        ]
    },
    "MoreAbout",
    CellID -> generateCellID[ ]
];

generateMoreAboutCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateRelatedLinksCells*)
generateRelatedLinksCells // beginDefinition;

generateRelatedLinksCells[ { } ] := { Cell[ "XXXX", "RelatedLinks", CellID -> generateCellID[ ] ] };

generateRelatedLinksCells[ links_List ] :=
    Cell[
        TextData @ {
            ButtonBox[ #[ "label" ], BaseStyle -> "Hyperlink", ButtonData -> { URL[ #[ "url" ] ], None } ]
        },
        "RelatedLinks",
        CellID -> generateCellID[ ]
    ] & /@ links;

generateRelatedLinksCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateKeywordsCells*)
generateKeywordsCells // beginDefinition;

generateKeywordsCells[ { } ] := { Cell[ "XXXX", "Keywords", CellID -> generateCellID[ ] ] };

generateKeywordsCells[ keywords_List ] :=
    Cell[ #, "Keywords", CellID -> generateCellID[ ] ] & /@ keywords;

generateKeywordsCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateExampleCells*)
generateExampleCells // beginDefinition;

generateExampleCells[ context_String, "" ] := { };

generateExampleCells[ context_String, markdown_String ] := Enclose[
    Module[ { groups, groupCells, cells },
        (* Split by horizontal rules to get example groups *)
        groups = StringSplit[ markdown, "\n---\n" | "\n---" | "---\n" ];

        (* Generate cells for each group *)
        groupCells = generateExampleGroup[ context, StringTrim @ # ] & /@ groups;

        (* Add delimiters between groups *)
        cells = If[ Length @ groupCells <= 1,
            Flatten @ groupCells,
            Flatten @ Riffle[ groupCells, { { exampleDelimiterCell[ ] } } ]
        ];

        ConfirmMatch[ cells, { ___Cell }, "Cells" ]
    ],
    throwInternalFailure
];

generateExampleCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateExampleGroup*)
generateExampleGroup // beginDefinition;

generateExampleGroup[ context_String, markdown_String ] := Enclose[
    Module[ { segments, processedCells },
        (* Split markdown into text and code segments *)
        segments = ConfirmMatch[ parseMarkdownSegments @ markdown, { ___Association }, "Segments" ];

        (* Process each segment *)
        processedCells = Flatten[ processMarkdownSegment[ context, # ] & /@ segments ];

        ConfirmMatch[ processedCells, { ___Cell }, "Cells" ]
    ],
    throwInternalFailure
];

generateExampleGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseMarkdownSegments*)

(* Triple backtick string for code fence matching - using StringRepeat to avoid escaping issues *)
$tripleTick = StringRepeat[ FromCharacterCode @ 96, 3 ];

parseMarkdownSegments // beginDefinition;

(* Parse markdown into segments of text and code blocks *)
parseMarkdownSegments[ markdown_String ] := Enclose[
    Module[ { codeBlockPattern, parts, segments },
        (* Pattern to match fenced code blocks with optional language identifier *)
        codeBlockPattern = $tripleTick ~~ (LetterCharacter | "-")... ~~ "\n" ~~ Shortest[ ___ ] ~~ $tripleTick;

        (* Split the markdown, keeping code blocks as separate elements *)
        parts = StringSplit[ markdown, cb:codeBlockPattern :> cb ];

        (* Convert each part to a segment association *)
        segments = Flatten @ Map[
            Function[ part,
                If[ StringMatchQ[ part, $tripleTick ~~ ___ ~~ $tripleTick ],
                    parseCodeBlock @ part,
                    parseTextSegment @ part
                ]
            ],
            parts
        ];

        (* Filter out empty segments *)
        Select[ segments, #[ "content" ] =!= "" & ]
    ],
    throwInternalFailure
];

parseMarkdownSegments // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseCodeBlock*)
parseCodeBlock // beginDefinition;

parseCodeBlock[ block_String ] := Enclose[
    Module[ { match },
        (* Extract language and code from fenced code block *)
        match = StringCases[
            block,
            $tripleTick ~~ lang:(LetterCharacter | "-")... ~~ "\n" ~~ code:Shortest[ ___ ] ~~ $tripleTick :>
                <| "lang" -> lang, "code" -> code |>,
            1
        ];

        If[ Length @ match === 0,
            <| "type" -> "text", "content" -> block |>,
            <| "type" -> "code", "content" -> StringTrim @ match[[1, "code"]], "lang" -> match[[1, "lang"]] |>
        ]
    ],
    throwInternalFailure
];

parseCodeBlock // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseTextSegment*)
parseTextSegment // beginDefinition;

parseTextSegment[ text_String ] :=
    If[ StringTrim @ text === "",
        { },
        { <| "type" -> "text", "content" -> StringTrim @ text |> }
    ];

parseTextSegment // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*processMarkdownSegment*)
processMarkdownSegment // beginDefinition;

processMarkdownSegment[ context_String, segment_Association ] :=
    Switch[ segment[ "type" ],
        "code",
            generateInputOutputCells[ context, segment[ "content" ], "Code" ],
        "text",
            processTextSegmentContent[ context, segment[ "content" ] ],
        _,
            { }
    ];

processMarkdownSegment // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*processTextSegmentContent*)
processTextSegmentContent // beginDefinition;

processTextSegmentContent[ context_String, content_String ] := Enclose[
    Module[ { notebook, cells },
        (* Use importMarkdownString for text content *)
        notebook = ConfirmMatch[
            importMarkdownString[ content, "Notebook" ],
            _Notebook,
            "NotebookImport"
        ];

        cells = First @ notebook;
        Flatten @ Map[ convertToExampleTextCell, cells ]
    ],
    throwInternalFailure
];

processTextSegmentContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToExampleTextCell*)
convertToExampleTextCell // beginDefinition;

convertToExampleTextCell[ Cell[ content_, "Text", ___ ] ] :=
    { Cell[ content, "ExampleText", CellID -> generateCellID[ ] ] };

convertToExampleTextCell[ Cell[ content_String, style_, ___ ] ] :=
    If[ StringTrim @ content =!= "",
        { Cell[ content, "ExampleText", CellID -> generateCellID[ ] ] },
        { }
    ];

convertToExampleTextCell[ Cell[ TextData[ content_ ], style_, ___ ] ] :=
    { Cell[ TextData @ content, "ExampleText", CellID -> generateCellID[ ] ] };

convertToExampleTextCell[ _ ] := { };

convertToExampleTextCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*processImportedCells*)
processImportedCells // beginDefinition;

processImportedCells[ context_String, cells_List ] :=
    processImportedCell[ context, # ] & /@ cells;

processImportedCells // endDefinition;

processImportedCell // beginDefinition;

(* Handle Input/Code cells - evaluate and create input/output pair *)
processImportedCell[ context_String, Cell[ content_, style: "Input" | "Code" | "Program", opts___ ] ] :=
    generateInputOutputCells[ context, content, style ];

(* Handle Text cells - convert to ExampleText *)
processImportedCell[ context_String, Cell[ content_, "Text", ___ ] ] :=
    { Cell[ content, "ExampleText", CellID -> generateCellID[ ] ] };

(* Handle other cell types - convert to ExampleText if they have content *)
processImportedCell[ context_String, Cell[ content_String, style_, ___ ] ] /; StringQ @ content && StringTrim @ content =!= "" :=
    { Cell[ content, "ExampleText", CellID -> generateCellID[ ] ] };

processImportedCell[ context_String, Cell[ TextData[ content_ ], style_, ___ ] ] :=
    { Cell[ TextData @ content, "ExampleText", CellID -> generateCellID[ ] ] };

(* Skip cells with no meaningful content *)
processImportedCell[ context_String, _ ] := { };

processImportedCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateInputOutputCells*)
generateInputOutputCells // beginDefinition;

(* Handle BoxData content (from Input cells) *)
generateInputOutputCells[ context_String, BoxData[ boxes_ ], style_ ] := Enclose[
    Module[ { inputCell, code, result, outputCell },

        inputCell = Cell[
            BoxData @ boxes,
            "Input",
            CellLabel -> "In[1]:=",
            CellID    -> generateCellID[ ]
        ];

        (* Convert boxes back to code string for evaluation *)
        code = ToString[ ToExpression[ boxes, StandardForm, HoldComplete ], InputForm ];
        code = StringTrim @ StringReplace[ code, StartOfString ~~ "HoldComplete[" ~~ body___ ~~ "]" ~~ EndOfString :> body ];

        (* Evaluate and create output cell *)
        result = Block[ { $Context = context, $ContextPath = { context, "System`" } },
            Quiet @ TimeConstrained[ ToExpression @ code, 10, $TimedOut ]
        ];

        outputCell = Cell[
            BoxData @ ToBoxes[ result, StandardForm ],
            "Output",
            CellLabel -> "Out[1]=",
            CellID    -> generateCellID[ ]
        ];

        { Cell[ CellGroupData[ { inputCell, outputCell }, Open ] ] }
    ],
    throwInternalFailure
];

(* Handle string content (from Code/Program cells) *)
generateInputOutputCells[ context_String, code0_String, style_ ] := Enclose[
    Module[ { code, inputBoxes, inputCell, result, outputCell },
        (* Code is already extracted - just trim whitespace *)
        code = StringTrim @ code0;

        (* Create input cell - convert code string to proper boxes *)
        inputBoxes = Quiet @ ToBoxes[ ToExpression[ code, InputForm, Defer ], StandardForm ];

        inputCell = Cell[
            BoxData @ inputBoxes,
            "Input",
            CellLabel -> "In[1]:=",
            CellID    -> generateCellID[ ]
        ];

        (* Evaluate and create output cell *)
        result = Block[ { $Context = context, $ContextPath = { context, "System`" } },
            Quiet @ TimeConstrained[ ToExpression @ code, 10, $TimedOut ]
        ];

        outputCell = Cell[
            BoxData @ ToBoxes[ result, StandardForm ],
            "Output",
            CellLabel -> "Out[1]=",
            CellID    -> generateCellID[ ]
        ];

        { Cell[ CellGroupData[ { inputCell, outputCell }, Open ] ] }
    ],
    throwInternalFailure
];

(* Handle TextData content (from Code cells with formatted content) *)
generateInputOutputCells[ context_String, TextData[ content_ ], style_ ] := Enclose[
    Module[ { code },
        (* Extract plain text from TextData *)
        code = textDataToString @ content;
        generateInputOutputCells[ context, code, style ]
    ],
    throwInternalFailure
];

generateInputOutputCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*textDataToString*)
textDataToString // beginDefinition;

textDataToString[ content_List ] :=
    StringJoin[ textDataToString /@ content ];

textDataToString[ content_String ] :=
    content;

textDataToString[ Cell[ BoxData[ boxes_ ], ___ ] ] :=
    ToString[ ToExpression[ boxes, StandardForm, HoldComplete ], InputForm ] //
        StringReplace[ #, StartOfString ~~ "HoldComplete[" ~~ body___ ~~ "]" ~~ EndOfString :> body ] &;

textDataToString[ StyleBox[ content_, ___ ] ] :=
    textDataToString @ content;

textDataToString[ _ ] := "";

textDataToString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*exampleDelimiterCell*)
exampleDelimiterCell // beginDefinition;

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
exampleDelimiterCell[ ] := Cell[
    CellGroupData[
        {
            Cell[
                BoxData @ InterpretationBox[ Cell[ "\t", "ExampleDelimiter" ], $Line = 0; ],
                "ExampleDelimiter",
                CellID -> generateCellID[ ]
            ]
        },
        Open
    ]
];
(* :!CodeAnalysis::EndBlock:: *)

exampleDelimiterCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];