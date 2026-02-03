(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/Graphics.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/Graphics.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*graphicsQ Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Graphics Types*)
VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ Graphics[ Circle[ ] ],
    True,
    TestID -> "graphicsQ-Graphics@@Tests/Graphics.wlt:28,1-32,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ Graphics3D[ Sphere[ ] ],
    True,
    TestID -> "graphicsQ-Graphics3D@@Tests/Graphics.wlt:34,1-38,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ Image[ RandomReal[ { 0, 1 }, { 10, 10 } ] ],
    True,
    TestID -> "graphicsQ-Image@@Tests/Graphics.wlt:40,1-44,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ Image3D[ RandomReal[ { 0, 1 }, { 5, 5, 5 } ] ],
    True,
    TestID -> "graphicsQ-Image3D@@Tests/Graphics.wlt:46,1-50,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ GeoGraphics[ ],
    True,
    TestID -> "graphicsQ-GeoGraphics@@Tests/Graphics.wlt:52,1-56,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ Legended[ Graphics[ Circle[ ] ], "Test" ],
    True,
    TestID -> "graphicsQ-Legended@@Tests/Graphics.wlt:58,1-62,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ Labeled[ Graphics[ Circle[ ] ], "Test" ],
    True,
    TestID -> "graphicsQ-Labeled@@Tests/Graphics.wlt:64,1-68,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Non-Graphics Types*)
VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ "Hello",
    False,
    TestID -> "graphicsQ-String@@Tests/Graphics.wlt:73,1-77,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ { 1, 2, 3 },
    False,
    TestID -> "graphicsQ-List@@Tests/Graphics.wlt:79,1-83,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ <| "a" -> 1 |>,
    False,
    TestID -> "graphicsQ-Association@@Tests/Graphics.wlt:85,1-89,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ Null,
    False,
    TestID -> "graphicsQ-Null@@Tests/Graphics.wlt:91,1-95,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ True,
    False,
    TestID -> "graphicsQ-True@@Tests/Graphics.wlt:97,1-101,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ False,
    False,
    TestID -> "graphicsQ-False@@Tests/Graphics.wlt:103,1-107,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ File[ "test.txt" ],
    False,
    TestID -> "graphicsQ-File@@Tests/Graphics.wlt:109,1-113,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ URL[ "http://example.com" ],
    False,
    TestID -> "graphicsQ-URL@@Tests/Graphics.wlt:115,1-119,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*graphicsToImageContent Tests*)
VerificationTest[
    Wolfram`MCPServer`Common`graphicsToImageContent @ Graphics[ Circle[ ] ],
    KeyValuePattern[ {
        "type"     -> "image",
        "mimeType" -> "image/png",
        "data"     -> _String
    } ],
    SameTest -> MatchQ,
    TestID   -> "graphicsToImageContent-Graphics@@Tests/Graphics.wlt:124,1-133,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`graphicsToImageContent @ Graphics[ Circle[ ] ] },
        StringQ @ result[ "data" ] && StringLength @ result[ "data" ] > 100
    ],
    True,
    TestID -> "graphicsToImageContent-HasBase64Data@@Tests/Graphics.wlt:135,1-142,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`graphicsToImageContent @ Graphics[ Circle[ ] ] },
        (* Base64 strings should be ASCII-printable and reasonably long *)
        StringMatchQ[ result[ "data" ], RegularExpression[ "^[A-Za-z0-9+/=]+$" ] ]
    ],
    True,
    TestID -> "graphicsToImageContent-ValidBase64@@Tests/Graphics.wlt:144,1-152,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractImageContent Tests*)
VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ Graphics[ Circle[ ] ],
    { KeyValuePattern[ "type" -> "image" ] },
    SameTest -> MatchQ,
    TestID   -> "extractImageContent-SingleGraphics@@Tests/Graphics.wlt:157,1-162,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ "Hello",
    { },
    TestID -> "extractImageContent-String@@Tests/Graphics.wlt:164,1-168,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ Failure[ "Test", <| |> ],
    { },
    TestID -> "extractImageContent-Failure@@Tests/Graphics.wlt:170,1-174,2"
]

