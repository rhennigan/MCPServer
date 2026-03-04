# Agent Skills — TODO

Tasks for implementing the [Agent Skills specification](../Specs/AgentSkills.md). Each item is a logical unit of work for one coding session.

---

- [x] **1. Fix Manifest.wl: add missing SymbolDefinition script**

  The spec lists `SymbolDefinition` under `wolfram-language`, but `AgentSkills/Skills/Manifest.wl` omits it. Add `"SymbolDefinition"` to the `"Scripts"` list for `wolfram-language`.

  **Files:** `AgentSkills/Skills/Manifest.wl`

---

- [x] **2. Write GetWolframEngine.md reference**

  `AgentSkills/References/GetWolframEngine.md` is a placeholder ("TODO"). Write platform-specific installation instructions for `wolframscript` (macOS via Homebrew, Linux/Windows downloads, verifying installation).

  **Files:** `AgentSkills/References/GetWolframEngine.md`

---

- [x] **3. Implement script generation in BuildAgentSkills.wls**

  This is the core build logic. Implement the TODO sections:

  1. Create a temporary build directory.
  2. For each tool name referenced across all skills in the manifest:
     - Look up the tool in `$DefaultMCPTools`.
     - Extract parameter metadata (name, required, interpreter type, help text).
     - Generate a `.wls` script with CLI argument parsing (`--flag value` for optional, positional for required), `--help` support, error handling, and tool invocation.
     - Write the script to the temporary directory.
  3. For each skill in the manifest:
     - Copy the relevant generated scripts into `AgentSkills/Skills/<skill-name>/scripts/`.
     - Copy shared reference files from `AgentSkills/References/` into `AgentSkills/Skills/<skill-name>/references/`.
  4. Clean up the temporary directory.

  Use `Notes/generating-scripts-from-tools.md` for reference on extracting tool parameters. The generated scripts should load the MCPServer paclet, delegate to the tool function, write output to stdout, and exit with appropriate codes.

  **Files:** `Scripts/BuildAgentSkills.wls`, `AgentSkills/Skills/*/scripts/*.wls` (generated output)

---

- [ ] **4. Verify and fix the build script**

  Run `BuildAgentSkills.wls` and validate the generated output:

  1. Execute the build script end-to-end and confirm it completes without errors.
  2. Verify that every tool listed in the manifest has a corresponding `.wls` script in each skill's `scripts/` directory.
  3. Verify that reference files are copied into each skill's `references/` directory.
  4. Spot-check generated scripts for correctness:
     - `--help` flag produces usage information.
     - Required/optional argument parsing works as expected.
     - Tool invocation returns sensible output for a simple test case.
  5. Fix any bugs found in the build logic or generated script templates.

  This task is intentionally narrower than the full test pass in task #9 — the goal here is to catch implementation mistakes early before writing the SKILL.md files that depend on knowing the exact script interfaces.

  **Files:** `Scripts/BuildAgentSkills.wls`, generated scripts

---

- [ ] **5. Write wolfram-language SKILL.md**

  Author the full SKILL.md for the `wolfram-language` skill following the spec's content structure:

  - YAML frontmatter (`name`, `description`, `compatibility`, `metadata` with author and version).
  - Prerequisites section pointing to `references/GetWolframEngine.md`.
  - Usage section with dual-mode detection (MCP tools preferred, bundled scripts fallback).
  - MCP server setup note pointing to `references/SetUpWolframMCPServer.md`.
  - Tool Reference section documenting each script: `WolframLanguageContext.wls`, `WolframLanguageEvaluator.wls`, `SymbolDefinition.wls`, `TestReport.wls`, `CodeInspector.wls` — with purpose, arguments, options, and example invocations.

  **Files:** `AgentSkills/Skills/wolfram-language/SKILL.md`

---

- [ ] **6. Write wolfram-alpha SKILL.md**

  Same structure as above for the `wolfram-alpha` skill, documenting `WolframAlphaContext.wls` and `WolframAlpha.wls`.

  **Files:** `AgentSkills/Skills/wolfram-alpha/SKILL.md`

---

- [ ] **7. Write wolfram-notebooks SKILL.md**

  Same structure as above for the `wolfram-notebooks` skill, documenting `ReadNotebook.wls` and `WriteNotebook.wls`.

  **Files:** `AgentSkills/Skills/wolfram-notebooks/SKILL.md`

---

- [ ] **8. Add plugin packaging to the build**

  After skills are generated, create the Claude Code plugin structure:

  1. Assemble the `wolfram/` plugin directory with `skills/` containing all three skill subdirectories (SKILL.md, scripts/, references/).
  2. Generate `.claude-plugin/marketplace.json` with the correct version (from `$pacletVersion`) and skill paths.
  3. This can be a new section in `BuildAgentSkills.wls` or a separate script — the spec says it's a separate step from skill generation.

  **Output structure:**
  ```
  wolfram/
  ├── .claude-plugin/
  │   └── marketplace.json
  └── skills/
      ├── wolfram-language/
      ├── wolfram-alpha/
      └── wolfram-notebooks/
  ```

  **Files:** `Scripts/BuildAgentSkills.wls` (or new script), generated output directory

---

- [ ] **9. Test the build script and generated scripts**

  Run `BuildAgentSkills.wls` end-to-end and verify:

  - [ ] All `.wls` scripts are generated in each skill's `scripts/` directory.
  - [ ] Reference files are copied into each skill's `references/` directory.
  - [ ] Each generated script runs correctly via `wolframscript -f <script>.wls --help`.
  - [ ] Each script produces correct output for a representative invocation.
  - [ ] The plugin directory structure matches the spec.

  Fix any issues found. Consider adding automated tests for script correctness (valid output, error handling, `--help` flag).

  **Files:** Generated scripts, potentially new test files

---

- [ ] **10. Create agent-level evals**

  Create `AgentSkills/Evals/` with eval definitions that verify:

  - [ ] **MCP detection:** Agent uses MCP tools when available instead of bundled scripts.
  - [ ] **Script fallback:** Agent invokes bundled scripts correctly when MCP tools are unavailable.
  - [ ] **Missing prerequisites:** Agent directs user to `references/GetWolframEngine.md` when `wolframscript` is not on PATH.
  - [ ] **Correct results:** Representative tasks produce accurate output (e.g., "evaluate `Solve[x^2 == 4, x]`", "search documentation for Plot options").

  Use the [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) skill as a reference for eval format. Evals should be repeatable with clear pass/fail summary.

  **Files:** `AgentSkills/Evals/` (new directory and eval files)
