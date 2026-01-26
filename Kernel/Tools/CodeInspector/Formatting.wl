(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`CodeInspector`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "CodeInspector`" -> "ci`"   ];
Needs[ "CodeParser`"    -> "cp`"   ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$contextLines = 1;  (* Number of lines of context before/after issue *)

$suppressionHint = "
---

**Tip:** To suppress specific issues, wrap code with:
```wl
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::{Tag}:: *)
...
(* :!CodeAnalysis::EndBlock:: *)
```
";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*inspectionsToMarkdown*)
inspectionsToMarkdown // beginDefinition;

(* Code string or single file inspection - list of InspectionObjects *)
inspectionsToMarkdown[ inspections_List, source_, opts_Association ] := Enclose[
    Module[ { limit, truncated, displayInspections, summary, issues, truncationNotice },
        limit = Lookup[ opts, "limit", 100 ];

        (* Check if we need to truncate *)
        truncated = Length @ inspections > limit;
        displayInspections = Take[ inspections, UpTo @ limit ];

        If[ displayInspections === { },
            (* No issues found *)
            noIssuesMarkdown[ source, opts ],
            (* Format issues *)
            summary = ConfirmBy[ summaryTable @ inspections, StringQ, "Summary" ];
            issues = ConfirmBy[ formatIssuesList[ displayInspections, source ], StringQ, "Issues" ];
            truncationNotice = If[ truncated,
                StringJoin[
                    "\n\n---\n\n*Showing ",
                    ToString @ limit, " of ",
                    ToString @ Length @ inspections,
                    " issues. Adjust the `limit` parameter to see more.*"
                ],
                ""
            ];
            StringJoin[
                "# Code Inspection Results\n\n",
                formatSourceHeader @ source,
                summary,
                "\n\n",
                issues,
                truncationNotice,
                $suppressionHint
            ]
        ]
    ],
    throwInternalFailure
];

(* Directory inspection - Association of file -> inspections *)
inspectionsToMarkdown[ resultsByFile_Association, dir_String, opts_Association ] /; DirectoryQ @ dir := Enclose[
    Module[ { limit, allInspections, totalCount, truncated, summary, fileCount, header, fileSections, truncationNotice },
        limit = Lookup[ opts, "limit", 100 ];

        (* Flatten all inspections for counting *)
        allInspections = Flatten @ Values @ resultsByFile;
        totalCount = Length @ allInspections;

        If[ totalCount === 0,
            (* No issues found in any file *)
            noIssuesMarkdown[ dir, opts ],
            (* Format by file *)
            truncated = totalCount > limit;
            summary = ConfirmBy[ summaryTable @ allInspections, StringQ, "Summary" ];
            fileCount = Length @ Select[ resultsByFile, Length @ # > 0 & ];
            header = StringJoin[
                "# Code Inspection Results\n\n",
                "**Directory:** `", dir, "`\n",
                "**Files inspected:** ", ToString @ Length @ resultsByFile, "\n",
                "**Files with issues:** ", ToString @ fileCount, "\n\n",
                summary, "\n\n",
                "## Issues by File\n"
            ];
            fileSections = ConfirmBy[ formatFilesSections[ resultsByFile, limit ], StringQ, "FileSections" ];
            truncationNotice = If[ truncated,
                StringJoin[
                    "\n\n---\n\n*Showing ",
                    ToString @ Min[ limit, totalCount ],
                    " of ",
                    ToString @ totalCount,
                    " issues. Adjust the `limit` parameter to see more.*"
                ],
                ""
            ];
            StringJoin[ header, fileSections, truncationNotice, $suppressionHint ]
        ]
    ],
    throwInternalFailure
];

inspectionsToMarkdown // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatSourceHeader*)
formatSourceHeader // beginDefinition;
formatSourceHeader[ _String ] := "";  (* Code string - no header *)
formatSourceHeader[ File[ path_String ] ] := "**File:** `" <> path <> "`\n\n";
formatSourceHeader[ _ ] := "";
formatSourceHeader // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*noIssuesMarkdown*)
noIssuesMarkdown // beginDefinition;

noIssuesMarkdown[ source_, opts_Association ] :=
    Module[ { confidenceLevel, severityExclusions, tagExclusions },
        confidenceLevel    = Lookup[ opts, "confidenceLevel", 0.75 ];
        severityExclusions = Lookup[ opts, "severityExclusions", { } ];
        tagExclusions      = Lookup[ opts, "tagExclusions", { } ];

        StringJoin[
            "# Code Inspection Results\n\n",
            formatSourceHeader @ source,
            "No issues found matching the specified criteria.\n\n",
            "**Settings:**\n",
            "- Confidence Level: ", ToString @ confidenceLevel, "\n",
            "- Severity Exclusions: ", formatExclusionsList @ severityExclusions, "\n",
            "- Tag Exclusions: ", formatExclusionsList @ tagExclusions
        ]
    ];

noIssuesMarkdown // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatExclusionsList*)
formatExclusionsList // beginDefinition;
formatExclusionsList[ { } ] := "(none)";
formatExclusionsList[ list_List ] := StringRiffle[ list, ", " ];
formatExclusionsList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*summaryTable*)
summaryTable // beginDefinition;

summaryTable[ inspections_List ] := Enclose[
    Module[ { severityCounts, orderedSeverities, rows, total },
        (* Count issues by severity *)
        severityCounts = Counts @ Map[ inspectionSeverity, inspections ];

        (* Order severities from most to least severe *)
        orderedSeverities = Select[
            { "Fatal", "Error", "Warning", "Scoping", "Remark", "Formatting" },
            KeyExistsQ[ severityCounts, # ] &
        ];

        (* Build table rows *)
        rows = Map[
            Function[ sev, "| " <> sev <> " | " <> ToString @ severityCounts @ sev <> " |" ],
            orderedSeverities
        ];

        total = Length @ inspections;

        StringJoin[
            "## Summary\n\n",
            "| Severity | Count |\n",
            "|----------|-------|\n",
            StringRiffle[ rows, "\n" ], "\n",
            "| **Total** | **", ToString @ total, "** |"
        ]
    ],
    throwInternalFailure
];

summaryTable // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectionSeverity*)
inspectionSeverity // beginDefinition;
inspectionSeverity[ ci`InspectionObject[ _, _, severity_String, _ ] ] := severity;
inspectionSeverity[ _ ] := "Unknown";
inspectionSeverity // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatIssuesList*)
formatIssuesList // beginDefinition;

formatIssuesList[ inspections_List, source_ ] :=
    Module[ { cachedContent, formatted },
        cachedContent = preReadSource @ source;
        formatted = MapIndexed[
            Function[ { insp, idx }, formatInspection[ insp, First @ idx, source, cachedContent ] ],
            inspections
        ];
        StringJoin[ "## Issues\n\n", StringRiffle[ formatted, "\n\n---\n\n" ] ]
    ];

formatIssuesList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*preReadSource*)
preReadSource // beginDefinition;
preReadSource[ File[ path_String ] ] := Quiet @ ReadString @ path;
preReadSource[ _ ] := None;
preReadSource // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatFilesSections*)
formatFilesSections // beginDefinition;

formatFilesSections[ resultsByFile_Association, limit_Integer ] :=
    Module[ { remaining, sections },
        remaining = limit;
        sections = KeyValueMap[
            Function[ { file, inspections },
                If[ remaining <= 0 || inspections === { },
                    Nothing,
                    Module[ { toShow, section },
                        toShow = Take[ inspections, UpTo @ remaining ];
                        remaining -= Length @ toShow;
                        section = formatFileSection[ file, toShow, Length @ inspections ];
                        section
                    ]
                ]
            ],
            resultsByFile
        ];
        StringRiffle[ sections, "\n\n" ]
    ];

formatFilesSections // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatFileSection*)
formatFileSection // beginDefinition;

formatFileSection[ file_String, inspections_List, totalInFile_Integer ] :=
    Module[ { fileName, cachedContent, header, formatted },
        fileName = FileNameTake @ file;
        cachedContent = Quiet @ ReadString @ file;
        header = StringJoin[
            "### ", fileName, " (", ToString @ totalInFile, " issue", If[ totalInFile === 1, "", "s" ], ")"
        ];
        formatted = MapIndexed[
            Function[ { insp, idx }, formatInspectionForFile[ insp, First @ idx, file, cachedContent ] ],
            inspections
        ];
        StringJoin[ header, "\n\n", StringRiffle[ formatted, "\n\n" ] ]
    ];

formatFileSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatInspectionForFile*)
formatInspectionForFile // beginDefinition;

formatInspectionForFile[ inspection_ci`InspectionObject, index_Integer, file_String, cachedContent_: None ] :=
    formatInspection[ inspection, index, File @ file, cachedContent ];

formatInspectionForFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatInspection*)
formatInspection // beginDefinition;

formatInspection[
    ci`InspectionObject[ tag_String, description_String, severity_String, data_Association ],
    index_Integer,
    source_,
    cachedContent_: None
] :=
    Module[ { confidence, location, locationStr, codeSnippet, codeActions, actionStr, displayTag },
        (* Extract confidence level *)
        confidence = Lookup[ data, ConfidenceLevel, 1.0 ];

        (* Extract source location *)
        location = Lookup[ data, cp`Source, Missing[ "NotAvailable" ] ];

        (* Format location *)
        locationStr = formatLocation[ source, location ];

        (* Extract code snippet *)
        codeSnippet = extractCodeSnippet[ source, location, $contextLines, cachedContent ];

        (* Extract and format CodeActions if present *)
        codeActions = Lookup[ data, cp`CodeActions, { } ];
        actionStr = formatCodeActions @ codeActions;

        (* Format tag with argument if present *)
        displayTag = If[ StringQ @ data[ "Argument" ],
            tag <> "::" <> data[ "Argument" ],
            tag
        ];

        (* Build the markdown *)
        StringJoin[
            "### Issue ", ToString @ index, ": ", displayTag, " (", severity, ", ", formatPercent @ confidence, ")\n\n",
            "**Location:** ", locationStr, "\n\n",
            "**Description:** ", description, "\n\n",
            codeSnippet,
            actionStr
        ]
    ];

(* Handle malformed InspectionObject *)
formatInspection[ insp_ci`InspectionObject, index_Integer, _, _: None ] :=
    StringJoin[ "### Issue ", ToString @ index, ": Malformed inspection object" ];

formatInspection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatPercent*)
formatPercent // beginDefinition;
formatPercent[ n_? NumericQ ] := ToString @ Round[ 100 * n ] <> "%";
formatPercent[ _ ] := "N/A";
formatPercent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatLocation*)
formatLocation // beginDefinition;

