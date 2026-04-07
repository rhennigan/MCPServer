(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`YAML`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Source label*)
(* Threaded through the parser via Block so that InvalidYAMLFormat failures
   can report the resolved file path (when called via importYAML) instead of
   the generic "<input>" placeholder. *)
$yamlSource = "<input>";

(* Threaded through the parser via Block so that parseScalar (which has no
   line argument of its own and can be reached recursively from flow-construct
   helpers) can attribute InvalidYAMLFormat failures to the originating line. *)
$yamlLine = 0;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Reading YAML*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*importYAML*)
importYAML // beginDefinition;

importYAML[ file_ ] := Enclose[
    Catch @ Module[ { path, content },
        path = ConfirmBy[ ExpandFileName @ file, StringQ, "Path" ];
        If[ ! FileExistsQ @ path, Throw @ <| |> ];
        content = ReadString @ path;
        If[ content === EndOfFile || content === "", Throw @ <| |> ];
        If[ ! StringQ @ content, Throw @ <| |> ];
        Block[ { $yamlSource = path },
            ConfirmMatch[ importYAMLString @ content, _Association | _List | <| |>, "Parsed" ]
        ]
    ],
    throwInternalFailure
];

importYAML // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*importYAMLString*)
importYAMLString // beginDefinition;

importYAMLString[ s_String ] := Enclose[
    Catch @ Module[ { lines, value, finalPos },
        lines = ConfirmMatch[ preprocessYAMLLines @ s, { ___Association }, "Lines" ];
        If[ lines === { }, Throw @ <| |> ];
        { value, finalPos } = ConfirmMatch[
            parseYAMLBlock[ lines, 1, 0 ],
            { _, _Integer },
            "Block"
        ];
        (* parseYAMLBlock can stop early on a sibling construct at the same
           indent (e.g. a mapping followed by a top-level sequence).  Anything
           left over is content we silently dropped, which would cause
           round-trip writes to lose data -- treat it as a parse error. *)
        If[ finalPos <= Length @ lines,
            throwFailure[ "InvalidYAMLFormat", $yamlSource,
                lines[[ finalPos, "Line" ]],
                "unexpected trailing content: " <> lines[[ finalPos, "Text" ]]
            ]
        ];
        Replace[ value, Null -> <| |> ]
    ],
    throwInternalFailure
];

importYAMLString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*preprocessYAMLLines*)
(* Splits the input into per-line records that include indentation, the
   comment-stripped text, and the original line number.  Lines that become empty
   after comment stripping are dropped -- the parser only ever sees content lines. *)
preprocessYAMLLines // beginDefinition;

preprocessYAMLLines[ s_String ] :=
    Module[ { rawLines, processed },
        rawLines = StringSplit[ s, "\n", All ];
        processed = Catenate @ MapIndexed[
            Function[ { rawLine, idx },
                Module[ { line, withoutComment, indent, text },
                    line = StringDelete[ rawLine, "\r" ~~ EndOfString ];
                    withoutComment = stripCommentOutsideQuotes @ line;
                    indent = countLeadingSpaces @ withoutComment;
                    text = StringDelete[
                        StringDrop[ withoutComment, indent ],
                        Whitespace.. ~~ EndOfString
                    ];
                    If[ text === "",
                        { },
                        splitInlineSequenceMapping[ indent, text, First @ idx ]
                    ]
                ]
            ],
            rawLines
        ];
        processed
    ];

preprocessYAMLLines // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*splitInlineSequenceMapping*)
(* If a line is "- key: value", split it into a "-" line at the original indent
   plus a "key: value" line at indent+2.  This lets the existing block parser
   handle inline sequence-mapping items uniformly via the explicit "-" form. *)
splitInlineSequenceMapping // beginDefinition;

splitInlineSequenceMapping[ indent_Integer, text_String, lineNum_Integer ] :=
    Module[ { rest },
        If[ ! StringStartsQ[ text, "- " ],
            { <| "Indent" -> indent, "Text" -> text, "Line" -> lineNum |> },
            rest = StringTrim @ StringDrop[ text, 2 ];
            If[ inlineMappingValueQ @ rest,
                {
                    <| "Indent" -> indent,     "Text" -> "-",  "Line" -> lineNum |>,
                    <| "Indent" -> indent + 2, "Text" -> rest, "Line" -> lineNum |>
                },
                { <| "Indent" -> indent, "Text" -> text, "Line" -> lineNum |> }
            ]
        ]
    ];

