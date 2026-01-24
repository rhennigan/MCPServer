(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Files`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$rootPath    := FileNameJoin @ { $UserBaseDirectory, "ApplicationData", "Wolfram", "MCPServer" };
$storagePath := FileNameJoin @ { $rootPath, "Servers" };
$imagePath   := FileNameJoin @ { $rootPath, "Images"  };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Server Files*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpServerFile*)
mcpServerFile // beginDefinition;

mcpServerFile[ obj_ ] :=
    mcpServerFile[ obj, "Metadata.wxf" ];

mcpServerFile[ obj_, name_String ] := Enclose[
    Module[ { dir, file },
        dir  = ConfirmMatch[ mcpServerDirectory @ obj, File[ _String ], "Directory" ];
        file = If[ StringContainsQ[ name, "." ], name, URLEncode @ name <> ".wxf" ];
        ConfirmBy[ fileNameJoin[ dir, file ], fileQ, "Result" ]
    ],
    throwInternalFailure
];

mcpServerFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpServerDirectory*)
mcpServerDirectory // beginDefinition;

mcpServerDirectory[ name_String ] :=
    fileNameJoin[ $storagePath, URLEncode @ name ];

mcpServerDirectory[ obj_MCPServerObject? MCPServerObjectQ ] :=
    With[ { location = obj[ "Location" ] },
        If[ location === "BuiltIn",
            mcpServerDirectory @ obj[ "Name" ],
            location
        ]
    ];

mcpServerDirectory // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpServerLogFile*)
mcpServerLogFile // beginDefinition;

mcpServerLogFile[ name_String ] :=
    fileNameJoin[ mcpServerDirectory @ name, "Log.wl" ];

mcpServerLogFile[ obj_MCPServerObject? MCPServerObjectQ ] :=
    With[ { location = obj[ "Location" ] },
        If[ location === "BuiltIn",
            mcpServerLogFile @ obj[ "Name" ],
            fileNameJoin[ location, "Log.wl" ]
        ]
    ];

mcpServerLogFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Misc Utilities*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fileQ*)
fileQ // beginDefinition;
fileQ[ File[ file_String ] ] := StringQ @ file;
fileQ[ _ ] := False;
fileQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*directoryQ*)
directoryQ // beginDefinition;
directoryQ[ dir_File ] := DirectoryQ @ dir;
directoryQ[ _ ] := False;
directoryQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*fileNameJoin*)
fileNameJoin // beginDefinition;

fileNameJoin[ args___ ] := Enclose[
    Module[ { flat, parts, string },
        flat   = Flatten @ { args };
        parts  = ConfirmMatch[ Replace[ flat, File[ x_String ] :> x, { 1 } ], { __String }, "Parts" ];
        string = ConfirmBy[ FileNameJoin @ parts, StringQ, "String" ];
        ConfirmBy[ toFile @ StringReplace[ string, "\\" -> "/" ], fileQ, "Result" ]
    ],
    throwInternalFailure
];

fileNameJoin // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensureDirectory*)
ensureDirectory // beginDefinition;

ensureDirectory[ File[ dir_String ] ] :=
    ensureDirectory @ dir;

ensureDirectory[ dir0_ ] := Enclose[
    Module[ { dir },
        dir = ConfirmBy[ GeneralUtilities`EnsureDirectory @ dir0, DirectoryQ, "Directory" ];
        ConfirmBy[ toFile @ dir, fileQ, "Result" ]
    ],
    throwInternalFailure
];

ensureDirectory // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensureFilePath*)
ensureFilePath // beginDefinition;

ensureFilePath[ file_ ] := Enclose[
    Module[ { dir },
        dir = ConfirmBy[ ensureDirectory @ DirectoryName @ file, DirectoryQ, "Directory" ];
        ConfirmBy[ toFile @ file, fileQ, "Result" ]
    ],
    throwInternalFailure
];

