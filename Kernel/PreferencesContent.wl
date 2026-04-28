(* ::Package:: *)

(* ::Section::Closed:: *)
(*Package Header*)


BeginPackage[ "Wolfram`AgentTools`PreferencesContent`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];



(* ::**************************************************************************************************************:: *)
(**)


(* ::Section::Closed:: *)
(*resources*)


tr[id_] := Dynamic[FEPrivate`FrontEndResource["AgentToolsStrings", id]];


icon[id_] := Dynamic[RawBoxes @ FEPrivate`FrontEndResource["AgentToolsExpressions", id]];
icon[id_, args__] := Dynamic[RawBoxes @ FEPrivate`FrontEndResource["AgentToolsExpressions", id][args]];


ldsGray[n_] := LightDarkSwitched[GrayLevel[n]]


(* ::Section::Closed:: *)
(*docsLink*)


docsLink[] := 
	MouseAppearance[
		Button[
			Framed[
				Row[{tr["prefsDocsLinkText"], " \[UpperRightArrow]"}, BaseStyle -> "DialogStyle"],
				RoundingRadius -> 2,
				FrameMargins -> {{5,5},{1,1}},
				FrameStyle -> Dynamic[If[CurrentValue["MouseOver"], ldsGray[0.7], ldsGray[0.85]]],
				Background -> Dynamic[If[CurrentValue["MouseOver"], ldsGray[0.9], ldsGray[0.97]]]],
			If[
				TrueQ @ CurrentValue["OptionKey"],
				CreateDocument[{
					ExpressionCell[Defer[DeployedAgentTools[]], "Input"],
					ExpressionCell[DeployedAgentTools[], "Output"]
				}],
				(* FIXME: Where should this link go? *)
				SystemOpen["https://resources.wolframcloud.com/PacletRepository/resources/Wolfram/AgentTools/"]
			],
			Appearance -> None
		],
		"LinkHand"
	]


(* ::Section::Closed:: *)
(*clientInterfaces*)


clientInterfaces[] := 
	DynamicModule[{update = 0, clients, servers, configuredclients, clientnamespacer, initdone},
	
		Dynamic[
			Which[
				initdone =!= True,
					ProgressIndicator[Appearance -> "Necklace"],
				
				MatchQ[clients, Except[{__String}]],
					Style["[[The list of supported MCP clients is not available.]]", Italic, FontColor -> ldsGray[0.5]],
				MatchQ[servers, Except[{__String}]],
					Style["[[The list of default MCP servers is not available.]]", Italic, FontColor -> ldsGray[0.5]],
				
				configuredclients === clients (* all *),
					Column[
						Prepend[
							clientRow[#, clientnamespacer]& /@ configuredclients,
							Style[tr["prefsHarnessesConfigured"], Smaller, FontColor -> ldsGray[0.5], Bold]
						],
						ItemSize -> Scaled[1]
					],
				MatchQ[configuredclients, {__String}], (* some *)
					Column[
						{
							Column[
								Prepend[
									clientRow[#, clientnamespacer]& /@ configuredclients,
									Style[tr["prefsHarnessesConfigured"], Smaller, FontColor -> ldsGray[0.5], Bold]
								],
								Spacings -> {0.4,0.4}
							],
							Column[
								Prepend[
									clientRow[#, clientnamespacer]& /@ DeleteCases[clients, Alternatives @@ configuredclients],
									Style[tr["prefsHarnessesMore"], Smaller, FontColor -> ldsGray[0.5], Bold]
								],
								Spacings -> {0.4,0.4}
							]
						},
						Spacings -> 3,
						Dividers -> Center,
						FrameStyle -> ldsGray[0.85],
						ItemSize -> Scaled[1]
					],
				True, (* none *)
					Column[
						clientRow[#, clientnamespacer]& /@ clients,
						ItemSize -> Scaled[1]
					]
			],
			TrackedSymbols :> {initdone}
		],
	
		Initialization :> (
			initdone = False;
			clients = Keys @ Wolfram`AgentTools`$SupportedMCPClients;
			servers = Keys @ Wolfram`AgentTools`$DefaultMCPServers;
			clientnamespacer = PaneSelector[Thread[clients -> clients], True];
			configuredclients = Cases[clients, Alternatives @@ Map[#["ClientName"]&, DeployedAgentTools[]]];
			initdone = True;
		),
		SynchronousInitialization -> False,
		UnsavedVariables :> {update, clients, servers, configuredclients, clientnamespacer, initdone}
	]


(* ::Section::Closed:: *)
(*clientRow*)


ClearAll[clientRow];
clientRow[client_, spacer_] :=
	Grid[
		{{
			clientName[client, spacer],
			clientControls[client]
		}},
		Dividers -> {{False, True, False}, None},
		FrameStyle -> ldsGray[0.85],
		Spacings -> {2,2}
	]


(* ::Section::Closed:: *)
(*clientName*)


clientName[client_, spacer_] :=
	With[{url = Wolfram`AgentTools`$SupportedMCPClients[client]["URL"]},
		If[
			StringQ[url],
			PaneSelector[
				{
					True -> Hyperlink[
							client,
							url,
							Tooltip -> ToBoxes[url],
							BaseStyle -> {FontColor -> ldsGray[0]},
							ActiveStyle -> {FontColor -> StandardBlue}
						],
					False -> spacer
				},
				True,
				Alignment -> Left,
				ImageMargins -> {{15,20},{0,0}}
			],
			client
		]
	]


(* ::Section::Closed:: *)
(*clientControls*)


(*
FIXME: The UX calls for this interface to list two MCP servers: "ComputationTools", and "DevelopmentTools".
However, Wolfram`AgentTools`$DefaultMCPServers currently returns a list of 4 servers, none of which have those
names.

So for now, the code below lists only the two names from the UX, and maps them to current names thusly:

"Wolfram" === "ComputationTools"
"WolframLanguage" === "DevelopmentTools"

Once the naming of MCP servers in AgentTools catches up to the UX, this code will need to be adjusted to remove
that name mapping.
*)


clientControls[client_] := 
	DynamicModule[{update = 0},
		Grid[
			{
				{
					(* menu *)
					PopupMenu[
						Dynamic[update;
							Switch[{#["Server"], #["Scope"]}& /@ DeployedAgentTools[client],
								{___, {"Wolfram", "Global"}, ___}, update = 1; "ComputationTools",
								{___, {"WolframLanguage", "Global"}, ___}, update = 1; "DevelopmentTools",
								_, None
							],
							(Switch[#,
								"ComputationTools",
									DeleteObject[DeployedAgentTools[client]];
									DeployAgentTools[client, "Wolfram"],
								"DevelopmentTools",
									DeleteObject[DeployedAgentTools[client]];
									DeployAgentTools[client, "WolframLanguage"],
								None | 0,
									DeleteObject[DeployedAgentTools[client]];
							];
							++update)&
						]
						,
						{
							None -> Dynamic[If[update === 0,
								tr["prefsPickTool"],
								tr["prefsNoTool"]
							]],
							Delimiter,
							"ComputationTools" -> tr["prefsComputationTools"],
							"DevelopmentTools" -> tr["prefsDevelopmentTools"]
						},
						Style[tr["prefsPickTool"], FontColor -> ldsGray[0.5]],
						Framed[
							Grid[
								{{
									Item[
										Dynamic[update;
											Switch[{#["Server"], #["Scope"]}& /@ DeployedAgentTools[client],
												{___, {"Wolfram", "Global"}, ___}, tr["prefsComputationTools"],
												{___, {"WolframLanguage", "Global"}, ___}, tr["prefsDevelopmentTools"],
												_, Dynamic[If[update === 0,
													Style[tr["prefsPickTool"], FontColor -> ldsGray[0.5]],
													tr["prefsNoTool"]]]
											]
										],
										ItemSize -> Fit
									],
									icon["prefsDownPointer", ldsGray[0.2], 10]
								}},
								Alignment -> Left
							],
							RoundingRadius -> 3,
							ImageSize -> 400,
							FrameStyle -> (*ldsGray[0.85]*)Dynamic[If[CurrentValue["MouseOver"], ldsGray[0.7], ldsGray[0.85]]],
							Background -> (*ldsGray[0.97]*)Dynamic[If[CurrentValue["MouseOver"], ldsGray[0.9], ldsGray[0.97]]]
						],
						ImageSize -> 400,
						Appearance -> "ActionMenu"
					],
					(* info link *)
					Dynamic[update; infoLink[client]]
				},
				(* per-directory settings *)
				Module[{dirsettings},
					dirsettings = Select[
						DeployedAgentTools[client],
						MatchQ[{#["Server"], #["Scope"]}, {"Wolfram" | "WolframLanguage", _File}]&
					];
					If[dirsettings === {},
						Nothing,
						{
							Pane[
								Grid[
									{
										{
											Style[tr["prefsSpecificDirectories"], Smaller, FontColor -> ldsGray[0.5], Bold],
											SpanFromLeft,
											SpanFromLeft
										},
										Splice[dirSettingsRow /@ dirsettings]
									},
									Alignment -> {{Left, Right, Right}},
									ItemSize -> {{Automatic, Fit, Automatic}},
									Spacings -> {1,Automatic}
								],
								ImageSize -> 390,
								Alignment -> Left,
								ImageMargins -> 5
							],
							""
						}
					]
				]
			},
			Alignment -> Left,
			BaselinePosition -> 1
		]
	]


(* ::Section::Closed:: *)
(*infoLink*)


(* Styling of this link/tooltip matches the standard Preferences dialog styling for such. *)


infoLink[client_] := 
	Module[{objs, info, locations},
		objs = DeployedAgentTools[client];
		info = {#["Scope"], #["MCP"]["Server"], #["MCP"]["ConfigFile"]}& /@ objs;
		locations = Cases[info, {"Global", "Wolfram" | "WolframLanguage", File[loc_]} :> loc];
		
		If[
			MatchQ[locations, {__String}],
			With[{locations = locations},
				Button[
					Tooltip[
						NotebookTools`Mousedown[
							icon["prefsInfoIcon", LightDarkSwitched @ RGBColor["#898989"], 14],
							icon["prefsInfoIcon", LightDarkSwitched @ RGBColor[0.692, 0.692, 0.692], 14],
							icon["prefsInfoIcon", LightDarkSwitched @ RGBColor[0.358, 0.358, 0.358], 14]],
						Pane[
							Column[
								{
									Style[tr["prefsInstallLocation"], FontColor -> ldsGray[0.4]],
									Row[{#, "\[UpperRightArrow]"}, "\[NonBreakingSpace]"]& /@ locations
								} // Flatten
							],
							ImageMargins -> 3,
							ImageSize -> UpTo[274]
						],
						TooltipStyle -> {
							Background -> LightDarkSwitched @ RGBColor["#EDEDED"],
							CellFrameColor -> LightDarkSwitched @ RGBColor["#D1D1D1"],
							CellFrameMargins -> 5,
							FontColor -> LightDarkSwitched @ RGBColor["#333333"],
							FontFamily -> "Roboto",
							FontSize -> 11
						}
					],
					SystemOpen[DirectoryName[#]]& /@ locations,
					Appearance -> None
				]
			],
			""
		]
	]


(* ::Section::Closed:: *)
(*dirSettingsRow*)


dirSettingsRow[obj_] := 
	{
		MouseAppearance[
			Button[
				Row[{
					Replace[obj["Scope"], 
						File[path_String] :> 
							FE`Evaluate[FEPrivate`TruncateStringToWidth[path, "Input", 200, Left]]
					],
					" \[UpperRightArrow]"
				}],
				SystemOpen[obj["Scope"]],
				Appearance -> None,
				DefaultBaseStyle -> {},
				BaseStyle -> {FontColor -> Dynamic[If[CurrentValue["MouseOver"], StandardBlue, ldsGray[0.5]]]},
				ImageMargins -> {{5,0},{0,0}},
				Tooltip -> ToBoxes @ First @ obj["Scope"]
			],
			"LinkHand"
		],
		Replace[obj["Server"],{
			"Wolfram" :> tr["prefsComputationTools"],
			"WolframLanguage" :> tr["prefsDevelopmentTools"]
		}],
		Button[
			Mouseover[
				icon["prefsRemoveIcon", ldsGray[0.2], 10],
				icon["prefsRemoveIcon", StandardRed, 10]
			],
			DeleteObject[obj],
			Appearance -> None,
			DefaultBaseStyle -> {},
			BaseStyle -> {FontColor -> Dynamic[If[CurrentValue["MouseOver"], StandardBlue, ldsGray[0.5]]]},
			Tooltip -> ToBoxes @ tr["prefsUninstallTool"]
		]
	}


