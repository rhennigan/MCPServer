(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    If[ ! TrueQ @ Wolfram`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ { DirectoryName[ $TestFileName ], "Common.wl" }
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/PacletDocumentationTools.wlt:4,1-11,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/PacletDocumentationTools.wlt:13,1-18,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Retrieval*)

VerificationTest[
    $createDocTool = $DefaultMCPTools[ "CreateSymbolDoc" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "CreateSymbolDoc-GetTool@@Tests/PacletDocumentationTools.wlt:24,1-29,2"
]

VerificationTest[
    $editDocTool = $DefaultMCPTools[ "EditSymbolDoc" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "EditSymbolDoc-GetTool@@Tests/PacletDocumentationTools.wlt:31,1-36,2"
]

VerificationTest[
    $editExamplesTool = $DefaultMCPTools[ "EditSymbolDocExamples" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "EditSymbolDocExamples-GetTool@@Tests/PacletDocumentationTools.wlt:38,1-43,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreateSymbolPacletDocumentation Tests*)

(* Test basic creation with minimal parameters *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something with *x*."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        AssociationQ[result] && KeyExistsQ[result, "file"] && KeyExistsQ[result, "uri"]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-BasicCreation@@Tests/PacletDocumentationTools.wlt:50,1-64,2"
]

(* Test file is created at correct location *)
VerificationTest[
    Module[{testDir, result, expectedPath},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "MyFunction",
            "pacletName" -> "MyPaclet",
            "usage" -> "- `MyFunction[x]` adds one to *x*."
        |>];
        expectedPath = FileNameJoin[{testDir, "Documentation", "English", "ReferencePages", "Symbols", "MyFunction.nb"}];
        DeleteDirectory[testDir, DeleteContents -> True];
        result["file"] === expectedPath
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-FileLocation@@Tests/PacletDocumentationTools.wlt:67,1-82,2"
]

(* Test URI is constructed correctly without publisher ID *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result["uri"]
    ],
    "TestPaclet/ref/TestFunc",
    TestID -> "CreateSymbolPacletDocumentation-URIWithoutPublisher@@Tests/PacletDocumentationTools.wlt:85,1-99,2"
]

(* Test URI is constructed correctly with publisher ID *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "AddOne",
            "pacletName" -> "MathUtils",
            "publisherID" -> "JohnDoe",
            "usage" -> "- `AddOne[x]` adds one to *x*."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result["uri"]
    ],
    "JohnDoe/MathUtils/ref/AddOne",
    TestID -> "CreateSymbolPacletDocumentation-URIWithPublisher@@Tests/PacletDocumentationTools.wlt:102,1-117,2"
]

(* Test URI when publisher ID is included in pacletName *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "MyFunc",
            "pacletName" -> "Publisher/PackageName",
            "usage" -> "- `MyFunc[x]` does something."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result["uri"]
    ],
    "Publisher/PackageName/ref/MyFunc",
    TestID -> "CreateSymbolPacletDocumentation-URIWithPublisherInPacletName@@Tests/PacletDocumentationTools.wlt:120,1-134,2"
]

(* Test created notebook is valid Notebook expression *)
VerificationTest[
    Module[{testDir, result, nb},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        DeleteDirectory[testDir, DeleteContents -> True];
        MatchQ[nb, _Notebook]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-ValidNotebook@@Tests/PacletDocumentationTools.wlt:137,1-152,2"
]

(* Test notebook contains ObjectName cell *)
VerificationTest[
    Module[{testDir, result, nb, cells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        cells = Cases[nb, Cell[_, "ObjectName" | "ObjectNameGrid", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[cells] > 0
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasObjectNameCell@@Tests/PacletDocumentationTools.wlt:155,1-171,2"
]

(* Test notebook contains Usage cell *)
VerificationTest[
    Module[{testDir, result, nb, cells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        cells = Cases[nb, Cell[_, "Usage", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[cells] > 0
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasUsageCell@@Tests/PacletDocumentationTools.wlt:174,1-190,2"
]

(* Test creation with multiple usage cases *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "MultiFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `MultiFunc[x]` does something with *x*.\n- `MultiFunc[x, y]` does something with *x* and *y*."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        AssociationQ[result]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-MultipleUsageCases@@Tests/PacletDocumentationTools.wlt:193,1-207,2"
]

(* Test creation with all optional parameters *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "FullFunc",
            "pacletName" -> "TestPaclet",
            "publisherID" -> "TestPublisher",
            "usage" -> "- `FullFunc[x]` does something.",
            "notes" -> "This function has notes.\n\n`FullFunc` threads over lists.",
            "seeAlso" -> "Plus, Minus",
            "techNotes" -> "[Tutorial](paclet:TestPublisher/TestPaclet/tutorial/Example)",
            "relatedGuides" -> "[Guide](paclet:TestPublisher/TestPaclet/guide/Example)",
            "relatedLinks" -> "[Wolfram](https://wolfram.com)",
            "keywords" -> "test, example, full",
            "newInVersion" -> "1.0",
            "basicExamples" -> "A basic example:\n\n```wl\n1 + 1\n```"
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        AssociationQ[result] && FileExistsQ[result["file"]] === False (* file was deleted with dir *)
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-AllOptionalParameters@@Tests/PacletDocumentationTools.wlt:210,1-233,2"
]

(* Test error: empty usage *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Quiet @ $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> ""
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        (* Error should return $Failed or a Failure, not a valid result *)
        FailureQ[result] || result === $Failed || !AssociationQ[parseToolResult[result]]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-ErrorEmptyUsage@@Tests/PacletDocumentationTools.wlt:236,1-251,2"
]

(* Test error: invalid usage format (no bullet points) *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Quiet @ $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "This is not a valid usage format"
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        (* Error should return $Failed or a Failure, not a valid result *)
        FailureQ[result] || result === $Failed || !AssociationQ[parseToolResult[result]]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-ErrorInvalidUsageFormat@@Tests/PacletDocumentationTools.wlt:254,1-269,2"
]

(* Test error: file already exists - verifies message is issued *)
VerificationTest[
    Module[{testDir, result1, outputFile, result2},
        testDir = CreateDirectory[];
        (* Create first notebook *)
        result1 = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "ExistingFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `ExistingFunc[x]` does something."
        |>];
        (* Verify first creation succeeded *)
        outputFile = FileNameJoin[{testDir, "Documentation", "English", "ReferencePages", "Symbols", "ExistingFunc.nb"}];
        If[!FileExistsQ[outputFile],
            DeleteDirectory[testDir, DeleteContents -> True];
            Return[$Failed, Module]
        ];
        (* Try to create same notebook again - should generate error message *)
        result2 = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "ExistingFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `ExistingFunc[x]` does something DIFFERENT."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        (* Test passes if error message was generated *)
        True
    ],
    True,
    { MCPServer::NotebookFileExists },
    SameTest -> MatchQ,
    TestID -> "CreateSymbolPacletDocumentation-ErrorFileExists@@Tests/PacletDocumentationTools.wlt:272,1-303,2"
]

(* Test that directories are created automatically *)
VerificationTest[
    Module[{testDir, result, docDir},
        testDir = CreateDirectory[];
        (* Delete any existing doc directory to ensure it gets created *)
        docDir = FileNameJoin[{testDir, "Documentation"}];
        If[DirectoryQ[docDir], DeleteDirectory[docDir, DeleteContents -> True]];

        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];

        DeleteDirectory[testDir, DeleteContents -> True];
        AssociationQ[result] && StringQ[result["file"]]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-CreatesDirectories@@Tests/PacletDocumentationTools.wlt:306,1-325,2"
]

(* Test notebook has correct TaggingRules for paclet *)
VerificationTest[
    Module[{testDir, result, nb, taggingRules},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        taggingRules = Cases[nb, (TaggingRules -> rules_) :> rules, Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[taggingRules] > 0 && MatchQ[First[taggingRules], _Association | {___Rule}]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasTaggingRules@@Tests/PacletDocumentationTools.wlt:328,1-344,2"
]

(* Test TaggingRules contains correct paclet base *)
VerificationTest[
    Module[{testDir, result, nb, allTaggingRules, pacletValue},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "MyPaclet",
            "publisherID" -> "Publisher",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        allTaggingRules = Cases[nb, (TaggingRules -> rules_) :> rules, Infinity];
        (* Find the TaggingRules that contains a "Paclet" key *)
        pacletValue = First[
            Cases[allTaggingRules, assoc_Association /; KeyExistsQ[assoc, "Paclet"] :> assoc["Paclet"]],
            Missing[]
        ];
        DeleteDirectory[testDir, DeleteContents -> True];
        pacletValue === "Publisher/MyPaclet"
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-TaggingRulesPacletBase@@Tests/PacletDocumentationTools.wlt:347,1-369,2"
]

(* Test notebook contains Notes cells when notes provided *)
VerificationTest[
    Module[{testDir, result, nb, notesCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "notes" -> "This is an important note.\n\nAnother note here."
        |>];
        nb = Import[result["file"], "NB"];
        notesCells = Cases[nb, Cell[_, "Notes", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        (* Should have notes cells with actual content, not just placeholder *)
        Length[notesCells] >= 2
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasNotesCells@@Tests/PacletDocumentationTools.wlt:372,1-390,2"
]

(* Test notebook contains placeholder Notes cell when no notes provided *)
VerificationTest[
    Module[{testDir, result, nb, notesCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        notesCells = Cases[nb, Cell["XXXX", "Notes", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[notesCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-PlaceholderNotes@@Tests/PacletDocumentationTools.wlt:393,1-409,2"
]

(* Test notebook contains See Also section *)
VerificationTest[
    Module[{testDir, result, nb, seeAlsoCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "seeAlso" -> "Plus, Minus\nTimes"
        |>];
        nb = Import[result["file"], "NB"];
        seeAlsoCells = Cases[nb, Cell[_, "SeeAlso" | "SeeAlsoSection", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[seeAlsoCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasSeeAlsoSection@@Tests/PacletDocumentationTools.wlt:412,1-429,2"
]

(* Test See Also section contains button boxes for specified symbols *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "seeAlso" -> "Plus, Minus"
        |>];
        nb = Import[result["file"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["Plus" | "Minus", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[buttonBoxes] >= 2
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-SeeAlsoContainsSymbols@@Tests/PacletDocumentationTools.wlt:432,1-449,2"
]

(* Test notebook contains Tech Notes section *)
VerificationTest[
    Module[{testDir, result, nb, tutorialsCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "techNotes" -> "[My Tutorial](paclet:TestPaclet/tutorial/MyTutorial)"
        |>];
        nb = Import[result["file"], "NB"];
        tutorialsCells = Cases[nb, Cell[_, "Tutorials", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[tutorialsCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasTechNotesSection@@Tests/PacletDocumentationTools.wlt:452,1-469,2"
]

(* Test Tech Notes contains link buttons *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "techNotes" -> "[My Tutorial](paclet:TestPaclet/tutorial/MyTutorial)"
        |>];
        nb = Import[result["file"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["My Tutorial", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[buttonBoxes] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-TechNotesContainsLinks@@Tests/PacletDocumentationTools.wlt:472,1-489,2"
]

(* Test notebook contains Related Guides section *)
VerificationTest[
    Module[{testDir, result, nb, moreAboutCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "relatedGuides" -> "[My Guide](paclet:TestPaclet/guide/MyGuide)"
        |>];
        nb = Import[result["file"], "NB"];
        moreAboutCells = Cases[nb, Cell[_, "MoreAbout", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[moreAboutCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasRelatedGuidesSection@@Tests/PacletDocumentationTools.wlt:492,1-509,2"
]

(* Test Related Guides contains link buttons *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "relatedGuides" -> "[My Guide](paclet:TestPaclet/guide/MyGuide)"
        |>];
        nb = Import[result["file"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["My Guide", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[buttonBoxes] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-RelatedGuidesContainsLinks@@Tests/PacletDocumentationTools.wlt:512,1-529,2"
]

(* Test notebook contains Related Links section with URL *)
VerificationTest[
    Module[{testDir, result, nb, relatedLinksCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "relatedLinks" -> "[Wolfram](https://wolfram.com)"
        |>];
        nb = Import[result["file"], "NB"];
        relatedLinksCells = Cases[nb, Cell[_, "RelatedLinks", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[relatedLinksCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasRelatedLinksSection@@Tests/PacletDocumentationTools.wlt:532,1-549,2"
]

(* Test Related Links contains hyperlink buttons with URL *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "relatedLinks" -> "[Wolfram](https://wolfram.com)"
        |>];
        nb = Import[result["file"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["Wolfram", BaseStyle -> "Hyperlink", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[buttonBoxes] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-RelatedLinksContainsHyperlinks@@Tests/PacletDocumentationTools.wlt:552,1-569,2"
]

(* Test notebook contains Keywords section *)
VerificationTest[
    Module[{testDir, result, nb, keywordsCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "keywords" -> "test, example, keyword"
        |>];
        nb = Import[result["file"], "NB"];
        keywordsCells = Cases[nb, Cell[_, "Keywords", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[keywordsCells] >= 3
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasKeywordsSection@@Tests/PacletDocumentationTools.wlt:572,1-589,2"
]

(* Test Keywords cells contain specified keywords *)
VerificationTest[
    Module[{testDir, result, nb, keywordsCells, keywordTexts},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "keywords" -> "test, example"
        |>];
        nb = Import[result["file"], "NB"];
        keywordsCells = Cases[nb, Cell[content_String, "Keywords", ___] :> content, Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        MemberQ[keywordsCells, "test"] && MemberQ[keywordsCells, "example"]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-KeywordsContainSpecifiedContent@@Tests/PacletDocumentationTools.wlt:592,1-609,2"
]

(* Test notebook contains History cell with newInVersion *)
VerificationTest[
    Module[{testDir, result, nb, historyCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "newInVersion" -> "1.5"
        |>];
        nb = Import[result["file"], "NB"];
        historyCells = Cases[nb, Cell[_, "History", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[historyCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasHistoryCell@@Tests/PacletDocumentationTools.wlt:612,1-629,2"
]

(* Test History cell contains version number *)
VerificationTest[
    Module[{testDir, result, nb, historyData},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "newInVersion" -> "2.0"
        |>];
        nb = Import[result["file"], "NB"];
        (* Version appears in CellChangeTimes or similar metadata structure *)
        historyData = Cases[nb, "2.0", Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[historyData] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HistoryContainsVersion@@Tests/PacletDocumentationTools.wlt:632,1-650,2"
]

(* Test notebook contains Basic Examples section with content *)
VerificationTest[
    Module[{testDir, result, nb, exampleCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "basicExamples" -> "A simple example:\n\n```wl\n1 + 1\n```"
        |>];
        nb = Import[result["file"], "NB"];
        exampleCells = Cases[nb, Cell[_, "ExampleText" | "Input", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[exampleCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasBasicExamplesContent@@Tests/PacletDocumentationTools.wlt:653,1-670,2"
]

(* Test Basic Examples generates Output cells *)
VerificationTest[
    Module[{testDir, result, nb, outputCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "basicExamples" -> "Compute something:\n\n```wl\n2 + 3\n```"
        |>];
        nb = Import[result["file"], "NB"];
        outputCells = Cases[nb, Cell[_, "Output", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[outputCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-BasicExamplesHasOutputCells@@Tests/PacletDocumentationTools.wlt:673,1-690,2"
]

(* Test Basic Examples with multiple groups creates ExampleDelimiter cells *)
VerificationTest[
    Module[{testDir, result, nb, delimiterCells},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "basicExamples" -> "First example:\n\n```wl\n1 + 1\n```\n\n---\n\nSecond example:\n\n```wl\n2 + 2\n```"
        |>];
        nb = Import[result["file"], "NB"];
        delimiterCells = Cases[nb, Cell[_, "ExampleDelimiter", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[delimiterCells] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-BasicExamplesHasDelimiters@@Tests/PacletDocumentationTools.wlt:693,1-710,2"
]

(* Test notebook contains PrimaryExamplesSection *)
VerificationTest[
    Module[{testDir, result, nb, primarySection},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        primarySection = Cases[nb, Cell[_, "PrimaryExamplesSection", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[primarySection] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasPrimaryExamplesSection@@Tests/PacletDocumentationTools.wlt:713,1-729,2"
]

(* Test notebook contains ExtendedExamplesSection with CellTags *)
VerificationTest[
    Module[{testDir, result, nb, extendedSection},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        (* CellTags can be a string or list, so check for both *)
        extendedSection = Cases[nb,
            Cell[_, _, ___, CellTags -> tags_, ___] /; MemberQ[Flatten[{tags}], "ExtendedExamples"],
            Infinity
        ];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[extendedSection] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasExtendedExamplesSection@@Tests/PacletDocumentationTools.wlt:732,1-752,2"
]

(* Test notebook contains ExampleSection cells for extended sections *)
VerificationTest[
    Module[{testDir, result, nb, exampleSections},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        exampleSections = Cases[nb, Cell[_, "ExampleSection", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        (* Should have multiple extended sections: Scope, Options, Applications, etc. *)
        Length[exampleSections] >= 5
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasExtendedSections@@Tests/PacletDocumentationTools.wlt:755,1-772,2"
]

(* Test custom context parameter is used *)
VerificationTest[
    Module[{testDir, result, nb, contextRefs},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "context" -> "CustomContext`Nested`"
        |>];
        nb = Import[result["file"], "NB"];
        (* Check for context in notebook metadata or cell options *)
        contextRefs = Cases[nb, "CustomContext`Nested`", Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[contextRefs] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-CustomContextUsed@@Tests/PacletDocumentationTools.wlt:775,1-793,2"
]

(* Test context is correctly built from publisher and paclet name *)
VerificationTest[
    Module[{testDir, result, nb, contextRefs},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "MyPaclet",
            "publisherID" -> "Publisher",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        (* Context should be Publisher`MyPaclet` *)
        contextRefs = Cases[nb, "Publisher`MyPaclet`", Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[contextRefs] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-ContextFromPublisher@@Tests/PacletDocumentationTools.wlt:796,1-814,2"
]

(* Test context is correctly built from paclet name with embedded publisher *)
VerificationTest[
    Module[{testDir, result, nb, contextRefs},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "Vendor/Package",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        (* Context should be Vendor`Package` *)
        contextRefs = Cases[nb, "Vendor`Package`", Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[contextRefs] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-ContextFromEmbeddedPublisher@@Tests/PacletDocumentationTools.wlt:817,1-834,2"
]

(* Test Usage cell contains correct syntax *)
VerificationTest[
    Module[{testDir, result, nb, usageCells, usageContent},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "AddOne",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `AddOne[x]` adds one to *x*."
        |>];
        nb = Import[result["file"], "NB"];
        (* Find button boxes with symbol name *)
        usageContent = Cases[nb, ButtonBox["AddOne", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[usageContent] >= 1
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-UsageContainsSyntax@@Tests/PacletDocumentationTools.wlt:837,1-854,2"
]

(* Test Usage cell contains argument formatting *)
VerificationTest[
    Module[{testDir, result, nb, usageContent},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "AddOne",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `AddOne[x]` adds one to *x*.\n- `AddOne[x, y]` adds *x* and *y*."
        |>];
        nb = Import[result["file"], "NB"];
        (* Find InlineFormula cells which contain the argument syntax *)
        usageContent = Cases[nb, Cell[_, "InlineFormula", ___], Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[usageContent] >= 2
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-UsageContainsArgumentFormatting@@Tests/PacletDocumentationTools.wlt:857,1-874,2"
]

(* Test that StyleDefinitions is set correctly *)
VerificationTest[
    Module[{testDir, result, nb, styleDef},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        nb = Import[result["file"], "NB"];
        styleDef = Cases[nb, (StyleDefinitions -> sd_) :> sd, Infinity];
        DeleteDirectory[testDir, DeleteContents -> True];
        Length[styleDef] >= 1 && MatchQ[First[styleDef], _FrontEnd`FileName]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-HasStyleDefinitions@@Tests/PacletDocumentationTools.wlt:877,1-893,2"
]

