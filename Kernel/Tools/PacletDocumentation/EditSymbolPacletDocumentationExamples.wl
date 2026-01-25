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
(*EditSymbolPacletDocumentationExamples Implementation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Position Normalization Helpers*)

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

normalizeInsertPosition[ _Missing | None, _Integer ] := 1;  (* Default to beginning *)

normalizeInsertPosition // endDefinition;

(* Converts 1-indexed position (with negative support) to internal element position.
   For a list of length n:
   - position 1: first element
   - position n or -1: last element
   - position -2: second to last element
   - etc. (like WL's Part function) *)
normalizeElementPosition // beginDefinition;

normalizeElementPosition[ position_Integer, length_Integer ] :=
    Module[ { pos },
        pos = If[ position < 0,
            length + position + 1,  (* -1 -> length (last), -2 -> length-1 (second to last), etc. *)
            position
        ];
        (* Clamp to valid range: 1 to length *)
        Clip[ pos, { 1, Max[ 1, length ] } ]
    ];

normalizeElementPosition[ _Missing | None, _Integer ] := 1;  (* Default to first *)

normalizeElementPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*editSymbolPacletDocumentationExamples*)
editSymbolPacletDocumentationExamples // beginDefinition;

editSymbolPacletDocumentationExamples[ params_Association ] := Enclose[
    Module[ { notebookPath, operation, section, content, position, subsection,
              notebook, result, generatedContent },

        notebookPath = ConfirmBy[ params[ "notebook" ], StringQ, "NotebookPath" ];
        operation    = ConfirmBy[ params[ "operation" ], StringQ, "Operation" ];
        section      = ConfirmBy[ params[ "section" ], StringQ, "Section" ];
        content      = Replace[ params[ "content" ], _Missing -> "" ];
        position     = Replace[ params[ "position" ], _Missing -> None ];
        subsection   = Replace[ params[ "subsection" ], _Missing -> None ];

        (* Validate section name *)
        If[ ! KeyExistsQ[ $sectionNameMap, section ],
            throwFailure[ "InvalidSection", section ]
        ];

        (* Load the notebook *)
        If[ ! FileExistsQ @ notebookPath,
            throwFailure[ "NotebookNotFound", notebookPath ]
        ];

        notebook = ConfirmMatch[ Import[ notebookPath, "NB" ], _Notebook, "Notebook" ];

        (* Perform the operation *)
        { notebook, generatedContent } = ConfirmMatch[
            performExamplesOperation[ notebook, operation, section, content, position, subsection ],
            { _Notebook, _String },
            "EditResult"
        ];

        (* Save the notebook *)
        ConfirmBy[ Export[ notebookPath, notebook, "NB" ], FileExistsQ, "Export" ];

        (* Return result *)
        <|
            "file"             -> notebookPath,
            "operation"        -> operation,
            "section"          -> section,
            "generatedContent" -> generatedContent
        |>
    ],
    throwInternalFailure
];

editSymbolPacletDocumentationExamples // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*performExamplesOperation*)
performExamplesOperation // beginDefinition;

performExamplesOperation[ notebook_Notebook, "appendExample", section_String, content_String, position_, subsection_ ] :=
    appendExampleToNotebook[ notebook, section, content, subsection ];

performExamplesOperation[ notebook_Notebook, "prependExample", section_String, content_String, position_, subsection_ ] :=
    prependExampleToNotebook[ notebook, section, content, subsection ];

performExamplesOperation[ notebook_Notebook, "insertExample", section_String, content_String, position_Integer, subsection_ ] :=
    insertExampleToNotebook[ notebook, section, content, position, subsection ];

performExamplesOperation[ notebook_Notebook, "replaceExample", section_String, content_String, position_Integer, subsection_ ] :=
    replaceExampleInNotebook[ notebook, section, content, position, subsection ];

performExamplesOperation[ notebook_Notebook, "removeExample", section_String, content_, position_Integer, subsection_ ] :=
    removeExampleFromNotebook[ notebook, section, position, subsection ];

performExamplesOperation[ notebook_Notebook, "clearExamples", section_String, content_, position_, subsection_ ] :=
    { clearExamplesInNotebook[ notebook, section, subsection ], "" };

performExamplesOperation[ notebook_Notebook, "setExamples", section_String, content_String, position_, subsection_ ] :=
    setExamplesInNotebook[ notebook, section, content, subsection ];

performExamplesOperation[ notebook_Notebook, op_String, section_, content_, position_, subsection_ ] :=
    throwFailure[ "InvalidOperation", op ];

performExamplesOperation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertExampleToNotebook*)
insertExampleToNotebook // beginDefinition;

