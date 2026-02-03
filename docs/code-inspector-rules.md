# Adding Custom CodeInspector Rules

This document explains how to add custom code inspection rules to the MCPServer CodeInspector tool.

## Overview

The CodeInspector tool uses the [CodeInspector](https://github.com/WolframResearch/codeinspector) package to analyze Wolfram Language code. MCPServer extends the default rules with custom rules defined in `Kernel/Tools/CodeInspector/Rules.wl`.

There are three types of rules:

| Type | Description | Custom Variable | Combined Variable |
|------|-------------|-----------------|-------------------|
| **Abstract Rules** | Pattern match on the abstract syntax tree (simplified, no whitespace/comments) | `$customAbstractRules` | `$abstractRules` |
| **Aggregate Rules** | Analyze relationships between multiple nodes in the AST | `$aggregateRules` | — |
| **Concrete Rules** | Pattern match on the concrete syntax tree (includes whitespace/comments) | `$concreteRules` | — |

> Custom rules are defined in the "Custom Variable" column. For abstract rules, `$abstractRules` combines the defaults from ``CodeInspector`AbstractRules`$DefaultAbstractRules`` with custom rules.

## Rule Structure

Rules are defined as associations mapping patterns to handler functions:

```wl
$customAbstractRules := $customAbstractRules = <|
    pattern1 -> handlerFunction1,
    pattern2 -> handlerFunction2,
    ...
|>;
```

## AST Node Types

The CodeParser package defines several node types used in patterns:

| Node Type | Description | Example |
|-----------|-------------|---------|
| ``cp`CallNode`` | Function call | `f[x, y]` |
| ``cp`LeafNode`` | Atomic expression | `42`, `"hello"`, `Symbol` |
| ``cp`GroupNode`` | Grouped expression | `(x + y)` |
| ``cp`InfixNode`` | Infix operator | `a + b` |
| ``cp`PrefixNode`` | Prefix operator | `-x` |
| ``cp`PostfixNode`` | Postfix operator | `x!` |

> **Note:** This is not an exhaustive list. CodeParser also defines `BinaryNode`, `TernaryNode`, `ErrorNode`, `CompoundNode`, and others. See the [CodeParser documentation](https://github.com/WolframResearch/codeparser) for all node types. Some nodes are only available in the concrete syntax tree.

Node structure: `NodeType[head, children, metadata]`

- **head**: For ``CallNode``, this is the function being called (usually a ``LeafNode``)
- **children**: List of argument nodes
- **metadata**: Association with source location and other info

To see the AST of a particular expression, you can use the `CodeParse` function via the `WolframLanguageEvaluator` MCP tool:

```wl
Needs[ "CodeParser`" ];
CodeParser`CodeParse[ "MyFunction[x]" ]
```

If you're writing a rule that inspects concrete syntax, you can use the `CodeConcreteParse` function:

```wl
Needs[ "CodeParser`" ];
CodeParser`CodeConcreteParse[ "MyFunction[x]" ]
```

## Pattern Matching Techniques

### Direct Pattern Matching

Match specific AST structures directly:

```wl
(* Match single-argument Throw calls *)
cp`CallNode[
    cp`LeafNode[ Symbol, "Throw"|"System`Throw", _ ],
    { _ },  (* exactly one argument *)
    _
] -> inspectSingleArgThrow
```

### Using Test Functions

Add test functions to patterns for complex conditions:

```wl
(* Match symbols in private contexts *)
cp`LeafNode[ Symbol, _String? privateContextQ, _ ] -> inspectPrivateContext
```

Where the test function is:

```wl
privateContextQ // beginDefinition;
privateContextQ[ name_String ] /; StringStartsQ[ name, "System`Private`" ] := False;
privateContextQ[ name_String ] := StringContainsQ[ name, __ ~~ ("`Private`"|"`PackagePrivate`") ];
privateContextQ[ ___ ] := False;
privateContextQ // endDefinition;
```

### Using astPattern Helper

The `astPattern` function provides higher-level pattern matching using standard Wolfram Language patterns:

```wl
(* Match negated date-yielding expressions *)
astPattern[ - $$yieldsDateObject ] -> inspectNegatedDateObject
```

Where `$$yieldsDateObject` is a reusable pattern:

```wl
$$yieldsDateObject = HoldPattern @ Alternatives[
    _CurrentDate,
    _DateObject,
    _DatePlus,
    _FileDate,
    _NextDate,
    _PreviousDate,
    _RandomDate,
    Now,
    Today,
    Tomorrow,
    Yesterday
];
```

## Handler Function Format

Handler functions receive two arguments: the position in the AST and the full AST.

### Standard Structure

```wl
inspectMyRule // beginDefinition;

inspectMyRule[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        (* Extract the matched node *)
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];

        (* Get metadata (contains source location) *)
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];

        (* Return an InspectionObject *)
        ci`InspectionObject[
            "MyRuleTag",                    (* Unique identifier *)
            "Description of the issue",     (* Message shown to user *)
            "Warning",                       (* Severity level *)
            <| as, ConfidenceLevel -> 0.9 |> (* Metadata with confidence *)
        ]
    ];

inspectMyRule // endDefinition;
```

### Skipping Metadata Matches

When patterns might match inside AST metadata (like the "Definitions" key), skip those:

```wl
inspectMyRule[ pos_, ast_ ] /; MemberQ[ pos, _Key ] := { };
```

### Returning No Issue

Return an empty list `{ }` when the pattern matches but no issue should be reported:

```wl
inspectMyRule[ pos_, ast_ ] /; someConditionToSkip := { };
```

### Complex Rules with AST Walking

For rules that need to examine surrounding context (like checking for enclosing `Catch`):

```wl
inspectSingleArgThrow[ pos_, ast_ ] := Catch[
    Replace[
        Fold[ walkASTForCatch, ast, pos ],  (* Walk up the AST *)
        {
            cp`CallNode[ cp`LeafNode[ Symbol, "Throw"|"System`Throw", _ ], _, as_Association ] :>
                ci`InspectionObject[
                    "NoSurroundingCatch",
                    "``Throw`` has no tag or surrounding ``Catch``",
                    "Error",
                    <| as, ConfidenceLevel -> 0.9 |>
                ],
            ___ :> { }  (* No issue if Catch found *)
        }
    ],
    $tag
];

(* Also stops at holding functions like Hold, HoldForm, HoldComplete, HoldCompleteForm *)
walkASTForCatch[ cp`CallNode[ cp`LeafNode[ Symbol, "Catch"|"System`Catch"|$$holdingSymbol, _ ], { _ }, _ ], _ ] :=
    Throw[ { }, $tag ];  (* Found enclosing Catch or holding function, abort with no issue *)

walkASTForCatch[ ast_, pos_ ] :=
    Extract[ ast, pos ];  (* Continue walking *)
```

## Severity Levels

Choose an appropriate severity for the issue:

| Severity | When to Use |
|----------|-------------|
| `"Fatal"` | Code will definitely fail or cause serious problems |
| `"Error"` | Code is almost certainly wrong |
| `"Warning"` | Code is likely problematic but might be intentional |
| `"Scoping"` | Scoping-related issues (shadowing, etc.) |
| `"Remark"` | Suggestions for improvement, not necessarily wrong |
| `"Formatting"` | Style and formatting issues |

## Confidence Levels

Set `ConfidenceLevel` between 0.0 and 1.0:

| Range | Meaning |
|-------|---------|
| 0.9 - 1.0 | Very confident this is an issue |
| 0.7 - 0.9 | Likely an issue |
| 0.5 - 0.7 | Possibly an issue, may be false positive |
| < 0.5 | Low confidence, high chance of false positive |

The default inspection threshold is 0.75, so issues below this won't be shown by default.

## Step-by-Step Guide

### 1. Define Reusable Patterns (Optional)

Add patterns to the "Argument Patterns" section if they'll be reused:

```wl
$$myPattern = HoldPattern @ Alternatives[ ... ];
```

### 2. Add the Rule

Add your rule to the appropriate rules association:

```wl
(* In $customAbstractRules for abstract rules *)
$customAbstractRules := $customAbstractRules = <|
    CodeInspector`AbstractRules`$DefaultAbstractRules,
    (* existing rules... *)
    myPattern -> inspectMyRule  (* Add your rule *)
|>;
```

### 3. Write the Handler Function

```wl
inspectMyRule // beginDefinition;

inspectMyRule[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "MyRuleTag",
            "Description of the issue",
            "Warning",
            <| as, ConfidenceLevel -> 0.9 |>
        ]
    ];

inspectMyRule // endDefinition;
```

### 4. Add to MX Initialization (If Using Delayed Evaluation)

If your rule uses `:=` (delayed assignment), add it to the MX initialization:

```wl
addToMXInitialization[
    $customAbstractRules;
];
```

### 5. Write Tests

Add tests to `Tests/CodeInspectorTool.wlt`:

```wl
(* ::Section::Closed:: *)
(*Custom Rules - MyRule*)

VerificationTest[
    $myRuleResult = Wolfram`MCPServer`Common`catchTop @
        Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
            "code"               -> "problematic code here",
            "file"               -> Missing[ "KeyAbsent" ],
            "tagExclusions"      -> Missing[ "KeyAbsent" ],
            "severityExclusions" -> "",
            "confidenceLevel"    -> 0.0,
            "limit"              -> Missing[ "KeyAbsent" ]
        |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "MyRule-ReturnsString"
]

VerificationTest[
    StringContainsQ[ $myRuleResult, "MyRuleTag" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MyRule-HasTag"
]

VerificationTest[
    StringContainsQ[ $myRuleResult, "Description of the issue" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MyRule-HasDescription"
]
```

### 6. Verify

Run tests using the `TestReport` MCP tool to verify your rule works.

## Example: `inspectNegatedDateObject`

Detects when date-yielding expressions are negated, which produces meaningless results.

**Pattern:**
```wl
astPattern[ - $$yieldsDateObject ] -> inspectNegatedDateObject
```

**Handler:**
```wl
inspectNegatedDateObject[ pos_, ast_ ] :=
    Enclose @ Module[ { node, as },
        node = ConfirmMatch[ Extract[ ast, pos ], _[ _, _, __ ], "Node" ];
        as = ConfirmBy[ node[[ 3 ]], AssociationQ, "Metadata" ];
        ci`InspectionObject[
            "NegatedDateObject",
            "Negating a ``DateObject`` does not produce a meaningful result",
            "Error",
            <| as, ConfidenceLevel -> 0.95 |>
        ]
    ];
```

**Detected code:**
```wl
SortBy[files, -FileDate[#1] &]  (* Common mistake *)
x = -Now
y = -Today
```

## Related Files

| File | Purpose |
|------|---------|
| `Kernel/Tools/CodeInspector/Rules.wl` | Custom rule definitions |
| `Kernel/Tools/CodeInspector/Inspection.wl` | Rule integration with CodeInspector |
| `Kernel/Tools/CodeInspector/CodeInspector.wl` | Main tool entry point |
| `Kernel/Tools/CodeInspector/Formatting.wl` | Output formatting for inspections |
| `Tests/CodeInspectorTool.wlt` | Tests for CodeInspector tool |

## See Also

- [CodeInspector documentation](https://github.com/WolframResearch/codeinspector)
- [CodeParser documentation](https://github.com/WolframResearch/codeparser)
- [MCP Tools documentation](tools.md)