(* Test Notes section handles tables correctly *)
VerificationTest[
    Module[{testDir, result, nb},
        testDir = CreateDirectory[];
        result = $createDocTool[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something.",
            "notes" -> "Options:\n\n| Option | Default |\n|--------|---------||\n| Method | Auto |"
        |>];
        nb = Import[result["file"], "NB"];
        DeleteDirectory[testDir, DeleteContents -> True];
        (* Should succeed even with table in notes *)
        MatchQ[nb, _Notebook]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-NotesWithTable@@Tests/PacletDocumentationTools.wlt:896,1-913,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*EditSymbolPacletDocumentationExamples Tests*)

(* Helper to create a test environment *)
createTestEnvironment[] := Module[{testDir, result},
    testDir = CreateDirectory[];
    result = $createDocTool[<|
        "pacletDirectory" -> testDir,
        "symbolName" -> "TestFunc",
        "pacletName" -> "TestPaclet",
        "usage" -> "- `TestFunc[x]` does something with *x*.",
        "basicExamples" -> "A basic example:\n\n```wl\n1 + 1\n```"
    |>];
    <|"testDir" -> testDir, "notebookPath" -> result["file"]|>
];

cleanupTestEnvironment[env_Association] :=
    DeleteDirectory[env["testDir"], DeleteContents -> True];

(* Test appendExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "A second example:\n\n```wl\n2 + 2\n```"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "appendExample",
    TestID -> "EditSymbolPacletDocumentationExamples-AppendExample@@Tests/PacletDocumentationTools.wlt:936,1-950,2"
]

(* Test prependExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "prependExample",
            "section" -> "BasicExamples",
            "content" -> "A prepended example:\n\n```wl\n0 + 0\n```"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "prependExample",
    TestID -> "EditSymbolPacletDocumentationExamples-PrependExample@@Tests/PacletDocumentationTools.wlt:953,1-967,2"
]

(* Test setExamples operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setExamples",
            "section" -> "BasicExamples",
            "content" -> "Replaced example:\n\n```wl\n5 + 5\n```\n\n---\n\nAnother example:\n\n```wl\n6 + 6\n```"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "setExamples",
    TestID -> "EditSymbolPacletDocumentationExamples-SetExamples@@Tests/PacletDocumentationTools.wlt:970,1-984,2"
]

(* Test clearExamples operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "clearExamples",
            "section" -> "BasicExamples"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "clearExamples",
    TestID -> "EditSymbolPacletDocumentationExamples-ClearExamples@@Tests/PacletDocumentationTools.wlt:987,1-1000,2"
]

(* Test insertExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        (* First append another example so we have multiple *)
        $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "Second example:\n\n```wl\n2 + 2\n```"
        |>];
        (* Now insert at position 2 (1-indexed: between first and second) *)
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "insertExample",
            "section" -> "BasicExamples",
            "content" -> "Inserted example:\n\n```wl\n99\n```",
            "position" -> 2  (* 1-indexed: insert at second position *)
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "insertExample",
    TestID -> "EditSymbolPacletDocumentationExamples-InsertExample@@Tests/PacletDocumentationTools.wlt:1003,1-1026,2"
]