splitInlineSequenceMapping // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*inlineMappingValueQ*)
(* True when the text after "- " on a sequence line looks like a mapping line
   ("key: value") that should start an inline mapping rather than be parsed as
   a scalar.  Quoted strings, flow constructs, and nested sequences (leading
   "-") all stay as scalars. *)
inlineMappingValueQ // beginDefinition;
inlineMappingValueQ[ "" ] := False;
inlineMappingValueQ[ text_String ] :=
    Which[
        StringStartsQ[ text, "\"" | "'" | "[" | "{" | "-" | "?" ], False,
        IntegerQ @ findUnquotedColon @ text, True,
        True, False
    ];
inlineMappingValueQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*countLeadingSpaces*)
countLeadingSpaces // beginDefinition;
countLeadingSpaces[ s_String ] := Length @ TakeWhile[ Characters @ s, # === " " & ];
countLeadingSpaces // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stripCommentOutsideQuotes*)
(* Removes any "# ..." trailing comment that lives outside of single- or double-quoted
   spans, leaving the rest of the line untouched.  Backslash escapes inside double
   quotes are honored so that the closing quote isn't misidentified. *)
stripCommentOutsideQuotes // beginDefinition;

stripCommentOutsideQuotes[ s_String ] := Enclose[
    Module[ { chars, n, i, ch, prev, inSingle, inDouble, out },
        chars    = Characters @ s;
        n        = Length @ chars;
        out      = Internal`Bag[ ];
        inSingle = False;
        inDouble = False;
        prev     = "";
        i = 1;
        While[ i <= n,
            ch = chars[[ i ]];
            Which[
                inDouble && ch === "\\" && i < n,
                    Internal`StuffBag[ out, ch ];
                    Internal`StuffBag[ out, chars[[ i + 1 ]] ];
                    prev = chars[[ i + 1 ]];
                    i += 2;
                    Continue[ ],
                inDouble && ch === "\"",
                    inDouble = False;
                    Internal`StuffBag[ out, ch ],
                inDouble,
                    Internal`StuffBag[ out, ch ],
                inSingle && ch === "'",
                    inSingle = False;
                    Internal`StuffBag[ out, ch ],
                inSingle,
                    Internal`StuffBag[ out, ch ],
                ch === "\"",
                    inDouble = True;
                    Internal`StuffBag[ out, ch ],
                ch === "'",
                    inSingle = True;
                    Internal`StuffBag[ out, ch ],
                ch === "#" && (prev === "" || prev === " " || prev === "\t"),
                    Break[ ],
                True,
                    Internal`StuffBag[ out, ch ]
            ];
            prev = ch;
            i++
        ];
        StringJoin @ Internal`BagPart[ out, All ]
    ],
    throwInternalFailure
];

stripCommentOutsideQuotes // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseYAMLBlock*)
(* Dispatch a block starting at index `pos` whose lines must have indent >= minIndent.
   Returns { value, nextPos }.  The block kind (mapping vs sequence) is decided by
   the first content line: lines that begin with "- " (or are exactly "-") are
   sequences; everything else is a mapping. *)
parseYAMLBlock // beginDefinition;

parseYAMLBlock[ lines_List, pos_Integer, minIndent_Integer ] :=
    Which[
        pos > Length @ lines,
            { Null, pos },
        lines[[ pos, "Indent" ]] < minIndent,
            { Null, pos },
        sequenceLineQ @ lines[[ pos, "Text" ]],
            parseYAMLSequence[ lines, pos, lines[[ pos, "Indent" ]] ],
        True,
            parseYAMLMapping[ lines, pos, lines[[ pos, "Indent" ]] ]
    ];

parseYAMLBlock // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*sequenceLineQ*)
sequenceLineQ // beginDefinition;
sequenceLineQ[ "-" ] := True;
sequenceLineQ[ s_String ] := StringStartsQ[ s, "- " ];
sequenceLineQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseYAMLMapping*)
parseYAMLMapping // beginDefinition;

parseYAMLMapping[ lines_List, startPos_Integer, blockIndent_Integer ] := Enclose[
    Module[ { pos, result, line, text, key, valueText, value, nextPos },
        pos    = startPos;
        result = <| |>;

        While[ pos <= Length @ lines,
            line = lines[[ pos ]];

            (* Stop on dedent or sequence marker at parent indent *)
            If[ line[ "Indent" ] < blockIndent, Break[ ] ];
            If[ line[ "Indent" ] > blockIndent,
                throwFailure[ "InvalidYAMLFormat", $yamlSource, line[ "Line" ],
                    "unexpected indentation: " <> line[ "Text" ]
                ]
            ];

            text = line[ "Text" ];
            If[ sequenceLineQ @ text, Break[ ] ];

            { key, valueText } = ConfirmMatch[
                parseMappingLine[ text, line[ "Line" ] ],
                { _String, _String },
                "MappingLine"
            ];

            pos++;

            If[ valueText === "",
                (* Child block on subsequent lines, or empty value *)
                Which[
                    (* Indented child block at strictly greater indent *)
                    pos <= Length @ lines && lines[[ pos, "Indent" ]] > blockIndent,
                        { value, nextPos } = ConfirmMatch[
                            parseYAMLBlock[ lines, pos, lines[[ pos, "Indent" ]] ],
                            { _, _Integer },
                            "ChildBlock"
                        ];
                        pos = nextPos,
                    (* Compact block sequence: YAML 1.2 allows sequence items
                       to sit at the same indent as the parent mapping key,
                       e.g. the widely used GitHub Actions `steps:` layout. *)
                    pos <= Length @ lines && lines[[ pos, "Indent" ]] === blockIndent && sequenceLineQ @ lines[[ pos, "Text" ]],
                        { value, nextPos } = ConfirmMatch[
                            parseYAMLSequence[ lines, pos, blockIndent ],
                            { _, _Integer },
                            "CompactSeq"
                        ];
                        pos = nextPos,
                    True,
                        value = Null
                ],
                value = Block[ { $yamlLine = line[ "Line" ] }, parseScalar @ valueText ]
            ];

            result[ key ] = value
        ];

        { result, pos }
    ],
    throwInternalFailure
];

parseYAMLMapping // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parseMappingLine*)
(* Splits a "key: value" line into { key, valueText }.  Handles unquoted, double-
   quoted, and single-quoted keys.  Trailing whitespace on the value is stripped
   (the parent already trimmed the line). *)
parseMappingLine // beginDefinition;

parseMappingLine[ text_String, lineNum_ ] :=
    Module[ { key, valueText, colonPos },
        Which[
            (* Double-quoted key *)
            StringStartsQ[ text, "\"" ],
                Module[ { close },
                    close = findClosingQuote[ text, "\"", 2 ];
                    If[ close === Missing[ ],
                        throwFailure[ "InvalidYAMLFormat", $yamlSource, lineNum, "unterminated quoted key: " <> text ]
                    ];
                    key = unescapeDoubleQuoted @ StringTake[ text, { 2, close - 1 } ];
                    If[ close >= StringLength @ text || StringTake[ text, { close + 1, close + 1 } ] =!= ":",
                        throwFailure[ "InvalidYAMLFormat", $yamlSource, lineNum, "expected ':' after quoted key: " <> text ]
                    ];
                    valueText = StringTrim @ StringDrop[ text, close + 1 ]
                ],
            (* Single-quoted key *)
            StringStartsQ[ text, "'" ],
                Module[ { close },
                    close = findClosingQuote[ text, "'", 2 ];
                    If[ close === Missing[ ],
                        throwFailure[ "InvalidYAMLFormat", $yamlSource, lineNum, "unterminated quoted key: " <> text ]
                    ];
                    key = unescapeSingleQuoted @ StringTake[ text, { 2, close - 1 } ];
                    If[ close >= StringLength @ text || StringTake[ text, { close + 1, close + 1 } ] =!= ":",
                        throwFailure[ "InvalidYAMLFormat", $yamlSource, lineNum, "expected ':' after quoted key: " <> text ]
                    ];
                    valueText = StringTrim @ StringDrop[ text, close + 1 ]
                ],
            (* Unquoted key -- split on the first ":" not inside flow brackets *)
            True,
                colonPos = findUnquotedColon @ text;
                If[ colonPos === Missing[ ],
                    throwFailure[ "InvalidYAMLFormat", $yamlSource, lineNum, "expected ':' in mapping line: " <> text ]
                ];
                key = StringTrim @ StringTake[ text, colonPos - 1 ];
                valueText = StringTrim @ StringDrop[ text, colonPos ]
        ];
        { key, valueText }
    ];

parseMappingLine // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*findUnquotedColon*)
(* Returns the 1-based index of the first ":" outside of any quoted span or flow
   bracket, or Missing[] if none exists. *)
findUnquotedColon // beginDefinition;

findUnquotedColon[ s_String ] :=
    Catch @ Module[ { chars, n, i, ch, inSingle, inDouble, depth },
        chars    = Characters @ s;
        n        = Length @ chars;
        inSingle = False;
        inDouble = False;
        depth    = 0;
        i = 1;
        While[ i <= n,
            ch = chars[[ i ]];
            Which[
                inDouble && ch === "\\" && i < n, i += 2; Continue[ ],
                inDouble && ch === "\"", inDouble = False,
                inDouble, Null,
                inSingle && ch === "'", inSingle = False,
                inSingle, Null,
                ch === "\"", inDouble = True,
                ch === "'", inSingle = True,
                ch === "[" || ch === "{", depth++,
                ch === "]" || ch === "}", depth--,
                ch === ":" && depth === 0, Throw @ i
            ];
            i++
        ];
        Missing[ ]
    ];

findUnquotedColon // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*findClosingQuote*)
findClosingQuote // beginDefinition;

findClosingQuote[ s_String, quote_String, startIdx_Integer ] :=
    Catch @ Module[ { chars, n, i, ch },
        chars = Characters @ s;
        n     = Length @ chars;
        i     = startIdx;
        While[ i <= n,
            ch = chars[[ i ]];
            (* "\"" inside a double-quoted scalar is escaped as \" *)
            If[ quote === "\"" && ch === "\\" && i < n, i += 2; Continue[ ] ];
            (* "'" inside a single-quoted scalar is escaped as '' (the only escape) *)
            If[ quote === "'" && ch === "'" && i < n && chars[[ i + 1 ]] === "'", i += 2; Continue[ ] ];
            If[ ch === quote, Throw @ i ];
            i++
        ];
        Missing[ ]
    ];

findClosingQuote // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*findMatchingFlowClose*)
(* Returns the 1-based index of the close bracket that matches the open bracket
   at openIdx, treating quoted spans as opaque and tracking nested [/{ depth.
   Returns Missing[] if no matching close exists or the matching close has the
   wrong shape (e.g. opened with "[" but closed with "}"). *)
findMatchingFlowClose // beginDefinition;

findMatchingFlowClose[ s_String, openIdx_Integer ] :=
    Catch @ Module[ { chars, n, close, depth, inSingle, inDouble, i, ch },
        chars    = Characters @ s;
        n        = Length @ chars;
        close    = If[ chars[[ openIdx ]] === "[", "]", "}" ];
        depth    = 0;
        inSingle = False;
        inDouble = False;
        i = openIdx;
        While[ i <= n,
            ch = chars[[ i ]];
            Which[
                inDouble && ch === "\\" && i < n, i += 2; Continue[ ],
                inDouble && ch === "\"", inDouble = False,
                inDouble, Null,
                inSingle && ch === "'", inSingle = False,
                inSingle, Null,
                ch === "\"", inDouble = True,
                ch === "'", inSingle = True,
                ch === "[" || ch === "{", depth++,
                ch === "]" || ch === "}",
                    depth--;
                    If[ depth === 0,
                        Throw @ If[ ch === close, i, Missing[ ] ]
                    ]
            ];
            i++
        ];
        Missing[ ]
    ];

findMatchingFlowClose // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseYAMLSequence*)
parseYAMLSequence // beginDefinition;

parseYAMLSequence[ lines_List, startPos_Integer, blockIndent_Integer ] := Enclose[
    Module[ { pos, result, line, text, valueText, value, nextPos },
        pos    = startPos;
        result = { };

        While[ pos <= Length @ lines,
            line = lines[[ pos ]];
            If[ line[ "Indent" ] < blockIndent, Break[ ] ];
            If[ line[ "Indent" ] > blockIndent,
                throwFailure[ "InvalidYAMLFormat", $yamlSource, line[ "Line" ],
                    "unexpected indentation in sequence: " <> line[ "Text" ]
                ]
            ];
            text = line[ "Text" ];
            If[ ! sequenceLineQ @ text, Break[ ] ];

            If[ text === "-",
                pos++;
                If[ pos <= Length @ lines && lines[[ pos ]][ "Indent" ] > blockIndent,
                    { value, nextPos } = ConfirmMatch[
                        parseYAMLBlock[ lines, pos, lines[[ pos ]][ "Indent" ] ],
                        { _, _Integer },
                        "SeqChild"
                    ];
                    pos = nextPos,
                    value = Null
                ],
                valueText = StringTrim @ StringDrop[ text, 2 ];
                pos++;
                value = Block[ { $yamlLine = line[ "Line" ] }, parseScalar @ valueText ]
            ];

            AppendTo[ result, value ]
        ];

        { result, pos }
    ],
    throwInternalFailure
];

parseYAMLSequence // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseScalar*)
(* Parses a scalar token (the value text on a "key: value" line, or a flow item).
   Handles quoted strings, flow sequences, flow mappings, and YAML literals
   (true/false/null/integer/float).  Falls back to treating the value as a plain
   string. *)
parseScalar // beginDefinition;

parseScalar[ "" ] := Null;

parseScalar[ s_String ] := Enclose[
    Module[ { trimmed, len },
        trimmed = StringTrim @ s;
        len     = StringLength @ trimmed;
        Which[
            trimmed === "", Null,
            StringStartsQ[ trimmed, "\"" ],
                requireClosedQuotedScalar[ trimmed, "\"", len ];
                unescapeDoubleQuoted @ StringTake[ trimmed, { 2, -2 } ],
            StringStartsQ[ trimmed, "'" ],
                requireClosedQuotedScalar[ trimmed, "'", len ];
                unescapeSingleQuoted @ StringTake[ trimmed, { 2, -2 } ],
            StringStartsQ[ trimmed, "[" ],
                requireClosedFlowConstruct[ trimmed, "sequence", len ];
                parseFlowSequence @ trimmed,
            StringStartsQ[ trimmed, "{" ],
                requireClosedFlowConstruct[ trimmed, "mapping", len ];
                parseFlowMapping @ trimmed,
            trimmed === "true" || trimmed === "True" || trimmed === "TRUE", True,
            trimmed === "false" || trimmed === "False" || trimmed === "FALSE", False,
            trimmed === "null" || trimmed === "Null" || trimmed === "NULL" || trimmed === "~", Null,
            integerStringQ @ trimmed, ToExpression @ trimmed,
            floatStringQ @ trimmed, parseFloatString @ trimmed,
            True, trimmed
        ]
    ],
    throwInternalFailure
];

parseScalar // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*requireClosedQuotedScalar*)
(* Reject quoted scalars that have no closing quote, or that have content past
   the closing quote.  Currently $yamlLine is set by the block parsers before
   each parseScalar call, so the failure can point at the originating line. *)
requireClosedQuotedScalar // beginDefinition;

requireClosedQuotedScalar[ trimmed_String, quote_String, len_Integer ] :=
    Module[ { close, label },
        close = findClosingQuote[ trimmed, quote, 2 ];
        label = If[ quote === "\"", "double-quoted", "single-quoted" ];
        If[ close === Missing[ ],
            throwFailure[ "InvalidYAMLFormat", $yamlSource, $yamlLine,
                "unterminated " <> label <> " scalar: " <> trimmed
            ]
        ];
        If[ close =!= len,
            throwFailure[ "InvalidYAMLFormat", $yamlSource, $yamlLine,
                "unexpected content after " <> label <> " scalar: " <> trimmed
            ]
        ]
    ];

requireClosedQuotedScalar // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*requireClosedFlowConstruct*)
(* Reject flow sequences/mappings whose opening "[" or "{" has no matching close,
   has a mismatched close, or has trailing content past the close. *)
requireClosedFlowConstruct // beginDefinition;

requireClosedFlowConstruct[ trimmed_String, label_String, len_Integer ] :=
    Module[ { close },
        close = findMatchingFlowClose[ trimmed, 1 ];
        If[ close === Missing[ ],
            throwFailure[ "InvalidYAMLFormat", $yamlSource, $yamlLine,
                "unterminated flow " <> label <> ": " <> trimmed
            ]
        ];
        If[ close =!= len,
            throwFailure[ "InvalidYAMLFormat", $yamlSource, $yamlLine,
                "unexpected content after flow " <> label <> ": " <> trimmed
            ]
        ]
    ];

requireClosedFlowConstruct // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*integerStringQ / floatStringQ*)
integerStringQ // beginDefinition;
integerStringQ[ s_String ] := StringMatchQ[ s, ("-"|"+"|"") ~~ DigitCharacter.. ];
integerStringQ // endDefinition;

floatStringQ // beginDefinition;
floatStringQ[ s_String ] := StringMatchQ[ s,
    ("-"|"+"|"") ~~ Alternatives[
        DigitCharacter.. ~~ "." ~~ DigitCharacter... ~~ ((("e"|"E") ~~ ("-"|"+"|"") ~~ DigitCharacter..) | ""),
        DigitCharacter.. ~~ ("e"|"E") ~~ ("-"|"+"|"") ~~ DigitCharacter..
    ]
];
floatStringQ // endDefinition;

(* Convert a YAML-style float string to a Real.  YAML uses "e"/"E" for the
   exponent (including exponent-only forms like "1e3"); Wolfram Language uses
   "*^", so the conversion goes through a StringReplace before ToExpression.
   The final N ensures exponent-only forms whose mantissa is integer-shaped
   ("1e3" -> "1*^3" -> 1000) come back as a Real rather than an Integer. *)
parseFloatString // beginDefinition;
parseFloatString[ s_String ] := N @ ToExpression @ StringReplace[ s, ("e"|"E") -> "*^" ];
parseFloatString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*unescapeDoubleQuoted*)
unescapeDoubleQuoted // beginDefinition;

unescapeDoubleQuoted[ s_String ] :=
    StringReplace[ s, {
        "\\\\" -> "\\",
        "\\\"" -> "\"",
        "\\n"  -> "\n",
        "\\t"  -> "\t",
        "\\r"  -> "\r",
        "\\/"  -> "/"
    } ];

unescapeDoubleQuoted // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*unescapeSingleQuoted*)
(* In YAML single-quoted strings, the only escape is "''" -> "'" *)
unescapeSingleQuoted // beginDefinition;
unescapeSingleQuoted[ s_String ] := StringReplace[ s, "''" -> "'" ];
unescapeSingleQuoted // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseFlowSequence*)
parseFlowSequence // beginDefinition;

parseFlowSequence[ s_String ] := Enclose[
    Module[ { inner, items },
        inner = StringTrim @ StringTake[ s, { 2, -2 } ];
        If[ inner === "",
            { },
            items = ConfirmMatch[ splitFlowElements @ inner, { __String }, "Items" ];
            parseScalar /@ items
        ]
    ],
    throwInternalFailure
];

parseFlowSequence // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseFlowMapping*)
parseFlowMapping // beginDefinition;

parseFlowMapping[ s_String ] := Enclose[
    Module[ { inner, items, result },
        inner = StringTrim @ StringTake[ s, { 2, -2 } ];
        If[ inner === "",
            <| |>,
            items = ConfirmMatch[ splitFlowElements @ inner, { __String }, "Items" ];
            result = <| |>;
            Scan[
                Function[ item,
                    Module[ { key, valueText },
                        { key, valueText } = parseMappingLine[ item, 0 ];
                        result[ key ] = parseScalar @ valueText
                    ]
                ],
                items
            ];
            result
        ]
    ],
    throwInternalFailure
];

parseFlowMapping // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*splitFlowElements*)
(* Splits a flow string by "," at depth zero, honoring nested [] and {} and quoted
   spans.  Mirrors splitTOMLElements in TOML.wl. *)
splitFlowElements // beginDefinition;

splitFlowElements[ s_String ] :=
    Module[ { chars, n, i, ch, inSingle, inDouble, depth, current, result },
        chars    = Characters @ s;
        n        = Length @ chars;
        result   = { };
        current  = Internal`Bag[ ];
        inSingle = False;
        inDouble = False;
        depth    = 0;
        i = 1;
        While[ i <= n,
            ch = chars[[ i ]];
            Which[
                inDouble && ch === "\\" && i < n,
                    Internal`StuffBag[ current, ch ];
                    Internal`StuffBag[ current, chars[[ i + 1 ]] ];
                    i += 2;
                    Continue[ ],
                inDouble && ch === "\"",
                    inDouble = False;
                    Internal`StuffBag[ current, ch ],
                inDouble,
                    Internal`StuffBag[ current, ch ],
                inSingle && ch === "'",
                    inSingle = False;
                    Internal`StuffBag[ current, ch ],
                inSingle,
                    Internal`StuffBag[ current, ch ],
                ch === "\"",
                    inDouble = True;
                    Internal`StuffBag[ current, ch ],
                ch === "'",
                    inSingle = True;
                    Internal`StuffBag[ current, ch ],
                ch === "[" || ch === "{",
                    depth++;
                    Internal`StuffBag[ current, ch ],
                ch === "]" || ch === "}",
                    depth--;
                    Internal`StuffBag[ current, ch ],
                ch === "," && depth === 0,
                    AppendTo[ result, StringTrim @ StringJoin @ Internal`BagPart[ current, All ] ];
                    current = Internal`Bag[ ],
                True,
                    Internal`StuffBag[ current, ch ]
            ];
            i++
        ];
        With[ { trailing = StringTrim @ StringJoin @ Internal`BagPart[ current, All ] },
            If[ trailing =!= "", AppendTo[ result, trailing ] ]
        ];
        result
    ];

splitFlowElements // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Writing YAML*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*exportYAML*)
exportYAML // beginDefinition;

exportYAML[ file_, data_ ] := Enclose[
    Module[ { path, content },
        path    = ConfirmBy[ ExpandFileName @ ensureFilePath @ file, StringQ, "Path" ];
        content = ConfirmBy[ exportYAMLString @ data, StringQ, "Content" ];
        ConfirmBy[ writeYAMLString[ path, content ], FileExistsQ, "Write" ];
        File @ path
    ],
    throwInternalFailure
];

exportYAML // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*writeYAMLString*)
writeYAMLString // beginDefinition;

writeYAMLString[ path_String, content_String ] :=
    Module[ { stream },
        stream = OpenWrite[ path, CharacterEncoding -> "UTF-8" ];
        WriteString[ stream, content ];
        If[ ! StringEndsQ[ content, "\n" ], WriteString[ stream, "\n" ] ];
        Close @ stream;
        path
    ];

writeYAMLString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*exportYAMLString*)
exportYAMLString // beginDefinition;

exportYAMLString[ data_ ] := Enclose[
    Block[ { $yamlDepth = 0 },
        ConfirmBy[ formatYAMLValue @ data, StringQ, "Formatted" ]
    ],
    throwInternalFailure
];

exportYAMLString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Indentation state*)
$yamlDepth = 0;
$yamlIndent := StringJoin @ ConstantArray[ "  ", $yamlDepth ];

