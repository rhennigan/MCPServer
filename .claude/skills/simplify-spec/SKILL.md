---
name: simplify-spec
description: |
  Simplify a design specification in Specs/ to focus on user-facing behavior.
  Use when asked to: "simplify a spec", "clean up a spec", "remove implementation details from a spec",
  "make a spec more high-level", "simplify the spec for [feature]", "rewrite spec to be user-facing",
  or any request to reduce internal/low-level detail in a specification document.
disable-model-invocation: true
argument-hint: "spec filename or feature name"
---

# Simplify a Design Specification

Rewrite a design specification to focus on user-facing behavior, removing or condensing internal implementation details. The goal is a spec that clearly communicates what the feature does and how users interact with it, without prescribing how it's built internally.

**Spec to simplify:** $ARGUMENTS

If no specific spec is given, ask the user which spec in `Specs/` they'd like simplified.

## Process

### 1. Read the Spec

Read the full spec file from `Specs/`. Identify every section and classify it:

- **User-facing:** Things a user of the paclet would see or interact with (function signatures, options, usage examples, option tables with types/defaults/descriptions, backward compatibility notes, future plans)
- **Internal:** Things only a developer implementing the feature would need (file modification lists, internal function signatures, internal symbol declarations, serialization details, parsing logic, private API code, environment variable plumbing, verification/test checklists)

### 2. Understand the Feature

Before rewriting, read the relevant source files to understand what the feature actually does. This is important because the spec may describe planned behavior that differs from what was implemented, or use terminology that's clearer in context.

Use the Explore agent or read files directly to understand:
- How users interact with the feature (the public API)
- What the actual defaults and option values are
- Which parts of the spec correspond to internal plumbing vs user-visible behavior

### 3. Rewrite the Spec

Apply these guidelines:

**Remove entirely:**
- File modification tables ("Files Modified")
- Internal symbol declarations (e.g., "Add to CommonSymbols.wl")
- Internal function implementations (e.g., full `toolOptionValue` code with `Enclose`/`ConfirmBy`)
- Serialization/storage mechanism details (e.g., JSON format, environment variable names, parsing logic)
- Verification/test step checklists
- "Goals" sections that describe internal engineering goals rather than user value
- Strikethrough notes about removed plans (e.g., "~~Deprecate the existing...~~ (removed — ...)")

**Keep as-is:**
- Usage examples showing the public API
- Option/parameter tables (name, type, default, description)
- Backward compatibility notes (what changed for existing users)
- Future plans / phase 2 previews (these help users understand direction)

**Simplify rather than remove:**
- Validation behavior → condense to a sentence or two about what happens with bad input (e.g., "Unrecognized names produce warnings but don't cause failure")
- Resolution/priority logic → describe in plain language without internal variable names (e.g., "User-specified value takes priority over built-in default")
- "Implementation notes" under option tables → remove if the table's Description column already conveys the behavior; rewrite to a brief user-facing note if it contains information users need (e.g., that two tools' options are independent of each other)

**Style:**
- Use the same markdown formatting conventions as the original spec
- Keep section headings clear and descriptive
- Don't add new content that wasn't in the original — the goal is reduction, not expansion
- If mentioning an exported symbol users can evaluate (like `$DefaultMCPToolOptions`), keep it; if mentioning an internal symbol (like `$toolOptions` or `parseToolOptions`), remove it

### 4. Summary

After rewriting, briefly tell the user what was removed, what was kept, and what was condensed. This helps them verify nothing important was lost.
