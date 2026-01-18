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
(*Config*)
$symbolPageTemplatePath := FileNameJoin @ { $thisPaclet[ "Location" ], "Assets", "Templates", "SymbolPage.wl" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$createSymbolDocDescription = "\
Creates a new symbol documentation page for a Wolfram Language paclet. \
The tool generates a properly structured .nb file in the correct location within the paclet's documentation directory.";

$editSymbolDocDescription = "\
Edits an existing symbol documentation page. \
Supports operations like setting usage, notes, see also, and adding/modifying examples. \
Example inputs are automatically evaluated and outputs are generated.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*CreateSymbolPacletDocumentation*)
$defaultMCPTools[ "CreateSymbolPacletDocumentation" ] := LLMTool @ <|
    "Name"        -> "CreateSymbolPacletDocumentation",
    "DisplayName" -> "Create Symbol Documentation",
    "Description" -> $createSymbolDocDescription,
    "Function"    -> createSymbolPacletDocumentation,
    "Options"     -> { },
    "Parameters"  -> {
        "pacletDirectory" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet root directory.",
            "Required"    -> True
        |>,
        "symbolName" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Name of the symbol being documented (e.g., \"MyFunction\").",
            "Required"    -> True
        |>,
        "pacletName" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Name of the paclet (e.g., \"MCPServer\" or \"Wolfram/MCPServer\").",
            "Required"    -> True
        |>,
        "publisherID" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Publisher ID for the paclet (e.g., \"Wolfram\"). Can be omitted for legacy paclets or included in pacletName.",
            "Required"    -> False
        |>,
        "context" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Full context for the symbol. Defaults based on pacletName/publisherID.",
            "Required"    -> False
        |>,
        "usage" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown string with usage cases as bullet points: `- \\`MyFunc[x]\\` does something with *x*`",
            "Required"    -> True
        |>,
        "notes" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown string for Details & Options section. Each paragraph becomes a note cell.",
            "Required"    -> False
        |>,
        "seeAlso" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Symbol names separated by newlines or commas (e.g., \"Plus\\nMinus\" or \"Plus, Minus\").",
            "Required"    -> False
        |>,
        "techNotes" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown links to tutorials, one per line: `[Title](paclet:Publisher/Paclet/tutorial/Name)`",
            "Required"    -> False
        |>,
        "relatedGuides" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown links to guides, one per line: `[Title](paclet:Publisher/Paclet/guide/Name)`",
            "Required"    -> False
        |>,
        "relatedLinks" -> <|
            "Interpreter" -> "String",
            "Help"        -> "External links in markdown format, one per line: `[label](url)`",
            "Required"    -> False
        |>,
        "keywords" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Keywords separated by newlines or commas.",
            "Required"    -> False
        |>,
        "newInVersion" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Version string for \"New in:\" field (e.g., \"1.0\").",
            "Required"    -> False
        |>,
        "basicExamples" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown content for Basic Examples section. Code blocks will be evaluated automatically.",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*EditSymbolPacletDocumentation*)
$defaultMCPTools[ "EditSymbolPacletDocumentation" ] := LLMTool @ <|
    "Name"        -> "EditSymbolPacletDocumentation",
    "DisplayName" -> "Edit Symbol Documentation",
    "Description" -> $editSymbolDocDescription,
    "Function"    -> editSymbolPacletDocumentation,
    "Options"     -> { },
    "Parameters"  -> {
        "notebook" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Path to the notebook file or documentation URI.",
            "Required"    -> True
        |>,
        "operation" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The edit operation: setUsage, setNotes, addNote, setDetailsTable, setSeeAlso, setTechNotes, setRelatedGuides, setRelatedLinks, setKeywords, setHistory.",
            "Required"    -> True
        |>,
        "content" -> <|
            "Interpreter" -> "String",
            "Help"        -> "New content in markdown or appropriate format for the operation.",
            "Required"    -> False
        |>,
        "position" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Position for addNote operation (0-indexed integer, or \"start\"/\"end\").",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreateSymbolPacletDocumentation Implementation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*createSymbolPacletDocumentation*)
createSymbolPacletDocumentation // beginDefinition;

createSymbolPacletDocumentation[ params_Association ] := Enclose[
    Module[ { pacletDir, symbolName, pacletName, publisherID, pacletBase, context, usage,
              notes, seeAlso, techNotes, relatedGuides, relatedLinks, keywords,
              newInVersion, basicExamples, outputDir, outputFile, notebook },

        (* Extract required parameters *)
        pacletDir   = ConfirmBy[ params[ "pacletDirectory" ], StringQ, "PacletDirectory" ];
        symbolName  = ConfirmBy[ params[ "symbolName" ], StringQ, "SymbolName" ];
        pacletName  = ConfirmBy[ params[ "pacletName" ], StringQ, "PacletName" ];

        (* Extract optional parameters *)
        publisherID   = params[ "publisherID" ];
        context       = params[ "context" ];
        usage         = ConfirmBy[ params[ "usage" ], StringQ, "Usage" ];
        notes         = Replace[ params[ "notes" ], _Missing -> "" ];
        seeAlso       = Replace[ params[ "seeAlso" ], _Missing -> "" ];
        techNotes     = Replace[ params[ "techNotes" ], _Missing -> "" ];
        relatedGuides = Replace[ params[ "relatedGuides" ], _Missing -> "" ];
        relatedLinks  = Replace[ params[ "relatedLinks" ], _Missing -> "" ];
        keywords      = Replace[ params[ "keywords" ], _Missing -> "" ];
        newInVersion  = Replace[ params[ "newInVersion" ], _Missing -> "XX" ];
        basicExamples = Replace[ params[ "basicExamples" ], _Missing -> "" ];

        (* Build paclet base and context *)
        pacletBase = ConfirmBy[ buildPacletBase[ pacletName, publisherID ], StringQ, "PacletBase" ];
        context    = ConfirmBy[
            If[ StringQ @ context, context, buildContext @ pacletBase ],
            StringQ,
            "Context"
        ];

        (* Ensure output directory exists *)
        outputDir = FileNameJoin @ { pacletDir, "Documentation", "English", "ReferencePages", "Symbols" };
        ConfirmBy[ GeneralUtilities`EnsureDirectory @ outputDir, DirectoryQ, "OutputDirectory" ];

        (* Check if file already exists *)
        outputFile = FileNameJoin @ { outputDir, symbolName <> ".nb" };
        If[ FileExistsQ @ outputFile,
            throwFailure[ "NotebookFileExists", outputFile ]
        ];

        (* Generate the notebook *)
        notebook = ConfirmMatch[
            generateSymbolPageNotebook[
                symbolName, pacletBase, context, usage, notes, seeAlso, techNotes,
                relatedGuides, relatedLinks, keywords, newInVersion, basicExamples
            ],
            _Notebook,
            "Notebook"
        ];

        (* Export the notebook *)
        ConfirmBy[ Export[ outputFile, notebook, "NB" ], FileExistsQ, "Export" ];

        (* Return result *)
        <|
            "file" -> outputFile,
            "uri"  -> pacletBase <> "/ref/" <> symbolName
        |>
    ],
    throwInternalFailure
];

createSymbolPacletDocumentation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*buildPacletBase*)
buildPacletBase // beginDefinition;

buildPacletBase[ pacletName_String, _Missing ] :=
    pacletName;

buildPacletBase[ pacletName_String, publisherID_String ] :=
    publisherID <> "/" <> pacletName;

buildPacletBase // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*buildContext*)
buildContext // beginDefinition;

buildContext[ pacletBase_String ] :=
    StringReplace[ pacletBase, "/" -> "`" ] <> "`";

buildContext // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseUsageMarkdown*)
parseUsageMarkdown // beginDefinition;

(* Parse markdown bullet points into usage case associations *)
(* Format: - `MyFunction[x]` does something with *x*. *)
parseUsageMarkdown[ "" ] := throwFailure[ "EmptyUsage" ];

parseUsageMarkdown[ markdown_String ] := Enclose[
    Module[ { lines, bulletLines, usageCases },
        (* Split into lines and filter for bullet points *)
        lines = StringSplit[ markdown, "\n" ];
        bulletLines = Select[ lines, StringStartsQ[ StringTrim @ #, "-" | "*" ] & ];

        If[ Length @ bulletLines === 0,
            throwFailure[ "InvalidUsageFormat", markdown ]
        ];

        usageCases = parseSingleUsageLine /@ bulletLines;
        ConfirmMatch[ usageCases, { __Association }, "UsageCases" ]
    ],
    throwInternalFailure
];

parseUsageMarkdown // endDefinition;

parseSingleUsageLine // beginDefinition;

parseSingleUsageLine[ line_String ] := Enclose[
    Module[ { trimmed, syntaxMatch, syntax, rest, description },
        (* Remove leading bullet marker *)
        trimmed = StringTrim @ StringReplace[ line, StartOfString ~~ ("-" | "*") ~~ Whitespace.. -> "" ];

        (* Extract syntax from backticks: `MyFunction[x]` *)
        syntaxMatch = StringCases[ trimmed, "`" ~~ s: Except[ "`" ].. ~~ "`" :> s, 1 ];

        If[ Length @ syntaxMatch === 0,
            throwFailure[ "InvalidUsageFormat", line ]
        ];

        syntax = First @ syntaxMatch;

        (* Get description after the syntax *)
        rest = StringTrim @ StringReplace[
            trimmed,
            StartOfString ~~ "`" ~~ Except[ "`" ].. ~~ "`" ~~ Whitespace... -> ""
        ];

        (* Remove leading "- " if present after syntax *)
        description = StringTrim @ StringReplace[ rest, StartOfString ~~ ("-" | "\[Dash]" | "\[LongDash]") ~~ Whitespace... -> "" ];

        <| "syntax" -> syntax, "description" -> description |>
    ],
    throwInternalFailure
];

parseSingleUsageLine // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseCommaSeparatedList*)
parseCommaSeparatedList // beginDefinition;

(* Parse a string of items separated by newlines or commas *)
parseCommaSeparatedList[ "" ] := { };

parseCommaSeparatedList[ str_String ] :=
    StringTrim /@ Select[
        StringSplit[ str, "," | "\n" ],
        StringTrim[ # ] =!= "" &
    ];

parseCommaSeparatedList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseMarkdownLinks*)
parseMarkdownLinks // beginDefinition;

(* Parse markdown links: [label](url) *)
parseMarkdownLinks[ "" ] := { };

parseMarkdownLinks[ str_String ] := Enclose[
    Module[ { lines, links },
        lines = StringSplit[ str, "\n" ];
        links = Flatten @ Map[ parseSingleMarkdownLink, lines ];
        (* Filter out empty results *)
        Select[ links, AssociationQ ]
    ],
    throwInternalFailure
];

parseMarkdownLinks // endDefinition;

parseSingleMarkdownLink // beginDefinition;

parseSingleMarkdownLink[ "" ] := { };

parseSingleMarkdownLink[ line_String ] :=
    StringCases[
        line,
        "[" ~~ label: Except[ "]" ].. ~~ "](" ~~ url: Except[ ")" ].. ~~ ")" :>
            <| "label" -> label, "url" -> url |>
    ];

parseSingleMarkdownLink // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateCellID*)
generateCellID // beginDefinition;
generateCellID[ ] := RandomInteger @ { 1, 999999999 };
generateCellID // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateSymbolPageNotebook*)
generateSymbolPageNotebook // beginDefinition;

generateSymbolPageNotebook[
    symbolName_String, pacletBase_String, context_String, usage_String, notes_String,
    seeAlso_String, techNotes_String, relatedGuides_String, relatedLinks_String,
    keywords_String, newInVersion_String, basicExamples_String
] := Enclose[
    Module[ { templateParams, template, parsedUsage, parsedSeeAlso, parsedKeywords,
              parsedTechNotes, parsedRelatedGuides, parsedRelatedLinks },

        (* Parse string inputs *)
        parsedUsage         = ConfirmMatch[ parseUsageMarkdown @ usage, { __Association }, "ParsedUsage" ];
        parsedSeeAlso       = parseCommaSeparatedList @ seeAlso;
        parsedKeywords      = parseCommaSeparatedList @ keywords;
        parsedTechNotes     = parseMarkdownLinks @ techNotes;
        parsedRelatedGuides = parseMarkdownLinks @ relatedGuides;
        parsedRelatedLinks  = parseMarkdownLinks @ relatedLinks;

        (* Build template parameters *)
        templateParams = <|
            "SymbolName"          -> symbolName,
            "PacletBase"          -> pacletBase,
            "Context"             -> context,
            "UsageContent"        -> ConfirmMatch[ generateUsageContent[ symbolName, pacletBase, parsedUsage ], _TextData, "UsageContent" ],
            "NotesCells"          -> ConfirmMatch[ generateNotesCells @ notes, { ___Cell }, "NotesCells" ],
            "SeeAlsoContent"      -> ConfirmMatch[ generateSeeAlsoContent[ pacletBase, parsedSeeAlso ], _TextData, "SeeAlsoContent" ],
            "TutorialsCells"      -> ConfirmMatch[ generateTutorialsCells @ parsedTechNotes, { ___Cell }, "TutorialsCells" ],
            "MoreAboutCells"      -> ConfirmMatch[ generateMoreAboutCells @ parsedRelatedGuides, { ___Cell }, "MoreAboutCells" ],
            "RelatedLinksCells"   -> ConfirmMatch[ generateRelatedLinksCells @ parsedRelatedLinks, { ___Cell }, "RelatedLinksCells" ],
            "KeywordsCells"       -> ConfirmMatch[ generateKeywordsCells @ parsedKeywords, { ___Cell }, "KeywordsCells" ],
            "BasicExamplesCells"  -> ConfirmMatch[ generateExampleCells[ context, basicExamples ], { ___Cell }, "BasicExamplesCells" ],
            "NewInVersion"        -> newInVersion
        |>;

        (* Load and apply template *)
        template = ConfirmMatch[ $symbolPageTemplate, _TemplateObject, "Template" ];
        ConfirmMatch[ TemplateApply[ template, templateParams ], _Notebook, "Result" ]
    ],
    throwInternalFailure
];

generateSymbolPageNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$symbolPageTemplate*)
$symbolPageTemplate := $symbolPageTemplate = loadSymbolPageTemplate[ ];

loadSymbolPageTemplate // beginDefinition;

loadSymbolPageTemplate[ ] := Enclose[
    Module[ { path },
        path = ConfirmBy[ $symbolPageTemplatePath, FileExistsQ, "TemplatePath" ];
        ConfirmMatch[ Get @ path, _TemplateObject, "Template" ]
    ],
    throwInternalFailure
];

loadSymbolPageTemplate // endDefinition;

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
            { __},
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
(*EditSymbolPacletDocumentation Implementation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*editSymbolPacletDocumentation*)
editSymbolPacletDocumentation // beginDefinition;

editSymbolPacletDocumentation[ params_Association ] := Enclose[
    Module[ { notebookPath, operation, notebook, result },

        notebookPath = ConfirmBy[ params[ "notebook" ], StringQ, "NotebookPath" ];
        operation    = ConfirmBy[ params[ "operation" ], StringQ, "Operation" ];

        (* Load the notebook *)
        If[ ! FileExistsQ @ notebookPath,
            throwFailure[ "NotebookNotFound", notebookPath ]
        ];

        notebook = ConfirmMatch[ Import[ notebookPath, "NB" ], _Notebook, "Notebook" ];

        (* Perform the operation *)
        notebook = ConfirmMatch[
            performEditOperation[ notebook, operation, params ],
            _Notebook,
            "EditResult"
        ];

        (* Save the notebook *)
        ConfirmBy[ Export[ notebookPath, notebook, "NB" ], FileExistsQ, "Export" ];

        (* Return result *)
        <|
            "file"      -> notebookPath,
            "operation" -> operation
        |>
    ],
    throwInternalFailure
];

editSymbolPacletDocumentation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*performEditOperation*)
performEditOperation // beginDefinition;

performEditOperation[ notebook_Notebook, "setUsage", params_ ] :=
    setUsageInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, "setNotes", params_ ] :=
    setNotesInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, "addNote", params_ ] :=
    addNoteToNotebook[ notebook, params[ "content" ], params[ "position" ] ];

performEditOperation[ notebook_Notebook, "setDetailsTable", params_ ] :=
    setDetailsTableInNotebook[ notebook, params[ "content" ], params[ "position" ] ];

performEditOperation[ notebook_Notebook, "setSeeAlso", params_ ] :=
    setSeeAlsoInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, "setTechNotes", params_ ] :=
    setTechNotesInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, "setRelatedGuides", params_ ] :=
    setRelatedGuidesInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, "setRelatedLinks", params_ ] :=
    setRelatedLinksInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, "setKeywords", params_ ] :=
    setKeywordsInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, "setHistory", params_ ] :=
    setHistoryInNotebook[ notebook, params[ "content" ] ];