insertExampleToNotebook[ Notebook[ cells_List, opts___ ], section_String, content_String, position_Integer, subsection_ ] := Enclose[
    Module[ { context, newExampleCells, newCells, generatedMarkdown },

        context = ConfirmBy[ extractContext[ cells, { opts } ], StringQ, "Context" ];
        newExampleCells = ConfirmMatch[ generateExampleCells[ context, content ], { ___Cell }, "ExampleCells" ];

        newCells = ConfirmMatch[
            insertExampleCellsAtPosition[ cells, section, newExampleCells, position, subsection ],
            { __Cell },
            "NewCells"
        ];

        generatedMarkdown = ConfirmBy[ cellsToMarkdown @ newExampleCells, StringQ, "GeneratedMarkdown" ];

        { Notebook[ newCells, opts ], generatedMarkdown }
    ],
    throwInternalFailure
];

insertExampleToNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertExampleCellsAtPosition*)
insertExampleCellsAtPosition // beginDefinition;

insertExampleCellsAtPosition[ cells_List, sectionName_String, newCells_List, position_Integer, subsection_ ] := Enclose[
    Module[ { sectionTitle },
        sectionTitle = ConfirmBy[ $sectionNameMap @ sectionName, StringQ, "SectionTitle" ];

        If[ sectionName === "BasicExamples",
            insertAtPositionInPrimaryExamples[ cells, newCells, position ],
            insertAtPositionInExtendedExamples[ cells, sectionTitle, newCells, position, subsection ]
        ]
    ],
    throwInternalFailure
];

insertExampleCellsAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertAtPositionInPrimaryExamples*)
insertAtPositionInPrimaryExamples // beginDefinition;

insertAtPositionInPrimaryExamples[ cells_List, newCells_List, position_Integer ] :=
    With[ { nc = newCells, pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ { header: Cell[ _, "PrimaryExamplesSection", ___ ], content___ }, state_ ] ] :>
                Cell[ CellGroupData[
                    insertExampleGroupAtPosition[ { header, content }, nc, pos ],
                    state
                ] ],
            { 1, Infinity }
        ]
    ];

insertAtPositionInPrimaryExamples // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertAtPositionInExtendedExamples*)
insertAtPositionInExtendedExamples // beginDefinition;

insertAtPositionInExtendedExamples[ cells_List, sectionTitle_String, newCells_List, position_Integer, subsection_ ] :=
    With[ { st = sectionTitle, nc = newCells, pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MatchQ[ First @ groupCells, Cell[ _, "ExtendedExamplesSection", ___ ] ] :>
                    Cell[ CellGroupData[
                        insertInExtendedSectionAtPosition[ groupCells, st, nc, pos ],
                        state
                    ] ],
            { 1 }
        ]
    ];

insertAtPositionInExtendedExamples // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertInExtendedSectionAtPosition*)
insertInExtendedSectionAtPosition // beginDefinition;

insertInExtendedSectionAtPosition[ groupCells_List, sectionTitle_String, newCells_List, position_Integer ] := Enclose[
    Catch @ Module[ { sectionIndex, sectionEndIndex, sectionContent, groups, insertedContent, newSectionContent },

        (* Find the section header *)
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

        (* Find where the next section starts *)
        sectionEndIndex = findNextSectionIndex[ groupCells, sectionIndex ];

        (* Get content between header and next section *)
        sectionContent = Take[ groupCells, { sectionIndex + 1, sectionEndIndex - 1 } ];

        (* Split content into example groups *)
        groups = splitIntoExampleGroups @ sectionContent;

        (* Insert new cells at the specified position *)
        insertedContent = insertExampleGroupAtList[ groups, newCells, position ];

        (* Rebuild the section *)
        newSectionContent = Flatten @ {
            Take[ groupCells, sectionIndex ],
            insertedContent,
            Drop[ groupCells, sectionEndIndex - 1 ]
        };

        newSectionContent
    ],
    throwInternalFailure
];

insertInExtendedSectionAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*findNextSectionIndex*)
findNextSectionIndex // beginDefinition;

findNextSectionIndex[ groupCells_List, currentIndex_Integer ] :=
    Module[ { nextIndex },
        nextIndex = FirstPosition[
            Drop[ groupCells, currentIndex ],
            Cell[ BoxData[ InterpretationBox[ Cell[ _, "ExampleSection", ___ ], ___ ] ], "ExampleSection", ___ ],
            None,
            { 1 }
        ];

        If[ nextIndex === None,
            Length @ groupCells + 1,
            currentIndex + First @ nextIndex
        ]
    ];

