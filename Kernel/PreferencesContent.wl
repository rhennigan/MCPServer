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
(*CreatePreferencesContent*)


CreatePreferencesContent // beginDefinition;



CreatePreferencesContent[] := 
Deploy[
	Pane[
		Column[
			{
				Style["[[Wolfram Agent Tools]]", FontWeight -> "Bold"],
				Style["[[The following tools may be used by AI Harnesses:]]", FontWeight -> "Plain"],
				
				Grid[
					{
						{
							"[[icon]]",
							Column[{
								"[[Computation Tools]]",
								"[[Tools for general computation and knowledge]]"}]
						},
						{
							"[[icon]]",
							Column[{
								"[[Development Tools]]",
								"[[Tools for Wolfram Language development]]"}]
						}
					},
					Alignment -> {Left, Top},
					Spacings -> {1,1}
				],
				
				Framed[
					Column[
						{
							"[[AI Harnesses installed on this computer:]]",
							mcpControlGrid[]
						},
						Spacings -> {Automatic, 1}
					],
					Background -> LightDarkSwitched[White],
					FrameMargins -> 10,
					FrameStyle -> LightDarkSwitched[LightGray],
					ImageSize -> Scaled[1]
				]
			},
			Dividers -> {None, {None, None, LightDarkSwitched[LightGray], None}},
			ItemSize -> Scaled[1],
			Spacings -> {Automatic, {0,1,3,2,1}}
		],
		ImageMargins -> 15
	]
]



CreatePreferencesContent // endDefinition;



mcpControlGrid[] :=
	DynamicModule[{update = 0, clients, servers},
		Dynamic[
			If[Not @ ListQ @ servers,
				ProgressIndicator[Appearance -> "Necklace"],
				update;
				With[
					(* TODO: Handle property extraction failures here: *)
					{deployed = {#["ClientName"], #["MCP"]["Server"]}& /@ DeployedAgentTools[]},
					{rows = Table[
						With[{client = client},
							{
								Style[client, FontWeight -> "DemiBold"],
								PopupMenu[
									Dynamic[update;
										Switch[#["Server"]& /@ DeployedAgentTools[client],
											{___, "Wolfram", ___}, "Computation Tools",
											{___, "WolframLanguage", ___}, "Development Tools",
											_, None
										],
										(Switch[#,
											"Computation Tools",
												DeleteObject[DeployedAgentTools[client]];
												DeployAgentTools[client, "Wolfram"],
											"Development Tools",
												DeleteObject[DeployedAgentTools[client]];
												DeployAgentTools[client, "WolframLanguage"],
											None,
												DeleteObject[DeployedAgentTools[client]]
										];
										++update)&
									]
									,
									{
										"Computation Tools",
										"Development Tools",
										Delimiter,
										None -> Style["No tool", Italic, FontColor -> LightDarkSwitched[Gray]]
									}
								],
								Dynamic[update;
									If[
										MemberQ[#["Server"]& /@ DeployedAgentTools[client], "Wolfram" | "WolframLanguage"],
										"[[info]]",
										""
									]
								]
							}
						],
						{client, clients}
					]},
					Grid[
						rows,
						BaseStyle -> "ControlStyle",
						Alignment -> {Left, Baseline},
						Spacings -> 2,
						FrameStyle -> LightDarkSwitched[LightGray],
						Dividers -> {{False, True, False}, None}
					]
				]
			]
		],
		Initialization :> (
			(*
			TODO: Clients that are actually installed on the user's machine should be indicated
			somehow, when that information becomes availble.
			*)
			(* TODO: Add error checking for these MCPServer` functions *)
			clients = Keys @ Wolfram`AgentTools`$SupportedMCPClients;
			servers = Prepend[Keys @ Wolfram`AgentTools`$DefaultMCPServers, None];
		),
		SynchronousInitialization -> False,
		UnsavedVariables :> {clients, servers}
	]


(* ::Section::Closed:: *)
(*Package Footer*)


addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
