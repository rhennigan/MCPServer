(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Utilities`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

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
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
