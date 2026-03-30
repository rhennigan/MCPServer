PreemptProtect[ BeginPackage[ "Wolfram`AgentTools`" ]; EndPackage[ ] ];

Wolfram`AgentToolsLoader`$MXFile = FileNameJoin @ {
    DirectoryName @ $InputFileName,
    ToString @ $SystemWordLength <> "Bit",
    "AgentTools.mx"
};

If[ MemberQ[ $Packages, "Wolfram`AgentTools`" ]
    ,
    Wolfram`AgentToolsLoader`$protectedNames = Replace[
        Wolfram`AgentTools`$AgentToolsProtectedNames,
        Except[ _List ] :> Names[ "Wolfram`AgentTools`*" ]
    ];

    Wolfram`AgentToolsLoader`$allNames = Replace[
        Wolfram`AgentTools`$AgentToolsSymbolNames,
        Except[ _List ] :> Union[ Wolfram`AgentToolsLoader`$protectedNames, Names[ "Wolfram`AgentTools`*`*" ] ]
    ];

    Unprotect @@ Wolfram`AgentToolsLoader`$protectedNames;
    ClearAll @@ Wolfram`AgentToolsLoader`$allNames;
];

Quiet[
    If[ FileExistsQ @ Wolfram`AgentToolsLoader`$MXFile
        ,
        Get @ Wolfram`AgentToolsLoader`$MXFile;
        (* Ensure all subcontexts are in $Packages to avoid reloading subcontexts out of order: *)
        If[ MatchQ[ Wolfram`AgentTools`$AgentToolsContexts, { __String } ],
            WithCleanup[
                Unprotect @ $Packages,
                $Packages = DeleteDuplicates @ Join[ $Packages, Wolfram`AgentTools`$AgentToolsContexts ],
                Protect @ $Packages
            ]
        ]
        ,
        WithCleanup[
            PreemptProtect @ Get[ "Wolfram`AgentTools`Main`" ],
            { $Context, $ContextPath, $ContextAliases } = { ## }
        ] & [ $Context, $ContextPath, $ContextAliases ]
    ],
    General::shdw
];

(* Set the paclet object for this paclet, ensuring that it corresponds to the one that's actually loaded: *)
Wolfram`AgentTools`Common`$thisPaclet = PacletObject @ File @ DirectoryName[ $InputFileName, 2 ];