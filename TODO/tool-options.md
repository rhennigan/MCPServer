# Tool Options

## Goals

We'd like to add a new ``"ToolOptions"`` option to ``InstallMCPServer`` which accepts an association where the keys correspond to default tool names, and their values would be associations containing option names and their values. This would be a convenient way for a user to customize the behavior of the default built-in tools. Example:

```wl
InstallMCPServer[
	"ClaudeCode",
	"WolframLanguage",
	"ToolOptions" -> <|
		"WolframLanguageContext" -> <|"MaxItems" -> 5|>,
		"WolframLanguageEvaluator" -> <|"Method" -> "Local"|>
	|>
]
```

## Implementation Notes

### Storing options during InstallMCPServer

If a user has specified tool options when evaluating InstallMCPServer, we should do the following:

* If the set of options is small enough to fit in an environment variable, serialize as JSON and include as ``"MCP_TOOL_OPTIONS" = "{...}"``

* If large, export to a JSON file, and set ``"MCP_TOOL_OPTIONS" = "file://..."``

Question: How large can environment variables be? Do we actually need the `file://` syntax?

### Retrieving options at runtime

* When starting the MCP server, read in the tool options (if any) and store them in a global association ``$toolOptions`` in the common context.

* Define ``toolOptionValue[toolName, optionName]`` that does the following:

	* Looks at ``$toolOptions[toolName, optionName]`` and uses that if defined

	* Otherwise checks ``$defaultToolOptions[toolName, optionName]``

We should define the values of ``$defaultToolOptions`` alongside ``$defaultMCPTools``.

## Initial Tool Options

### CodeInspector

None

### SymbolDefinition

None

### TestReport

None

### WolframAlpha

None

### WolframAlphaContext

* MaxItems

* IncludeWolframLanguageResults (passed as the option ``IncludeWLResults`` in ``RelatedWolframAlphaResults``).

```wl
In[10]:= Options[Wolfram`Chatbook`RelatedWolframAlphaResults]

Out[10]= {"AppID" -> Automatic, "CacheResults" -> False, "Debug" -> False, "IncludeWLResults" -> Automatic, "Instructions" -> None, "LLMEvaluator" -> Automatic, "MaxItems" -> Automatic, "PromptHeader" -> Automatic, "RandomQueryCount" -> Automatic, "Reinterpret" -> False, "RelatedQueryCount" -> Automatic, "SampleQueryCount" -> Automatic}
```

### WolframLanguageContext

* MaxItems

Note that ``MaxItems`` needs special handling depending on whether or not ``llmKitSubscribedQ[]`` is True. Instead of passing this directly to ``RelatedDocumentation``, we should use the following options:

If subscribed:

```wl
Wolfram`Chatbook`RelatedDocumentation[
	context,
	"Prompt",
	"PromptHeader" -> False,
	"FilterResults" -> True,
	"FilteredCount" -> max,
	"MaxItems" -> max * 5
]
```

If not subscribed:

```wl
Wolfram`Chatbook`RelatedDocumentation[
	context,
	"Prompt",
	"PromptHeader" -> False,
	"FilterResults" -> False,
	"MaxItems" -> max
]
```

### WolframContext

This one is a bit special since it combines the other two context tools. This means we need multiple options for things like ``MaxItems``.

* WolframLanguageMaxItems

* WolframLanguageSources

* WolframAlphaMaxItems

We should always set ``IncludeWLResults`` to ``True`` in this tool.

### WolframLanguageEvaluator

* Method

* ImageExportMethod

* TimeConstraint

### WriteNotebook

None

## Other Notes

The two environment variables currently used by the WolframLanguageEvaluator tool will be deprecated and no longer supported.

* ``WOLFRAM_LANGUAGE_EVALUATOR_METHOD``

* ``WOLFRAM_LANGUAGE_EVALUATOR_IMAGE_EXPORT_METHOD``

## Phase 2

We do not need this for the initial implementation, but we should plan to support it later.

### Options Derived From Parameters

For each tool in ``$DefaultMCPTools``, we would automatically derive some available options. To do this for a given tool, we look at each optional parameter and define two tool options:

* ``<NameOfParameter>``: If this is set, we *always* use the specified value instead of exposing it as a tool parameter for the LLM.

* ``Default<NameOfParameter>``: If this is set, we use the specified value as the default when the parameter is not provided by the LLM.

#### Example

This would set up some customizations for the CodeInspector tool:

```wl
InstallMCPServer[
    "ClaudeCode",
    "WolframLanguage",
    "ToolOptions" -> <|
        "CodeInspector" -> <|
            "ConfidenceLevel" -> 0.25,
            "DefaultSeverityExclusions" -> {"Remark", "Scoping"}
        |>
    |>
]
```

Because we've explicitly set a value for ``ConfidenceLevel``, we would remove that parameter entirely from the tool schema when exposing it via MCP.

Since ``DefaultSeverityExclusions`` has the ``"Default"`` prefix, we still include this parameter in the schema, but we use the specified value as the default instead of the currently hard-coded behavior.

### New Options

#### CodeInspector

* MaxPageWidth: Customize the max line width before warnings are generated.
* MaxLineCount: Customize the max number of lines before warnings are generated.

#### WolframLanguageEvaluator

* Initialization: Code to run when the evaluator kernel starts up.