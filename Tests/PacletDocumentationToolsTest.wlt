(* Tests for EditSymbolPacletDocumentationExamples tool *)

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
    TestID -> "EditSymbolPacletDocumentationExamples-AppendExample@@Tests/PacletDocumentationToolsTest.wlt:20,1-34,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-PrependExample@@Tests/PacletDocumentationToolsTest.wlt:37,1-51,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-SetExamples@@Tests/PacletDocumentationToolsTest.wlt:54,1-68,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-ClearExamples@@Tests/PacletDocumentationToolsTest.wlt:71,1-84,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-InsertExample@@Tests/PacletDocumentationToolsTest.wlt:87,1-110,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-ReplaceExample@@Tests/PacletDocumentationToolsTest.wlt:113,1-128,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-RemoveExample@@Tests/PacletDocumentationToolsTest.wlt:131,1-153,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-InvalidSection@@Tests/PacletDocumentationToolsTest.wlt:156,1-173,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-InvalidOperation@@Tests/PacletDocumentationToolsTest.wlt:176,1-193,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-NotebookNotFound@@Tests/PacletDocumentationToolsTest.wlt:196,1-211,2"
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
    TestID -> "EditSymbolPacletDocumentationExamples-GeneratedContentReturned@@Tests/PacletDocumentationToolsTest.wlt:214,1-228,2"
]