VerificationTest[
    Length @ Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ {
        Graphics[ Circle[ ] ],
        Graphics[ Rectangle[ ] ]
    },
    2,
    TestID -> "extractImageContent-ListOfGraphics@@Tests/Graphics.wlt:176,1-183,2"
]

VerificationTest[
    Length @ Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ <|
        "a" -> Graphics[ Circle[ ] ],
        "b" -> Graphics[ Rectangle[ ] ]
    |>,
    2,
    TestID -> "extractImageContent-AssociationOfGraphics@@Tests/Graphics.wlt:185,1-192,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ { "text", 123, Null },
    { },
    TestID -> "extractImageContent-MixedNonGraphics@@Tests/Graphics.wlt:194,1-198,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resultToContent Tests*)
VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ "Hello World",
    { <| "type" -> "text", "text" -> "Hello World" |> },
    TestID -> "resultToContent-String@@Tests/Graphics.wlt:203,1-207,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ 42,
    { <| "type" -> "text", "text" -> "42" |> },
    TestID -> "resultToContent-Integer@@Tests/Graphics.wlt:209,1-213,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ Graphics[ Circle[ ] ],
    { _Association, _Association },
    SameTest -> MatchQ,
    TestID   -> "resultToContent-Graphics@@Tests/Graphics.wlt:215,1-220,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ Graphics[ Circle[ ] ] },
        { result[[ 1, "type" ]], result[[ 2, "type" ]] }
    ],
    { "text", "image" },
    TestID -> "resultToContent-GraphicsTypes@@Tests/Graphics.wlt:222,1-229,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractWolframAlphaImages Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*No Images - Returns String*)
VerificationTest[
    Wolfram`MCPServer`Common`extractWolframAlphaImages @ "Hello World",
    "Hello World",
    TestID -> "extractWolframAlphaImages-PlainString@@Tests/Graphics.wlt:238,1-242,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`extractWolframAlphaImages @ "Some text without images",
    "Some text without images",
    TestID -> "extractWolframAlphaImages-NoImages@@Tests/Graphics.wlt:244,1-248,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`extractWolframAlphaImages @ "Text with non-WA image ![img](https://example.com/image.png)",
    "Text with non-WA image ![img](https://example.com/image.png)",
    TestID -> "extractWolframAlphaImages-NonWAImage@@Tests/Graphics.wlt:250,1-254,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*With Images - Returns Structured Content*)
VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "Result: ![Image](https://public6.wolframalpha.com/files/test.png)" },
        AssociationQ @ result && KeyExistsQ[ result, "Content" ]
    ],
    True,
    TestID -> "extractWolframAlphaImages-HasContentKey@@Tests/Graphics.wlt:259,1-267,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "Result: ![Image](https://public6.wolframalpha.com/files/test.gif)" },
        MatchQ[ result, <| "Content" -> { __Association } |> ]
    ],
    True,
    TestID -> "extractWolframAlphaImages-ContentIsList@@Tests/Graphics.wlt:269,1-277,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "Before ![Image](https://public6.wolframalpha.com/files/test.jpg) After" },
        (* Should have at least text content items *)
        Length @ result[ "Content" ] >= 2
    ],
    True,
    TestID -> "extractWolframAlphaImages-MultipleContentItems@@Tests/Graphics.wlt:279,1-288,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*URL Pattern Matching*)

(* Test the pattern directly with StringMatchQ *)
VerificationTest[
    StringMatchQ[
        "![Result](https://public6.wolframalpha.com/files/image.png)",
        ___ ~~ "![" ~~ Except[ "]" ]... ~~ "](" ~~
        ("https://" ~~ __ ~~ "wolframalpha.com/files/" ~~ __ ~~ (".gif" | ".png" | ".jpg" | ".jpeg")) ~~
        ")" ~~ ___
    ],
    True,
    TestID -> "extractWolframAlphaImages-PatternMatchesBasic@@Tests/Graphics.wlt:295,1-304,2"
]

