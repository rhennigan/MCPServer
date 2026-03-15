---
name: spec-to-todo
description: |
  Generate a TODO task list from a design specification. Reads a spec file from Specs/,
  explores the codebase to identify what's already implemented vs. what remains, and
  produces a markdown TODO file with checkboxes in TODO/. Use when asked to: "create a
  task list from a spec", "make a TODO from a spec", "what needs to be done for [feature]",
  "generate tasks from the spec", "create a work plan for [feature]", "turn this spec into
  a checklist", or any request to break a specification into trackable work items.
disable-model-invocation: true
argument-hint: "spec filename or feature name"
---

# Generate TODO from Specification

Read a design specification and produce a TODO task list that captures everything needed to fully implement it, organized into logical work units.

**Spec to process:** $ARGUMENTS

If no specific spec is given, ask the user which spec in `Specs/` they'd like to turn into a task list.

## Process

### 1. Read the Spec

Read the full spec file from `Specs/`. Identify every deliverable it describes:

- Source files to create or modify
- Build scripts or tooling
- Generated artifacts (scripts, config files, packages)
- Hand-authored content (documentation, reference files, skill definitions)
- Tests and evals
- Directory structures that must exist

### 2. Explore Current State

Launch parallel Explore agents to understand what already exists. Focus on:

- **What's implemented:** Files that exist and have real content matching the spec.
- **What's partial:** Files that exist but are stubs/placeholders (e.g., contain only "TODO").
- **What's missing:** Files or directories the spec requires that don't exist at all.
- **Discrepancies:** Differences between the spec and reality (e.g., a manifest missing an entry, wrong directory structure, mismatched names).

Key areas to check:
- The directories and files the spec references directly
- `Scripts/` for any build scripts mentioned
- `Kernel/` for source code the spec depends on (tool definitions, parameters, etc.)
- `Tests/` for any existing test coverage
- `Notes/` for implementation hints or reference code
- `docs/` for related developer documentation

### 3. Gap Analysis

Compare spec requirements against exploration results. For each deliverable, classify it:

- **Done:** Fully implemented, matches spec. Don't create a task for it.
- **Partial:** Exists but incomplete. Create a task describing what remains.
- **Missing:** Doesn't exist. Create a task for the full implementation.
- **Discrepancy:** Exists but doesn't match spec. Create a task to fix it.

### 4. Organize into Tasks

Group related work into logical units, where each task represents roughly one coding session. Guidelines:

- **One concern per task.** A task should have a clear, testable outcome. "Implement the build script" is one task; "implement the build script and write all the documentation" is two.
- **Order by dependency.** Tasks that others depend on come first (e.g., fix a manifest before generating scripts from it).
- **Separate hand-authored from generated.** Writing documentation is a different task from writing the code that generates artifacts.
- **Include tests with non-trivial code.** If a task involves writing non-trivial code (new functions, modified logic, etc.), it should include writing and running unit tests for that code as part of the same task. Only create separate testing tasks for cross-cutting concerns like integration tests, end-to-end tests, or evals that span multiple tasks.
- **Include file paths.** Every task should list the files it touches under a `**Files:**` line.

### 5. Write the TODO File

Write the task list to `TODO/<SpecName>.md` (matching the spec filename without extension). Use this format:

```markdown
# <Feature Name> — TODO

Tasks for implementing the [<Feature> specification](../Specs/<SpecName>.md).
Each item is a logical unit of work for one coding session.

---

- [ ] **1. <Task title>**

  <Description of what needs to be done and why. Include enough context
  that someone could pick this up without re-reading the entire spec.
  Note any discrepancies found between spec and current state.>

  **Files:** `path/to/file1`, `path/to/file2`

---

- [ ] **2. <Task title>**

  ...
```

Rules for the format:
- Use `- [ ]` checkboxes for every top-level task.
- Use `- [ ]` sub-checkboxes for tasks with independently verifiable sub-items (like test checklists).
- Bold the task number and title.
- Include a `**Files:**` line listing every file the task touches.
- Separate tasks with `---` horizontal rules.
- Link back to the spec in the header.

### 6. Summary

After writing the TODO file, give the user a brief summary:
- How many tasks were created
- Which items are quick fixes vs. substantial work
- Any ambiguities or decisions found in the spec that the user should resolve
