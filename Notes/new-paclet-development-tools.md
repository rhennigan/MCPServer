# New Paclet Development Tools

## Goals

We'd like to add the following new MCP tools:

* ``CheckPaclet`` - Checks paclet for common issues

* ``BuildPaclet`` - Builds a ``.paclet`` file

* ``SubmitPaclet`` - Publishes a paclet to the [Wolfram Paclet Repository](https://paclets.com/)

These tools should be made available to the ``"WolframPacletDevelopment"`` server.

## Implementation Notes

These tools should use functionality from the ``Wolfram/PacletCICD`` paclet. In particular, the tools should use the following functions:

```wl
Wolfram`PacletCICD`CheckPaclet
Wolfram`PacletCICD`BuildPaclet
Wolfram`PacletCICD`SubmitPaclet
```

The primary implementation work will be in converting the outputs of these functions into useful markdown that's understandable by an LLM.

## Additional Context

The source code of PacletCICD has been made available for you in ``H:/Documents/PacletCICD`` in case you need to explore how these functions work. They also heavily rely on the DefinitionNotebookClient paclet, which has also been made available in ``H:/Documents/DefinitionNotebookClient`` in case you need to explore further.

Use the ReadNotebook MCP tool to read documentation notebooks. In particular, ``Documentation/English/ReferencePages/Symbols/ExampleDirectory.nb`` in PacletCICD has good examples of how you can use `CheckPaclet` and `BuildPaclet` with some predefined sample paclets.

PacletCICD is not a default paclet included with Wolfram Language, so the code will need to ensure that it is installed before using these functions with ``PacletInstall[ "Wolfram/PacletCICD" ]``. Note that ``PacletInstall`` is very fast for already installed paclets.