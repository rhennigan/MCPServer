(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`TOML`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Reading TOML*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readTOMLFile*)
readTOMLFile // beginDefinition;

readTOMLFile[ file_ ] := Enclose[
    Module[ { path, content, lines, parsed },
        path = ConfirmBy[ ExpandFileName @ file, StringQ, "Path" ];

        If[ ! FileExistsQ @ path,
            Throw[
                <|
                    "Data"          -> <| |>,
                    "Lines"         -> { },
                    "SectionRanges" -> <| |>
                |>,
                $tomlTag
            ]
        ];

        content = ReadString @ path;

        (* Handle empty file or EndOfFile *)
        If[ content === EndOfFile || content === "",
            Throw[
                <|
                    "Data"          -> <| |>,
                    "Lines"         -> { },
                    "SectionRanges" -> <| |>
                |>,
                $tomlTag
            ]
        ];

        lines = ConfirmMatch[ StringSplit[ content, "\n" ], { ___String }, "Lines" ];
        parsed = ConfirmBy[ parseTOMLLines @ lines, AssociationQ, "Parsed" ];
        parsed
    ] ~Catch~ $tomlTag,
    throwInternalFailure
];

readTOMLFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseTOMLLines*)
parseTOMLLines // beginDefinition;

parseTOMLLines[ lines: { ___String } ] := Enclose[
    Module[ { data, sectionRanges, currentSection, startLine, i, line, stripped, sectionName },

        data = <| |>;
        sectionRanges = <| |>;
        currentSection = None;
        startLine = 1;

        For[ i = 1, i <= Length @ lines, i++,
            line = lines[[ i ]];
            stripped = StringTrim @ line;

            (* Skip empty lines and comments *)
            If[ stripped === "" || StringStartsQ[ stripped, "#" ],
                Continue[ ]
            ];

            (* Check for section header *)
            If[ StringMatchQ[ stripped, "[" ~~ __ ~~ "]" ],
                (* Close previous section range *)
                If[ currentSection =!= None,
                    sectionRanges[ currentSection ] = { startLine, i - 1 }
                ];

                sectionName = StringTrim @ StringTake[ stripped, { 2, -2 } ];
                currentSection = sectionName;
                startLine = i;

                (* Initialize nested association path *)
                data = setNestedKey[ data, parseSectionPath @ sectionName, <| |> ];
                Continue[ ]
            ];

            (* Parse key-value pair *)
            If[ currentSection =!= None && StringContainsQ[ stripped, "=" ],
                data = parseAndSetKeyValue[ data, currentSection, stripped ]
            ]
        ];

        (* Close final section range *)
        If[ currentSection =!= None,
            sectionRanges[ currentSection ] = { startLine, Length @ lines }
        ];

        <|
            "Data"          -> data,
            "Lines"         -> lines,
            "SectionRanges" -> sectionRanges
        |>
    ],
    throwInternalFailure
];

parseTOMLLines // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parseSectionPath*)
parseSectionPath // beginDefinition;

parseSectionPath[ section_String ] :=
    StringTrim /@ StringSplit[ section, "." ] /. s_String :> unquoteTOMLKey @ s;

parseSectionPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*unquoteTOMLKey*)
unquoteTOMLKey // beginDefinition;
unquoteTOMLKey[ s_String ] /; StringMatchQ[ s, "\"" ~~ ___ ~~ "\"" ] := StringTake[ s, { 2, -2 } ];
unquoteTOMLKey[ s_String ] := s;
unquoteTOMLKey // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*setNestedKey*)
(* Functional version that returns the modified association *)
setNestedKey // beginDefinition;

setNestedKey[ data_Association, { key_String }, value_ ] :=
    If[ ! KeyExistsQ[ data, key ] || ! AssociationQ @ data[ key ],
        <| data, key -> value |>,
        data
    ];

setNestedKey[ data_Association, { first_String, rest__String }, value_ ] :=
    <| data, first -> setNestedKey[ Lookup[ data, first, <| |> ], { rest }, value ] |>;

setNestedKey[ data_, _, _ ] := data;

setNestedKey // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parseAndSetKeyValue*)
(* Returns the modified data association *)
parseAndSetKeyValue // beginDefinition;