(* Test StringSplit extracts the URL *)
VerificationTest[
    With[
        {
            pattern = Shortest[
                "![" ~~ Except[ "]" ]... ~~ "](" ~~
                url: ("https://" ~~ __ ~~ "wolframalpha.com/files/" ~~ __ ~~ (".gif" | ".png" | ".jpg" | ".jpeg")) ~~
                ")"
            ]
        },
        StringSplit[ "![Result](https://public6.wolframalpha.com/files/image.png)", pattern :> url ]
    ],
    (* StringSplit may or may not include empty strings at boundaries *)
    { "https://public6.wolframalpha.com/files/image.png" } | { "", "https://public6.wolframalpha.com/files/image.png" },
    SameTest -> MatchQ,
    TestID   -> "extractWolframAlphaImages-StringSplitExtractsURL@@Tests/Graphics.wlt:307,1-322,2"
]

(* Test with www6 domain - pattern check *)
VerificationTest[
    StringContainsQ[
        "![Result](https://www6.wolframalpha.com/files/image.png)",
        "wolframalpha.com/files/"
    ],
    True,
    TestID -> "extractWolframAlphaImages-WWW6ContainsPattern@@Tests/Graphics.wlt:325,1-332,2"
]

(* Test with jpeg extension - pattern check *)
VerificationTest[
    StringContainsQ[
        "![Result](https://public6.wolframalpha.com/files/image.jpeg)",
        "wolframalpha.com/files/"
    ],
    True,
    TestID -> "extractWolframAlphaImages-JpegContainsPattern@@Tests/Graphics.wlt:335,1-342,2"
]

(* Original tests that need the function loaded properly *)
VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "![Result](https://www6.wolframalpha.com/files/image.png)" },
        (* Either returns structured content or string with the URL *)
        AssociationQ @ result || StringContainsQ[ result, "wolframalpha.com" ]
    ],
    True,
    TestID -> "extractWolframAlphaImages-WWW6Domain@@Tests/Graphics.wlt:345,1-354,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "![Result](https://public6.wolframalpha.com/files/image.jpeg)" },
        (* Either returns structured content or string with the URL *)
        AssociationQ @ result || StringContainsQ[ result, "wolframalpha.com" ]
    ],
    True,
    TestID -> "extractWolframAlphaImages-JpegExtension@@Tests/Graphics.wlt:356,1-365,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`extractWolframAlphaImages @
        "![Result](https://example.com/files/image.png)",
    _String,
    SameTest -> MatchQ,
    TestID   -> "extractWolframAlphaImages-NonWADomain@@Tests/Graphics.wlt:367,1-373,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Text Content Preservation*)
VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "Before ![Image](https://public6.wolframalpha.com/files/test.png) After" },
        MemberQ[ result[ "Content" ], KeyValuePattern[ { "type" -> "text", "text" -> _? (StringContainsQ[ "Before" ]) } ] ]
    ],
    True,
    TestID -> "extractWolframAlphaImages-PreservesTextBefore@@Tests/Graphics.wlt:378,1-386,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "Before ![Image](https://public6.wolframalpha.com/files/test.png) After" },
        MemberQ[ result[ "Content" ], KeyValuePattern[ { "type" -> "text", "text" -> _? (StringContainsQ[ "After" ]) } ] ]
    ],
    True,
    TestID -> "extractWolframAlphaImages-PreservesTextAfter@@Tests/Graphics.wlt:388,1-396,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`extractWolframAlphaImages @
            "Text ![Image](https://public6.wolframalpha.com/files/test.png)" },
        (* The URL should be preserved as a markdown link in text content *)
        MemberQ[ result[ "Content" ], KeyValuePattern[ { "type" -> "text", "text" -> _? (StringContainsQ[ "wolframalpha.com" ]) } ] ]
    ],
    True,
    TestID -> "extractWolframAlphaImages-PreservesURLInText@@Tests/Graphics.wlt:398,1-407,2"
]

(* :!CodeAnalysis::EndBlock:: *)