descendYAML // Attributes = { HoldFirst };
descendYAML[ eval_ ] := Internal`InheritedBlock[ { $yamlDepth }, $yamlDepth += 1; eval ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatYAMLValue*)
(* Top-level dispatch.  An empty association becomes "{}", an empty list becomes
   "[]", and other top-level associations/lists become block constructs starting
   at column 0. *)
formatYAMLValue // beginDefinition;

formatYAMLValue[ <| |> ] := "{}";
formatYAMLValue[ {  } ] := "[]";

formatYAMLValue[ as_? AssociationQ ] :=
    StringRiffle[ KeyValueMap[ formatYAMLMappingEntry, as ], "\n" ];

formatYAMLValue[ list_List ] :=
    StringRiffle[ formatYAMLSequenceItem /@ list, "\n" ];

formatYAMLValue[ scalar_ ] := formatYAMLScalar @ scalar;

formatYAMLValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatYAMLMappingEntry*)
formatYAMLMappingEntry // beginDefinition;

(* Empty nested association *)
formatYAMLMappingEntry[ key_, <| |> ] :=
    $yamlIndent <> formatYAMLKey @ key <> ": {}";

(* Nested association: emit "key:" then indent the children *)
formatYAMLMappingEntry[ key_, as_? AssociationQ ] :=
    $yamlIndent <> formatYAMLKey @ key <> ":\n" <>
        descendYAML @ formatYAMLValue @ as;

(* Empty list *)
formatYAMLMappingEntry[ key_, {  } ] :=
    $yamlIndent <> formatYAMLKey @ key <> ": []";

(* List of associations -> block sequence *)
formatYAMLMappingEntry[ key_, list: { __? AssociationQ } ] :=
    $yamlIndent <> formatYAMLKey @ key <> ":\n" <>
        descendYAML @ formatYAMLValue @ list;

(* List of scalars -> flow sequence (always -- Goose uses flow for `args`) *)
formatYAMLMappingEntry[ key_, list_List ] :=
    $yamlIndent <> formatYAMLKey @ key <> ": " <> formatYAMLFlowList @ list;

(* Null value *)
formatYAMLMappingEntry[ key_, Null ] :=
    $yamlIndent <> formatYAMLKey @ key <> ":";

(* Scalar value *)
formatYAMLMappingEntry[ key_, value_ ] :=
    $yamlIndent <> formatYAMLKey @ key <> ": " <> formatYAMLScalar @ value;

formatYAMLMappingEntry // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatYAMLSequenceItem*)
formatYAMLSequenceItem // beginDefinition;

formatYAMLSequenceItem[ <| |> ] :=
    $yamlIndent <> "- {}";

(* Render the entries one indent level deeper so subsequent keys line up with
   the first key (which sits two columns past the "-").  The first line's deeper
   indent is then replaced with "<parent indent>- " to splice the dash in. *)
formatYAMLSequenceItem[ as_? AssociationQ ] :=
    Module[ { childIndent, body },
        childIndent = $yamlIndent <> "  ";
        body = descendYAML @ StringRiffle[
            KeyValueMap[ formatYAMLMappingEntry, as ],
            "\n"
        ];
        $yamlIndent <> "- " <> StringDrop[ body, StringLength @ childIndent ]
    ];

formatYAMLSequenceItem[ list_List ] :=
    $yamlIndent <> "- " <> formatYAMLFlowList @ list;

formatYAMLSequenceItem[ value_ ] :=
    $yamlIndent <> "- " <> formatYAMLScalar @ value;

formatYAMLSequenceItem // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatYAMLFlowList*)
formatYAMLFlowList // beginDefinition;
formatYAMLFlowList[ {  } ] := "[]";
formatYAMLFlowList[ list_List ] := "[" <> StringRiffle[ formatYAMLScalar /@ list, ", " ] <> "]";
formatYAMLFlowList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatYAMLKey*)
(* Quote a key only if it contains characters that would confuse the parser.
   Plain identifiers and identifiers with hyphens/underscores stay unquoted; keys
   with colons, quotes, leading/trailing whitespace, or other special characters
   become double-quoted. *)
formatYAMLKey // beginDefinition;

formatYAMLKey[ key_String ] :=
    If[ plainScalarQ @ key, key, formatDoubleQuoted @ key ];

formatYAMLKey[ key_ ] := formatYAMLKey @ ToString @ key;

formatYAMLKey // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatYAMLReal*)
(* Convert a Real to a YAML-compatible numeric string.  ToString on a Real can
   emit Wolfram Language scientific notation like "1.5*^20" (or even multi-line
   superscript form), neither of which is valid YAML.  JSON's number grammar is
   a strict subset of YAML 1.2's float grammar, so we delegate to the JSON
   serializer to get plain decimals or "e"-style exponents that round-trip
   cleanly through importYAMLString and external YAML parsers. *)
formatYAMLReal // beginDefinition;
formatYAMLReal[ r_Real ] := Developer`WriteRawJSONString @ r;
formatYAMLReal // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatYAMLScalar*)
formatYAMLScalar // beginDefinition;