ensureFilePath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toFile*)
toFile // beginDefinition;
toFile[ file: File[ _String ] ] := file;
toFile[ file_String ] := File @ file;
toFile[ parts_List ] := fileNameJoin @ parts;
toFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Developer Functions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readWXFFile*)
readWXFFile // beginDefinition;
readWXFFile[ file_ ] := Developer`ReadWXFFile @ ExpandFileName @ file;
readWXFFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeWXFFile*)
writeWXFFile // beginDefinition;

writeWXFFile[ file_, data_, opts: OptionsPattern[ ] ] :=
    Developer`WriteWXFFile[
        ExpandFileName @ ensureFilePath @ file,
        data,
        opts
    ];

writeWXFFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readRawJSONFile*)
readRawJSONFile // beginDefinition;
readRawJSONFile[ file_, opts: OptionsPattern[ ] ] := Developer`ReadRawJSONFile[ ExpandFileName @ file, opts ];
readRawJSONFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeRawJSONFile*)
writeRawJSONFile // beginDefinition;

writeRawJSONFile[ file_, data_, opts: OptionsPattern[ ] ] :=
    Developer`WriteRawJSONFile[
        ExpandFileName @ ensureFilePath @ file,
        data,
        opts
    ];

writeRawJSONFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*TOML Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readTOMLFile*)
readTOMLFile // beginDefinition;

readTOMLFile[ file_ ] := Enclose[
    Module[ { content },
        If[ ! FileExistsQ @ file, Throw[ <| |>, $tomlTag ] ];
        content = ConfirmBy[ ReadString @ ExpandFileName @ file, StringQ, "Content" ];
        ConfirmBy[ parseTOML @ content, AssociationQ, "Parse" ]
    ] ~Catch~ $tomlTag,
    throwInternalFailure
];

readTOMLFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeTOMLFile*)
writeTOMLFile // beginDefinition;

writeTOMLFile[ file_, data_Association ] := Enclose[
    Module[ { toml, path },
        toml = ConfirmBy[ serializeTOML @ data, StringQ, "Serialize" ];
        path = ConfirmBy[ ensureFilePath @ file, fileQ, "Path" ];
        ConfirmBy[ WriteString[ ExpandFileName @ path, toml ]; path, fileQ, "Write" ]
    ],
    throwInternalFailure
];

writeTOMLFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseTOML*)
parseTOML // beginDefinition;

parseTOML[ content_String ] := Enclose[
    Module[ { lines, result, currentPath },
        lines = StringSplit[ content, "\n" ];
        result = <| |>;
        currentPath = { };

        Do[
            With[ { parsed = parseTOMLLine[ line, currentPath ] },
                Switch[ parsed,
                    (* Section header *)
                    { "Section", _List },
                    currentPath = parsed[[ 2 ]],
                    (* Key-value pair *)
                    { "KeyValue", _String, _ },
                    result = setNestedKey[ result, Append[ currentPath, parsed[[ 2 ]] ], parsed[[ 3 ]] ],
                    (* Comment or empty line *)
                    "Skip",
                    Null,
                    (* Unknown *)
                    _,
                    Null
                ]
            ],
            { line, lines }
        ];

        result
    ],
    throwInternalFailure
];

parseTOML // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parseTOMLLine*)
parseTOMLLine // beginDefinition;

(* Empty line or comment *)
parseTOMLLine[ line_String, _ ] /; StringMatchQ[ StringTrim @ line, "" | ("#" ~~ ___) ] :=
    "Skip";

(* Section header: [section.name] *)
parseTOMLLine[ line_String, _ ] /; StringMatchQ[ StringTrim @ line, "[" ~~ __ ~~ "]" ] :=
    Module[ { trimmed, sectionName },
        trimmed = StringTrim @ line;
        sectionName = StringTake[ trimmed, { 2, -2 } ];
        { "Section", StringSplit[ sectionName, "." ] }
    ];

(* Key-value pair *)
parseTOMLLine[ line_String, currentPath_List ] :=
    Module[ { trimmed, pos, key, value },
        trimmed = StringTrim @ line;
        (* Find first = sign *)
        pos = StringPosition[ trimmed, "=", 1 ];
        If[ pos === { },
            "Skip",
            key = StringTrim @ StringTake[ trimmed, pos[[ 1, 1 ]] - 1 ];
            value = parseTOMLValue @ StringTrim @ StringDrop[ trimmed, pos[[ 1, 2 ]] ];
            { "KeyValue", key, value }
        ]
    ];

parseTOMLLine // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*parseTOMLValue*)
parseTOMLValue // beginDefinition;