findNextSectionIndex // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*splitIntoExampleGroups*)
splitIntoExampleGroups // beginDefinition;

splitIntoExampleGroups[ cells_List ] :=
    Module[ { delimiterPositions, groups },
        (* Find positions of ExampleDelimiter cells *)
        delimiterPositions = Flatten @ Position[
            cells,
            Cell[ CellGroupData[ { Cell[ _, "ExampleDelimiter", ___ ], ___ }, _ ] ] |
            Cell[ _, "ExampleDelimiter", ___ ],
            { 1 }
        ];

        If[ Length @ delimiterPositions === 0,
            (* No delimiters, entire content is one group *)
            { cells },
            (* Split at delimiters *)
            groups = splitAtPositions[ cells, delimiterPositions ];
            groups
        ]
    ];

splitIntoExampleGroups // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*splitAtPositions*)
splitAtPositions // beginDefinition;

splitAtPositions[ cells_List, positions_List ] :=
    Module[ { ranges, result },
        (* Create ranges between delimiter positions *)
        ranges = Partition[ Join[ { 0 }, positions, { Length @ cells + 1 } ], 2, 1 ];
        result = Map[
            Function[ { start, end },
                Take[ cells, { start + 1, end - 1 } ]
            ] @@ # &,
            ranges
        ];
        (* Filter out empty groups *)
        Select[ result, Length @ # > 0 & ]
    ];

splitAtPositions // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertExampleGroupAtPosition*)
insertExampleGroupAtPosition // beginDefinition;

insertExampleGroupAtPosition[ groupCells_List, newCells_List, position_Integer ] :=
    Module[ { header, content, groups, insertedGroups },
        header = First @ groupCells;
        content = Rest @ groupCells;

        (* Split existing content into groups *)
        groups = splitIntoExampleGroups @ content;

        (* Insert at position *)
        insertedGroups = insertExampleGroupAtList[ groups, newCells, position ];

        Join[ { header }, insertedGroups ]
    ];

insertExampleGroupAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertExampleGroupAtList*)
insertExampleGroupAtList // beginDefinition;

insertExampleGroupAtList[ groups_List, newCells_List, position_Integer ] :=
    Module[ { pos, before, after, result },
        (* Normalize position using 1-indexed with negative support *)
        pos = normalizeInsertPosition[ position, Length @ groups ];

        before = Take[ groups, pos - 1 ];
        after = Drop[ groups, pos - 1 ];

        (* Combine with delimiters *)
        result = If[ Length @ before > 0 && Length @ newCells > 0,
            Join[ Flatten @ before, { exampleDelimiterCell[ ] }, newCells ],
            Join[ Flatten @ before, newCells ]
        ];

        If[ Length @ after > 0 && Length @ result > 0,
            Join[ result, { exampleDelimiterCell[ ] }, Flatten @ after ],
            Join[ result, Flatten @ after ]
        ]
    ];

insertExampleGroupAtList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceExampleInNotebook*)
replaceExampleInNotebook // beginDefinition;

replaceExampleInNotebook[ Notebook[ cells_List, opts___ ], section_String, content_String, position_Integer, subsection_ ] := Enclose[
    Module[ { context, newExampleCells, newCells, generatedMarkdown },

        context = ConfirmBy[ extractContext[ cells, { opts } ], StringQ, "Context" ];
        newExampleCells = ConfirmMatch[ generateExampleCells[ context, content ], { ___Cell }, "ExampleCells" ];

        newCells = ConfirmMatch[
            replaceExampleCellsAtPosition[ cells, section, newExampleCells, position, subsection ],
            { __Cell },
            "NewCells"
        ];

        generatedMarkdown = ConfirmBy[ cellsToMarkdown @ newExampleCells, StringQ, "GeneratedMarkdown" ];

        { Notebook[ newCells, opts ], generatedMarkdown }
    ],
    throwInternalFailure
];

replaceExampleInNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceExampleCellsAtPosition*)
replaceExampleCellsAtPosition // beginDefinition;

replaceExampleCellsAtPosition[ cells_List, sectionName_String, newCells_List, position_Integer, subsection_ ] := Enclose[
    Module[ { sectionTitle },
        sectionTitle = ConfirmBy[ $sectionNameMap @ sectionName, StringQ, "SectionTitle" ];

        If[ sectionName === "BasicExamples",
            replaceAtPositionInPrimaryExamples[ cells, newCells, position ],
            replaceAtPositionInExtendedExamples[ cells, sectionTitle, newCells, position, subsection ]
        ]
    ],
    throwInternalFailure
];

replaceExampleCellsAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceAtPositionInPrimaryExamples*)
replaceAtPositionInPrimaryExamples // beginDefinition;

