---
name: add-code-inspector-rule
description: |
  Add a new custom CodeInspector rule to detect problematic Wolfram Language patterns.
  Use when asked to: "add a code inspector rule", "create an inspection rule",
  "add a lint rule", "detect [pattern] in code inspector", "add CodeInspector rule",
  "new code analysis rule".
argument-hint: "description of the pattern to detect"
---

# Add a Custom CodeInspector Rule

Follow this workflow to implement a new code inspection rule. The rule system lives in `Kernel/Tools/CodeInspector/Rules.wl` with tests in `Tests/CodeInspectorTool.wlt`.

## Step 1: Understand the Rule

Clarify these details (ask the user if not provided via `$ARGUMENTS`):

- **What code pattern should be detected?** Get an example of the problematic code.
- **Why is it problematic?** This becomes the inspection message.
- **Severity:** Fatal (will crash), Error (almost certainly wrong), Warning (likely wrong), Remark (suggestion), Formatting (style).
- **Confidence:** 0.95 for highly certain rules, 0.9 for confident, 0.7-0.9 for likely.

## Step 2: Choose the Rule Type

| Type | When to Use | Add To |
|------|-------------|--------|
| **Abstract** | Match simplified AST patterns (most common) | `$customAbstractRules` in Rules.wl |
| **Concrete** | Need whitespace/comments (e.g., comment content) | `$concreteRules` in Rules.wl |
| **Aggregate** | Analyze relationships between multiple AST nodes | `$aggregateRules` in Rules.wl |
| **Text-level** | Raw source text (line length, file size, etc.) | `textLevelInspections` function in Rules.wl |

## Step 3: Explore the AST Structure

Use the `WolframLanguageEvaluator` tool to parse example code and understand its AST:

```wl
Needs["CodeParser`"];
(* For abstract rules: *)
CodeParser`CodeParse["problematic code here"]
(* For concrete rules: *)
CodeParser`CodeConcreteParse["problematic code here"]
```

Study the output to determine which node types and patterns to match. Key node types:
- ``CodeParser`CallNode`` — function calls like `f[x]`
- ``CodeParser`LeafNode`` — atoms like `42`, `"hello"`, `Symbol`
- ``CodeParser`InfixNode`` — infix ops like `a + b`
- ``CodeParser`PrefixNode`` — prefix ops like `-x`

## Step 4: Read the Current Rules File

Read `Kernel/Tools/CodeInspector/Rules.wl` to understand the current state and find the right insertion points.

## Step 5: Define Reusable Patterns (if needed)

If the rule needs reusable patterns, add them to the **Argument Patterns** section (near the top of Rules.wl, after the `Needs` statements):

```wl
$$myPattern = HoldPattern @ Alternatives[
    _SomeFunction,
    _AnotherFunction,
    SomeSymbol
];
```

## Step 6: Add the Rule Entry

### For abstract rules — add to `$customAbstractRules`:

```wl
$customAbstractRules := $customAbstractRules = <|
    (* ...existing rules... *)
    (* MyNewRule - short description *)
    myPattern -> inspectMyNewRule
|>;
```

**Pattern approaches (choose one):**

Direct AST pattern matching:
```wl
cp`CallNode[ cp`LeafNode[ Symbol, "FunctionName"|"System`FunctionName", _ ], { _ }, _ ] -> inspectMyRule
```

Using a test predicate:
```wl
cp`LeafNode[ Symbol, _String? myPredicateQ, _ ] -> inspectMyRule
```

Using `astPattern` for Wolfram-syntax-level patterns:
```wl
astPattern[ - $$yieldsDateObject ] -> inspectMyRule
astPattern @ HoldPattern @ ReadString[ __, CharacterEncoding -> _, ___ ] -> inspectMyRule
```

### For concrete rules — add to `$concreteRules`:

```wl
$concreteRules := $concreteRules = <|
    CodeInspector`ConcreteRules`$DefaultConcreteRules,
    (* ...existing rules... *)
    myConcretePattern -> inspectMyRule
|>;
```

### For text-level rules — add to `textLevelInspections`:

```wl
textLevelInspections[ code_String ] :=
    Module[ { lines },
        lines = StringSplit[ code, "\n", All ];
        Flatten @ {
            inspectLineLengths @ lines,
            inspectFileLength @ lines,
            inspectMyTextRule @ lines  (* Add here *)
        }
    ];
```