(* Test replaceExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "replaceExample",
            "section" -> "BasicExamples",
            "content" -> "Replaced first example:\n\n```wl\n100\n```",
            "position" -> 1  (* 1-indexed: 1 = first element *)
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "replaceExample",
    TestID -> "EditSymbolPacletDocumentationExamples-ReplaceExample@@Tests/PacletDocumentationTools.wlt:1029,1-1044,2"
]

(* Test removeExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        (* First append another example so we have multiple *)
        $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "Second example:\n\n```wl\n2 + 2\n```"
        |>];
        (* Now remove the first example *)
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "removeExample",
            "section" -> "BasicExamples",
            "position" -> 1  (* 1-indexed: 1 = first element *)
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "removeExample",
    TestID -> "EditSymbolPacletDocumentationExamples-RemoveExample@@Tests/PacletDocumentationTools.wlt:1047,1-1069,2"
]

(* Test invalid section name *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Quiet @ $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "InvalidSection",
            "content" -> "test"
        |>];
        cleanupTestEnvironment[env];
        (* Error should return $Failed or a Failure, not a valid result *)
        FailureQ[result] || result === $Failed || !AssociationQ[parseToolResult[result]]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-InvalidSection@@Tests/PacletDocumentationTools.wlt:1072,1-1087,2"
]

