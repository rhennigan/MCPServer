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
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
