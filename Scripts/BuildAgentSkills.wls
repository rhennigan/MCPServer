#!/usr/bin/env wolframscript

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
If[ ! PacletObjectQ @ PacletObject[ "Wolfram/PacletCICD" ],
    PacletInstall[ "https://github.com/WolframResearch/PacletCICD/releases/download/v0.36.2/Wolfram__PacletCICD-0.36.2.paclet" ]
];
Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Paths*)
pacletDir     = cicd`ScriptConfirmBy[ DirectoryName[ $InputFileName, 2 ], DirectoryQ ];
agentSkillDir = cicd`ScriptConfirmBy[ GeneralUtilities`EnsureDirectory @ { pacletDir, "AgentSkills" }, DirectoryQ ];
skillsDir     = cicd`ScriptConfirmBy[ GeneralUtilities`EnsureDirectory @ { agentSkillDir, "Skills" }, DirectoryQ ];
refsDir       = cicd`ScriptConfirmBy[ FileNameJoin @ { agentSkillDir, "References" }, DirectoryQ ];
manifestFile  = cicd`ScriptConfirmBy[ FileNameJoin @ { agentSkillDir, "Skills", "Manifest.wl" }, FileExistsQ ];
manifest      = cicd`ScriptConfirmBy[ Get @ manifestFile, AssociationQ ];
templateFile  = cicd`ScriptConfirmBy[ FileNameJoin @ { pacletDir, "Scripts", "Resources", "SkillScriptTemplate.wls" }, FileExistsQ ];
tempBuildDir  = CreateDirectory[ ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Load Paclet*)
cicd`ScriptConfirmBy[ PacletDirectoryLoad @ pacletDir, MemberQ @ pacletDir ];
cicd`ScriptConfirmMatch[ Get[ "Wolfram`MCPServer`" ], Null ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Script Generation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Collect Unique Tool Names*)
allToolNames = Union @@ Map[ Lookup[ "Scripts" ], Values @ manifest ];
cicd`ConsoleNotice @ SequenceForm[ "Tools to generate scripts for: ", allToolNames ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Extract Tool Metadata*)
getToolMetadata[ toolName_String ] := Module[ { tool, data, params },
    tool = $DefaultMCPTools[ toolName ];
    If[ ! MatchQ[ tool, _LLMTool ],
        cicd`ConsoleError @ SequenceForm[ "Tool not found in $DefaultMCPTools: ", toolName ];
        Exit[ 1 ]
    ];
    data = tool[ "Data" ];
    params = Association @ data[ "Parameters" ];
    <|
        "Name"        -> data[ "Name" ],
        "Description" -> data[ "Description" ],
        "Required"    -> Select[ params, TrueQ @ #[ "Required" ] & ],
        "Optional"    -> Select[ params, ! TrueQ @ #[ "Required" ] & ]
    |>
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate Usage Code*)
generateUsageCode[ toolName_String, reqNames_List, optNames_List ] := Module[
    { usageParts, usageStr },
    usageParts = Join[
        Map[ "<" <> # <> ">" &, reqNames ],
        Map[ "[--" <> # <> " value]" &, optNames ]
    ];
    usageStr = "wolframscript -script " <> toolName <> ".wls " <> StringRiffle[ usageParts, " " ];
    "$usage = \"" <> StringReplace[ usageStr, "\"" -> "\\\"" ] <> "\";"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate Help Text Code*)
$escapeRules = { "\\" -> "\\\\", "\"" -> "\\\"", "\n" -> "\\n" };

generateHelpLines[ meta_Association, reqNames_List, optNames_List ] := Join[
    Map[
        Function[ name,
            "  " <> name <> " (required): " <>
                Replace[ meta[ "Required" ][ name ][ "Help" ], Except[ _String ] -> "No description" ]
        ],
        reqNames
    ],
    Map[
        Function[ name,
            "  --" <> name <> ": " <>
                Replace[ meta[ "Optional" ][ name ][ "Help" ], Except[ _String ] -> "No description" ]
        ],
        optNames
    ]
];

generateHelpTextCode[ meta_Association, helpLines_List ] := StringJoin[
    "$helpText = StringJoin[\n",
    "    \"Usage: \", $usage, \"\\n\\n\",\n",
    "    \"", StringReplace[ meta[ "Description" ], $escapeRules ], "\\n\\n\",\n",
    If[ helpLines === {},
        "    \"No arguments.\\n\"\n",
        "    \"Arguments:\\n\",\n" <>
        StringRiffle[
            Map[ "    \"" <> StringReplace[ #, $escapeRules ] <> "\\n\"" &, helpLines ],
            ",\n"
        ] <> "\n"
    ],
    "];"
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate Argument Parsing Code*)
generateArgParsingCode[ reqNames_List, optNames_List ] := Module[
    { code },

    code = "";

    (* Validate required positional arguments *)
    If[ reqNames =!= {},
        code = code <> StringJoin[
            "    (* Validate required arguments *)\n",
            "    If[ Length @ positional < ", ToString @ Length @ reqNames, ",\n",
            "        WriteString[ \"stderr\", \"[Error] Missing required argument(s).\\n\\n\" <> $helpText ];\n",
            "        Exit[ 1 ]\n",
            "    ];\n",
            "\n"
        ]
    ];

    (* Assign required positional args *)
    MapIndexed[
        Function[ { name, idx },
            code = code <> "    $parsedArgs[ \"" <> name <> "\" ] = positional[[ " <> ToString @ First @ idx <> " ]];\n"
        ],
        reqNames
    ];

    (* Assign optional flag args *)
    Map[
        Function[ name,
            code = code <> "    If[ KeyExistsQ[ flags, \"" <> name <> "\" ], $parsedArgs[ \"" <> name <> "\" ] = flags[ \"" <> name <> "\" ] ];\n"
        ],
        optNames
    ];

    StringReplace[ code, "\n" ~~ EndOfString -> "" ]
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate Script Source*)
generateScript[ toolName_String ] := Module[
    { meta, reqNames, optNames, helpLines, usageCode, helpTextCode, parsingCode, sourceTemplate },

    meta     = getToolMetadata[ toolName ];
    reqNames = Keys @ meta[ "Required" ];
    optNames = Keys @ meta[ "Optional" ];

    helpLines    = generateHelpLines[ meta, reqNames, optNames ];
    usageCode    = generateUsageCode[ toolName, reqNames, optNames ];
    helpTextCode = generateHelpTextCode[ meta, helpLines ];
    parsingCode  = generateArgParsingCode[ reqNames, optNames ];

    sourceTemplate = ReadString[ templateFile ];

    StringReplace[
        sourceTemplate,
        {
            "(*<<Usage>>*)"           -> usageCode,
            "(*<<HelpText>>*)"        -> helpTextCode,
            "(*<<ArgumentParsing>>*)" -> parsingCode,
            "(*<<ToolName>>*)"        -> toolName
        }
    ]
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Build Agent Skill Scripts*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate All Scripts to Temp Directory*)
cicd`ConsoleNotice[ "Generating scripts..." ];

Map[
    Function[ toolName,
        Module[ { source, outFile },
            source  = generateScript[ toolName ];
            outFile = FileNameJoin @ { tempBuildDir, toolName <> ".wls" };
            Export[ outFile, source, "String" ];
            cicd`ConsoleNotice @ SequenceForm[ "  Generated: ", toolName <> ".wls" ];
        ]
    ],
    allToolNames
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Distribute Scripts and References to Each Skill*)
cicd`ConsoleNotice[ "Distributing scripts and references to skills..." ];

KeyValueMap[
    Function[ { skillName, skillDef },
        Module[ { skillDir, scriptDir, refDir, scriptNames, refNames },

            skillDir  = GeneralUtilities`EnsureDirectory @ { skillsDir, skillName };
            scriptDir = GeneralUtilities`EnsureDirectory @ { skillDir, "scripts" };
            refDir    = GeneralUtilities`EnsureDirectory @ { skillDir, "references" };

            (* Copy generated scripts *)
            scriptNames = Lookup[ skillDef, "Scripts", {} ];
            Map[
                Function[ scriptName,
                    Module[ { src, dst },
                        src = FileNameJoin @ { tempBuildDir, scriptName <> ".wls" };
                        dst = FileNameJoin @ { scriptDir, scriptName <> ".wls" };
                        If[ FileExistsQ @ src,
                            CopyFile[ src, dst, OverwriteTarget -> True ];
                            cicd`ConsoleNotice @ SequenceForm[ "  ", skillName, "/scripts/", scriptName <> ".wls" ],
                            cicd`ConsoleError @ SequenceForm[ "  Missing script: ", src ];
                            Exit[ 1 ]
                        ]
                    ]
                ],
                scriptNames
            ];

            (* Copy reference files *)
            refNames = Lookup[ skillDef, "References", {} ];
            Map[
                Function[ refName,
                    Module[ { src, dst },
                        src = FileNameJoin @ { refsDir, refName <> ".md" };
                        dst = FileNameJoin @ { refDir, refName <> ".md" };
                        If[ FileExistsQ @ src,
                            CopyFile[ src, dst, OverwriteTarget -> True ];
                            cicd`ConsoleNotice @ SequenceForm[ "  ", skillName, "/references/", refName <> ".md" ],
                            cicd`ConsoleError @ SequenceForm[ "  Missing reference: ", src ];
                            Exit[ 1 ]
                        ]
                    ]
                ],
                refNames
            ];

            cicd`ConsoleNotice @ SequenceForm[ "  Completed skill: ", skillName ];
        ]
    ],
    manifest
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
cicd`ConsoleNotice[ "Cleaning up temporary build directory..." ];
DeleteDirectory[ tempBuildDir, DeleteContents -> True ];

cicd`ConsoleNotice[ "Build complete." ];

(* :!CodeAnalysis::EndBlock:: *)