formatYAMLScalar[ True  ] := "true";
formatYAMLScalar[ False ] := "false";
formatYAMLScalar[ Null  ] := "null";
formatYAMLScalar[ n_Integer ] := ToString @ n;
formatYAMLScalar[ r_Real    ] := formatYAMLReal @ r;

formatYAMLScalar[ s_String ] :=
    If[ plainScalarQ @ s, s, formatDoubleQuoted @ s ];

formatYAMLScalar[ as_? AssociationQ ] :=
    "{" <> StringRiffle[
        KeyValueMap[ Function[ { k, v }, formatYAMLKey[ k ] <> ": " <> formatYAMLScalar @ v ], as ],
        ", "
    ] <> "}";

formatYAMLScalar[ list_List ] := formatYAMLFlowList @ list;

formatYAMLScalar[ other_ ] := formatDoubleQuoted @ ToString @ other;

formatYAMLScalar // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*plainScalarQ*)
(* True when a string can be safely emitted without quoting.  Errs on the side of
   quoting:  any character that could change the parse, any leading/trailing
   whitespace, or anything that looks like a YAML literal forces quoting. *)
plainScalarQ // beginDefinition;

plainScalarQ[ "" ] := False;

plainScalarQ[ s_String ] :=
    Which[
        StringMatchQ[ s, WhitespaceCharacter ~~ ___ ], False,
        StringMatchQ[ s, ___ ~~ WhitespaceCharacter ], False,
        StringContainsQ[ s, ":" | "#" | "\"" | "'" | "[" | "]" | "{" | "}" | "," | "&" | "*" | "!" | "|" | ">" | "%" | "@" | "`" | "\n" | "\r" | "\t" ], False,
        StringStartsQ[ s, "-" | "?" ], False,
        MemberQ[
            { "true", "True", "TRUE", "false", "False", "FALSE",
              "null", "Null", "NULL", "yes", "Yes", "YES",
              "no", "No", "NO", "on", "On", "ON", "off", "Off", "OFF", "~" },
            s
        ], False,
        integerStringQ @ s, False,
        floatStringQ @ s, False,
        True, True
    ];

plainScalarQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatDoubleQuoted*)
formatDoubleQuoted // beginDefinition;

formatDoubleQuoted[ s_String ] :=
    "\"" <> StringReplace[ s, {
        "\\" -> "\\\\",
        "\"" -> "\\\"",
        "\n" -> "\\n",
        "\t" -> "\\t",
        "\r" -> "\\r"
    } ] <> "\"";

formatDoubleQuoted // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