performEditOperation[ notebook_Notebook, op_String, params_ ] :=
    throwFailure[ "InvalidOperation", op ];

performEditOperation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setUsageInNotebook*)
setUsageInNotebook // beginDefinition;

setUsageInNotebook[ Notebook[ cells_List, opts___ ], usageMarkdown_String ] := Enclose[
    Module[ { newCells, pacletBase, symbolName, parsedUsage },
        (* Extract paclet info from notebook *)
        pacletBase = ConfirmBy[ extractPacletBase[ cells, { opts } ], StringQ, "PacletBase" ];
        symbolName = ConfirmBy[ extractSymbolName @ cells, StringQ, "SymbolName" ];

        (* Parse the usage markdown *)
        parsedUsage = ConfirmMatch[ parseUsageMarkdown @ usageMarkdown, { __Association }, "ParsedUsage" ];

        (* Replace usage cell *)
        newCells = ConfirmMatch[
            replaceUsageCell[ cells, symbolName, pacletBase, parsedUsage ],
            { __Cell },
            "NewCells"
        ];

        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setUsageInNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractPacletBase*)
extractPacletBase // beginDefinition;

extractPacletBase[ cells_List, opts_List ] := Enclose[
    Module[ { taggingRules },
        taggingRules = TaggingRules /. opts /. TaggingRules -> <| |>;
        ConfirmBy[ taggingRules[ "Paclet" ], StringQ, "PacletBase" ]
    ],
    throwInternalFailure
];

extractPacletBase // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractSymbolName*)
extractSymbolName // beginDefinition;

extractSymbolName[ cells_List ] :=
    FirstCase[
        cells,
        Cell[ name_String, "ObjectName", ___ ] :> name,
        None,
        Infinity
    ];

extractSymbolName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceUsageCell*)
replaceUsageCell // beginDefinition;