parseAndSetKeyValue[ data_Association, section_String, line_String ] := Enclose[
    Module[ { eqPos, key, valueStr, value, path },
        eqPos = First @ StringPosition[ line, "=", 1 ];
        key = StringTrim @ StringTake[ line, eqPos[[ 1 ]] - 1 ];
        valueStr = StringTrim @ StringDrop[ line, eqPos[[ 2 ]] ];
        value = ConfirmMatch[ parseTOMLValue @ valueStr, Except[ $Failed ], "Value" ];
        path = Append[ parseSectionPath @ section, unquoteTOMLKey @ key ];
        setNestedValue[ data, path, value ]
    ],
    throwInternalFailure
];

parseAndSetKeyValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*setNestedValue*)
(* Functional version that returns the modified association *)
setNestedValue // beginDefinition;

setNestedValue[ data_Association, { key_String }, value_ ] :=
    <| data, key -> value |>;

setNestedValue[ data_Association, { first_String, rest__String }, value_ ] :=
    <| data, first -> setNestedValue[ Lookup[ data, first, <| |> ], { rest }, value ] |>;

setNestedValue[ data_, _, _ ] := data;

setNestedValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseTOMLValue*)
parseTOMLValue // beginDefinition;

(* String value *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, "\"" ~~ ___ ~~ "\"" ] :=
    StringReplace[
        StringTake[ s, { 2, -2 } ],
        {
            "\\\"" -> "\"",
            "\\\\" -> "\\",
            "\\n"  -> "\n",
            "\\t"  -> "\t",
            "\\r"  -> "\r"
        }
    ];

(* Boolean values *)
parseTOMLValue[ "true"  ] := True;
parseTOMLValue[ "false" ] := False;

(* Integer value *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, ("-"|"+"|"")~~DigitCharacter.. ] :=
    ToExpression @ s;

(* Float value *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, ("-"|"+"|"")~~DigitCharacter..~~"."~~DigitCharacter.. ] :=
    ToExpression @ s;

(* Array value *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, "[" ~~ ___ ~~ "]" ] :=
    parseTOMLArray @ s;

(* Inline table value *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, "{" ~~ ___ ~~ "}" ] :=
    parseTOMLInlineTable @ s;

(* Fallback - return as string *)
parseTOMLValue[ s_String ] := s;

parseTOMLValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parseTOMLArray*)
parseTOMLArray // beginDefinition;

parseTOMLArray[ s_String ] := Enclose[
    Module[ { inner, elements },
        inner = StringTrim @ StringTake[ s, { 2, -2 } ];
        If[ inner === "", Return[ { }, Module ] ];
        elements = splitTOMLElements[ inner, "," ];
        ConfirmMatch[ parseTOMLValue /@ elements, { ___? validTOMLValueQ }, "Elements" ]
    ],
    throwInternalFailure
];

parseTOMLArray // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validTOMLValueQ*)
validTOMLValueQ // beginDefinition;
validTOMLValueQ[ _String | _Integer | _Real | True | False | _List | _Association ] := True;
validTOMLValueQ[ _ ] := False;
validTOMLValueQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*splitTOMLElements*)
splitTOMLElements // beginDefinition;

splitTOMLElements[ s_String, sep_String ] :=
    Module[ { result, current, depth, inString, i, char },
        result = { };
        current = "";
        depth = 0;
        inString = False;

        For[ i = 1, i <= StringLength @ s, i++,
            char = StringTake[ s, { i, i } ];

            (* Handle string literals *)
            If[ char === "\"" && (i === 1 || StringTake[ s, { i - 1, i - 1 } ] =!= "\\"),
                inString = ! inString
            ];

            If[ ! inString,
                Switch[ char,
                    "[" | "{", depth++,
                    "]" | "}", depth--
                ];

                If[ char === sep && depth === 0,
                    AppendTo[ result, StringTrim @ current ];
                    current = "";
                    Continue[ ]
                ]
            ];

            current = current <> char
        ];

        If[ StringTrim @ current =!= "",
            AppendTo[ result, StringTrim @ current ]
        ];

        result
    ];

splitTOMLElements // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parseTOMLInlineTable*)
parseTOMLInlineTable // beginDefinition;

parseTOMLInlineTable[ s_String ] := Enclose[
    Module[ { inner, pairs, result },
        inner = StringTrim @ StringTake[ s, { 2, -2 } ];
        If[ inner === "", Return[ <| |>, Module ] ];
        pairs = splitTOMLElements[ inner, "," ];
        result = <| |>;
        Do[
            Module[ { eqPos, key, valueStr },
                eqPos = First @ StringPosition[ pair, "=", 1 ];
                key = unquoteTOMLKey @ StringTrim @ StringTake[ pair, eqPos[[ 1 ]] - 1 ];
                valueStr = StringTrim @ StringDrop[ pair, eqPos[[ 2 ]] ];
                result[ key ] = ConfirmMatch[ parseTOMLValue @ valueStr, Except[ $Failed ], "Value" ]
            ],
            { pair, pairs }
        ];
        result
    ],
    throwInternalFailure
];

