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
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
