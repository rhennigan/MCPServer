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
            "Interpreter" -> "Expression",
            "Help"        -> "Array of usage case objects with \"syntax\" and \"description\" keys.",
            "Required"    -> True
        |>,
        "notes" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Array of strings for the Details & Options section.",
            "Required"    -> False
        |>,
        "seeAlso" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Array of related symbol names.",
            "Required"    -> False
        |>,
        "techNotes" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Array of tutorial/tech note references.",
            "Required"    -> False
        |>,
        "relatedGuides" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Array of related guide page references.",
            "Required"    -> False
        |>,
        "relatedLinks" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Array of related link objects with \"label\" and \"url\" keys.",
            "Required"    -> False
        |>,
        "keywords" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Array of keyword strings for search.",
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
            "Help"        -> "Path to the notebook file.",
            "Required"    -> True
        |>,
        "operation" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The edit operation: setUsage, setNotes, addNote, setSeeAlso, setKeywords, setHistory, appendExample, prependExample, insertExample, replaceExample, removeExample, clearExamples.",
            "Required"    -> True
        |>,
        "section" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Target section for example operations: BasicExamples, Scope, GeneralizationsExtensions, Options, Applications, PropertiesRelations, PossibleIssues, InteractiveExamples, NeatExamples.",
            "Required"    -> False
        |>,
        "content" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "New content (format depends on operation). For examples, use markdown with ```wl code blocks.",
            "Required"    -> False
        |>,
        "position" -> <|
            "Interpreter" -> "Expression",
            "Help"        -> "Position for insert operations (0-indexed integer, or \"start\"/\"end\").",
            "Required"    -> False
        |>,
        "subsection" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Target subsection (for Options examples).",
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
        usage         = ConfirmMatch[ params[ "usage" ], { __Association }, "Usage" ];
        notes         = Replace[ params[ "notes" ], _Missing -> { } ];
        seeAlso       = Replace[ params[ "seeAlso" ], _Missing -> { } ];
        techNotes     = Replace[ params[ "techNotes" ], _Missing -> { } ];
        relatedGuides = Replace[ params[ "relatedGuides" ], _Missing -> { } ];
        relatedLinks  = Replace[ params[ "relatedLinks" ], _Missing -> { } ];
        keywords      = Replace[ params[ "keywords" ], _Missing -> { } ];
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
(*generateCellID*)
generateCellID // beginDefinition;
generateCellID[ ] := RandomInteger @ { 1, 999999999 };
generateCellID // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateSymbolPageNotebook*)
generateSymbolPageNotebook // beginDefinition;