parseTOMLInlineTable // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Writing TOML*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeTOMLFile*)
writeTOMLFile // beginDefinition;

writeTOMLFile[ file_, newData_Association, existingTOML_Association ] := Enclose[
    Module[ { path, existingLines, existingRanges, mcpSection, newLines, outputLines },
        path = ConfirmBy[ ExpandFileName @ ensureFilePath @ file, StringQ, "Path" ];

        existingLines = Lookup[ existingTOML, "Lines", { } ];
        existingRanges = Lookup[ existingTOML, "SectionRanges", <| |> ];

        (* Find all mcp_servers.* sections *)
        mcpSection = Select[ Keys @ existingRanges, StringStartsQ[ "mcp_servers" ] ];

        (* Generate new MCP server lines *)
        newLines = ConfirmMatch[ generateMCPServerLines @ newData, { ___String }, "NewLines" ];

        (* Build output by preserving non-MCP content *)
        outputLines = ConfirmMatch[
            buildOutputLines[ existingLines, existingRanges, mcpSection, newLines ],
            { ___String },
            "OutputLines"
        ];

        ConfirmBy[ writeStringToFile[ path, StringRiffle[ outputLines, "\n" ] ], FileExistsQ, "Write" ];
        File @ path
    ],
    throwInternalFailure
];

writeTOMLFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeStringToFile*)
writeStringToFile // beginDefinition;

writeStringToFile[ path_String, content_String ] :=
    Module[ { stream },
        stream = OpenWrite[ path, CharacterEncoding -> "UTF-8" ];
        WriteString[ stream, content ];
        Close @ stream;
        path
    ];

writeStringToFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*buildOutputLines*)
buildOutputLines // beginDefinition;

