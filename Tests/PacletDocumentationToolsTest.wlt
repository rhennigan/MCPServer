(* Tests for PacletDocumentation tools *)

(* ::Section:: *)
(* CreateSymbolPacletDocumentation Tests *)

(* Test basic creation with minimal parameters *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something with *x*."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        AssociationQ[result] && KeyExistsQ[result, "file"] && KeyExistsQ[result, "uri"]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-BasicCreation@@Tests/PacletDocumentationToolsTest.wlt:7,1-21,2"
]

(* Test file is created at correct location *)
VerificationTest[
    Module[{testDir, result, expectedPath},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-FileLocation@@Tests/PacletDocumentationToolsTest.wlt:24,1-39,2"
]

(* Test URI is constructed correctly without publisher ID *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result["uri"]
    ],
    "TestPaclet/ref/TestFunc",
    TestID -> "CreateSymbolPacletDocumentation-URIWithoutPublisher@@Tests/PacletDocumentationToolsTest.wlt:42,1-56,2"
]

(* Test URI is constructed correctly with publisher ID *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-URIWithPublisher@@Tests/PacletDocumentationToolsTest.wlt:59,1-74,2"
]

(* Test URI when publisher ID is included in pacletName *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "MyFunc",
            "pacletName" -> "Publisher/PackageName",
            "usage" -> "- `MyFunc[x]` does something."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result["uri"]
    ],
    "Publisher/PackageName/ref/MyFunc",
    TestID -> "CreateSymbolPacletDocumentation-URIWithPublisherInPacletName@@Tests/PacletDocumentationToolsTest.wlt:77,1-91,2"
]

(* Test created notebook is valid Notebook expression *)
VerificationTest[
    Module[{testDir, result, nb},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-ValidNotebook@@Tests/PacletDocumentationToolsTest.wlt:94,1-109,2"
]

(* Test notebook contains ObjectName cell *)
VerificationTest[
    Module[{testDir, result, nb, cells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasObjectNameCell@@Tests/PacletDocumentationToolsTest.wlt:112,1-128,2"
]

(* Test notebook contains Usage cell *)
VerificationTest[
    Module[{testDir, result, nb, cells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasUsageCell@@Tests/PacletDocumentationToolsTest.wlt:131,1-147,2"
]

(* Test creation with multiple usage cases *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "MultiFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `MultiFunc[x]` does something with *x*.\n- `MultiFunc[x, y]` does something with *x* and *y*."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        AssociationQ[result]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-MultipleUsageCases@@Tests/PacletDocumentationToolsTest.wlt:150,1-164,2"
]

(* Test creation with all optional parameters *)
VerificationTest[
    Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-AllOptionalParameters@@Tests/PacletDocumentationToolsTest.wlt:167,1-190,2"
]

(* Test error: empty usage *)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> ""
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result
    ],
    _Failure,
    { MCPServer::EmptyUsage },
    SameTest -> MatchQ,
    TestID -> "CreateSymbolPacletDocumentation-ErrorEmptyUsage@@Tests/PacletDocumentationToolsTest.wlt:193,1-209,2"
]

(* Test error: invalid usage format (no bullet points) *)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Module[{testDir, result},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "This is not a valid usage format"
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result
    ],
    _Failure,
    { MCPServer::InvalidUsageFormat },
    SameTest -> MatchQ,
    TestID -> "CreateSymbolPacletDocumentation-ErrorInvalidUsageFormat@@Tests/PacletDocumentationToolsTest.wlt:212,1-228,2"
]

(* Test error: file already exists *)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Module[{testDir, result1, result2, outputFile},
        testDir = CreateDirectory[];
        (* Create first notebook *)
        result1 = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
        (* Try to create same notebook again - should fail *)
        result2 = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "ExistingFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `ExistingFunc[x]` does something else."
        |>];
        DeleteDirectory[testDir, DeleteContents -> True];
        result2
    ],
    _Failure,
    { MCPServer::NotebookFileExists },
    SameTest -> MatchQ,
    TestID -> "CreateSymbolPacletDocumentation-ErrorFileExists@@Tests/PacletDocumentationToolsTest.wlt:231,1-261,2"
]