replaceAtPositionInPrimaryExamples[ cells_List, newCells_List, position_Integer ] :=
    With[ { nc = newCells, pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ { header: Cell[ _, "PrimaryExamplesSection", ___ ], content___ }, state_ ] ] :>
                Cell[ CellGroupData[
                    replaceExampleGroupAtPosition[ { header, content }, nc, pos ],
                    state
                ] ],
            { 1, Infinity }
        ]
    ];

replaceAtPositionInPrimaryExamples // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceAtPositionInExtendedExamples*)
replaceAtPositionInExtendedExamples // beginDefinition;

replaceAtPositionInExtendedExamples[ cells_List, sectionTitle_String, newCells_List, position_Integer, subsection_ ] :=
    With[ { st = sectionTitle, nc = newCells, pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MatchQ[ First @ groupCells, Cell[ _, "ExtendedExamplesSection", ___ ] ] :>
                    Cell[ CellGroupData[
                        replaceInExtendedSectionAtPosition[ groupCells, st, nc, pos ],
                        state
                    ] ],
            { 1 }
        ]
    ];

replaceAtPositionInExtendedExamples // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceInExtendedSectionAtPosition*)
replaceInExtendedSectionAtPosition // beginDefinition;

replaceInExtendedSectionAtPosition[ groupCells_List, sectionTitle_String, newCells_List, position_Integer ] := Enclose[
    Catch @ Module[ { sectionIndex, sectionEndIndex, sectionContent, groups, replacedContent, newSectionContent },

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
        sectionContent = Take[ groupCells, { sectionIndex + 1, sectionEndIndex - 1 } ];
        groups = splitIntoExampleGroups @ sectionContent;
        replacedContent = replaceExampleGroupAtList[ groups, newCells, position ];

        newSectionContent = Flatten @ {
            Take[ groupCells, sectionIndex ],
            replacedContent,
            Drop[ groupCells, sectionEndIndex - 1 ]
        };

        newSectionContent
    ],
    throwInternalFailure
];

replaceInExtendedSectionAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceExampleGroupAtPosition*)
replaceExampleGroupAtPosition // beginDefinition;

replaceExampleGroupAtPosition[ groupCells_List, newCells_List, position_Integer ] :=
    Module[ { header, content, groups, replacedGroups },
        header = First @ groupCells;
        content = Rest @ groupCells;
        groups = splitIntoExampleGroups @ content;
        replacedGroups = replaceExampleGroupAtList[ groups, newCells, position ];
        Join[ { header }, replacedGroups ]
    ];

replaceExampleGroupAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*replaceExampleGroupAtList*)
replaceExampleGroupAtList // beginDefinition;

replaceExampleGroupAtList[ groups_List, newCells_List, position_Integer ] :=
    Catch @ Module[ { pos, before, after, result },
        (* Normalize position using 1-indexed with negative support *)
        pos = normalizeElementPosition[ position, Length @ groups ];

        If[ Length @ groups === 0,
            (* No existing groups, just add the new cells *)
            Throw @ newCells
        ];

        before = Take[ groups, pos - 1 ];
        after = Drop[ groups, pos ];

        (* Combine with delimiters *)
        result = If[ Length @ before > 0 && Length @ newCells > 0,
            Join[ Flatten @ before, { exampleDelimiterCell[ ] }, newCells ],
            Join[ Flatten @ before, newCells ]
        ];

        If[ Length @ after > 0 && Length @ result > 0,
            Join[ result, { exampleDelimiterCell[ ] }, Flatten @ after ],
            Join[ result, Flatten @ after ]
        ]
    ];

replaceExampleGroupAtList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeExampleFromNotebook*)
removeExampleFromNotebook // beginDefinition;

removeExampleFromNotebook[ Notebook[ cells_List, opts___ ], section_String, position_Integer, subsection_ ] := Enclose[
    Module[ { newCells },
        newCells = ConfirmMatch[
            removeExampleCellsAtPosition[ cells, section, position, subsection ],
            { __Cell },
            "NewCells"
        ];
        { Notebook[ newCells, opts ], "" }
    ],
    throwInternalFailure
];

removeExampleFromNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeExampleCellsAtPosition*)
removeExampleCellsAtPosition // beginDefinition;

removeExampleCellsAtPosition[ cells_List, sectionName_String, position_Integer, subsection_ ] := Enclose[
    Module[ { sectionTitle },
        sectionTitle = ConfirmBy[ $sectionNameMap @ sectionName, StringQ, "SectionTitle" ];

        If[ sectionName === "BasicExamples",
            removeAtPositionInPrimaryExamples[ cells, position ],
            removeAtPositionInExtendedExamples[ cells, sectionTitle, position, subsection ]
        ]
    ],
    throwInternalFailure
];

removeExampleCellsAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeAtPositionInPrimaryExamples*)
removeAtPositionInPrimaryExamples // beginDefinition;

removeAtPositionInPrimaryExamples[ cells_List, position_Integer ] :=
    With[ { pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ { header: Cell[ _, "PrimaryExamplesSection", ___ ], content___ }, state_ ] ] :>
                Cell[ CellGroupData[
                    removeExampleGroupAtPosition[ { header, content }, pos ],
                    state
                ] ],
            { 1, Infinity }
        ]
    ];

removeAtPositionInPrimaryExamples // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeAtPositionInExtendedExamples*)
removeAtPositionInExtendedExamples // beginDefinition;

removeAtPositionInExtendedExamples[ cells_List, sectionTitle_String, position_Integer, subsection_ ] :=
    With[ { st = sectionTitle, pos = position },
        Replace[
            cells,
            Cell[ CellGroupData[ groupCells_List, state_ ] ] /;
                MatchQ[ First @ groupCells, Cell[ _, "ExtendedExamplesSection", ___ ] ] :>
                    Cell[ CellGroupData[
                        removeInExtendedSectionAtPosition[ groupCells, st, pos ],
                        state
                    ] ],
            { 1 }
        ]
    ];

removeAtPositionInExtendedExamples // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeInExtendedSectionAtPosition*)
removeInExtendedSectionAtPosition // beginDefinition;

removeInExtendedSectionAtPosition[ groupCells_List, sectionTitle_String, position_Integer ] := Enclose[
    Catch @ Module[ { sectionIndex, sectionEndIndex, sectionContent, groups, removedContent, newSectionContent },

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
        sectionContent = Take[ groupCells, { sectionIndex + 1, sectionEndIndex - 1 } ];
        groups = splitIntoExampleGroups @ sectionContent;
        removedContent = removeExampleGroupAtList[ groups, position ];

        newSectionContent = Flatten @ {
            Take[ groupCells, sectionIndex ],
            removedContent,
            Drop[ groupCells, sectionEndIndex - 1 ]
        };

        newSectionContent
    ],
    throwInternalFailure
];

removeInExtendedSectionAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeExampleGroupAtPosition*)
removeExampleGroupAtPosition // beginDefinition;

removeExampleGroupAtPosition[ groupCells_List, position_Integer ] :=
    Module[ { header, content, groups, removedGroups },
        header = First @ groupCells;
        content = Rest @ groupCells;
        groups = splitIntoExampleGroups @ content;
        removedGroups = removeExampleGroupAtList[ groups, position ];
        Join[ { header }, removedGroups ]
    ];

removeExampleGroupAtPosition // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeExampleGroupAtList*)
removeExampleGroupAtList // beginDefinition;

removeExampleGroupAtList[ groups_List, position_Integer ] :=
    Catch @ Module[ { pos, remaining },
        (* Normalize position using 1-indexed with negative support *)
        pos = normalizeElementPosition[ position, Length @ groups ];

        If[ Length @ groups === 0,
            Throw @ { }
        ];

        remaining = Delete[ groups, pos ];

        (* Rejoin with delimiters *)
        If[ Length @ remaining === 0,
            { },
            Flatten @ Riffle[ remaining, { { exampleDelimiterCell[ ] } } ]
        ]
    ];

removeExampleGroupAtList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setExamplesInNotebook*)
setExamplesInNotebook // beginDefinition;

setExamplesInNotebook[ Notebook[ cells_List, opts___ ], section_String, content_String, subsection_ ] := Enclose[
    Module[ { context, newExampleCells, clearedCells, newCells, generatedMarkdown },

        context = ConfirmBy[ extractContext[ cells, { opts } ], StringQ, "Context" ];

        (* Generate new example cells from content *)
        newExampleCells = ConfirmMatch[ generateExampleCells[ context, content ], { ___Cell }, "ExampleCells" ];

        (* Clear existing examples in section *)
        clearedCells = clearExampleCellsInSection[ cells, section, subsection ];

        (* Add new examples *)
        newCells = ConfirmMatch[
            insertExampleCellsInSection[ clearedCells, section, newExampleCells, "append", subsection ],
            { __Cell },
            "NewCells"
        ];

        generatedMarkdown = ConfirmBy[ cellsToMarkdown @ newExampleCells, StringQ, "GeneratedMarkdown" ];

        { Notebook[ newCells, opts ], generatedMarkdown }
    ],
    throwInternalFailure
];

setExamplesInNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];