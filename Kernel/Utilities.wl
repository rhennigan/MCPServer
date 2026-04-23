(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`Utilities`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*LLMKit Information*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*llmKitSubscribedQ*)
llmKitSubscribedQ // beginDefinition;
llmKitSubscribedQ[ ] := llmKitSubscribedQ @ getLLMKitInfo[ ];
llmKitSubscribedQ[ KeyValuePattern[ "userHasSubscription" -> bool: True|False ] ] := bool;
llmKitSubscribedQ[ _ ] := False;
llmKitSubscribedQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getLLMKitInfo*)
getLLMKitInfo // beginDefinition;

getLLMKitInfo[ ] :=
    getLLMKitInfo[ $CloudConnected, $CloudUserID, $CloudBase ];

getLLMKitInfo[ False, _, _ ] :=
    $fallBackLLMKitInfo;

getLLMKitInfo[ connected_, user_, cloudBase_ ] := Enclose[
    Module[ { info },
        LLMSynthesize;
        ConfirmQuiet[ Wolfram`LLMFunctions`Common`UpdateLLMKitInfo[ ], All, "UpdateLLMKitInfo" ];
        chatbookVersionCheck[ ];

        info = ConfirmMatch[
            <| "connected" -> connected, Wolfram`LLMFunctions`Common`$LLMKitInfo |>,
            KeyValuePattern @ { "userHasSubscription" -> True|False, "buyNowUrl" -> _String },
            "LLMKitInfo"
        ];

        If[ TrueQ @ info[ "userHasSubscription" ],
            Wolfram`LLMFunctions`Common`$LLMKitSubscribed = True;
            getLLMKitInfo[ connected, user, cloudBase ] = info,
            info
        ]
    ],

    $fallBackLLMKitInfo &
];

getLLMKitInfo // endDefinition;


$fallBackLLMKitInfo := <|
    "connected"           -> $CloudConnected,
    "service"             -> "llmkit",
    "currentProvider"     -> "AzureOpenAI",
    "userHasSubscription" -> False,
    "learnMoreUrl"        -> "https://www.wolfram.com/notebook-assistant-llm-kit",
    "buyNowUrl"           -> "https://www.wolfram.com/notebook-assistant-llm-kit#pricing"
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Dependencies*)
$minimumChatbookVersion = "2.3.0";

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*chatbookVersionCheck*)
chatbookVersionCheck // beginDefinition;
chatbookVersionCheck[ ] := chatbookVersionCheck[ ] = chatbookVersionCheck0 @ PacletObject[ "Wolfram/Chatbook" ];
chatbookVersionCheck // endDefinition;


chatbookVersionCheck0 // beginDefinition;

chatbookVersionCheck0[ paclet_PacletObject ] :=
    chatbookVersionCheck0 @ paclet[ "Version" ];

chatbookVersionCheck0[ $minimumChatbookVersion ] :=
    True;

chatbookVersionCheck0[ version_String ] /; PacletNewerQ[ version, $minimumChatbookVersion ] :=
    True;

chatbookVersionCheck0[ other_ ] := Enclose[
    Module[ { installed, version },

        installed = ConfirmBy[
            PacletInstall[ "Wolfram/Chatbook", UpdatePacletSites -> True ],
            PacletObjectQ,
            "PacletInstall"
        ];

        version = ConfirmBy[ installed[ "Version" ], StringQ, "Version" ];

        ConfirmAssert[
            version === $minimumChatbookVersion || PacletNewerQ[ version, $minimumChatbookVersion ],
            "PacletNewerQ"
        ];

        Block[ { $ContextPath }, Get[ "Wolfram`Chatbook`" ] ];

        True
    ],
    throwInternalFailure
];

chatbookVersionCheck0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Regular Expressions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toJSRegex*)

(* Convert an ICU/PCRE-flavored regex (as produced by StringPattern`PatternConvert) into a
   best-effort ECMA 262 pattern suitable for JSON Schema "pattern" fields consumed by
   JavaScript-based validators.

   Non-goals: we do not try to sanitize arbitrary user-supplied PCRE; we target the patterns
   that LLMTool's JSONSchema emits via StringPattern`PatternConvert. Known limitations are
   documented in the plan at C:\Users\rhennigan\.claude\plans\we-need-to-make-rippling-sketch.md *)

toJSRegex // beginDefinition;

toJSRegex[ regex_String ] := Module[ { body, hadDotAll },
    { body, hadDotAll } = extractLeadingRegexFlags @ regex;
    body = stripInnerRegexModifiers @ body;
    body = convertPOSIXClasses @ body;
    body = convertPCREAnchors @ body;
    body = convertUnicodeEscapes @ body;
    If[ hadDotAll, body = convertDotAllDots @ body ];
    body
];

toJSRegex // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*extractLeadingRegexFlags*)
(* Strip a leading "(?flags)" group and return { body, hadDotAll }. *)
extractLeadingRegexFlags // beginDefinition;

extractLeadingRegexFlags[ s_String ] :=
    Module[ { match },
        match = StringCases[
            s,
            StartOfString ~~ "(?" ~~ flags: (LetterCharacter..) ~~ ")" ~~ rest___ :>
                { flags, rest },
            1
        ];
        If[ match === { },
            { s, False },
            { match[[ 1, 2 ]], StringContainsQ[ match[[ 1, 1 ]], "s" ] }
        ]
    ];

extractLeadingRegexFlags // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*stripInnerRegexModifiers*)
(* Remove scope-less inline modifiers like "(?-m-s)" that wrap RegularExpression[] contents.
   These have no JS equivalent; the surrounding "(?:...)" non-capturing group is left in place. *)
stripInnerRegexModifiers // beginDefinition;

stripInnerRegexModifiers[ s_String ] := StringReplace[
    s,
    "(?-m-s)" | "(?-s-m)" | "(?-ms)" | "(?-sm)" | "(?-s)" | "(?-m)" -> ""
];

stripInnerRegexModifiers // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertPOSIXClasses*)
(* Map POSIX character class tokens like "[:alpha:]" to JS-compatible bodies. By replacing only
   the inner token (not the outer brackets), "[[:alpha:]]" becomes "[a-zA-Z]" and nested forms
   like "[[:alpha:][:digit:]]" become "[a-zA-Z0-9]". *)
convertPOSIXClasses // beginDefinition;

convertPOSIXClasses[ s_String ] := StringReplace[
    s,
    {
        "[:alpha:]"  -> "a-zA-Z",
        "[:digit:]"  -> "0-9",
        "[:alnum:]"  -> "a-zA-Z0-9",
        "[:upper:]"  -> "A-Z",
        "[:lower:]"  -> "a-z",
        "[:xdigit:]" -> "0-9a-fA-F",
        "[:space:]"  -> "\\s",
        "[:blank:]"  -> " \\t",
        "[:cntrl:]"  -> "\\x00-\\x1F\\x7F",
        "[:print:]"  -> "\\x20-\\x7E",
        "[:graph:]"  -> "\\x21-\\x7E",
        "[:punct:]"  -> "!-/:-@[-`{-~"
    }
];

convertPOSIXClasses // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertPCREAnchors*)
(* "\A" and "\z"/"\Z" are PCRE start/end-of-string anchors with no JS equivalent. JS "^"/"$"
   mean start/end-of-string when the regex has no "m" flag - which is our target since we
   strip all flags for JSON Schema output. *)
convertPCREAnchors // beginDefinition;

convertPCREAnchors[ s_String ] := StringReplace[
    s,
    { "\\A" -> "^", "\\z" -> "$", "\\Z" -> "$" }
];

convertPCREAnchors // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertUnicodeEscapes*)
(* Convert "\x{HEX}" to the narrowest JS-valid form. "\xNN" and "\uNNNN" work without the u
   flag; "\u{NNNNN}" requires it - Wolfram's auto-generated patterns only contain BMP codes,
   so the supplementary case is a documented limitation. *)
convertUnicodeEscapes // beginDefinition;

convertUnicodeEscapes[ s_String ] := StringReplace[
    s,
    "\\x{" ~~ hex: (HexadecimalCharacter..) ~~ "}" :> convertHexEscape @ hex
];

convertUnicodeEscapes // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertHexEscape*)
convertHexEscape // beginDefinition;

convertHexEscape[ hex_String ] := With[ { len = StringLength @ hex },
    Which[
        len <= 2, "\\x" <> StringPadLeft[ hex, 2, "0" ],
        len <= 4, "\\u" <> StringPadLeft[ hex, 4, "0" ],
        True    , "\\u{" <> hex <> "}"
    ]
];

convertHexEscape // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertDotAllDots*)
(* Replace unescaped "." outside character classes with "[\s\S]" to preserve dotall semantics
   of the stripped outer "(?s)" flag. Walks the string once tracking escape and class state;
   leaves "\.", "[.]", and dots inside "[...]" untouched. *)
convertDotAllDots // beginDefinition;

convertDotAllDots[ s_String ] :=
    Module[ { inClass = False, escaped = False },
        StringJoin @ Map[
            Function[ c,
                Which[
                    escaped     , escaped = False; c,
                    c === "\\"  , escaped = True; c,
                    inClass     , If[ c === "]", inClass = False ]; c,
                    c === "["   , inClass = True; c,
                    c === "."   , "[\\s\\S]",
                    True        , c
                ]
            ],
            Characters @ s
        ]
    ];

convertDotAllDots // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
