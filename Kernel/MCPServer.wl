PreemptProtect[ BeginPackage[ "Wolfram`MCPServer`" ]; EndPackage[ ] ];

Wolfram`MCPServerLoader`$MXFile = FileNameJoin @ {
    DirectoryName @ $InputFileName,
    ToString @ $SystemWordLength <> "Bit",
    "MCPServer.mx"
};

If[ MemberQ[ $Packages, "Wolfram`MCPServer`" ]
    ,
    Wolfram`MCPServerLoader`$protectedNames = Replace[
        Wolfram`MCPServer`$MCPServerProtectedNames,
        Except[ _List ] :> Names[ "Wolfram`MCPServer`*" ]
    ];

    Wolfram`MCPServerLoader`$allNames = Replace[
        Wolfram`MCPServer`$MCPServerSymbolNames,
        Except[ _List ] :> Union[ Wolfram`MCPServerLoader`$protectedNames, Names[ "Wolfram`MCPServer`*`*" ] ]
    ];

    Unprotect @@ Wolfram`MCPServerLoader`$protectedNames;
    ClearAll @@ Wolfram`MCPServerLoader`$allNames;
];

Quiet[
    If[ FileExistsQ @ Wolfram`MCPServerLoader`$MXFile
        ,
        Get @ Wolfram`MCPServerLoader`$MXFile;
        (* Ensure all subcontexts are in $Packages to avoid reloading subcontexts out of order: *)
        If[ MatchQ[ Wolfram`MCPServer`$MCPServerContexts, { __String } ],
            WithCleanup[
                Unprotect @ $Packages,
                $Packages = DeleteDuplicates @ Join[ $Packages, Wolfram`MCPServer`$MCPServerContexts ],
                Protect @ $Packages
            ]
        ]
        ,
        WithCleanup[
            PreemptProtect @ Get[ "Wolfram`MCPServer`Main`" ],
            { $Context, $ContextPath, $ContextAliases } = { ## }
        ] & [ $Context, $ContextPath, $ContextAliases ]
    ],
    General::shdw
];

(* Set the paclet object for this paclet, ensuring that it corresponds to the one that's actually loaded: *)
Wolfram`MCPServer`Common`$thisPaclet = PacletObject @ File @ DirectoryName[ $InputFileName, 2 ];