replaceUsageCell[ cells_List, symbolName_String, pacletBase_String, usageCases_List ] :=
    Replace[
        cells,
        Cell[ _, "Usage", rest___ ] :> Cell[
            generateUsageContent[ symbolName, pacletBase, usageCases ],
            "Usage",
            rest
        ],
        { 1, Infinity }
    ];

replaceUsageCell // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setNotesInNotebook*)
setNotesInNotebook // beginDefinition;

setNotesInNotebook[ Notebook[ cells_List, opts___ ], notesMarkdown_String ] := Enclose[
    Module[ { newCells, notesCells },
        notesCells = ConfirmMatch[ generateNotesCells @ notesMarkdown, { ___Cell }, "NotesCells" ];
        newCells = ConfirmMatch[ replaceNotesCells[ cells, notesCells ], { __Cell }, "NewCells" ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setNotesInNotebook // endDefinition;

replaceNotesCells // beginDefinition;

replaceNotesCells[ cells_List, notesCells_List ] :=
    (* The notes cells are in the first CellGroupData, after ObjectName and Usage cells *)
    (* Use With to inject notesCells into the RuleDelayed *)
    With[ { nc = notesCells },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MemberQ[ groupCells, Cell[ _, "ObjectName", ___ ], { 1 } ] :>
                    Cell[ CellGroupData[ replaceNotesInGroup[ groupCells, nc ], state ] ],
            { 1 }
        ]
    ];

replaceNotesCells // endDefinition;

replaceNotesInGroup // beginDefinition;

replaceNotesInGroup[ groupCells_List, notesCells_List ] :=
    Module[ { usagePos, beforeNotes },
        (* Find Usage position *)
        usagePos = FirstPosition[ groupCells, Cell[ _, "Usage", ___ ], None, { 1 } ];

        If[ usagePos === None,
            Return @ groupCells
        ];

        (* Take cells up to and including Usage *)
        beforeNotes = Take[ groupCells, First @ usagePos ];

        (* The new group is: ObjectName, Usage, then new notes cells *)
        Join[ beforeNotes, notesCells ]
    ];

replaceNotesInGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*addNoteToNotebook*)
addNoteToNotebook // beginDefinition;

addNoteToNotebook[ Notebook[ cells_List, opts___ ], noteMarkdown_String, position_ ] := Enclose[
    Module[ { noteCell, newCells },
        (* Generate a single note cell from the markdown *)
        noteCell = First @ ConfirmMatch[
            generateNotesCells @ noteMarkdown,
            { _Cell, ___Cell },
            "NoteCell"
        ];

        newCells = ConfirmMatch[
            insertNoteCell[ cells, noteCell, position ],
            { __Cell },
            "NewCells"
        ];

        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

addNoteToNotebook // endDefinition;

insertNoteCell // beginDefinition;

insertNoteCell[ cells_List, noteCell_Cell, position_ ] :=
    With[ { nc = noteCell, pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MemberQ[ groupCells, Cell[ _, "ObjectName", ___ ], { 1 } ] :>
                    Cell[ CellGroupData[ insertNoteInGroup[ groupCells, nc, pos ], state ] ],
            { 1 }
        ]
    ];

insertNoteCell // endDefinition;

insertNoteInGroup // beginDefinition;

insertNoteInGroup[ groupCells_List, noteCell_Cell, position_ ] :=
    Module[ { usagePos, existingNotes, insertPos, beforeInsert, afterInsert },
        usagePos = FirstPosition[ groupCells, Cell[ _, "Usage", ___ ], None, { 1 } ];

        If[ usagePos === None,
            Return @ groupCells
        ];

        (* Get existing notes (all cells after Usage) *)
        existingNotes = Drop[ groupCells, First @ usagePos ];

        (* Determine insertion position *)
        insertPos = Switch[ position,
            "start" | _Missing, 1,
            "end", Length @ existingNotes + 1,
            _Integer, position + 1,
            _, Length @ existingNotes + 1
        ];

        (* Insert the note cell *)
        beforeInsert = Take[ groupCells, First @ usagePos + insertPos - 1 ];
        afterInsert = Drop[ groupCells, First @ usagePos + insertPos - 1 ];

        Join[ beforeInsert, { noteCell }, afterInsert ]
    ];

insertNoteInGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setDetailsTableInNotebook*)
setDetailsTableInNotebook // beginDefinition;

setDetailsTableInNotebook[ Notebook[ cells_List, opts___ ], tableMarkdown_String, position_ ] := Enclose[
    Module[ { tableCells, newCells },
        (* Generate cells from the markdown, which may include text before the table *)
        tableCells = ConfirmMatch[
            generateNotesCells @ tableMarkdown,
            { ___Cell },
            "TableCells"
        ];

        If[ Length @ tableCells === 0,
            Return @ Notebook[ cells, opts ]
        ];

        newCells = ConfirmMatch[
            insertNotesCells[ cells, tableCells, position ],
            { __Cell },
            "NewCells"
        ];

        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setDetailsTableInNotebook // endDefinition;

insertNotesCells // beginDefinition;

insertNotesCells[ cells_List, noteCells_List, position_ ] :=
    With[ { nc = noteCells, pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MemberQ[ groupCells, Cell[ _, "ObjectName", ___ ], { 1 } ] :>
                    Cell[ CellGroupData[ insertNotesInGroup[ groupCells, nc, pos ], state ] ],
            { 1 }
        ]
    ];

insertNotesCells // endDefinition;

insertNotesInGroup // beginDefinition;

insertNotesInGroup[ groupCells_List, noteCells_List, position_ ] :=
    Module[ { usagePos, insertPos, beforeInsert, afterInsert },
        usagePos = FirstPosition[ groupCells, Cell[ _, "Usage", ___ ], None, { 1 } ];

        If[ usagePos === None,
            Return @ groupCells
        ];

        (* Determine insertion position based on "position" parameter *)
        insertPos = Switch[ position,
            "start" | _Missing, First @ usagePos + 1,
            "end", Length @ groupCells + 1,
            _Integer, First @ usagePos + position + 1,
            _, Length @ groupCells + 1
        ];

        (* Clamp to valid range *)
        insertPos = Clip[ insertPos, { First @ usagePos + 1, Length @ groupCells + 1 } ];

        beforeInsert = Take[ groupCells, insertPos - 1 ];
        afterInsert = Drop[ groupCells, insertPos - 1 ];

        Join[ beforeInsert, noteCells, afterInsert ]
    ];

insertNotesInGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setSeeAlsoInNotebook*)
setSeeAlsoInNotebook // beginDefinition;

setSeeAlsoInNotebook[ Notebook[ cells_List, opts___ ], symbolsString_String ] := Enclose[
    Module[ { pacletBase, symbols, newCells },
        pacletBase = ConfirmBy[ extractPacletBase[ cells, { opts } ], StringQ, "PacletBase" ];
        symbols    = parseCommaSeparatedList @ symbolsString;
        newCells   = ConfirmMatch[ replaceSeeAlsoCells[ cells, pacletBase, symbols ], { __Cell }, "NewCells" ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setSeeAlsoInNotebook // endDefinition;

replaceSeeAlsoCells // beginDefinition;

replaceSeeAlsoCells[ cells_List, pacletBase_String, symbols_List ] :=
    Replace[
        cells,
        Cell[ _, "SeeAlso", rest___ ] :> Cell[
            generateSeeAlsoContent[ pacletBase, symbols ],
            "SeeAlso",
            rest
        ],
        { 1, Infinity }
    ];

replaceSeeAlsoCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setTechNotesInNotebook*)
setTechNotesInNotebook // beginDefinition;

setTechNotesInNotebook[ Notebook[ cells_List, opts___ ], techNotesString_String ] := Enclose[
    Module[ { parsedLinks, tutorialsCells, newCells },
        parsedLinks    = parseMarkdownLinks @ techNotesString;
        tutorialsCells = ConfirmMatch[ generateTutorialsCells @ parsedLinks, { ___Cell }, "TutorialsCells" ];
        newCells       = ConfirmMatch[ replaceTutorialsCells[ cells, tutorialsCells ], { __Cell }, "NewCells" ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setTechNotesInNotebook // endDefinition;

replaceTutorialsCells // beginDefinition;

replaceTutorialsCells[ cells_List, tutorialsCells_List ] :=
    replaceCellsInSection[ cells, "TechNotesSection", "Tutorials", tutorialsCells ];

replaceTutorialsCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceCellsInSection*)
replaceCellsInSection // beginDefinition;

(* Helper function to replace content cells within a section's CellGroupData *)
replaceCellsInSection[ cells_List, headerStyle_String, contentStyle_String, newContentCells_List ] :=
    With[ { hs = headerStyle, cs = contentStyle, ncc = newContentCells },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MemberQ[ groupCells, Cell[ _, hs, ___ ], { 1 } ] :>
                    Cell[ CellGroupData[
                        replaceSectionContent[ groupCells, hs, cs, ncc ],
                        state
                    ] ],
            { 1 }
        ]
    ];

replaceCellsInSection // endDefinition;

replaceSectionContent // beginDefinition;

replaceSectionContent[ groupCells_List, headerStyle_String, contentStyle_String, newContentCells_List ] :=
    Module[ { headerPos, header },
        headerPos = FirstPosition[ groupCells, Cell[ _, headerStyle, ___ ], None, { 1 } ];

        If[ headerPos === None,
            Return @ groupCells
        ];

        header = groupCells[[ First @ headerPos ]];

        (* Replace: header + old content cells -> header + new content cells *)
        Join[ { header }, newContentCells ]
    ];

replaceSectionContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setRelatedGuidesInNotebook*)
setRelatedGuidesInNotebook // beginDefinition;

setRelatedGuidesInNotebook[ Notebook[ cells_List, opts___ ], guidesString_String ] := Enclose[
    Module[ { parsedLinks, moreAboutCells, newCells },
        parsedLinks    = parseMarkdownLinks @ guidesString;
        moreAboutCells = ConfirmMatch[ generateMoreAboutCells @ parsedLinks, { ___Cell }, "MoreAboutCells" ];
        newCells       = ConfirmMatch[ replaceMoreAboutCells[ cells, moreAboutCells ], { __Cell }, "NewCells" ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setRelatedGuidesInNotebook // endDefinition;

replaceMoreAboutCells // beginDefinition;

replaceMoreAboutCells[ cells_List, moreAboutCells_List ] :=
    replaceCellsInSection[ cells, "MoreAboutSection", "MoreAbout", moreAboutCells ];

replaceMoreAboutCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setRelatedLinksInNotebook*)
setRelatedLinksInNotebook // beginDefinition;

setRelatedLinksInNotebook[ Notebook[ cells_List, opts___ ], linksString_String ] := Enclose[
    Module[ { parsedLinks, linksCells, newCells },
        parsedLinks = parseMarkdownLinks @ linksString;
        linksCells  = ConfirmMatch[ generateRelatedLinksCells @ parsedLinks, { ___Cell }, "LinksCells" ];
        newCells    = ConfirmMatch[ replaceRelatedLinksCells[ cells, linksCells ], { __Cell }, "NewCells" ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setRelatedLinksInNotebook // endDefinition;

replaceRelatedLinksCells // beginDefinition;

replaceRelatedLinksCells[ cells_List, linksCells_List ] :=
    replaceCellsInSection[ cells, "RelatedLinksSection", "RelatedLinks", linksCells ];

replaceRelatedLinksCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setKeywordsInNotebook*)
setKeywordsInNotebook // beginDefinition;

setKeywordsInNotebook[ Notebook[ cells_List, opts___ ], keywordsString_String ] := Enclose[
    Module[ { keywords, keywordsCells, newCells },
        keywords      = parseCommaSeparatedList @ keywordsString;
        keywordsCells = ConfirmMatch[ generateKeywordsCells @ keywords, { ___Cell }, "KeywordsCells" ];
        newCells = ConfirmMatch[ replaceKeywordsCells[ cells, keywordsCells ], { __Cell }, "NewCells" ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setKeywordsInNotebook // endDefinition;

replaceKeywordsCells // beginDefinition;

replaceKeywordsCells[ cells_List, keywordsCells_List ] :=
    (* Keywords are inside the Metadata section, in a nested CellGroupData *)
    With[ { kc = keywordsCells },
        Replace[
            cells,
            Cell[ CellGroupData[ metadataCells_List, state1_ ] ] /;
                MemberQ[ metadataCells, Cell[ "Metadata", "MetadataSection", ___ ], { 1 } ] :>
                    Cell[ CellGroupData[ replaceKeywordsInMetadata[ metadataCells, kc ], state1 ] ],
            { 1 }
        ]
    ];

replaceKeywordsCells // endDefinition;

replaceKeywordsInMetadata // beginDefinition;

replaceKeywordsInMetadata[ metadataCells_List, keywordsCells_List ] :=
    With[ { kc = keywordsCells },
        Replace[
            metadataCells,
            Cell[ CellGroupData[ keywordsGroupCells_List, state_ ] ] /;
                MemberQ[ keywordsGroupCells, Cell[ "Keywords", "KeywordsSection", ___ ], { 1 } ] :>
                    Cell[ CellGroupData[
                        Join[
                            { Cell[ "Keywords", "KeywordsSection", CellID -> generateCellID[ ] ] },
                            kc
                        ],
                        state
                    ] ],
            { 1 }
        ]
    ];

replaceKeywordsInMetadata // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setHistoryInNotebook*)
setHistoryInNotebook // beginDefinition;

setHistoryInNotebook[ Notebook[ cells_List, opts___ ], historyString_String ] := Enclose[
    Module[ { historyData, newCells },
        (* Parse the history string: "new:1.0, modified:1.2, obsolete:2.0" *)
        historyData = ConfirmMatch[
            parseHistoryString @ historyString,
            _Association,
            "HistoryData"
        ];

        newCells = ConfirmMatch[
            replaceHistoryCell[ cells, historyData ],
            { __Cell },
            "NewCells"
        ];

        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setHistoryInNotebook // endDefinition;

parseHistoryString // beginDefinition;

parseHistoryString[ historyString_String ] :=
    Module[ { pairs },
        pairs = StringSplit[ historyString, "," ];
        Association @ Map[
            Function[ pair,
                Module[ { parts },
                    parts = StringTrim /@ StringSplit[ pair, ":" ];
                    If[ Length @ parts === 2,
                        parts[[1]] -> parts[[2]],
                        Nothing
                    ]
                ]
            ],
            pairs
        ]
    ];

parseHistoryString // endDefinition;

replaceHistoryCell // beginDefinition;

replaceHistoryCell[ cells_List, historyData_Association ] :=
    With[ { hd = historyData },
        Replace[
            cells,
            Cell[ CellGroupData[ metadataCells_List, state_ ] ] /;
                MemberQ[ metadataCells, Cell[ "Metadata", "MetadataSection", ___ ], { 1 } ] :>
                    Cell[ CellGroupData[ updateHistoryInMetadata[ metadataCells, hd ], state ] ],
            { 1 }
        ]
    ];

replaceHistoryCell // endDefinition;

updateHistoryInMetadata // beginDefinition;

updateHistoryInMetadata[ metadataCells_List, historyData_Association ] :=
    With[ { hd = historyData },
        Replace[
            metadataCells,
            Cell[ content_TextData, "History", opts___ ] :>
                Cell[ generateHistoryTextData @ hd, "History", opts ],
            { 1 }
        ]
    ];

updateHistoryInMetadata // endDefinition;

generateHistoryTextData // beginDefinition;

generateHistoryTextData[ historyData_Association ] :=
    TextData @ {
        "New in: ",
        Cell[ Lookup[ historyData, "new", " " ], "HistoryData", CellTags -> "New" ],
        " | Modified in: ",
        Cell[ Lookup[ historyData, "modified", " " ], "HistoryData", CellTags -> "Modified" ],
        " | Obsolete in: ",
        Cell[ Lookup[ historyData, "obsolete", " " ], "HistoryData", CellTags -> "Obsolete" ]
    };

generateHistoryTextData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*appendExampleToNotebook*)
appendExampleToNotebook // beginDefinition;

appendExampleToNotebook[ Notebook[ cells_List, opts___ ], section_String, content_String, subsection_ ] := Enclose[
    Module[ { context, newExampleCells, newCells, generatedMarkdown },

        (* Get context from notebook *)
        context = ConfirmBy[ extractContext[ cells, { opts } ], StringQ, "Context" ];

        (* Generate example cells from markdown *)
        newExampleCells = ConfirmMatch[ generateExampleCells[ context, content ], { ___Cell }, "ExampleCells" ];

        (* Insert cells into the appropriate section *)
        newCells = ConfirmMatch[
            insertExampleCellsInSection[ cells, section, newExampleCells, "append", subsection ],
            { __Cell },
            "NewCells"
        ];

        (* Generate markdown representation of what was added *)
        generatedMarkdown = ConfirmBy[ cellsToMarkdown @ newExampleCells, StringQ, "GeneratedMarkdown" ];

        { Notebook[ newCells, opts ], generatedMarkdown }
    ],
    throwInternalFailure
];

appendExampleToNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*prependExampleToNotebook*)
prependExampleToNotebook // beginDefinition;

prependExampleToNotebook[ Notebook[ cells_List, opts___ ], section_String, content_String, subsection_ ] := Enclose[
    Module[ { context, newExampleCells, newCells, generatedMarkdown },

        context = ConfirmBy[ extractContext[ cells, { opts } ], StringQ, "Context" ];
        newExampleCells = ConfirmMatch[ generateExampleCells[ context, content ], { ___Cell }, "ExampleCells" ];

        newCells = ConfirmMatch[
            insertExampleCellsInSection[ cells, section, newExampleCells, "prepend", subsection ],
            { __Cell },
            "NewCells"
        ];

        generatedMarkdown = ConfirmBy[ cellsToMarkdown @ newExampleCells, StringQ, "GeneratedMarkdown" ];

        { Notebook[ newCells, opts ], generatedMarkdown }
    ],
    throwInternalFailure
];

prependExampleToNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clearExamplesInNotebook*)
clearExamplesInNotebook // beginDefinition;

clearExamplesInNotebook[ Notebook[ cells_List, opts___ ], section_String, subsection_ ] := Enclose[
    Module[ { newCells },
        newCells = ConfirmMatch[
            clearExampleCellsInSection[ cells, section, subsection ],
            { __Cell },
            "NewCells"
        ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

clearExamplesInNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractContext*)
extractContext // beginDefinition;

extractContext[ cells_List, opts_List ] := Enclose[
    Module[ { pacletBase },
        pacletBase = ConfirmBy[ extractPacletBase[ cells, opts ], StringQ, "PacletBase" ];
        buildContext @ pacletBase
    ],
    throwInternalFailure
];

extractContext // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertExampleCellsInSection*)
insertExampleCellsInSection // beginDefinition;

(* Map section names to their identifiers in the notebook *)
$sectionNameMap = <|
    "BasicExamples"            -> "Basic Examples",
    "Scope"                    -> "Scope",
    "GeneralizationsExtensions" -> "Generalizations & Extensions",
    "Options"                  -> "Options",
    "Applications"             -> "Applications",
    "PropertiesRelations"      -> "Properties & Relations",
    "PossibleIssues"           -> "Possible Issues",
    "InteractiveExamples"      -> "Interactive Examples",
    "NeatExamples"             -> "Neat Examples"
|>;

insertExampleCellsInSection[ cells_List, sectionName_String, newCells_List, mode_String, subsection_ ] := Enclose[
    Module[ { sectionTitle, position },
        sectionTitle = ConfirmBy[ $sectionNameMap @ sectionName, StringQ, "SectionTitle" ];

        (* Find the section and insert cells *)
        (* This is a simplified implementation - a full version would properly
           navigate the CellGroupData structure *)

        If[ sectionName === "BasicExamples",
            insertInPrimaryExamplesSection[ cells, newCells, mode ],
            insertInExtendedExamplesSection[ cells, sectionTitle, newCells, mode, subsection ]
        ]
    ],
    throwInternalFailure
];

insertExampleCellsInSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertInPrimaryExamplesSection*)
insertInPrimaryExamplesSection // beginDefinition;

insertInPrimaryExamplesSection[ cells_List, newCells_List, "append" ] :=
    (* Find PrimaryExamplesSection cell group and append *)
    Replace[
        cells,
        Cell[ CellGroupData[ { header: Cell[ _, "PrimaryExamplesSection", ___ ], content___ }, state_ ] ] :>
            Cell[ CellGroupData[ { header, content, Sequence @@ addDelimiterIfNeeded[ { content }, newCells ] }, state ] ],
        { 1, Infinity }
    ];

insertInPrimaryExamplesSection[ cells_List, newCells_List, "prepend" ] :=
    Replace[
        cells,
        Cell[ CellGroupData[ { header: Cell[ _, "PrimaryExamplesSection", ___ ], content___ }, state_ ] ] :>
            Cell[ CellGroupData[ { header, Sequence @@ newCells, Sequence @@ addDelimiterIfNeeded[ newCells, { content } ] }, state ] ],
        { 1, Infinity }
    ];

insertInPrimaryExamplesSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertInExtendedExamplesSection*)
insertInExtendedExamplesSection // beginDefinition;

insertInExtendedExamplesSection[ cells_List, sectionTitle_String, newCells_List, mode_String, subsection_ ] :=
    Replace[
        cells,
        (* Find the ExtendedExamplesSection CellGroupData and modify it *)
        Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
            MatchQ[ First @ groupCells, Cell[ _, "ExtendedExamplesSection", ___ ] ] :>
                Cell[ CellGroupData[
                    insertInExampleSection[ groupCells, sectionTitle, newCells, mode ],
                    state
                ] ],
        { 1 }
    ];

insertInExtendedExamplesSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertInExampleSection*)
insertInExampleSection // beginDefinition;

insertInExampleSection[ groupCells_List, sectionTitle_String, newCells_List, mode_String ] := Enclose[
    Module[ { sectionIndex, beforeSection, sectionCell, afterSection, modifiedSection },

        (* Find the index of the target section *)
        sectionIndex = FirstPosition[
            groupCells,
            Cell[ BoxData[ InterpretationBox[ Cell[ sectionTitle, "ExampleSection", ___ ], ___ ] ], "ExampleSection", ___ ],
            None,
            { 1 }
        ];

        If[ sectionIndex === None,
            (* Section not found, return cells unchanged *)
            Return @ groupCells
        ];

        sectionIndex = First @ sectionIndex;

        (* Find the next ExampleSection or end of list to determine section boundary *)
        beforeSection = Take[ groupCells, sectionIndex ];
        sectionCell = groupCells[[ sectionIndex ]];

        (* Find where the next section starts (or end of list) *)
        afterSection = Drop[ groupCells, sectionIndex ];

        (* Insert the new cells right after the section header *)
        modifiedSection = If[ mode === "append",
            (* Append: Insert before the next section *)
            Join[
                beforeSection,
                addDelimiterIfNeeded[ { }, newCells ],  (* Add delimiter if there's content before *)
                afterSection
            ],
            (* Prepend: Insert right after the section header *)
            Join[
                beforeSection,
                newCells,
                If[ Length @ afterSection > 0, { exampleDelimiterCell[ ] }, { } ],
                afterSection
            ]
        ];

        modifiedSection
    ],
    throwInternalFailure
];

insertInExampleSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clearExampleCellsInSection*)
clearExampleCellsInSection // beginDefinition;

clearExampleCellsInSection[ cells_List, sectionName_String, subsection_ ] :=
    (* This is a stub - full implementation would clear example cells from the section *)
    cells;

clearExampleCellsInSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*addDelimiterIfNeeded*)
addDelimiterIfNeeded // beginDefinition;

addDelimiterIfNeeded[ existingCells_List, newCells_List ] :=
    If[ Length @ existingCells > 0 && Length @ newCells > 0,
        Prepend[ newCells, exampleDelimiterCell[ ] ],
        newCells
    ];

addDelimiterIfNeeded // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*cellsToMarkdown*)
cellsToMarkdown // beginDefinition;

cellsToMarkdown[ cells_List ] := Enclose[
    Module[ { parts },
        parts = cellToMarkdown /@ Flatten @ cells;
        ConfirmBy[ StringRiffle[ DeleteCases[ parts, "" ], "\n\n" ], StringQ, "Result" ]
    ],
    throwInternalFailure
];

cellsToMarkdown // endDefinition;

cellToMarkdown // beginDefinition;

cellToMarkdown[ Cell[ text_String, "ExampleText", ___ ] ] :=
    text;

cellToMarkdown[ Cell[ BoxData[ boxes_ ], "Input", ___ ] ] :=
    "```wl\n" <> boxesToInputForm @ boxes <> "\n```";

cellToMarkdown[ Cell[ BoxData[ boxes_ ], "Output", ___ ] ] :=
    "```wl-output\n" <> boxesToInputForm @ boxes <> "\n```";

cellToMarkdown[ Cell[ CellGroupData[ groupCells_List, _ ] ] ] :=
    StringRiffle[ cellToMarkdown /@ groupCells, "\n" ];

cellToMarkdown[ Cell[ _, "ExampleDelimiter", ___ ] ] :=
    "---";

cellToMarkdown[ _ ] := "";

cellToMarkdown // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*boxesToInputForm*)
boxesToInputForm // beginDefinition;

boxesToInputForm[ boxes_ ] := Module[ { held, str },
    held = ToExpression[ boxes, StandardForm, HoldComplete ];
    str = ToString[ held, InputForm ];
    (* Remove the HoldComplete wrapper from the string representation *)
    StringTrim @ StringReplace[
        str,
        StartOfString ~~ "HoldComplete[" ~~ body___ ~~ "]" ~~ EndOfString :> body
    ]
];

boxesToInputForm // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