(* Test invalid operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Quiet @ $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "invalidOp",
            "section" -> "BasicExamples",
            "content" -> "test"
        |>];
        cleanupTestEnvironment[env];
        (* Error should return $Failed or a Failure, not a valid result *)
        FailureQ[result] || result === $Failed || !AssociationQ[parseToolResult[result]]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-InvalidOperation@@Tests/PacletDocumentationTools.wlt:1090,1-1105,2"
]

(* Test notebook not found *)
VerificationTest[
    Module[{result},
        result = Quiet @ $editExamplesTool[<|
            "notebook" -> "C:\\nonexistent\\path\\to\\notebook.nb",
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "test"
        |>];
        (* Error should return $Failed or a Failure, not a valid result *)
        FailureQ[result] || result === $Failed || !AssociationQ[parseToolResult[result]]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-NotebookNotFound@@Tests/PacletDocumentationTools.wlt:1108,1-1121,2"
]

(* Test that generatedContent is returned for append *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = $editExamplesTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "Test:\n\n```wl\n3 + 3\n```"
        |>];
        cleanupTestEnvironment[env];
        StringQ[result["generatedContent"]] && StringContainsQ[result["generatedContent"], "wl-output"]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-GeneratedContentReturned@@Tests/PacletDocumentationTools.wlt:1124,1-1138,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*EditSymbolPacletDocumentation Tests*)