(* Test that directories are created automatically *)
VerificationTest[
    Module[{testDir, result, docDir},
        testDir = CreateDirectory[];
        (* Delete any existing doc directory to ensure it gets created *)
        docDir = FileNameJoin[{testDir, "Documentation"}];
        If[DirectoryQ[docDir], DeleteDirectory[docDir, DeleteContents -> True]];

        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
            "pacletDirectory" -> testDir,
            "symbolName" -> "TestFunc",
            "pacletName" -> "TestPaclet",
            "usage" -> "- `TestFunc[x]` does something."
        |>];

        DeleteDirectory[testDir, DeleteContents -> True];
        AssociationQ[result] && StringQ[result["file"]]
    ],
    True,
    TestID -> "CreateSymbolPacletDocumentation-CreatesDirectories@@Tests/PacletDocumentationToolsTest.wlt:264,1-283,2"
]

(* Test notebook has correct TaggingRules for paclet *)
VerificationTest[
    Module[{testDir, result, nb, taggingRules},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasTaggingRules@@Tests/PacletDocumentationToolsTest.wlt:286,1-302,2"
]

(* Test TaggingRules contains correct paclet base *)
VerificationTest[
    Module[{testDir, result, nb, allTaggingRules, pacletValue},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-TaggingRulesPacletBase@@Tests/PacletDocumentationToolsTest.wlt:305,1-327,2"
]

(* Test notebook contains Notes cells when notes provided *)
VerificationTest[
    Module[{testDir, result, nb, notesCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasNotesCells@@Tests/PacletDocumentationToolsTest.wlt:330,1-348,2"
]

(* Test notebook contains placeholder Notes cell when no notes provided *)
VerificationTest[
    Module[{testDir, result, nb, notesCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-PlaceholderNotes@@Tests/PacletDocumentationToolsTest.wlt:351,1-367,2"
]

(* Test notebook contains See Also section *)
VerificationTest[
    Module[{testDir, result, nb, seeAlsoCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasSeeAlsoSection@@Tests/PacletDocumentationToolsTest.wlt:370,1-387,2"
]

(* Test See Also section contains button boxes for specified symbols *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-SeeAlsoContainsSymbols@@Tests/PacletDocumentationToolsTest.wlt:390,1-407,2"
]

(* Test notebook contains Tech Notes section *)
VerificationTest[
    Module[{testDir, result, nb, tutorialsCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasTechNotesSection@@Tests/PacletDocumentationToolsTest.wlt:410,1-427,2"
]

(* Test Tech Notes contains link buttons *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-TechNotesContainsLinks@@Tests/PacletDocumentationToolsTest.wlt:430,1-447,2"
]

(* Test notebook contains Related Guides section *)
VerificationTest[
    Module[{testDir, result, nb, moreAboutCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasRelatedGuidesSection@@Tests/PacletDocumentationToolsTest.wlt:450,1-467,2"
]

(* Test Related Guides contains link buttons *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-RelatedGuidesContainsLinks@@Tests/PacletDocumentationToolsTest.wlt:470,1-487,2"
]

(* Test notebook contains Related Links section with URL *)
VerificationTest[
    Module[{testDir, result, nb, relatedLinksCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasRelatedLinksSection@@Tests/PacletDocumentationToolsTest.wlt:490,1-507,2"
]

(* Test Related Links contains hyperlink buttons with URL *)
VerificationTest[
    Module[{testDir, result, nb, buttonBoxes},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-RelatedLinksContainsHyperlinks@@Tests/PacletDocumentationToolsTest.wlt:510,1-527,2"
]

(* Test notebook contains Keywords section *)
VerificationTest[
    Module[{testDir, result, nb, keywordsCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasKeywordsSection@@Tests/PacletDocumentationToolsTest.wlt:530,1-547,2"
]

(* Test Keywords cells contain specified keywords *)
VerificationTest[
    Module[{testDir, result, nb, keywordsCells, keywordTexts},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-KeywordsContainSpecifiedContent@@Tests/PacletDocumentationToolsTest.wlt:550,1-567,2"
]

(* Test notebook contains History cell with newInVersion *)
VerificationTest[
    Module[{testDir, result, nb, historyCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasHistoryCell@@Tests/PacletDocumentationToolsTest.wlt:570,1-587,2"
]

(* Test History cell contains version number *)
VerificationTest[
    Module[{testDir, result, nb, historyData},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HistoryContainsVersion@@Tests/PacletDocumentationToolsTest.wlt:590,1-608,2"
]

(* Test notebook contains Basic Examples section with content *)
VerificationTest[
    Module[{testDir, result, nb, exampleCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasBasicExamplesContent@@Tests/PacletDocumentationToolsTest.wlt:611,1-628,2"
]

(* Test Basic Examples generates Output cells *)
VerificationTest[
    Module[{testDir, result, nb, outputCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-BasicExamplesHasOutputCells@@Tests/PacletDocumentationToolsTest.wlt:631,1-648,2"
]

(* Test Basic Examples with multiple groups creates ExampleDelimiter cells *)
VerificationTest[
    Module[{testDir, result, nb, delimiterCells},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-BasicExamplesHasDelimiters@@Tests/PacletDocumentationToolsTest.wlt:651,1-668,2"
]

(* Test notebook contains PrimaryExamplesSection *)
VerificationTest[
    Module[{testDir, result, nb, primarySection},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasPrimaryExamplesSection@@Tests/PacletDocumentationToolsTest.wlt:671,1-687,2"
]

(* Test notebook contains ExtendedExamplesSection with CellTags *)
VerificationTest[
    Module[{testDir, result, nb, extendedSection},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasExtendedExamplesSection@@Tests/PacletDocumentationToolsTest.wlt:690,1-710,2"
]

(* Test notebook contains ExampleSection cells for extended sections *)
VerificationTest[
    Module[{testDir, result, nb, exampleSections},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasExtendedSections@@Tests/PacletDocumentationToolsTest.wlt:713,1-730,2"
]

(* Test custom context parameter is used *)
VerificationTest[
    Module[{testDir, result, nb, contextRefs},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-CustomContextUsed@@Tests/PacletDocumentationToolsTest.wlt:733,1-751,2"
]

(* Test context is correctly built from publisher and paclet name *)
VerificationTest[
    Module[{testDir, result, nb, contextRefs},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-ContextFromPublisher@@Tests/PacletDocumentationToolsTest.wlt:754,1-772,2"
]

(* Test context is correctly built from paclet name with embedded publisher *)
VerificationTest[
    Module[{testDir, result, nb, contextRefs},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-ContextFromEmbeddedPublisher@@Tests/PacletDocumentationToolsTest.wlt:775,1-792,2"
]

(* Test Usage cell contains correct syntax *)
VerificationTest[
    Module[{testDir, result, nb, usageCells, usageContent},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-UsageContainsSyntax@@Tests/PacletDocumentationToolsTest.wlt:795,1-812,2"
]

(* Test Usage cell contains argument formatting *)
VerificationTest[
    Module[{testDir, result, nb, usageContent},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-UsageContainsArgumentFormatting@@Tests/PacletDocumentationToolsTest.wlt:815,1-832,2"
]

(* Test that StyleDefinitions is set correctly *)
VerificationTest[
    Module[{testDir, result, nb, styleDef},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-HasStyleDefinitions@@Tests/PacletDocumentationToolsTest.wlt:835,1-851,2"
]

(* Test Notes section handles tables correctly *)
VerificationTest[
    Module[{testDir, result, nb},
        testDir = CreateDirectory[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
    TestID -> "CreateSymbolPacletDocumentation-NotesWithTable@@Tests/PacletDocumentationToolsTest.wlt:854,1-871,2"
]

(* ::Section:: *)
(* EditSymbolPacletDocumentationExamples Tests *)

(* Helper to create a test environment *)
createTestEnvironment[] := Module[{testDir, result},
    testDir = CreateDirectory[];
    result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "A second example:\n\n```wl\n2 + 2\n```"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "appendExample",
    TestID -> "EditSymbolPacletDocumentationExamples-AppendExample@@Tests/PacletDocumentationToolsTest.wlt:893,1-907,2"
]

(* Test prependExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "prependExample",
            "section" -> "BasicExamples",
            "content" -> "A prepended example:\n\n```wl\n0 + 0\n```"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "prependExample",
    TestID -> "EditSymbolPacletDocumentationExamples-PrependExample@@Tests/PacletDocumentationToolsTest.wlt:910,1-924,2"
]

(* Test setExamples operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setExamples",
            "section" -> "BasicExamples",
            "content" -> "Replaced example:\n\n```wl\n5 + 5\n```\n\n---\n\nAnother example:\n\n```wl\n6 + 6\n```"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "setExamples",
    TestID -> "EditSymbolPacletDocumentationExamples-SetExamples@@Tests/PacletDocumentationToolsTest.wlt:927,1-941,2"
]

(* Test clearExamples operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "clearExamples",
            "section" -> "BasicExamples"
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "clearExamples",
    TestID -> "EditSymbolPacletDocumentationExamples-ClearExamples@@Tests/PacletDocumentationToolsTest.wlt:944,1-957,2"
]

(* Test insertExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        (* First append another example so we have multiple *)
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "Second example:\n\n```wl\n2 + 2\n```"
        |>];
        (* Now insert at position 1 *)
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "insertExample",
            "section" -> "BasicExamples",
            "content" -> "Inserted example:\n\n```wl\n99\n```",
            "position" -> 1
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "insertExample",
    TestID -> "EditSymbolPacletDocumentationExamples-InsertExample@@Tests/PacletDocumentationToolsTest.wlt:960,1-983,2"
]

(* Test replaceExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "replaceExample",
            "section" -> "BasicExamples",
            "content" -> "Replaced first example:\n\n```wl\n100\n```",
            "position" -> 0
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "replaceExample",
    TestID -> "EditSymbolPacletDocumentationExamples-ReplaceExample@@Tests/PacletDocumentationToolsTest.wlt:986,1-1001,2"
]

(* Test removeExample operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        (* First append another example so we have multiple *)
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "Second example:\n\n```wl\n2 + 2\n```"
        |>];
        (* Now remove the first example *)
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "removeExample",
            "section" -> "BasicExamples",
            "position" -> 0
        |>];
        cleanupTestEnvironment[env];
        result["operation"]
    ],
    "removeExample",
    TestID -> "EditSymbolPacletDocumentationExamples-RemoveExample@@Tests/PacletDocumentationToolsTest.wlt:1004,1-1026,2"
]

(* Test invalid section name *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Quiet[
            Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
                "notebook" -> env["notebookPath"],
                "operation" -> "appendExample",
                "section" -> "InvalidSection",
                "content" -> "test"
            |>],
            { MCPServer::InvalidSection, MCPServer::Internal, General::stop }
        ];
        cleanupTestEnvironment[env];
        FailureQ[result]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-InvalidSection@@Tests/PacletDocumentationToolsTest.wlt:1029,1-1046,2"
]

(* Test invalid operation *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Quiet[
            Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
                "notebook" -> env["notebookPath"],
                "operation" -> "invalidOp",
                "section" -> "BasicExamples",
                "content" -> "test"
            |>],
            { MCPServer::InvalidOperation, MCPServer::Internal }
        ];
        cleanupTestEnvironment[env];
        FailureQ[result]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-InvalidOperation@@Tests/PacletDocumentationToolsTest.wlt:1049,1-1066,2"
]

(* Test notebook not found *)
VerificationTest[
    Module[{result},
        result = Quiet[
            Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
                "notebook" -> "C:\\nonexistent\\path\\to\\notebook.nb",
                "operation" -> "appendExample",
                "section" -> "BasicExamples",
                "content" -> "test"
            |>],
            { MCPServer::NotebookNotFound, MCPServer::Internal, Import::nffil }
        ];
        FailureQ[result]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-NotebookNotFound@@Tests/PacletDocumentationToolsTest.wlt:1069,1-1084,2"
]

(* Test that generatedContent is returned for append *)
VerificationTest[
    Module[{env, result},
        env = createTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentationExamples[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "appendExample",
            "section" -> "BasicExamples",
            "content" -> "Test:\n\n```wl\n3 + 3\n```"
        |>];
        cleanupTestEnvironment[env];
        StringQ[result["generatedContent"]] && StringContainsQ[result["generatedContent"], "wl-output"]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentationExamples-GeneratedContentReturned@@Tests/PacletDocumentationToolsTest.wlt:1087,1-1101,2"
]

(* ::Section:: *)
(* EditSymbolPacletDocumentation Tests *)

(* Helper to create a test environment for EditSymbolPacletDocumentation tests *)
createEditTestEnvironment[] := Module[{testDir, result},
    testDir = CreateDirectory[];
    result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`createSymbolPacletDocumentation[<|
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
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setUsage",
            "content" -> "- `EditTestFunc[a]` computes something with *a*.\n- `EditTestFunc[a, b, c]` combines *a*, *b*, and *c*."
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setUsage",
    TestID -> "EditSymbolPacletDocumentation-SetUsage-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1131,1-1144,2"
]

(* Test setUsage operation - verify usage cell is updated *)
VerificationTest[
    Module[{env, result, nb, usageContent},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetUsage-VerifyUpdate@@Tests/PacletDocumentationToolsTest.wlt:1147,1-1163,2"
]

(* Test setNotes operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setNotes",
            "content" -> "This is a completely new note.\n\nAnd another new note."
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setNotes",
    TestID -> "EditSymbolPacletDocumentation-SetNotes-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1166,1-1179,2"
]

(* Test setNotes operation - verify notes cells are replaced *)
VerificationTest[
    Module[{env, nb, notesCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetNotes-VerifyReplacement@@Tests/PacletDocumentationToolsTest.wlt:1182,1-1198,2"
]

(* Test addNote operation at end (default) *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "addNote",
            "content" -> "This is an added note at the end."
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "addNote",
    TestID -> "EditSymbolPacletDocumentation-AddNote-AtEnd@@Tests/PacletDocumentationToolsTest.wlt:1201,1-1214,2"
]

(* Test addNote operation at start *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "addNote",
            "content" -> "This is an added note at the start.",
            "position" -> "start"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "addNote",
    TestID -> "EditSymbolPacletDocumentation-AddNote-AtStart@@Tests/PacletDocumentationToolsTest.wlt:1217,1-1231,2"
]

(* Test addNote operation at specific position *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "addNote",
            "content" -> "This is an inserted note.",
            "position" -> 1
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "addNote",
    TestID -> "EditSymbolPacletDocumentation-AddNote-AtPosition@@Tests/PacletDocumentationToolsTest.wlt:1234,1-1248,2"
]

(* Test setDetailsTable operation *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setDetailsTable",
            "content" -> "The value for *x* can be any of the following:\n\n| Value | Description |\n|-------|-------------|\n| *int* | an `Integer` |\n| *real* | a `Real` number |"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setDetailsTable",
    TestID -> "EditSymbolPacletDocumentation-SetDetailsTable-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1251,1-1264,2"
]

(* Test setSeeAlso operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "Times, Divide\nPower, Sqrt"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setSeeAlso",
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1267,1-1280,2"
]

(* Test setSeeAlso operation - verify button boxes are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-VerifyButtonBoxes@@Tests/PacletDocumentationToolsTest.wlt:1283,1-1298,2"
]

(* Test setTechNotes operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setTechNotes",
            "content" -> "[New Tutorial 1](paclet:TestPaclet/tutorial/NewTutorial1)\n[New Tutorial 2](paclet:TestPaclet/tutorial/NewTutorial2)"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setTechNotes",
    TestID -> "EditSymbolPacletDocumentation-SetTechNotes-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1301,1-1314,2"
]

(* Test setTechNotes operation - verify links are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetTechNotes-VerifyLinks@@Tests/PacletDocumentationToolsTest.wlt:1317,1-1332,2"
]

(* Test setRelatedGuides operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedGuides",
            "content" -> "[New Guide 1](paclet:TestPaclet/guide/NewGuide1)\n[New Guide 2](paclet:TestPaclet/guide/NewGuide2)"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setRelatedGuides",
    TestID -> "EditSymbolPacletDocumentation-SetRelatedGuides-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1335,1-1348,2"
]

(* Test setRelatedGuides operation - verify links are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetRelatedGuides-VerifyLinks@@Tests/PacletDocumentationToolsTest.wlt:1351,1-1366,2"
]

(* Test setRelatedLinks operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setRelatedLinks",
            "content" -> "[New External Link](https://new.example.com)\n[Another Link](https://another.example.com)"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setRelatedLinks",
    TestID -> "EditSymbolPacletDocumentation-SetRelatedLinks-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1369,1-1382,2"
]

(* Test setRelatedLinks operation - verify hyperlinks are created *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetRelatedLinks-VerifyHyperlinks@@Tests/PacletDocumentationToolsTest.wlt:1385,1-1400,2"
]

(* Test setKeywords operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setKeywords",
            "content" -> "new, keywords, updated, test"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setKeywords",
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1403,1-1416,2"
]

(* Test setKeywords operation - verify keywords cells are updated *)
VerificationTest[
    Module[{env, nb, keywordsCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-VerifyKeywords@@Tests/PacletDocumentationToolsTest.wlt:1419,1-1434,2"
]

(* Test setHistory operation - basic functionality *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setHistory",
            "content" -> "new:2.0, modified:2.5"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"]
    ],
    "setHistory",
    TestID -> "EditSymbolPacletDocumentation-SetHistory-BasicFunctionality@@Tests/PacletDocumentationToolsTest.wlt:1437,1-1450,2"
]

(* Test setHistory operation - verify version number is present *)
VerificationTest[
    Module[{env, nb, historyData},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetHistory-VerifyVersions@@Tests/PacletDocumentationToolsTest.wlt:1453,1-1469,2"
]

(* Test that file path is returned correctly *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "Plus"
        |>];
        cleanupEditTestEnvironment[env];
        StringQ[result["file"]] && StringEndsQ[result["file"], ".nb"]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-ReturnsFilePath@@Tests/PacletDocumentationToolsTest.wlt:1472,1-1485,2"
]

(* Test error: invalid operation *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Quiet[
            Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
                "notebook" -> env["notebookPath"],
                "operation" -> "invalidOperation",
                "content" -> "test"
            |>],
            { MCPServer::InvalidOperation, MCPServer::Internal }
        ];
        cleanupEditTestEnvironment[env];
        FailureQ[result]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-ErrorInvalidOperation@@Tests/PacletDocumentationToolsTest.wlt:1488,1-1504,2"
]

(* Test error: notebook not found *)
VerificationTest[
    Module[{result},
        result = Quiet[
            Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
                "notebook" -> "C:\\nonexistent\\path\\to\\notebook.nb",
                "operation" -> "setSeeAlso",
                "content" -> "Plus"
            |>],
            { MCPServer::NotebookNotFound, MCPServer::Internal, Import::nffil }
        ];
        FailureQ[result]
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-ErrorNotebookNotFound@@Tests/PacletDocumentationToolsTest.wlt:1507,1-1521,2"
]

(* Test setUsage with single usage case *)
VerificationTest[
    Module[{env, result, nb, usageCells},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetUsage-SingleCase@@Tests/PacletDocumentationToolsTest.wlt:1524,1-1539,2"
]

(* Test setNotes with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, notesCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetNotes-EmptyCreatesPlaceholder@@Tests/PacletDocumentationToolsTest.wlt:1542,1-1557,2"
]

(* Test setSeeAlso with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-EmptyCreatesPlaceholder@@Tests/PacletDocumentationToolsTest.wlt:1560,1-1576,2"
]

(* Test setSeeAlso with comma-separated symbols on same line *)
VerificationTest[
    Module[{env, nb, buttonBoxes},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetSeeAlso-CommaSeparated@@Tests/PacletDocumentationToolsTest.wlt:1579,1-1594,2"
]

(* Test setKeywords with newline-separated keywords *)
VerificationTest[
    Module[{env, nb, keywordsCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-NewlineSeparated@@Tests/PacletDocumentationToolsTest.wlt:1597,1-1612,2"
]

(* Test setTechNotes with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetTechNotes-EmptyCreatesPlaceholder@@Tests/PacletDocumentationToolsTest.wlt:1615,1-1630,2"
]

(* Test setRelatedGuides with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetRelatedGuides-EmptyCreatesPlaceholder@@Tests/PacletDocumentationToolsTest.wlt:1633,1-1648,2"
]

(* Test setRelatedLinks with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetRelatedLinks-EmptyCreatesPlaceholder@@Tests/PacletDocumentationToolsTest.wlt:1651,1-1666,2"
]

(* Test setKeywords with empty string creates placeholder *)
VerificationTest[
    Module[{env, nb, placeholderCells},
        env = createEditTestEnvironment[];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-SetKeywords-EmptyCreatesPlaceholder@@Tests/PacletDocumentationToolsTest.wlt:1669,1-1684,2"
]

(* Test setHistory with only 'new' field *)
VerificationTest[
    Module[{env, result},
        env = createEditTestEnvironment[];
        result = Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setHistory",
            "content" -> "new:5.0"
        |>];
        cleanupEditTestEnvironment[env];
        result["operation"] === "setHistory"
    ],
    True,
    TestID -> "EditSymbolPacletDocumentation-SetHistory-OnlyNewField@@Tests/PacletDocumentationToolsTest.wlt:1687,1-1700,2"
]

(* Test multiple sequential operations on same notebook *)
VerificationTest[
    Module[{env, nb, seeAlsoButtons, keywordsCells},
        env = createEditTestEnvironment[];
        (* Perform multiple operations *)
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
            "notebook" -> env["notebookPath"],
            "operation" -> "setSeeAlso",
            "content" -> "SequentialSymbol1, SequentialSymbol2"
        |>];
        Wolfram`MCPServer`Tools`PacletDocumentation`Private`editSymbolPacletDocumentation[<|
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
    TestID -> "EditSymbolPacletDocumentation-MultipleSequentialOperations@@Tests/PacletDocumentationToolsTest.wlt:1703,1-1725,2"
]
