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
    Wolfram`MCPServer`Common`graphicsQ @ CloudObject[ "test" ],
    False,
    TestID -> "graphicsQ-CloudObject@@Tests/Graphics.wlt:109,1-113,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ File[ "test.txt" ],
    False,
    TestID -> "graphicsQ-File@@Tests/Graphics.wlt:115,1-119,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`graphicsQ @ URL[ "http://example.com" ],
    False,
    TestID -> "graphicsQ-URL@@Tests/Graphics.wlt:121,1-125,2"
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
    TestID   -> "graphicsToImageContent-Graphics@@Tests/Graphics.wlt:130,1-139,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`graphicsToImageContent @ Graphics[ Circle[ ] ] },
        StringQ @ result[ "data" ] && StringLength @ result[ "data" ] > 100
    ],
    True,
    TestID -> "graphicsToImageContent-HasBase64Data@@Tests/Graphics.wlt:141,1-148,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`Common`graphicsToImageContent @ Graphics[ Circle[ ] ] },
        (* Base64 strings should be ASCII-printable and reasonably long *)
        StringMatchQ[ result[ "data" ], RegularExpression[ "^[A-Za-z0-9+/=]+$" ] ]
    ],
    True,
    TestID -> "graphicsToImageContent-ValidBase64@@Tests/Graphics.wlt:150,1-158,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractImageContent Tests*)
VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ Graphics[ Circle[ ] ],
    { KeyValuePattern[ "type" -> "image" ] },
    SameTest -> MatchQ,
    TestID   -> "extractImageContent-SingleGraphics@@Tests/Graphics.wlt:163,1-168,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ "Hello",
    { },
    TestID -> "extractImageContent-String@@Tests/Graphics.wlt:170,1-174,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ Failure[ "Test", <| |> ],
    { },
    TestID -> "extractImageContent-Failure@@Tests/Graphics.wlt:176,1-180,2"
]

VerificationTest[
    Length @ Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ {
        Graphics[ Circle[ ] ],
        Graphics[ Rectangle[ ] ]
    },
    2,
    TestID -> "extractImageContent-ListOfGraphics@@Tests/Graphics.wlt:182,1-189,2"
]

VerificationTest[
    Length @ Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ <|
        "a" -> Graphics[ Circle[ ] ],
        "b" -> Graphics[ Rectangle[ ] ]
    |>,
    2,
    TestID -> "extractImageContent-AssociationOfGraphics@@Tests/Graphics.wlt:191,1-198,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`extractImageContent @ { "text", 123, Null },
    { },
    TestID -> "extractImageContent-MixedNonGraphics@@Tests/Graphics.wlt:200,1-204,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resultToContent Tests*)
VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ "Hello World",
    { <| "type" -> "text", "text" -> "Hello World" |> },
    TestID -> "resultToContent-String@@Tests/Graphics.wlt:209,1-213,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ 42,
    { <| "type" -> "text", "text" -> "42" |> },
    TestID -> "resultToContent-Integer@@Tests/Graphics.wlt:215,1-219,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ Graphics[ Circle[ ] ],
    { _Association, _Association },
    SameTest -> MatchQ,
    TestID   -> "resultToContent-Graphics@@Tests/Graphics.wlt:221,1-226,2"
]

VerificationTest[
    With[
        { result = Wolfram`MCPServer`StartMCPServer`Private`resultToContent @ Graphics[ Circle[ ] ] },
        { result[[ 1, "type" ]], result[[ 2, "type" ]] }
    ],
    { "text", "image" },
    TestID -> "resultToContent-GraphicsTypes@@Tests/Graphics.wlt:228,1-235,2"
]

(* :!CodeAnalysis::EndBlock:: *)