(* Code string with line/column *)
formatLocation[ _String, { { line_Integer, col_Integer }, { endLine_Integer, endCol_Integer } } ] :=
    StringJoin[
        "Line ", ToString @ line, ", Column ", ToString @ col,
        If[ line === endLine && col === endCol,
            "",
            " - Line " <> ToString @ endLine <> ", Column " <> ToString @ endCol
        ]
    ];

(* File with line/column *)
formatLocation[ File[ path_String ], { { line_Integer, col_Integer }, _ } ] :=
    StringJoin[ "`", FileNameTake @ path, ":", ToString @ line, ":", ToString @ col, "`" ];

(* File with only start position *)
formatLocation[ File[ path_String ], { { line_Integer, col_Integer } } ] :=
    StringJoin[ "`", FileNameTake @ path, ":", ToString @ line, ":", ToString @ col, "`" ];

(* Missing or unavailable location *)
formatLocation[ _, _Missing ] := "Unknown";
formatLocation[ _, _ ] := "Unknown";

formatLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractCodeSnippet*)
extractCodeSnippet // beginDefinition;

(* Code string with location *)
extractCodeSnippet[
    code_String,
    { { startLine_Integer, startCol_Integer }, { endLine_Integer, endCol_Integer } },
    contextLines_Integer,
    _: None
] :=
    Module[ { lines, totalLines, firstLine, lastLine, snippetLines, numbered },
        lines = StringSplit[ code, "\n" ];
        totalLines = Length @ lines;

        (* Calculate range with context *)
        firstLine = Max[ 1, startLine - contextLines ];
        lastLine = Min[ totalLines, endLine + contextLines ];

        (* Extract relevant lines *)
        snippetLines = Take[ lines, { firstLine, lastLine } ];

        (* Add line numbers *)
        numbered = MapIndexed[
            Function[ { line, idx },
                Module[ { lineNum, prefix },
                    lineNum = firstLine + First @ idx - 1;
                    prefix = StringPadLeft[ ToString @ lineNum, 4 ] <> " | ";
                    (* Mark the issue line *)
                    If[ lineNum >= startLine && lineNum <= endLine,
                        prefix <> line <> "  (* <- issue here *)",
                        prefix <> line
                    ]
                ]
            ],
            snippetLines
        ];

        StringJoin[
            "**Code:**\n",
            "```wl\n",
            StringRiffle[ numbered, "\n" ], "\n",
            "```\n"
        ]
    ];

(* File with location - use cached content if available *)
extractCodeSnippet[
    File[ path_String ],
    location: { { startLine_Integer, _ }, { endLine_Integer, _ } },
    contextLines_Integer,
    cachedContent_: None
] :=
    Module[ { content },
        content = If[ StringQ @ cachedContent, cachedContent, Quiet @ ReadString @ path ];
        If[ StringQ @ content,
            extractCodeSnippet[ content, location, contextLines, None ],
            "**Code:** (Unable to read file)\n"
        ]
    ];

(* Missing location *)
extractCodeSnippet[ _, _Missing, _, _: None ] := "";
extractCodeSnippet[ _, _, _, _: None ] := "";

extractCodeSnippet // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