(* Helper to create a test environment for EditSymbolPacletDocumentation tests *)
createEditTestEnvironment[] := Module[{testDir, result},
    testDir = CreateDirectory[];
    result = $createDocTool[<|
        "pacletDirectory" -> testDir,
        "symbolName" -> "EditTestFunc",
        "pacletName" -> "TestPaclet",
        "publisherID" -> "TestPublisher",
        "usage" -> "- `EditTestFunc[x]` does something with *x*.\n- `EditTestFunc[x, y]` does something with *x* and *y*.",
        "notes" -> "This is an initial note.\n\nAnother initial note.",
        "seeAlso" -> "Plus, Minus",
        "techNotes" -> "[Initial Tutorial](paclet:TestPaclet/tutorial/Initial)",
        "relatedGuides" -> "[Initial Guide](paclet:TestPaclet/guide/Initial)",
        "relatedLinks" -> "[Initial Link](https://initial.example.com)",
        "keywords" -> "initial, test",
        "newInVersion" -> "1.0",
        "basicExamples" -> "A basic example:\n\n```wl\n1 + 1\n```"
    |>];
    <|"testDir" -> testDir, "notebookPath" -> result["file"]|>
];

cleanupEditTestEnvironment[env_Association] :=
    DeleteDirectory[env["testDir"], DeleteContents -> True];

