# New Code Inspection Rules: Unreachable Conditional Definitions

## Examples for Context

```wl
In[1]:= ClearAll[x, f, g, h]
```

These do not have patterns in the LHS, so the conditional definition never matches:

```wl
In[2]:=
x /; True := 1;
x := 2;
x

Out[4]= 2

In[5]:=
f[] /; True := 1;
f[] := 2;
f[]

Out[7]= 2
```

This has conditions on all definitions, so it works as expected:

```wl
In[8]:=
g[] /; True := 1;
g[] /; False := 2;
g[]

Out[10]= 1
```

This has patterns in the definition, so the ordering works as expected:

```wl
In[11]:=
h[_] /; True := 1;
h[_] := 2;
h[a]

Out[13]= 1
```

## Goals

- In the examples above, we should be able to identify definitions like `x` and `f` and issue a warning that the first definition is unreachable.
- It should _not_ issue a warning for `g` because all LHS patterns have conditions.
- It should _not_ issue a warning for `h` because the presence of patterns preserves the order of definitions.

## Challenges

### There may be other code between definitions

```wl
f[] /; cond := a;

f[x_] := x + 1;

f[] := b;
```

However, this should still be detected because the first definition is unreachable.

### The code doesn't necessarily have to be terminated by a semicolon

```wl
f[] /; cond := a
f[] := b
```

### The problem is also present when the LHS contains literal expressions instead of patterns

This would be extremely difficult to distinguish from definitions that have patterns (like `h` above) with static analysis:

```wl
In[14]:=
f // ClearAll;
f[x] /; True := 1;
f[x] := 2;
f[x]

Out[17]= 2
```

We may want to initially restrict the inspection to definitions like `x` and `f[]` because these are reasonable candidates for the problem.

## Implementation Notes

This pattern can be used to find definitions like `x /; cond := value`:

```wl
astPattern @ HoldPattern[ Verbatim[ Condition ][ _Symbol, _ ] := _ ]
```

This pattern can be used to find definitions like `f[] /; cond := value`:

```wl
astPattern @ HoldPattern[ Verbatim[ Condition ][ _Symbol[ ], _ ] := _ ]
```

Once matched, we can extract all the definition nodes for a symbol in the order they appear in the AST using something like this:

```wl
Cases[
    ast,
    cp`CallNode[
        _,
        _,
        KeyValuePattern[ "Definitions" -> { ___, CodeParser`LeafNode[ Symbol, "symbolName", _ ], ___ } ]
    ],
    Infinity
]
```
