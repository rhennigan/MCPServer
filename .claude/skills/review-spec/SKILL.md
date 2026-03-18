---
name: review-spec
description: >-
  Review a design specification in Specs/ against the actual codebase to find
  inaccuracies, potential issues, or things that need correction before
  implementation. Use when asked to: "review a spec", "check a spec for issues",
  "validate a spec", "find problems in a spec", "review the spec for [feature]",
  "audit a spec against the codebase", or any request to verify that a
  specification accurately reflects the current code and conventions.
disable-model-invocation: true
argument-hint: "spec filename or feature name"
---

# Review a Design Specification

Review a design specification against the actual codebase to surface inaccuracies, missing details, convention violations, and potential issues — before implementation begins. The goal is to catch problems that would cause confusion or rework during implementation.

**Spec to review:** $ARGUMENTS

If no specific spec is given, ask the user which spec in `Specs/` they'd like reviewed.

## Process

### 1. Read the Spec

Read the full spec file. As you read, collect:

- **Referenced files**: Every source file mentioned (implementation touchpoints, code examples, "see also" references)
- **Factual claims**: Specific assertions about existing code (option names/defaults, function signatures, symbol locations, data structures, file paths)
- **New additions**: Symbols, options, files, or behaviors the spec proposes to add
- **Behavioral descriptions**: How existing functions work, what they accept, what they return

### 2. Cross-Reference with the Codebase

Read all referenced files in parallel using the Explore agent or direct reads. For each file, verify:

- **Options and signatures**: Do the current options match what the spec claims? Are default values correct? Does the spec list all required changes?
- **Symbol locations**: Are symbols declared where the spec says they should be (e.g., CommonSymbols.wl vs private context)? Follow existing conventions — if similar symbols are private in other files, new ones should be too.
- **Function behavior**: Does the code actually work the way the spec describes? Look at the actual implementation, not just the signature.
- **Naming and conventions**: Do proposed names follow codebase conventions (lowerCamelCase for internal functions, UpperCamelCase for exported, etc.)?
- **Implementation touchpoints completeness**: Are there files that would need changes but aren't listed? For example, if a new path variable is added, does it need a declaration in CommonSymbols.wl AND a definition in Files.wl?

### 3. Check for Common Issues

Look specifically for these categories of problems:

**Factual inaccuracies:**
- Option names or defaults that don't match the current code
- Function signatures that accept different arguments than described
- Symbols described as being in one location when they're in another
- Properties or features attributed to objects that don't exist yet

**Missing touchpoints:**
- Files that need changes but aren't listed in the implementation table
- Intermediate helpers or utilities the spec assumes exist but don't
- Test files, documentation, or configuration that should be updated

**Vague or ambiguous language:**
- "such as" or "e.g." where a concrete decision is needed
- Placeholder names that should be pinned down
- Underspecified behavior for edge cases (e.g., what happens with `File[...]` targets?)

**Logical and ordering issues:**
- Operations that could fail partway through, leaving inconsistent state
- Missing error handling
- Race conditions or atomicity concerns in multi-step operations

**Convention violations:**
- Symbols proposed for shared contexts that are only used in one file (should be private)
- Patterns that diverge from how similar features are already implemented
- Error handling that doesn't follow the project's Enclose/Confirm/throwFailure patterns

### 4. Triage and Act

For each issue found, decide:

- **Straightforward fix** (wrong default value, vague language, missing file in touchpoints table): Edit the spec directly to correct it.
- **Needs discussion** (design trade-offs, ordering concerns, architectural decisions): Present the issue clearly with the trade-offs so the user can decide.

Focus on the **top three issues by importance**. If there are more, mention them briefly but don't overwhelm. Importance is determined by how much implementation pain the issue would cause if left uncorrected.

### 5. Report

For each issue addressed:
- State what the issue is
- Explain why it matters (what would go wrong during implementation)
- Show what you changed (for fixes) or present the options (for discussions)

If no significant issues are found, say so — then consider whether the spec could be improved in other ways (clarity, readability, completeness of examples).
