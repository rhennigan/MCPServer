---
name: update-docs
description: Review branch changes and update markdown documentation files to reflect them
disable-model-invocation: true
argument-hint: "target branch (default: main)"
---

# Update Documentation for Branch Changes

Review all changes on the current branch compared to a base branch and update markdown documentation files to reflect those changes.

**Base branch:** Use `$ARGUMENTS` if provided, otherwise default to `main`.

## Process

### 1. Understand the Changes

Examine what changed on the current branch:

- Run `git diff <base>...HEAD --stat` to see which files changed
- Run `git log <base>..HEAD --oneline` to understand the commit history
- Run `git diff <base>...HEAD` on source files (not tests, not assets) to understand the actual code changes

Build a mental model of:
- What new features, modules, or capabilities were added
- What existing behavior changed
- What new files, symbols, options, or configuration were introduced
- What was removed or renamed

### 2. Inventory Documentation Files

Read ALL markdown documentation files that could be affected:

- `AGENTS.md` (project structure, development patterns, file listings)
- `README.md` (features, tools, options, API reference)
- Every file in `docs/` (tools, servers, clients, prompts, apps, testing, building, getting-started, etc.)

### 3. Identify What Needs Updating

For each documentation file, check whether the changes on the branch affect any of its content:

- **Project structure listings** - Do they include new files/directories?
- **Feature lists** - Do they mention new capabilities?
- **Tool tables** - Do they list new tools or note changed tool behavior?
- **Option/config tables** - Do they document new options or environment variables?
- **Server descriptions** - Do they reflect changes to server configurations?
- **Related files sections** - Do they reference new source files?
- **Cross-references/links** - Are there broken links to renamed/removed sections?
- **Code examples** - Are they still accurate?

### 4. Make Updates

Edit existing documentation files to reflect the changes. Follow these principles:

- **Match existing style**: Follow the formatting conventions already used in each file (table style, heading levels, link style, etc.)
- **Be concise**: Add only what's necessary to accurately document the changes
- **Cross-reference**: Link to related documentation where appropriate
- **Don't over-document**: Implementation details belong in code comments, not docs

### 5. Create New Documentation Files

If the changes introduce a major new subsystem or concept that doesn't fit neatly into existing docs, create a new file in `docs/`. When doing so:

- Add it to the `docs/README.md` index
- Add it to the `AGENTS.md` docs listing
- Cross-reference it from related existing docs

### 6. Summary

After making all changes, provide a summary listing:
- Which files were modified and what was changed
- Any new files that were created
- Any issues or ambiguities found that may need manual attention
