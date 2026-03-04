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
manifestFile  = cicd`ScriptConfirmBy[ FileNameJoin @ { agentSkillDir, "Manifest.wl" }, FileExistsQ ];
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
cicd`ConsoleLog @ SequenceForm[ "Tools to generate scripts for: ", allToolNames ];

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
        "Name"        -> convertPUACharacters @ data[ "Name" ],
        "Description" -> convertPUACharacters @ data[ "Description" ],
        "Required"    -> Select[ params, TrueQ @ #[ "Required" ] & ],
        "Optional"    -> Select[ params, ! TrueQ @ #[ "Required" ] & ]
    |>
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Convert Private Use Area Characters to Printable ASCII*)
convertPUACharacters[ str_String ] := StringJoin[ convertPUACharacters /@ ToCharacterCode @ str ];
convertPUACharacters[ n_Integer ] /; 57344 <= n <= 63743 := toPrintableASCII @ FromCharacterCode @ n;
convertPUACharacters[ n_Integer ] := FromCharacterCode @ n;

toPrintableASCII[ expr_ ] := ToString[ Unevaluated @ expr, CharacterEncoding -> "PrintableASCII" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate Usage Code*)
generateUsageCode[ toolName_String, reqNames_List, optNames_List ] := Module[
    { usageParts, usageStr },
    usageParts = Join[
        Map[ "<" <> # <> ">" &, reqNames ],
        Map[ "[--" <> # <> " value]" &, optNames ]
    ];
    usageStr = "wolframscript -f " <> toolName <> ".wls " <> StringRiffle[ usageParts, " " ];
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
(* ::Subsection::Closed:: *)
(*Generate Scripts.md Reference*)

(* Build a usage line for markdown display *)
scriptUsageLine[ toolName_String, reqNames_List, optNames_List ] := Module[ { parts },
    parts = Join[
        Map[ "<" <> # <> ">" &, reqNames ],
        Map[ "[--" <> # <> " value]" &, optNames ]
    ];
    "wolframscript -f scripts/" <> toolName <> ".wls " <> StringRiffle[ parts, " " ]
];

(* Build a markdown argument table for a single tool *)
scriptArgTable[ meta_Association, reqNames_List, optNames_List ] := Module[ { rows },
    rows = Join[
        Map[
            Function[ name,
                "| `" <> name <> "` | Yes | " <>
                    Replace[ meta[ "Required" ][ name ][ "Help" ], Except[ _String ] -> "No description" ] <> " |"
            ],
            reqNames
        ],
        Map[
            Function[ name,
                "| `--" <> name <> "` | No | " <>
                    Replace[ meta[ "Optional" ][ name ][ "Help" ], Except[ _String ] -> "No description" ] <> " |"
            ],
            optNames
        ]
    ];
    If[ rows === {},
        "This script has no arguments.\n",
        StringJoin[
            "| Argument | Required | Description |\n",
            "| --- | --- | --- |\n",
            StringRiffle[ rows, "\n" ], "\n"
        ]
    ]
];

(* Build a markdown section for a single tool *)
scriptMdSection[ toolName_String ] := Module[ { meta, reqNames, optNames },
    meta     = getToolMetadata[ toolName ];
    reqNames = Keys @ meta[ "Required" ];
    optNames = Keys @ meta[ "Optional" ];
    StringJoin[
        "## ", toolName, ".wls\n\n",
        meta[ "Description" ], "\n\n",
        "**Usage:**\n\n",
        "```\n",
        scriptUsageLine[ toolName, reqNames, optNames ], "\n",
        "```\n\n",
        "**Arguments:**\n\n",
        scriptArgTable[ meta, reqNames, optNames ]
    ]
];

(* Build the full Scripts.md content for a skill *)
generateScriptsMd[ scriptNames_List ] := StringJoin[
    "# Script Reference\n\n",
    "Auto-generated reference for bundled scripts. Pass `--usage` to any\n",
    "script for the latest argument documentation.\n\n",
    StringRiffle[ Map[ scriptMdSection, scriptNames ], "\n---\n\n" ],
    "\n"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Build Agent Skill Scripts*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate All Scripts to Temp Directory*)
cicd`ConsoleLog[ "Generating scripts..." ];

Map[
    Function[ toolName,
        Module[ { source, outFile },
            source  = generateScript[ toolName ];
            outFile = FileNameJoin @ { tempBuildDir, toolName <> ".wls" };
            Export[ outFile, source, "String" ];
            cicd`ConsoleLog @ SequenceForm[ "  Generated: ", toolName <> ".wls" ];
        ]
    ],
    allToolNames
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Distribute Scripts and References to Each Skill*)
cicd`ConsoleLog[ "Distributing scripts and references to skills..." ];

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
                            cicd`ConsoleLog @ SequenceForm[ "  ", skillName, "/scripts/", scriptName <> ".wls" ],
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
                            cicd`ConsoleLog @ SequenceForm[ "  ", skillName, "/references/", refName <> ".md" ],
                            cicd`ConsoleError @ SequenceForm[ "  Missing reference: ", src ];
                            Exit[ 1 ]
                        ]
                    ]
                ],
                refNames
            ];

            (* Generate Scripts.md reference *)
            Module[ { scriptsMd, scriptsMdFile },
                scriptsMd = generateScriptsMd[ scriptNames ];
                scriptsMdFile = FileNameJoin @ { refDir, "Scripts.md" };
                Export[ scriptsMdFile, scriptsMd, "String" ];
                cicd`ConsoleLog @ SequenceForm[ "  ", skillName, "/references/Scripts.md" ];
            ];

            cicd`ConsoleLog @ SequenceForm[ "  Completed skill: ", skillName ];
        ]
    ],
    manifest
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Update Marketplace Version*)
cicd`ConsoleLog[ "Updating marketplace version..." ];
marketplaceFile = cicd`ScriptConfirmBy[ FileNameJoin @ { pacletDir, ".claude-plugin", "marketplace.json" }, FileExistsQ ];
marketplaceData = cicd`ScriptConfirmBy[ Import[ marketplaceFile, "RawJSON" ], AssociationQ ];
paclet = cicd`ScriptConfirmBy[ PacletObject @ File @ pacletDir, PacletObjectQ ];
version = cicd`ScriptConfirmBy[ paclet[ "Version" ], StringQ ];
marketplaceData[ "metadata", "version" ] = version;
Export[ marketplaceFile, marketplaceData, "RawJSON" ];
cicd`ConsoleLog[ "Marketplace version updated." ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
cicd`ConsoleLog[ "Cleaning up temporary build directory..." ];
DeleteDirectory[ tempBuildDir, DeleteContents -> True ];

cicd`ConsoleLog[ "Build complete." ];

(* :!CodeAnalysis::EndBlock:: *)