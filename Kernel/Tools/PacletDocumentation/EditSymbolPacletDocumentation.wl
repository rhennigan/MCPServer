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
    Catch @ Module[ { usagePos, beforeNotes },
        (* Find Usage position *)
        usagePos = FirstPosition[ groupCells, Cell[ _, "Usage", ___ ], None, { 1 } ];

        If[ usagePos === None,
            Throw @ groupCells
        ];

        (* Take cells up to and including Usage *)
        beforeNotes = Take[ groupCells, First @ usagePos ];

        (* The new group is: ObjectName, Usage, then new notes cells *)
        Join[ beforeNotes, notesCells ]
    ];

replaceNotesInGroup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*normalizeInsertPosition*)
(* Converts 1-indexed position (with negative support) to internal insert position.
   For a list of length n:
   - position 1 to n: insert before that element
   - position n+1 or -1: insert at the end (append)
   - position -2: insert before the last element
   - etc. (like WL's Insert function) *)
normalizeInsertPosition // beginDefinition;

normalizeInsertPosition[ position_Integer, length_Integer ] :=
    Module[ { pos },
        pos = If[ position < 0,
            length + position + 2,  (* -1 -> length+1 (end), -2 -> length (before last), etc. *)
            position
        ];
        (* Clamp to valid range: 1 to length+1 *)
        Clip[ pos, { 1, length + 1 } ]
    ];

normalizeInsertPosition[ _Missing, _Integer ] := 1;  (* Default to beginning *)

normalizeInsertPosition // endDefinition;

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
    Catch @ Module[ { usagePos, existingNotes, insertPos, beforeInsert, afterInsert },
        usagePos = FirstPosition[ groupCells, Cell[ _, "Usage", ___ ], None, { 1 } ];

        If[ usagePos === None,
            Throw @ groupCells
        ];

        (* Get existing notes (all cells after Usage) *)
        existingNotes = Drop[ groupCells, First @ usagePos ];

        (* Determine insertion position using 1-indexed with negative support *)
        insertPos = normalizeInsertPosition[ position, Length @ existingNotes ];

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
    Catch @ Module[ { tableCells, newCells },
        (* Generate cells from the markdown, which may include text before the table *)
        tableCells = ConfirmMatch[
            generateNotesCells @ tableMarkdown,
            { ___Cell },
            "TableCells"
        ];

        If[ Length @ tableCells === 0,
            Throw @ Notebook[ cells, opts ]
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
    Catch @ Module[ { usagePos, existingNotes, insertPos, beforeInsert, afterInsert },
        usagePos = FirstPosition[ groupCells, Cell[ _, "Usage", ___ ], None, { 1 } ];

        If[ usagePos === None,
            Throw @ groupCells
        ];

        (* Get existing notes (all cells after Usage) *)
        existingNotes = Drop[ groupCells, First @ usagePos ];

        (* Determine insertion position using 1-indexed with negative support *)
        insertPos = normalizeInsertPosition[ position, Length @ existingNotes ];

        beforeInsert = Take[ groupCells, First @ usagePos + insertPos - 1 ];
        afterInsert = Drop[ groupCells, First @ usagePos + insertPos - 1 ];

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
    Catch @ Module[ { headerPos, header },
        headerPos = FirstPosition[ groupCells, Cell[ _, headerStyle, ___ ], None, { 1 } ];

        If[ headerPos === None,
            Throw @ groupCells
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
    "BasicExamples"             -> "Basic Examples",
    "Scope"                     -> "Scope",
    "GeneralizationsExtensions" -> "Generalizations & Extensions",
    "Options"                   -> "Options",
    "Applications"              -> "Applications",
    "PropertiesRelations"       -> "Properties & Relations",
    "PossibleIssues"            -> "Possible Issues",
    "InteractiveExamples"       -> "Interactive Examples",
    "NeatExamples"              -> "Neat Examples"
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
    Catch @ Module[ { sectionIndex, beforeSection, sectionCell, afterSection, modifiedSection },

        (* Find the index of the target section *)
        sectionIndex = FirstPosition[
            groupCells,
            Cell[ BoxData[ InterpretationBox[ Cell[ sectionTitle, "ExampleSection", ___ ], ___ ] ], "ExampleSection", ___ ],
            None,
            { 1 }
        ];

        If[ sectionIndex === None,
            (* Section not found, return cells unchanged *)
            Throw @ groupCells
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

clearExampleCellsInSection[ cells_List, sectionName_String, subsection_ ] := Enclose[
    Module[ { sectionTitle },
        sectionTitle = ConfirmBy[ $sectionNameMap @ sectionName, StringQ, "SectionTitle" ];

        If[ sectionName === "BasicExamples",
            clearPrimaryExamplesSection @ cells,
            clearExtendedExamplesSection[ cells, sectionTitle, subsection ]
        ]
    ],
    throwInternalFailure
];

clearExampleCellsInSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clearPrimaryExamplesSection*)
clearPrimaryExamplesSection // beginDefinition;

clearPrimaryExamplesSection[ cells_List ] :=
    Replace[
        cells,
        Cell[ CellGroupData[ { header: Cell[ _, "PrimaryExamplesSection", ___ ], content___ }, state_ ] ] :>
            Cell[ CellGroupData[ { header }, state ] ],
        { 1, Infinity }
    ];

clearPrimaryExamplesSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clearExtendedExamplesSection*)
clearExtendedExamplesSection // beginDefinition;

clearExtendedExamplesSection[ cells_List, sectionTitle_String, subsection_ ] :=
    With[ { st = sectionTitle },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MatchQ[ First @ groupCells, Cell[ _, "ExtendedExamplesSection", ___ ] ] :>
                    Cell[ CellGroupData[
                        clearExamplesFromExtendedSection[ groupCells, st ],
                        state
                    ] ],
            { 1 }
        ]
    ];

clearExtendedExamplesSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clearExamplesFromExtendedSection*)
clearExamplesFromExtendedSection // beginDefinition;

clearExamplesFromExtendedSection[ groupCells_List, sectionTitle_String ] := Enclose[
    Catch @ Module[ { sectionIndex, sectionEndIndex, newCells },

        sectionIndex = FirstPosition[
            groupCells,
            Cell[ BoxData[ InterpretationBox[ Cell[ sectionTitle, "ExampleSection", ___ ], ___ ] ], "ExampleSection", ___ ],
            None,
            { 1 }
        ];

        If[ sectionIndex === None,
            Throw @ groupCells
        ];

        sectionIndex = First @ sectionIndex;
        sectionEndIndex = findNextSectionIndex[ groupCells, sectionIndex ];

        (* Remove all cells between the section header and the next section *)
        newCells = Flatten @ {
            Take[ groupCells, sectionIndex ],
            Drop[ groupCells, sectionEndIndex - 1 ]
        };

        newCells
    ],
    throwInternalFailure
];

clearExamplesFromExtendedSection // endDefinition;

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