buildOutputLines[ existingLines_List, existingRanges_Association, mcpSections_List, newMCPLines_List ] :=
    Module[ { linesToRemove, preservedLines, insertIndex, beforeMCP, afterMCP },

        (* Find line ranges to remove (all mcp_servers.* sections) *)
        linesToRemove = Flatten @ Table[
            Range @@ existingRanges[ section ],
            { section, mcpSections }
        ];

        (* Get lines that are NOT part of MCP sections *)
        preservedLines = Delete[ existingLines, List /@ linesToRemove ];

        (* If there were MCP sections, insert new ones at the first MCP section location *)
        If[ mcpSections =!= { },
            insertIndex = Min[ existingRanges[ # ][[ 1 ]] & /@ mcpSections ];
            beforeMCP = Take[ existingLines, insertIndex - 1 ];
            afterMCP = preservedLines[[ insertIndex ;; ]];

            (* Add blank line before MCP section if needed *)
            If[ beforeMCP =!= { } && Last @ beforeMCP =!= "",
                beforeMCP = Append[ beforeMCP, "" ]
            ];

            Join[ beforeMCP, newMCPLines, If[ afterMCP =!= { }, { "" }, { } ], afterMCP ]
            ,
            (* No existing MCP sections - append at end *)
            If[ preservedLines =!= { } && Last @ preservedLines =!= "",
                Join[ preservedLines, { "" }, newMCPLines ],
                Join[ preservedLines, newMCPLines ]
            ]
        ]
    ];

buildOutputLines // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*generateMCPServerLines*)
generateMCPServerLines // beginDefinition;

generateMCPServerLines[ data_Association ] := Enclose[
    Module[ { mcpServers, lines },
        mcpServers = Lookup[ data, "mcp_servers", <| |> ];
        If[ ! AssociationQ @ mcpServers || mcpServers === <| |>,
            Return[ { }, Module ]
        ];

        lines = Flatten @ KeyValueMap[
            Function[ { serverName, serverConfig },
                ConfirmMatch[
                    formatMCPServerSection[ serverName, serverConfig ],
                    { __String },
                    "ServerSection"
                ]
            ],
            mcpServers
        ];
        lines
    ],
    throwInternalFailure
];

generateMCPServerLines // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatMCPServerSection*)
formatMCPServerSection // beginDefinition;

formatMCPServerSection[ serverName_String, config_Association ] := Enclose[
    Module[ { header, lines },
        header = ConfirmBy[ formatSectionHeader[ "mcp_servers", serverName ], StringQ, "Header" ];
        lines = { header };

        (* Add command *)
        If[ KeyExistsQ[ config, "command" ],
            AppendTo[ lines, "command = " <> formatTOMLValue @ config[ "command" ] ]
        ];

        (* Add args *)
        If[ KeyExistsQ[ config, "args" ],
            AppendTo[ lines, "args = " <> formatTOMLValue @ config[ "args" ] ]
        ];

        (* Add env as inline table *)
        If[ KeyExistsQ[ config, "env" ] && AssociationQ @ config[ "env" ] && Length @ config[ "env" ] > 0,
            AppendTo[ lines, "env = " <> formatTOMLValue @ config[ "env" ] ]
        ];

        (* Add enabled *)
        If[ KeyExistsQ[ config, "enabled" ],
            AppendTo[ lines, "enabled = " <> formatTOMLValue @ config[ "enabled" ] ]
        ];

        lines
    ],
    throwInternalFailure
];

formatMCPServerSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatSectionHeader*)
formatSectionHeader // beginDefinition;

formatSectionHeader[ prefix_String, name_String ] :=
    If[ StringMatchQ[ name, LetterCharacter ~~ (WordCharacter | "-" | "_")... ],
        "[" <> prefix <> "." <> name <> "]",
        "[" <> prefix <> ".\"" <> escapeForTOML @ name <> "\"]"
    ];

formatSectionHeader // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatTOMLValue*)
formatTOMLValue // beginDefinition;

(* String *)
formatTOMLValue[ s_String ] := "\"" <> escapeForTOML @ s <> "\"";

(* Boolean *)
formatTOMLValue[ True  ] := "true";
formatTOMLValue[ False ] := "false";

(* Integer *)
formatTOMLValue[ n_Integer ] := ToString @ n;

(* Real *)
formatTOMLValue[ r_Real ] := ToString @ r;

(* List/Array *)
formatTOMLValue[ list_List ] :=
    "[" <> StringRiffle[ formatTOMLValue /@ list, ", " ] <> "]";

(* Association/Inline Table *)
formatTOMLValue[ assoc_Association ] :=
    "{ " <> StringRiffle[
        KeyValueMap[
            formatTOMLKeyName[ #1 ] <> " = " <> formatTOMLValue @ #2 &,
            assoc
        ],
        ", "
    ] <> " }";

formatTOMLValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatTOMLKeyName*)
formatTOMLKeyName // beginDefinition;

formatTOMLKeyName[ key_String ] :=
    If[ StringMatchQ[ key, LetterCharacter ~~ (WordCharacter | "-" | "_")... ],
        key,
        "\"" <> escapeForTOML @ key <> "\""
    ];

formatTOMLKeyName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*escapeForTOML*)
escapeForTOML // beginDefinition;

escapeForTOML[ s_String ] :=
    StringReplace[ s, {
        "\\" -> "\\\\",
        "\"" -> "\\\"",
        "\n" -> "\\n",
        "\t" -> "\\t",
        "\r" -> "\\r"
    } ];

escapeForTOML // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Updating TOML Data*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*setMCPServer*)
setMCPServer // beginDefinition;

setMCPServer[ tomlData_Association, serverName_String, serverConfig_Association ] :=
    Module[ { data },
        data = Lookup[ tomlData, "Data", <| |> ];
        If[ ! KeyExistsQ[ data, "mcp_servers" ],
            data[ "mcp_servers" ] = <| |>
        ];
        data[ "mcp_servers", serverName ] = serverConfig;
        <| tomlData, "Data" -> data |>
    ];

setMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*removeMCPServer*)
removeMCPServer // beginDefinition;

removeMCPServer[ tomlData_Association, serverName_String ] :=
    Module[ { data },
        data = Lookup[ tomlData, "Data", <| |> ];
        If[ KeyExistsQ[ data, "mcp_servers" ] && KeyExistsQ[ data[ "mcp_servers" ], serverName ],
            KeyDropFrom[ data[ "mcp_servers" ], serverName ]
        ];
        <| tomlData, "Data" -> data |>
    ];

removeMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getMCPServers*)
getMCPServers // beginDefinition;

getMCPServers[ tomlData_Association ] :=
    Lookup[ Lookup[ tomlData, "Data", <| |> ], "mcp_servers", <| |> ];

getMCPServers // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
