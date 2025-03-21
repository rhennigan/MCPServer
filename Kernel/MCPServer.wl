PreemptProtect[ BeginPackage[ "RickHennigan`MCPServer`" ]; EndPackage[ ] ];

RickHennigan`MCPServerLoader`$MXFile = FileNameJoin @ {
    DirectoryName @ $InputFileName,
    ToString @ $SystemWordLength <> "Bit",
    "MCPServer.mx"
};

If[ MemberQ[ $Packages, "RickHennigan`MCPServer`" ]
    ,
    RickHennigan`MCPServerLoader`$protectedNames = Replace[
        RickHennigan`MCPServer`$MCPServerProtectedNames,
        Except[ _List ] :> Names[ "RickHennigan`MCPServer`*" ]
    ];

    RickHennigan`MCPServerLoader`$allNames = Replace[
        RickHennigan`MCPServer`$MCPServerSymbolNames,
        Except[ _List ] :> Union[ RickHennigan`MCPServerLoader`$protectedNames, Names[ "RickHennigan`MCPServer`*`*" ] ]
    ];

    Unprotect @@ RickHennigan`MCPServerLoader`$protectedNames;
    ClearAll @@ RickHennigan`MCPServerLoader`$allNames;
];

Quiet[
    If[ FileExistsQ @ RickHennigan`MCPServerLoader`$MXFile
        ,
        Get @ RickHennigan`MCPServerLoader`$MXFile;
        (* Ensure all subcontexts are in $Packages to avoid reloading subcontexts out of order: *)
        If[ MatchQ[ RickHennigan`MCPServer`$MCPServerContexts, { __String } ],
            WithCleanup[
                Unprotect @ $Packages,
                $Packages = DeleteDuplicates @ Join[ $Packages, RickHennigan`MCPServer`$MCPServerContexts ],
                Protect @ $Packages
            ]
        ]
        ,
        WithCleanup[
            PreemptProtect @ Get[ "RickHennigan`MCPServer`Main`" ],
            { $Context, $ContextPath, $ContextAliases } = { ## }
        ] & [ $Context, $ContextPath, $ContextAliases ]
    ],
    General::shdw
];

(* Set the paclet object for this paclet, ensuring that it corresponds to the one that's actually loaded: *)
RickHennigan`MCPServer`Common`$thisPaclet = PacletObject @ File @ DirectoryName[ $InputFileName, 2 ];