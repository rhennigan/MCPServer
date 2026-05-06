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


$allowDirectoryOperations = False;


(* ::Section::Closed:: *)
(*docsLink*)


docsLink[] :=
	MouseAppearance[
		Button[
			Framed[
				Row[{tr["prefsDocsLinkText"], " \[UpperRightArrow]"}, BaseStyle -> {FontSize -> Inherited - 2}],
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
				SystemOpen["paclet:Wolfram/AgentTools/tutorial/QuickStartforAICodingApplications"]
			],
			Appearance -> None,
			BaseStyle -> {},
			DefaultBaseStyle -> {}
		],
		"LinkHand"
	]


(* ::Section::Closed:: *)
(*clientInterfaces*)


clientInterfaces[] :=
	DynamicModule[{update = 0, clients, servers, configuredClients, clientNameSpacer, initDone},

		Dynamic[
			Which[
				initDone =!= True,
					ProgressIndicator[Appearance -> "Necklace"],

				MatchQ[clients, Except[{__String}]],
					Style["[[The list of supported MCP clients is not available.]]", Italic, FontColor -> ldsGray[0.5]],
				MatchQ[servers, Except[{__String}]],
					Style["[[The list of default MCP servers is not available.]]", Italic, FontColor -> ldsGray[0.5]],

				configuredClients === clients (* all *),
					Column[
						Prepend[
							clientRow[#, clientNameSpacer]& /@ configuredClients,
							Style[tr["prefsHarnessesConfigured"], Smaller, FontColor -> ldsGray[0.5], Bold]
						],
						ItemSize -> Scaled[1]
					],
				MatchQ[configuredClients, {__String}], (* some *)
					Column[
						{
							Column[
								Prepend[
									clientRow[#, clientNameSpacer]& /@ configuredClients,
									Style[tr["prefsHarnessesConfigured"], Smaller, FontColor -> ldsGray[0.5], Bold]
								],
								Spacings -> {0.4,0.4}
							],
							Column[
								Prepend[
									clientRow[#, clientNameSpacer]& /@ DeleteCases[clients, Alternatives @@ configuredClients],
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
						clientRow[#, clientNameSpacer]& /@ clients,
						ItemSize -> Scaled[1]
					]
			],
			TrackedSymbols :> {initDone}
		],

		Initialization :> (
			initDone = False;
			clients = Keys @ Wolfram`AgentTools`$SupportedMCPClients;
			servers = Keys @ Wolfram`AgentTools`$DefaultMCPServers;
			clientNameSpacer = PaneSelector[KeyValueMap[#1 -> #2["DisplayName"]&, Wolfram`AgentTools`$SupportedMCPClients], True];
			configuredClients = Cases[clients, Alternatives @@
				Map[#["ClientName"]&, Select[DeployedAgentTools[ ], MatchQ[#["Toolset"], "Wolfram" | "WolframLanguage"]&]]
			];
			initDone = True;
		),
		SynchronousInitialization -> False,
		UnsavedVariables :> {update, clients, servers, configuredClients, clientNameSpacer, initDone}
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
	With[{
			displayName = Wolfram`AgentTools`$SupportedMCPClients[client]["DisplayName"],
			url = Wolfram`AgentTools`$SupportedMCPClients[client]["URL"]
		},

		If[
			StringQ[url],
			PaneSelector[
				{
					True -> Hyperlink[
							displayName,
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
	DynamicModule[{update = 0, dirSettings},
		Grid[
			{
				{
					(* menu *)
					PopupMenu[
						Dynamic[update;
							Switch[{#["Toolset"], #["Scope"]}& /@ DeployedAgentTools[client],
								{___, {"Wolfram", "Global"}, ___}, update = 1; "ComputationTools",
								{___, {"WolframLanguage", "Global"}, ___}, update = 1; "DevelopmentTools",
								_, None
							],
							(Switch[#,
								"ComputationTools",
									DeployAgentTools[client, "Wolfram", OverwriteTarget -> True],
								"DevelopmentTools",
									DeployAgentTools[client, "WolframLanguage", OverwriteTarget -> True],
								None | 0,
									(* Only delete global "Wolfram" or "WolframLanguage" deployments *)
									DeleteObject @ Select[
										DeployedAgentTools @ client,
										#["Scope"] === "Global" && MatchQ[#["Toolset"], "Wolfram"|"WolframLanguage"]&
									]
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
											Switch[{#["Toolset"], #["Scope"]}& /@ DeployedAgentTools[client],
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
						Appearance -> "ActionMenu",
						BaseStyle -> {}, (* needed to avoid very strange notebook-level settings in the Preferences Dialog *)
						DefaultBaseStyle -> {},
						DefaultMenuStyle -> {}
					],
					(* info link *)
					Dynamic[update; infoLink[client]]
				},
				(*
					We cache per-directory settings when each instance of the interface is
					created. This allows us to continue displaying the info for any such
					objects, suitably restyled, after they have been removed by clicking
					the 'x' button.
				*)
				dirSettings = Cases[
					{#, #["Toolset"], #["Scope"], True}& /@ DeployedAgentTools[client],
					{_, "Wolfram" | "WolframLanguage", _File, _}
				];
				If[dirSettings === {},
					Nothing,
					{
						Pane[
							Dynamic[
								Grid[
									{
										{
											Style[tr["prefsSpecificDirectories"], Smaller, FontColor -> ldsGray[0.5], Bold],
											SpanFromLeft,
											If[$allowDirectoryOperations, SpanFromLeft, Nothing]
										},
										Splice @ Table[
											dirSettingsRow[Dynamic[dirSettings], i, dirSettings[[i]]],
											{i, Length[dirSettings]}
										]
									},
									Alignment -> {{Left, Right, Right}},
									ItemSize -> {{Automatic, Fit, Automatic}},
									Spacings -> {1,Automatic},
									BaseStyle -> {PrivateFontOptions -> {"OperatorSubstitution" -> False}}
								],
								TrackedSymbols :> {dirSettings}
							],
							ImageSize -> 390,
							Alignment -> Left,
							ImageMargins -> 5
						],
						""
					}
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
	Module[{objects, info, locations},
		objects = DeployedAgentTools[client];
		info = {#["Scope"], #["MCP"]["Server"], #["MCP"]["ConfigFile"]}& /@ objects;
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
					SystemOpen @ DirectoryName @ First @ locations,
					Appearance -> None
				]
			],
			""
		]
	]


(* ::Section::Closed:: *)
(*dirSettingsRow*)


dirSettingsRow[Dynamic[dirSettings_], i_, {obj_, server_, scope_, active_}] :=
	{
		MouseAppearance[
			Button[
				Row[{
					Replace[scope,
						File[path_String] :>
							FE`Evaluate[FEPrivate`TruncateStringToWidth[path, "ControlStyle", 200, Left]]
					],
					If[active, " \[UpperRightArrow]", Nothing]
				}]
				,
				SystemOpen[scope],
				Appearance -> None,
				DefaultBaseStyle -> {},
				Enabled -> active,
				BaseStyle -> {
					FontColor -> Dynamic[If[active && CurrentValue["MouseOver"], StandardBlue, ldsGray[0.5]]],
					FontVariations -> If[active, {}, {"StrikeThrough" -> True}],
					FontSize -> Inherited
				},
				ImageMargins -> {{5,0},{0,0}},
				Tooltip -> ToBoxes @ First @ obj["Scope"]
			],
			If[active, "LinkHand", Automatic]
		],
		Style[
			Replace[server, {
				"Wolfram" :> tr["prefsComputationTools"],
				"WolframLanguage" :> tr["prefsDevelopmentTools"]
			}],
			FontColor -> If[active, Inherited, ldsGray[0.5], Inherited],
			FontVariations -> If[active, {}, {"StrikeThrough" -> True}]
		],
		If[$allowDirectoryOperations,
			Button[
				Mouseover[
					icon["prefsRemoveIcon", ldsGray[0.2], 10],
					icon["prefsRemoveIcon", StandardRed, 10]
				],
				DeleteObject[obj];
				dirSettings[[i, 4]] = False,
				Appearance -> None,
				DefaultBaseStyle -> {},
				BaseStyle -> {
					FontColor -> Dynamic[If[CurrentValue["MouseOver"], StandardBlue, ldsGray[0.5]]],
					ShowContents -> active
				},
				Tooltip -> ToBoxes @ tr["prefsUninstallTool"]
			],
			Nothing
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



CreatePreferencesContent // endExportedDefinition;


(* ::Section::Closed:: *)
(*DetectedMCPClients*)


DetectedMCPClients // beginDefinition;


DetectedMCPClients[ ] :=
	Select[
		$SupportedMCPClients, 
		FileExistsQ @ FileNameJoin @ Replace[
			Lookup[#, "InstallLocation", {}], 
			{
				a_Association :> Lookup[a, $OperatingSystem, {}],
				Except[_List] :> {}
			}
		]&
	]


DetectedMCPClients // endExportedDefinition;


(* ::Section::Closed:: *)
(*Package Footer*)


addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
