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
(*Config*)
$symbolPageTemplatePath := FileNameJoin @ { $thisPaclet[ "Location" ], "Assets", "Templates", "SymbolPage.wl" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$createSymbolDocDescription = "\
Creates a new symbol documentation page for a Wolfram Language paclet. \
The tool generates a properly structured .nb file in the correct location within the paclet's documentation directory.";

$editSymbolDocDescription = "\
Edits an existing symbol documentation page. \
Supports operations like setting usage, notes, see also, and adding/modifying examples. \
Example inputs are automatically evaluated and outputs are generated.";

$editSymbolDocExamplesDescription = "\
Edits example sections of an existing symbol documentation page. \
Supports operations for appending, prepending, inserting, replacing, removing, clearing, and setting examples. \
Example code is automatically evaluated and output cells are generated. \
Returns the generated content as markdown for verification.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*CreateSymbolPacletDocumentation*)
$defaultMCPTools[ "CreateSymbolPacletDocumentation" ] := LLMTool @ <|
    "Name"        -> "CreateSymbolPacletDocumentation",
    "DisplayName" -> "Create Symbol Documentation",
    "Description" -> $createSymbolDocDescription,
    "Function"    -> createSymbolPacletDocumentation,
    "Options"     -> { },
    "Parameters"  -> {
        "pacletDirectory" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet root directory.",
            "Required"    -> True
        |>,
        "symbolName" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Name of the symbol being documented (e.g., \"MyFunction\").",
            "Required"    -> True
        |>,
        "pacletName" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Name of the paclet (e.g., \"MCPServer\" or \"Wolfram/MCPServer\").",
            "Required"    -> True
        |>,
        "publisherID" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Publisher ID for the paclet (e.g., \"Wolfram\"). Can be omitted for legacy paclets or included in pacletName.",
            "Required"    -> False
        |>,
        "context" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Full context for the symbol. Defaults based on pacletName/publisherID.",
            "Required"    -> False
        |>,
        "usage" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown string with usage cases as bullet points: `- \\`MyFunc[x]\\` does something with *x*`",
            "Required"    -> True
        |>,
        "notes" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown string for Details & Options section. Each paragraph becomes a note cell.",
            "Required"    -> False
        |>,
        "seeAlso" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Symbol names separated by newlines or commas (e.g., \"Plus\\nMinus\" or \"Plus, Minus\").",
            "Required"    -> False
        |>,
        "techNotes" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown links to tutorials, one per line: `[Title](paclet:Publisher/Paclet/tutorial/Name)`",
            "Required"    -> False
        |>,
        "relatedGuides" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown links to guides, one per line: `[Title](paclet:Publisher/Paclet/guide/Name)`",
            "Required"    -> False
        |>,
        "relatedLinks" -> <|
            "Interpreter" -> "String",
            "Help"        -> "External links in markdown format, one per line: `[label](url)`",
            "Required"    -> False
        |>,
        "keywords" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Keywords separated by newlines or commas.",
            "Required"    -> False
        |>,
        "newInVersion" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Version string for \"New in:\" field (e.g., \"1.0\").",
            "Required"    -> False
        |>,
        "basicExamples" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown content for Basic Examples section. Code blocks will be evaluated automatically.",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*EditSymbolPacletDocumentation*)
$defaultMCPTools[ "EditSymbolPacletDocumentation" ] := LLMTool @ <|
    "Name"        -> "EditSymbolPacletDocumentation",
    "DisplayName" -> "Edit Symbol Documentation",
    "Description" -> $editSymbolDocDescription,
    "Function"    -> editSymbolPacletDocumentation,
    "Options"     -> { },
    "Parameters"  -> {
        "notebook" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Path to the notebook file or documentation URI.",
            "Required"    -> True
        |>,
        "operation" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The edit operation: setUsage, setNotes, addNote, setDetailsTable, setSeeAlso, setTechNotes, setRelatedGuides, setRelatedLinks, setKeywords, setHistory.",
            "Required"    -> True
        |>,
        "content" -> <|
            "Interpreter" -> "String",
            "Help"        -> "New content in markdown or appropriate format for the operation.",
            "Required"    -> False
        |>,
        "position" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "Position for addNote operation (1-indexed). Negative values count from the end (-1 = last).",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*EditSymbolPacletDocumentationExamples*)
$defaultMCPTools[ "EditSymbolPacletDocumentationExamples" ] := LLMTool @ <|
    "Name"        -> "EditSymbolPacletDocumentationExamples",
    "DisplayName" -> "Edit Symbol Documentation Examples",
    "Description" -> $editSymbolDocExamplesDescription,
    "Function"    -> editSymbolPacletDocumentationExamples,
    "Options"     -> { },
    "Parameters"  -> {
        "notebook" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Path to the notebook file or documentation URI.",
            "Required"    -> True
        |>,
        "operation" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The edit operation: appendExample, prependExample, insertExample, replaceExample, removeExample, clearExamples, setExamples.",
            "Required"    -> True
        |>,
        "section" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Target example section: BasicExamples, Scope, GeneralizationsExtensions, Options, Applications, PropertiesRelations, PossibleIssues, InteractiveExamples, NeatExamples.",
            "Required"    -> True
        |>,
        "content" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Markdown content for example cells. Code blocks are evaluated automatically. Use --- to separate example groups.",
            "Required"    -> False
        |>,
        "position" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "Position for insert/replace/remove operations (1-indexed). Negative values count from the end (-1 = last).",
            "Required"    -> False
        |>,
        "subsection" -> <|
            "Interpreter" -> "String",
            "Help"        -> "For Options section, the option name to target.",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreateSymbolPacletDocumentation Implementation*)
(* Load definitions from ./CreateSymbolPacletDocumentation.wl *)
<<Wolfram`MCPServer`Tools`PacletDocumentation`CreateSymbolPacletDocumentation`;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cell Generation Functions*)
(* Load definitions from ./CellGenerationFunctions.wl *)
<<Wolfram`MCPServer`Tools`PacletDocumentation`CellGenerationFunctions`;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*EditSymbolPacletDocumentation Implementation*)
(* Load definitions from ./EditSymbolPacletDocumentation.wl *)
<<Wolfram`MCPServer`Tools`PacletDocumentation`EditSymbolPacletDocumentation`;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*EditSymbolPacletDocumentationExamples Implementation*)
(* Load definitions from ./EditSymbolPacletDocumentationExamples.wl *)
<<Wolfram`MCPServer`Tools`PacletDocumentation`EditSymbolPacletDocumentationExamples`;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