(* ::Section::Closed:: *)
(*CreatePreferencesContent*)


CreatePreferencesContent // beginDefinition;


CreatePreferencesContent[] := 
Deploy[
	Pane[
		Column[
			{
				Grid[
					{{
						Item[tr["prefsSubtitle"], ItemSize -> Fit],
						Item[docsLink[], Alignment -> Right]
					}},
					Alignment -> {Left, Center},
					BaseStyle -> {LinebreakAdjustments -> {1, 10, 1, 0, 1}},
					Spacings -> {2,0}
				],
				
				Style[tr["prefsComputationTools"], FontWeight -> "DemiBold"],
				Style[tr["prefsComputationToolsDescription"], FontColor -> ldsGray[0.4], Italic],
				
				Style[tr["prefsDevelopmentTools"], FontWeight -> "DemiBold"],
				Style[tr["prefsDevelopmentToolsDescription"], FontColor -> ldsGray[0.4], Italic],

				clientInterfaces[]
			},
			Dividers -> {None, {None, None, None, None, None, ldsGray[0.85], None}},
			ItemSize -> Scaled[1],
			Spacings -> {Automatic, {0,1.4,0.5,1.4,0.5,3}}
		],
		Alignment -> Left,
		ImageMargins -> {{25,25},{11,11}}
	]
]



CreatePreferencesContent // endDefinition;


(* ::Section::Closed:: *)
(*Package Footer*)


addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