(* Quoted string *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, "\"" ~~ ___ ~~ "\"" ] :=
    StringTake[ s, { 2, -2 } ] // StringReplace[ {
        "\\\"" -> "\"",
        "\\\\" -> "\\",
        "\\n" -> "\n",
        "\\t" -> "\t"
    } ];

(* Array *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, "[" ~~ ___ ~~ "]" ] :=
    Module[ { inner, elements },
        inner = StringTrim @ StringTake[ s, { 2, -2 } ];
        If[ inner === "", Return[ { } ] ];
        elements = StringSplit[ inner, "," ];
        parseTOMLValue /@ Map[ StringTrim, elements ]
    ];

(* Boolean *)
parseTOMLValue[ "true" ] := True;
parseTOMLValue[ "false" ] := False;

(* Integer *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, DigitCharacter.. | ("-" ~~ DigitCharacter..) ] :=
    ToExpression @ s;

(* Float *)
parseTOMLValue[ s_String ] /; StringMatchQ[ s, NumberString ] :=
    ToExpression @ s;

(* Fallback: treat as unquoted string *)
parseTOMLValue[ s_String ] := s;

parseTOMLValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*setNestedKey*)
setNestedKey // beginDefinition;

setNestedKey[ assoc_Association, { key_ }, value_ ] :=
    Append[ assoc, key -> value ];

setNestedKey[ assoc_Association, { first_, rest__ }, value_ ] :=
    Module[ { current },
        current = Lookup[ assoc, first, <| |> ];
        If[ ! AssociationQ @ current, current = <| |> ];
        Append[ assoc, first -> setNestedKey[ current, { rest }, value ] ]
    ];

setNestedKey // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*serializeTOML*)
serializeTOML // beginDefinition;

serializeTOML[ data_Association ] := Enclose[
    Module[ { lines },
        lines = Flatten @ serializeTOMLSection[ data, { } ];
        ConfirmBy[ StringRiffle[ lines, "\n" ] <> "\n", StringQ, "Result" ]
    ],
    throwInternalFailure
];

serializeTOML // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*serializeTOMLSection*)
serializeTOMLSection // beginDefinition;

serializeTOMLSection[ data_Association, path_List ] :=
    Module[ { simpleKeys, nestedKeys, simpleLines, nestedLines },
        (* Separate simple values from nested associations *)
        simpleKeys = Select[ Keys @ data, ! AssociationQ[ data[ # ] ] & ];
        nestedKeys = Select[ Keys @ data, AssociationQ[ data[ # ] ] & ];

        (* Generate lines for simple key-values *)
        simpleLines = KeyValueMap[
            Function[ { k, v }, k <> " = " <> serializeTOMLValue @ v ],
            KeyTake[ data, simpleKeys ]
        ];

        (* Generate lines for nested sections *)
        nestedLines = Flatten @ Map[
            Function[ key,
                Module[ { newPath, header, content },
                    newPath = Append[ path, key ];
                    header = "[" <> StringRiffle[ newPath, "." ] <> "]";
                    content = serializeTOMLSection[ data @ key, newPath ];
                    { "", header, content }
                ]
            ],
            nestedKeys
        ];

        (* Combine: simple values first (with section header if needed), then nested sections *)
        If[ path =!= { } && simpleLines =!= { },
            { simpleLines, nestedLines },
            If[ path === { },
                { simpleLines, nestedLines },
                { simpleLines, nestedLines }
            ]
        ]
    ];

serializeTOMLSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*serializeTOMLValue*)
serializeTOMLValue // beginDefinition;

serializeTOMLValue[ s_String ] :=
    "\"" <> StringReplace[ s, { "\\" -> "\\\\", "\"" -> "\\\"", "\n" -> "\\n", "\t" -> "\\t" } ] <> "\"";

serializeTOMLValue[ True ] := "true";
serializeTOMLValue[ False ] := "false";

serializeTOMLValue[ n_Integer ] := ToString @ n;
serializeTOMLValue[ n_Real ] := ToString @ n;

serializeTOMLValue[ list_List ] :=
    "[" <> StringRiffle[ serializeTOMLValue /@ list, ", " ] <> "]";

serializeTOMLValue // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