## Step 7: Write the Handler Function

Add the handler in the **Definitions** section of Rules.wl, using the appropriate subsection marker.

### Standard AST handler template:

```wl
(* ::***...:: *)
(* ::Subsection::Closed:: *)
(*inspectMyNewRule*)
inspectMyNewRule // beginDefinition;

inspectMyNewRule[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "MyRuleTag",
            "Description of the issue shown to the user",
            "Warning",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];

inspectMyNewRule // endDefinition;
```

### If the pattern might match inside AST metadata, add a skip clause FIRST:

```wl
inspectMyNewRule[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };
```

### If extracting a string field (e.g., symbol name) for the message:

```wl
inspectMyNewRule[ pos_, ast_ ] :=
    Enclose @ Module[ { node, name, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        name = ConfirmBy[ node[[ 2 ]], StringQ, "Name" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "MyRuleTag",
            "The symbol ``" <> name <> "`` has an issue",
            "Warning",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];
```

### Text-level handler template:

```wl
inspectMyTextRule // beginDefinition;

inspectMyTextRule[ lines_List ] := MapIndexed[
    Function[ { line, idx },
        If[ someCondition @ line,
            ci`InspectionObject[
                "MyTextRuleTag",
                "Description of the issue",
                "Formatting",
                <| cp`Source -> { { First @ idx, 1 }, { First @ idx, StringLength @ line } }, ConfidenceLevel -> 0.95 |>
            ],
            Nothing
        ]
    ],
    lines
];

inspectMyTextRule // endDefinition;
```

### If the handler needs a test predicate, define it nearby:

```wl
myPredicateQ // beginDefinition;
myPredicateQ[ name_String ] := (* condition *);
myPredicateQ[ ___ ] := False;
myPredicateQ // endDefinition;
```

## Step 8: Update MX Initialization (if needed)

If the rules association uses `:=` (delayed evaluation), ensure it's in the MX init block at the bottom of Rules.wl (before `End[]`):

```wl
addToMXInitialization[
    $customAbstractRules;
];
```

This is already present for `$customAbstractRules`. Only add new entries if you created a new delayed variable.

## Step 9: Write Tests

Add tests to `Tests/CodeInspectorTool.wlt` at the end, before the cleanup section (`Integration Tests - Cleanup`). Follow this exact pattern:

```wl
(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - MyRuleTag*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectMyNewRule - Basic Detection*)
VerificationTest[
    $myRuleResult = CodeInspectorToolFunction @ <|
        "code"               -> "problematic code here",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "MyRuleTag-Basic-ReturnsString"
]

VerificationTest[
    StringContainsQ[ $myRuleResult, "MyRuleTag" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MyRuleTag-Basic-HasTag"
]

VerificationTest[
    StringContainsQ[ $myRuleResult, "Description of the issue" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MyRuleTag-Basic-HasDescription"
]

VerificationTest[
    StringContainsQ[ $myRuleResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MyRuleTag-Basic-HasSeverity"
]
```

**Always include:**
- A detection test (returns `_String` result containing the tag)
- A description test (message text appears)
- A severity test (correct severity in output)
- A false-positive test (clean code does NOT trigger the rule)

**For text-level rules**, use `runInspection` directly:

```wl
VerificationTest[
    $myInspections = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "test code",
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.0 |>
    ],
    { ___InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "MyRuleTag-ReturnsInspections"
]

VerificationTest[
    MemberQ[ $myInspections, InspectionObject[ "MyRuleTag", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "MyRuleTag-HasTag"
]
```

## Step 10: Verify

1. **Run the tests** using the `TestReport` MCP tool on `Tests/CodeInspectorTool.wlt`
2. **Run CodeInspector** on the modified `Kernel/Tools/CodeInspector/Rules.wl` to check for issues
3. Fix any failures and re-run until all tests pass

## Reference: Key Aliases in Rules.wl

These short aliases are used throughout the file:
- `ci`...` = `CodeInspector`...` (e.g., `ci`InspectionObject`, `ci`CodeInspect`)
- `cp`...` = `CodeParser`...` (e.g., `cp`CallNode`, `cp`LeafNode`, `cp`Source`)

## Reference: Section Marker Format

Use this exact format for section/subsection markers in Rules.wl:
```
(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*functionName*)
```