(* Test setUsage operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setUsage",
            "content" -> "- `EditTestFunc[a]` computes something with *a*.\n- `EditTestFunc[a, b, c]` combines *a*, *b*, and *c*."
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setUsage",
    TestID -> "EditSymbolPacletDocumentation-SetUsage-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1169,1-1182,2"
]

(* Test setUsage operation - verify usage cell is updated *)
VerificationTest[
    Module[{env, result, nb, usageContent},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setUsage",
            "content" -> "- `EditTestFunc[newArg]` is the new usage."
        |>];
        nb = Import[env["notebookPath"], "NB"];
        (* Check for the new usage syntax in ButtonBox *)
        usageContent = Cases[nb, ButtonBox["EditTestFunc", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[usageContent] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetUsage-VerifyUpdate@@Tests/PacletDocumentationTools.wlt:1185,1-1201,2"
]

(* Test setNotes operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setNotes",
            "content" -> "This is a completely new note.\n\nAnd another new note."
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setNotes",
    TestID -> "EditSymbolPacletDocumentation-SetNotes-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1204,1-1217,2"
]

(* Test setNotes operation - verify notes cells are replaced *)
VerificationTest[
    Module[{env, nb, notesCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setNotes",
            "content" -> "Replaced note one.\n\nReplaced note two.\n\nReplaced note three."
        |>];
        nb = Import[env["notebookPath"], "NB"];
        notesCells = Cases[nb, Cell[_, "Notes", ___], Infinity];
        cleanupEditTestEnvironment[env];
        (* Should have at least 3 notes cells now *)
        Length[notesCells] >= 3
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetNotes-VerifyReplacement@@Tests/PacletDocumentationTools.wlt:1220,1-1236,2"
]

(* Test addNote operation at end (default) *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "addNote",
            "content" -> "This is an added note at the end."
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "addNote",
    TestID -> "EditSymbolPacletDocumentation-AddNote-AtEnd@@Tests/PacletDocumentationTools.wlt:1239,1-1252,2"
]

(* Test addNote operation at start *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "addNote",
            "content" -> "This is an added note at the start.",
            "position" -> 1  (* 1-indexed: 1 = insert at start *)
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "addNote",
    TestID -> "EditSymbolPacletDocumentation-AddNote-AtStart@@Tests/PacletDocumentationTools.wlt:1255,1-1269,2"
]

(* Test addNote operation at specific position *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "addNote",
            "content" -> "This is an inserted note.",
            "position" -> 2  (* 1-indexed: 2 = insert at second position *)
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "addNote",
    TestID -> "EditSymbolPacletDocumentation-AddNote-AtPosition@@Tests/PacletDocumentationTools.wlt:1272,1-1286,2"
]

(* Test setDetailsTable operation *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setDetailsTable",
            "content" -> "The value for *x* can be any of the following:\n\n| Value | Description |\n|-------|-------------|\n| *int* | an `Integer` |\n| *real* | a `Real` number |"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setDetailsTable",
    TestID -> "EditSymbolPacletDocumentation-SetDetailsTable-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1289,1-1302,2"
]

(* Test setSeeAlso operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "Times, Divide\nPower, Sqrt"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setSeeAlso",
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1305,1-1318,2"
]

(* Test setSeeAlso operation - verify button boxes are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "NewSymbol1, NewSymbol2"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["NewSymbol1" | "NewSymbol2", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[buttonBoxes] >= 2
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-VerifyButtonBoxes@@Tests/PacletDocumentationTools.wlt:1321,1-1336,2"
]

(* Test setTechNotes operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setTechNotes",
            "content" -> "[New Tutorial 1](paclet:TestPaclet/tutorial/NewTutorial1)\n[New Tutorial 2](paclet:TestPaclet/tutorial/NewTutorial2)"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setTechNotes",
    TestID -> "EditSymbolPacletDocumentation-SetTechNotes-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1339,1-1352,2"
]

(* Test setTechNotes operation - verify links are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setTechNotes",
            "content" -> "[Updated Tech Note](paclet:TestPaclet/tutorial/UpdatedTech)"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["Updated Tech Note", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[buttonBoxes] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetTechNotes-VerifyLinks@@Tests/PacletDocumentationTools.wlt:1355,1-1370,2"
]

(* Test setRelatedGuides operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedGuides",
            "content" -> "[New Guide 1](paclet:TestPaclet/guide/NewGuide1)\n[New Guide 2](paclet:TestPaclet/guide/NewGuide2)"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setRelatedGuides",
    TestID -> "EditSymbolPacletDocumentation-SetRelatedGuides-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1373,1-1386,2"
]

(* Test setRelatedGuides operation - verify links are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedGuides",
            "content" -> "[Updated Guide](paclet:TestPaclet/guide/UpdatedGuide)"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["Updated Guide", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[buttonBoxes] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetRelatedGuides-VerifyLinks@@Tests/PacletDocumentationTools.wlt:1389,1-1404,2"
]

(* Test setRelatedLinks operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedLinks",
            "content" -> "[New External Link](https://new.example.com)\n[Another Link](https://another.example.com)"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setRelatedLinks",
    TestID -> "EditSymbolPacletDocumentation-SetRelatedLinks-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1407,1-1420,2"
]

(* Test setRelatedLinks operation - verify hyperlinks are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedLinks",
            "content" -> "[Updated External](https://updated.example.com)"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["Updated External", BaseStyle -> "Hyperlink", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[buttonBoxes] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetRelatedLinks-VerifyHyperlinks@@Tests/PacletDocumentationTools.wlt:1423,1-1438,2"
]

(* Test setKeywords operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setKeywords",
            "content" -> "new, keywords, updated, test"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setKeywords",
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1441,1-1454,2"
]

(* Test setKeywords operation - verify keywords cells are updated *)
VerificationTest[
    Module[{env, nb, keywordsCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setKeywords",
            "content" -> "alpha, beta, gamma"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        keywordsCells = Cases[nb, Cell[content_String, "Keywords", ___] :> content, Infinity];
        cleanupEditTestEnvironment[env];
        MemberQ[keywordsCells, "alpha"] && MemberQ[keywordsCells, "beta"] && MemberQ[keywordsCells, "gamma"]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-VerifyKeywords@@Tests/PacletDocumentationTools.wlt:1457,1-1472,2"
]

(* Test setHistory operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setHistory",
            "content" -> "new:2.0, modified:2.5"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setHistory",
    TestID -> "EditSymbolPacletDocumentation-SetHistory-BasicFunctionality@@Tests/PacletDocumentationTools.wlt:1475,1-1488,2"
]

(* Test setHistory operation - verify version number is present *)
VerificationTest[
    Module[{env, nb, historyData},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setHistory",
            "content" -> "new:3.0, modified:3.5, obsolete:4.0"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        (* Check for version numbers in the notebook *)
        historyData = Cases[nb, "3.0" | "3.5" | "4.0", Infinity];
        cleanupEditTestEnvironment[env];
        Length[historyData] >= 3
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetHistory-VerifyVersions@@Tests/PacletDocumentationTools.wlt:1491,1-1507,2"
]

(* Test that file path is returned correctly *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "Plus"
        |>];
        cleanupEditTestEnvironment[env];
        StringQ[result["file"]] && StringEndsQ[result["file"], ".nb"]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-ReturnsFilePath@@Tests/PacletDocumentationTools.wlt:1510,1-1523,2"
]

(* Test error: invalid operation *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Quiet @ $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "invalidOperation",
            "content" -> "test"
        |>];
        cleanupEditTestEnvironment[env];
        (* Error should return $Failed or a Failure, not a valid result *)
        FailureQ[result] || result === $Failed || !AssociationQ[parseToolResult[result]]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-ErrorInvalidOperation@@Tests/PacletDocumentationTools.wlt:1526,1-1540,2"
]

(* Test error: notebook not found *)
VerificationTest[
    Module[{result},
        result = Quiet @ $editDocTool[<|
            "notebook" -> "C:\\nonexistent\\path\\to\\notebook.nb",
            "operation" -> "setSeeAlso",
            "content" -> "Plus"
        |>];
        (* Error should return $Failed or a Failure, not a valid result *)
        FailureQ[result] || result === $Failed || !AssociationQ[parseToolResult[result]]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-ErrorNotebookNotFound@@Tests/PacletDocumentationTools.wlt:1543,1-1555,2"
]

(* Test setUsage with single usage case *)
VerificationTest[
    Module[{env, result, nb, usageCells},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setUsage",
            "content" -> "- `EditTestFunc[singleArg]` performs a single operation on *singleArg*."
        |>];
        nb = Import[env["notebookPath"], "NB"];
        usageCells = Cases[nb, Cell[_, "Usage", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[usageCells] >= 1 && result["operation"] === "setUsage"
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetUsage-SingleCase@@Tests/PacletDocumentationTools.wlt:1558,1-1573,2"
]

(* Test setNotes with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, notesCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setNotes",
            "content" -> ""
        |>];
        nb = Import[env["notebookPath"], "NB"];
        notesCells = Cases[nb, Cell["XXXX", "Notes", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[notesCells] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetNotes-EmptyCreatesPlaceholder@@Tests/PacletDocumentationTools.wlt:1576,1-1591,2"
]

(* Test setSeeAlso with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> ""
        |>];
        nb = Import[env["notebookPath"], "NB"];
        (* Look for placeholder in SeeAlso section *)
        placeholderCells = Cases[nb, FrameBox["\"XXXX\"", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[placeholderCells] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-EmptyCreatesPlaceholder@@Tests/PacletDocumentationTools.wlt:1594,1-1610,2"
]

(* Test setSeeAlso with comma-separated symbols on same line *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "Alpha, Beta, Gamma, Delta"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        buttonBoxes = Cases[nb, ButtonBox["Alpha" | "Beta" | "Gamma" | "Delta", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[buttonBoxes] >= 4
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-CommaSeparated@@Tests/PacletDocumentationTools.wlt:1613,1-1628,2"
]

(* Test setKeywords with newline-separated keywords *)
VerificationTest[
    Module[{env, nb, keywordsCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setKeywords",
            "content" -> "keyword1\nkeyword2\nkeyword3"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        keywordsCells = Cases[nb, Cell[content_String, "Keywords", ___] :> content, Infinity];
        cleanupEditTestEnvironment[env];
        MemberQ[keywordsCells, "keyword1"] && MemberQ[keywordsCells, "keyword2"] && MemberQ[keywordsCells, "keyword3"]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-NewlineSeparated@@Tests/PacletDocumentationTools.wlt:1631,1-1646,2"
]

(* Test setTechNotes with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setTechNotes",
            "content" -> ""
        |>];
        nb = Import[env["notebookPath"], "NB"];
        placeholderCells = Cases[nb, Cell["XXXX", "Tutorials", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[placeholderCells] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetTechNotes-EmptyCreatesPlaceholder@@Tests/PacletDocumentationTools.wlt:1649,1-1664,2"
]

(* Test setRelatedGuides with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedGuides",
            "content" -> ""
        |>];
        nb = Import[env["notebookPath"], "NB"];
        placeholderCells = Cases[nb, Cell["XXXX", "MoreAbout", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[placeholderCells] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetRelatedGuides-EmptyCreatesPlaceholder@@Tests/PacletDocumentationTools.wlt:1667,1-1682,2"
]

(* Test setRelatedLinks with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedLinks",
            "content" -> ""
        |>];
        nb = Import[env["notebookPath"], "NB"];
        placeholderCells = Cases[nb, Cell["XXXX", "RelatedLinks", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[placeholderCells] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetRelatedLinks-EmptyCreatesPlaceholder@@Tests/PacletDocumentationTools.wlt:1685,1-1700,2"
]

(* Test setKeywords with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setKeywords",
            "content" -> ""
        |>];
        nb = Import[env["notebookPath"], "NB"];
        placeholderCells = Cases[nb, Cell["XXXX", "Keywords", ___], Infinity];
        cleanupEditTestEnvironment[env];
        Length[placeholderCells] >= 1
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-EmptyCreatesPlaceholder@@Tests/PacletDocumentationTools.wlt:1703,1-1718,2"
]

(* Test setHistory with only 'new' field *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setHistory",
            "content" -> "new:5.0"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"] === "setHistory"
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetHistory-OnlyNewField@@Tests/PacletDocumentationTools.wlt:1721,1-1734,2"
]

(* Test multiple sequential operations on same notebook *)
VerificationTest[
    Module[{env, nb, seeAlsoButtons, keywordsCells},
        env = createEditTestEnvironment[];
        (* Perform multiple operations *)
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "SequentialSymbol1, SequentialSymbol2"
        |>];
        $editDocTool[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setKeywords",
            "content" -> "sequential, test, keywords"
        |>];
        nb = Import[env["notebookPath"], "NB"];
        seeAlsoButtons = Cases[nb, ButtonBox["SequentialSymbol1" | "SequentialSymbol2", ___], Infinity];
        keywordsCells = Cases[nb, Cell[content_String, "Keywords", ___] :> content, Infinity];
        cleanupEditTestEnvironment[env];
        Length[seeAlsoButtons] >= 2 && MemberQ[keywordsCells, "sequential"]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-MultipleSequentialOperations@@Tests/PacletDocumentationTools.wlt:1737,1-1759,2"
]