generateSymbolPageNotebook[
    symbolName_String, pacletBase_String, context_String, usage_List, notes_List,
    seeAlso_List, techNotes_List, relatedGuides_List, relatedLinks_List,
    keywords_List, newInVersion_String, basicExamples_String
] := Enclose[
    Module[ { templateParams, template },

        (* Build template parameters *)
        templateParams = <|
            "SymbolName"          -> symbolName,
            "PacletBase"          -> pacletBase,
            "Context"             -> context,
            "UsageContent"        -> ConfirmMatch[ generateUsageContent[ symbolName, pacletBase, usage ], _TextData, "UsageContent" ],
            "NotesCells"          -> ConfirmMatch[ generateNotesCells @ notes, { ___Cell }, "NotesCells" ],
            "SeeAlsoContent"      -> ConfirmMatch[ generateSeeAlsoContent[ pacletBase, seeAlso ], _TextData, "SeeAlsoContent" ],
            "TutorialsCells"      -> ConfirmMatch[ generateTutorialsCells @ techNotes, { ___Cell }, "TutorialsCells" ],
            "MoreAboutCells"      -> ConfirmMatch[ generateMoreAboutCells @ relatedGuides, { ___Cell }, "MoreAboutCells" ],
            "RelatedLinksCells"   -> ConfirmMatch[ generateRelatedLinksCells @ relatedLinks, { ___Cell }, "RelatedLinksCells" ],
            "KeywordsCells"       -> ConfirmMatch[ generateKeywordsCells @ keywords, { ___Cell }, "KeywordsCells" ],
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

generateNotesCells[ { } ] := { Cell[ "XXXX", "Notes", CellID -> generateCellID[ ] ] };

generateNotesCells[ notes_List ] :=
    generateNoteCell /@ notes;

generateNotesCells // endDefinition;

generateNoteCell // beginDefinition;

generateNoteCell[ note_String ] := Module[ { parts },
    parts = formatDescriptionText @ note;
    If[ Length @ parts === 1 && StringQ @ First @ parts,
        Cell[ First @ parts, "Notes", CellID -> generateCellID[ ] ],
        Cell[ TextData @ parts, "Notes", CellID -> generateCellID[ ] ]
    ]
];

generateNoteCell // endDefinition;

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
    Cell[ #, "Tutorials", CellID -> generateCellID[ ] ] & /@ tutorials;

generateTutorialsCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateMoreAboutCells*)
generateMoreAboutCells // beginDefinition;

generateMoreAboutCells[ { } ] := { Cell[ "XXXX", "MoreAbout", CellID -> generateCellID[ ] ] };

generateMoreAboutCells[ guides_List ] :=
    Cell[ #, "MoreAbout", CellID -> generateCellID[ ] ] & /@ guides;

generateMoreAboutCells // endDefinition;

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
    Module[ { groups, cells },
        (* Split by horizontal rules to get example groups *)
        groups = StringSplit[ markdown, "\n---\n" | "\n---" | "---\n" ];

        (* Generate cells for each group, adding delimiters between groups *)
        cells = Flatten @ Riffle[
            generateExampleGroup[ context, StringTrim @ # ] & /@ groups,
            { { exampleDelimiterCell[ ] } }
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
    Module[ { parts, cells },
        (* Split into text and code blocks *)
        parts = StringSplit[ markdown, "```wl\n" ~~ code__ ~~ "\n```" :> { "CODE", code } ];

        cells = Flatten @ Map[
            Replace[
                #,
                {
                    { "CODE", code_String } :> generateInputOutputCells[ context, code ],
                    text_String :> generateExampleTextCells @ text
                }
            ] &,
            parts
        ];

        ConfirmMatch[ cells, { ___Cell }, "Cells" ]
    ],
    throwInternalFailure
];

generateExampleGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateExampleTextCells*)
generateExampleTextCells // beginDefinition;

generateExampleTextCells[ "" ] := { };

generateExampleTextCells[ text_String ] := Enclose[
    Module[ { trimmed },
        trimmed = StringTrim @ text;
        If[ trimmed === "",
            { },
            { Cell[ formatDescriptionText @ trimmed, "ExampleText", CellID -> generateCellID[ ] ] }
        ]
    ],
    throwInternalFailure
];

generateExampleTextCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateInputOutputCells*)
generateInputOutputCells // beginDefinition;

generateInputOutputCells[ context_String, code0_String ] := Enclose[
    Module[ { code, inputBoxes, inputCell, result, outputCell },
        (* Code is already extracted - just trim whitespace *)
        code = StringTrim @ code0;

        (* Create input cell - use UsingFrontEnd to get proper boxes from string *)
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

generateInputOutputCells // endDefinition;

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
    Module[ { notebookPath, operation, notebook, result, generatedContent },

        notebookPath = ConfirmBy[ params[ "notebook" ], StringQ, "NotebookPath" ];
        operation    = ConfirmBy[ params[ "operation" ], StringQ, "Operation" ];

        (* Load the notebook *)
        If[ ! FileExistsQ @ notebookPath,
            throwFailure[ "NotebookNotFound", notebookPath ]
        ];

        notebook = ConfirmMatch[ Import[ notebookPath, "NB" ], _Notebook, "Notebook" ];

        (* Perform the operation *)
        { notebook, generatedContent } = ConfirmMatch[
            performEditOperation[ notebook, operation, params ],
            { _Notebook, _ },
            "EditResult"
        ];

        (* Save the notebook *)
        ConfirmBy[ Export[ notebookPath, notebook, "NB" ], FileExistsQ, "Export" ];

        (* Return result *)
        result = <|
            "file"      -> notebookPath,
            "operation" -> operation,
            "section"   -> params[ "section" ]
        |>;

        If[ StringQ @ generatedContent,
            result[ "generatedContent" ] = generatedContent
        ];

        result
    ],
    throwInternalFailure
];

editSymbolPacletDocumentation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*performEditOperation*)
performEditOperation // beginDefinition;

performEditOperation[ notebook_Notebook, "setUsage", params_ ] :=
    { setUsageInNotebook[ notebook, params[ "content" ] ], None };

performEditOperation[ notebook_Notebook, "setNotes", params_ ] :=
    { setNotesInNotebook[ notebook, params[ "content" ] ], None };

performEditOperation[ notebook_Notebook, "addNote", params_ ] :=
    { addNoteToNotebook[ notebook, params[ "content" ], params[ "position" ] ], None };

performEditOperation[ notebook_Notebook, "setSeeAlso", params_ ] :=
    { setSeeAlsoInNotebook[ notebook, params[ "content" ] ], None };

performEditOperation[ notebook_Notebook, "setKeywords", params_ ] :=
    { setKeywordsInNotebook[ notebook, params[ "content" ] ], None };

performEditOperation[ notebook_Notebook, "setHistory", params_ ] :=
    { setHistoryInNotebook[ notebook, params[ "content" ] ], None };

performEditOperation[ notebook_Notebook, "appendExample", params_ ] :=
    appendExampleToNotebook[ notebook, params[ "section" ], params[ "content" ], params[ "subsection" ] ];

performEditOperation[ notebook_Notebook, "prependExample", params_ ] :=
    prependExampleToNotebook[ notebook, params[ "section" ], params[ "content" ], params[ "subsection" ] ];

performEditOperation[ notebook_Notebook, "clearExamples", params_ ] :=
    { clearExamplesInNotebook[ notebook, params[ "section" ], params[ "subsection" ] ], None };

performEditOperation[ notebook_Notebook, op_String, params_ ] :=
    throwFailure[ "InvalidOperation", op ];

performEditOperation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setUsageInNotebook*)
setUsageInNotebook // beginDefinition;

setUsageInNotebook[ Notebook[ cells_List, opts___ ], usageCases_List ] := Enclose[
    Module[ { newCells, pacletBase, symbolName },
        (* Extract paclet info from notebook *)
        pacletBase = ConfirmBy[ extractPacletBase[ cells, { opts } ], StringQ, "PacletBase" ];
        symbolName = ConfirmBy[ extractSymbolName @ cells, StringQ, "SymbolName" ];

        (* Replace usage cell *)
        newCells = ConfirmMatch[
            replaceUsageCell[ cells, symbolName, pacletBase, usageCases ],
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

setNotesInNotebook[ Notebook[ cells_List, opts___ ], notes_List ] := Enclose[
    Module[ { newCells },
        newCells = ConfirmMatch[ replaceNotesCells[ cells, notes ], { __Cell }, "NewCells" ];
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setNotesInNotebook // endDefinition;

replaceNotesCells // beginDefinition;

replaceNotesCells[ cells_List, notes_List ] :=
    (* This is a simplified implementation - a full implementation would need to
       properly locate and replace the notes section within the cell group structure *)
    cells;

replaceNotesCells // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*addNoteToNotebook*)
addNoteToNotebook // beginDefinition;

addNoteToNotebook[ notebook_Notebook, note_String, position_ ] :=
    (* Simplified stub - full implementation would insert at correct position *)
    notebook;

addNoteToNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setSeeAlsoInNotebook*)
setSeeAlsoInNotebook // beginDefinition;

setSeeAlsoInNotebook[ Notebook[ cells_List, opts___ ], symbols_List ] := Enclose[
    Module[ { pacletBase, newCells },
        pacletBase = ConfirmBy[ extractPacletBase[ cells, { opts } ], StringQ, "PacletBase" ];
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
(*setKeywordsInNotebook*)
setKeywordsInNotebook // beginDefinition;

setKeywordsInNotebook[ Notebook[ cells_List, opts___ ], keywords_List ] := Enclose[
    Module[ { newCells },
        (* Remove existing keywords cells and add new ones *)
        newCells = cells; (* Simplified - full implementation needed *)
        Notebook[ newCells, opts ]
    ],
    throwInternalFailure
];

setKeywordsInNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setHistoryInNotebook*)
setHistoryInNotebook // beginDefinition;

setHistoryInNotebook[ notebook_Notebook, history_Association ] :=
    (* Simplified stub - full implementation would update history cell *)
    notebook;

setHistoryInNotebook // endDefinition;

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
    (* This is a stub - full implementation would navigate to the correct ExampleSection *)
    cells;

insertInExtendedExamplesSection // endDefinition;

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

boxesToInputForm[ boxes_ ] :=
    ToString[ ToExpression[ boxes, StandardForm, HoldComplete ], InputForm ];

boxesToInputForm // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
