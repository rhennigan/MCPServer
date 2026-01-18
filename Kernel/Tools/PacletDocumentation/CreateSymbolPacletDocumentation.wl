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
        path = ConfirmBy[ $thisPaclet[ "AssetLocation", "SymbolPageTemplate" ], FileExistsQ, "TemplatePath" ];
        ConfirmMatch[ Get @ path, _TemplateObject, "Template" ]
    ],
    throwInternalFailure
];

loadSymbolPageTemplate // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];