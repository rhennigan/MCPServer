We need a code inspector hint that checks for ``Needs["context`"]`` appearing in functions:

```wl
findMCPPaclets[ ] := Enclose[
    Module[ { paclets },
        Needs[ "PacletTools`" ];
        paclets = PacletFind[ ];
        ConfirmMatch[
            Select[ paclets, mcpPacletQ ],
            { ___PacletObject },
            "Result"
        ]
    ],
    throwInternalFailure
];
```

This should produce a warning that it will modify the `$ContextPath` at runtime, which is usually not intended. Suggested fix is to use ``Needs["context`" -> None]`` instead.

Similarly, we should check for ``Get["context`"]`` appearing in functions. The suggested fix should be different though: ``Block[{$ContextPath}, Get["context`"]]``.