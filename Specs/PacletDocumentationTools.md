# Paclet Documentation Tools - Detailed Specification

## Overview

This specification defines MCP tools for creating and editing Wolfram Language paclet documentation notebooks. These tools enable LLMs to programmatically generate and modify symbol reference pages (and eventually guide pages and tutorials).

## Goals

- Create MCP tools for creating and editing paclet documentation notebooks
- Notebook content should be specified as markdown and converted to cells with `importMarkdownString` (declared in `Kernel/Tools/Tools.wl`)
- Tool definitions should be placed in `Kernel/Tools/PacletDocumentation.wl`
- Initial tools focus on symbol pages (most common documentation type):
    - `CreateSymbolPacletDocumentation`
    - `EditSymbolPacletDocumentation` (for metadata and non-example sections)
    - `EditSymbolPacletDocumentationExamples` (for example sections)
- Future expansion to guide pages and tutorials

---

## Tool 1: CreateSymbolPacletDocumentation

### Purpose

Creates a new symbol documentation page from scratch, generating a properly structured `.nb` file in the correct location within the paclet's documentation directory.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pacletDirectory` | String | Yes | Absolute path to the paclet root directory |
| `symbolName` | String | Yes | Name of the symbol being documented (e.g., `"MyFunction"`) |
| `pacletName` | String | Yes | Name of the paclet (e.g., `"MCPServer"` or `"Wolfram/MCPServer"`) |
| `publisherID` | String | No | Publisher ID for the paclet (e.g., `"Wolfram"`). Can be omitted for legacy paclets or included in `pacletName` |
| `context` | String | No | Full context for the symbol. Defaults to ``"{publisherID}`{pacletName}`"`` if publisherID is provided, otherwise ``"{pacletName}`"`` |
| `usage` | String | Yes | Markdown string containing usage cases (see format below) |
| `notes` | String | No | Markdown string for the Details & Options section |
| `seeAlso` | String | No | Symbol names separated by newlines or commas |
| `techNotes` | String | No | Tutorial/tech note references as markdown links, one per line |
| `relatedGuides` | String | No | Guide page references as markdown links, one per line |
| `relatedLinks` | String | No | External links in markdown format `[label](url)`, one per line |
| `keywords` | String | No | Keywords separated by newlines or commas |
| `newInVersion` | String | No | Version string for "New in:" field (e.g., `"1.0"`) |
| `basicExamples` | String | No | Markdown content for Basic Examples section |

#### Usage Format

The `usage` parameter should be a markdown string where each usage case is a bullet point with the syntax in backticks followed by a description. Parameters in descriptions should be italicized.

**Format:**
```markdown
- `MyFunction[x]` adds one to *x*.
- `MyFunction[x, y]` adds *x* and *y* together.
```

The tool will parse this markdown and generate proper usage cells with formatted syntax and descriptions.

#### Notes Format

The `notes` parameter should be a markdown string. Each paragraph or bullet point becomes a separate note cell. Tables are supported for "Details & Options" style tables.

**Format:**
```markdown
The value for *x* must be positive.

`MyFunction` automatically threads over lists.

The following options can be specified:

| Option | Default | Description |
|--------|---------|-------------|
| `Method` | `Automatic` | the method to use |
| `Tolerance` | `0.001` | numerical tolerance |
```

#### See Also Format

Symbol names separated by newlines or commas:
```
Plus
Minus
Increment, Decrement
```

#### Tech Notes / Related Guides Format

Markdown links, one per line:
```markdown
[Working with Numbers](paclet:Wolfram/MathUtils/tutorial/WorkingWithNumbers)
[Advanced Techniques](paclet:Wolfram/MathUtils/tutorial/AdvancedTechniques)
```

#### Related Links Format

External links in markdown format, one per line:
```markdown
[Wolfram Documentation](https://reference.wolfram.com)
[GitHub Repository](https://github.com/example/repo)
```

### Output File Location

The tool will create the notebook at:
```
{pacletDirectory}/Documentation/English/ReferencePages/Symbols/{symbolName}.nb
```

The tool should create any missing intermediate directories.

### Implementation Notes

1. **Markdown Conversion**: Use `importMarkdownString` to convert markdown content to cells. This function handles:
   - Text formatting (italic, bold, inline code)
   - Code blocks (become Input cells)
   - Tables (become Grid cells)
   - Lists (become bulleted cells or individual notes)

2. **Template System**: Use `TemplateApply` with `TemplateObject` and `TemplateSlot` to generate the notebook structure.

3. **Cell ID Generation**: Generate unique `CellID` values using `RandomInteger[{1, 999999999}]` or similar.

4. **Required Sections** (in order):
   - ObjectName cell
   - Usage cell (with ModInfo styling)
   - Notes cells (Details & Options)
   - See Also section
   - Tech Notes section
   - Related Guides section
   - Related Links section
   - Examples Initialization section
   - Basic Examples section (PrimaryExamplesSection)
   - More Examples section (ExtendedExamplesSection) with subsections:
     - Scope
     - Generalizations & Extensions
     - Options
     - Applications
     - Properties & Relations
     - Possible Issues
     - Interactive Examples
     - Neat Examples
   - Metadata section with:
     - History
     - Categorization
     - Keywords
     - Syntax Templates

5. **Notebook Metadata**: Set `TaggingRules` and `StyleDefinitions` appropriately:
   ```wl
   TaggingRules -> <|"Paclet" -> "{pacletBase}"|>,
   StyleDefinitions -> FrontEnd`FileName[{"Wolfram"}, "FunctionPageStylesExt.nb", CharacterEncoding -> "UTF-8"]
   ```

6. **Paclet Base Construction**: The paclet base (used in URIs and metadata) should be constructed as:
   - If `publisherID` is provided: `"{publisherID}/{pacletName}"`
   - If `publisherID` is omitted but `pacletName` contains `/`: use `pacletName` as-is (e.g., `"Wolfram/MCPServer"`)
   - If `publisherID` is omitted and `pacletName` has no `/`: use `pacletName` alone (e.g., `"MyPaclet"`)

7. **URI Construction**: The documentation URI should be:
   ```
   {pacletBase}/ref/{symbolName}
   ```

   Examples:
   - With publisher: `Wolfram/MCPServer/ref/CreateMCPServer`
   - Without publisher: `MyPaclet/ref/MyFunction`

8. **Link Button Data**: Internal links should use:
   ```
   ButtonData -> "paclet:{pacletBase}/ref/{symbolName}"
   ```

9. **Context Construction**: The default context should be:
   - If explicit `context` provided: use it as-is
   - If `publisherID` provided: `"{publisherID}\`{pacletName}\`"`
   - If `pacletName` contains `/`: split and use `"{part1}\`{part2}\`"`
   - Otherwise: `"{pacletName}\`"`

### Return Value

On success, return an object containing:
- `file`: Path to the created notebook file
- `uri`: Documentation URI for the symbol

On failure, return a descriptive error message.

---

## Tool 2: EditSymbolPacletDocumentation

### Purpose

Edits an existing symbol documentation page, allowing targeted modifications to metadata and non-example sections. For example section modifications, use the `EditSymbolPacletDocumentationExamples` tool.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `notebook` | String | Yes | Path to the notebook file or documentation URI |
| `operation` | String | Yes | The edit operation to perform (see operations below) |
| `content` | String | Conditional | New content (format depends on operation) |
| `position` | Integer/String | No | Position for insert operations (0-indexed, or "start"/"end") |

### Operations

#### 1. `setUsage` - Replace Usage Section

Completely replaces the usage cases in the Usage cell.

**Required parameters:**
- `content`: Markdown string with usage cases (same format as CreateSymbolPacletDocumentation)

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setUsage",
  "content": "- `MyFunction[x]` computes the result for *x*.\n- `MyFunction[x, y]` computes the result for *x* and *y*."
}
```

#### 2. `setNotes` - Replace Notes Section

Replaces all notes in the Details & Options section.

**Required parameters:**
- `content`: Markdown string with notes (same format as CreateSymbolPacletDocumentation)

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setNotes",
  "content": "The value for *x* must be positive.\n\n`MyFunction` automatically threads over lists."
}
```

#### 3. `addNote` - Add a Single Note

Adds a new note to the Details & Options section.

**Required parameters:**
- `content`: Markdown string (the note text)

**Optional parameters:**
- `position`: Integer or "start"/"end" (default: "end")

#### 4. `setDetailsTable` - Set a Details Table

Creates or replaces a details table (like the "values can be" tables in standard docs).

**Required parameters:**
- `content`: Markdown string containing the table

**Format:**
```markdown
The value for *x* can be any of the following:

| Value | Description |
|-------|-------------|
| *int* | an `Integer` |
| *expr* | any expression |
| {*x*_1, *x*_2, ...} | a list of expressions |
```

**Optional parameters:**
- `position`: Integer position in notes section (default: "end")

#### 5. `setSeeAlso` - Replace See Also Section

**Required parameters:**
- `content`: Symbol names separated by newlines or commas

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setSeeAlso",
  "content": "Plus\nMinus\nIncrement, Decrement"
}
```

#### 6. `setTechNotes` - Replace Tech Notes Section

**Required parameters:**
- `content`: Markdown links, one per line

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setTechNotes",
  "content": "[Working with Numbers](paclet:Wolfram/MathUtils/tutorial/WorkingWithNumbers)"
}
```

#### 7. `setRelatedGuides` - Replace Related Guides Section

**Required parameters:**
- `content`: Markdown links, one per line

#### 8. `setRelatedLinks` - Replace Related Links Section

**Required parameters:**
- `content`: Markdown links in format `[label](url)`, one per line

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setRelatedLinks",
  "content": "[Wolfram Documentation](https://reference.wolfram.com)\n[GitHub](https://github.com)"
}
```

#### 9. `setKeywords` - Replace Keywords

**Required parameters:**
- `content`: Keywords separated by newlines or commas

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setKeywords",
  "content": "add, increment, plus one"
}
```

#### 10. `setHistory` - Set Version History

**Required parameters:**
- `content`: Comma-separated key:value pairs

**Format:**
```
new:1.0, modified:1.2
```

Supported keys: `new`, `modified`, `obsolete`

### Return Value

On success, return an object containing:
- `file`: Path to the modified notebook file
- `operation`: The operation that was performed

On failure, return a descriptive error message.

---

## Tool 3: EditSymbolPacletDocumentationExamples

### Purpose

Edits example sections of an existing symbol documentation page. This tool is separate from `EditSymbolPacletDocumentation` because example editing involves more complex operations including code evaluation and output generation.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `notebook` | String | Yes | Path to the notebook file or documentation URI |
| `operation` | String | Yes | The edit operation to perform (see operations below) |
| `section` | String | Conditional | Target example section (required for most operations) |
| `content` | String | Conditional | Markdown content for example cells |
| `position` | Integer/String | No | Position for insert operations (0-indexed, or "start"/"end") |
| `subsection` | String | No | Target subsection (for Options section) |

### Section Names

The `section` parameter accepts the following values:

| Section Name | Description |
|--------------|-------------|
| `BasicExamples` | Primary examples section |
| `Scope` | Examples showing scope of functionality |
| `GeneralizationsExtensions` | Generalizations & Extensions |
| `Options` | Option examples (use with `subsection`) |
| `Applications` | Application examples |
| `PropertiesRelations` | Properties & Relations |
| `PossibleIssues` | Known issues and edge cases |
| `InteractiveExamples` | Interactive/dynamic examples |
| `NeatExamples` | Neat/interesting examples |

### Operations

#### 1. `appendExample` - Append to Example Section

Adds content to the end of an example section.

**Required parameters:**
- `section`: Target section name
- `content`: Markdown string with example content

**Optional parameters:**
- `subsection`: For "Options" section, the option name to add examples under

**Content Format:**

The content should be markdown that can include:
- Text descriptions (become "ExampleText" cells)
- Code blocks with `wl` language tag (become "Input" cells)

**Important:** Do NOT include expected outputs in the markdown. The tool will:
1. Parse the input code blocks using `importMarkdownString`
2. Evaluate each input expression in the Wolfram Language kernel
3. Generate proper "Output" cells using `Cell[BoxData[ToBoxes[result]], "Output", ...]`
4. Return the generated content (with real outputs) as markdown feedback

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "appendExample",
  "section": "BasicExamples",
  "content": "Add one to a symbolic expression:\n\n```wl\nMyFunction[x + y]\n```"
}
```

#### 2. `prependExample` - Prepend to Example Section

Same as `appendExample` but adds content at the beginning of the section.

**Required parameters:**
- `section`: Target section name
- `content`: Markdown string with example content

**Optional parameters:**
- `subsection`: For "Options" section

#### 3. `insertExample` - Insert at Position in Example Section

Same as `appendExample` but with required `position` parameter specifying where to insert (0-indexed, counting example groups).

**Required parameters:**
- `section`: Target section name
- `content`: Markdown string with example content
- `position`: Index where to insert (0-indexed)

**Optional parameters:**
- `subsection`: For "Options" section

#### 4. `replaceExample` - Replace Example at Position

**Required parameters:**
- `section`: Target section name
- `content`: New content for that example group
- `position`: Index of the example group to replace (0-indexed)

**Optional parameters:**
- `subsection`: For "Options" section

#### 5. `removeExample` - Remove Example at Position

**Required parameters:**
- `section`: Target section name
- `position`: Index of the example group to remove (0-indexed)

**Optional parameters:**
- `subsection`: For "Options" section

#### 6. `clearExamples` - Clear All Examples in Section

**Required parameters:**
- `section`: Target section name

**Optional parameters:**
- `subsection`: For "Options" section, specific option to clear

#### 7. `setExamples` - Replace All Examples in Section

Completely replaces all examples in a section.

**Required parameters:**
- `section`: Target section name
- `content`: Markdown string with all examples (use `---` to separate example groups)

**Optional parameters:**
- `subsection`: For "Options" section

### Example Delimiters

When multiple independent examples exist within a section, they should be separated by "ExampleDelimiter" cells. In markdown input, use `---` (horizontal rule) to indicate example group boundaries.

The tool should automatically:
- Add delimiters when appending/inserting new examples after existing ones
- Handle delimiters correctly when removing examples
- Not add a delimiter before the first example in a section

### Options Subsection Handling

The "Options" example section has a special structure with subsections for each option. Operations on this section should:
- Support `subsection` parameter to target specific options
- Auto-create new option subsections if they don't exist
- Use "ExampleSubsection" cells for option names

### Return Value

On success, return an object containing:
- `file`: Path to the modified notebook file
- `operation`: The operation that was performed
- `section`: The section that was modified
- `generatedContent`: Markdown representation of the cells that were added, including evaluated outputs

**Example return for `appendExample`:**
```json
{
  "file": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
  "operation": "appendExample",
  "section": "BasicExamples",
  "generatedContent": "Add one to a symbolic expression:\n\n```wl\nAddOne[x + y]\n```\n```wl-output\n1 + x + y\n```"
}
```

The `generatedContent` field uses `wl-output` code blocks to distinguish evaluated outputs from inputs. This allows the caller to see exactly what was generated and verify correctness.

On failure, return a descriptive error message.

---

## Implementation Architecture

### File Structure

```
Kernel/Tools/PacletDocumentation.wl    (* Tool definitions and implementation *)
Assets/Templates/SymbolPage.wl         (* TemplateObject for symbol documentation pages *)
```

### Template Storage

The notebook template should be stored as a `TemplateObject` in `Assets/Templates/SymbolPage.wl`. This keeps the template out of the main source code and allows lazy loading.

**Template File Format** (`Assets/Templates/SymbolPage.wl`):
```wl
(* Symbol Page Documentation Template *)
(* Used by CreateSymbolPacletDocumentation *)

TemplateObject[
    Notebook[
        {
            (* Template structure with TemplateSlot expressions *)
            ...
        },
        TaggingRules -> <|"Paclet" -> TemplateSlot["PacletBase"]|>,
        StyleDefinitions -> FrontEnd`FileName[{"Wolfram"}, "FunctionPageStylesExt.nb", CharacterEncoding -> "UTF-8"]
    ],
    CombinerFunction -> Identity,
    InsertionFunction -> Identity
]
```

**Required Template Slots**:

| Slot Name | Type | Description |
|-----------|------|-------------|
| `"SymbolName"` | String | The symbol being documented |
| `"PacletBase"` | String | Full paclet identifier (e.g., `"Wolfram/MCPServer"` or `"MyPaclet"`) |
| `"Context"` | String | Full context string (e.g., `"Wolfram\`MCPServer\`"`) |
| `"UsageCells"` | List | Pre-generated usage cell content (TextData) |
| `"NotesCells"` | List | List of notes cells (or empty list) |
| `"SeeAlsoCells"` | List | Pre-generated see also content (or placeholder) |
| `"TutorialsCells"` | List | Tech notes cells (or placeholder) |
| `"MoreAboutCells"` | List | Related guides cells (or placeholder) |
| `"RelatedLinksCells"` | List | Related links cells (or placeholder) |
| `"KeywordsCells"` | List | Keywords cells (or placeholder) |
| `"BasicExamplesCells"` | List | Basic examples cells (or empty) |
| `"NewInVersion"` | String | Version string for history (or `"XX"` placeholder) |

Note: Some slots contain pre-generated cell content rather than raw data. This is because certain cell structures (like usage cases with inline formulas) are complex to generate and are better prepared by helper functions before template application.

### Section Identification Strategy

For editing operations, sections can be identified by:

1. **Cell Style**: Most sections have distinct styles:
   - `"ObjectName"` - Symbol name
   - `"Usage"` - Usage information
   - `"Notes"` - Details & Options notes
   - `"SeeAlsoSection"` / `"SeeAlso"` - See Also
   - `"TechNotesSection"` / `"Tutorials"` - Tech Notes
   - `"MoreAboutSection"` / `"MoreAbout"` - Related Guides
   - `"RelatedLinksSection"` / `"RelatedLinks"` - Related Links
   - `"PrimaryExamplesSection"` - Basic Examples
   - `"ExampleSection"` - Extended example sections
   - `"ExampleSubsection"` - Options subsections
   - `"ExampleText"` - Example descriptions
   - `"ExampleDelimiter"` - Example separators
   - `"KeywordsSection"` / `"Keywords"` - Keywords
   - `"History"` - Version history

2. **Cell Tags**: Some cells use `CellTags`:
   - `"ExtendedExamples"` - Start of More Examples section

3. **InterpretationBox Content**: Example section headers use InterpretationBox with the section name:
   ```wl
   InterpretationBox[Cell["Scope", "ExampleSection"], $Line = 0;]
   ```

4. **CellGroupData Structure**: Related cells are grouped together in `CellGroupData`

---

## Markdown Content Format

### Text Content

Standard markdown formatting is supported for text:
- `*italic*` or `_italic_` for variable names
- `**bold**` for emphasis
- `[link text](url)` for hyperlinks
- Inline code with backticks for Wolfram Language expressions

### Code Blocks

Code blocks should use the `wl` language identifier:

````markdown
```wl
MyFunction[5]
```
````

**Note:** Do not include outputs in input markdown. The tool automatically evaluates inputs and generates output cells.

### Example Groups

Separate independent examples with horizontal rules:

````markdown
Add one to a number:

```wl
MyFunction[5]
```

---

Add one to a symbol:

```wl
MyFunction[x]
```
````

### Output Representation (in tool responses)

When the tool returns `generatedContent`, outputs are shown using `wl-output` blocks:

````markdown
Add one to a number:

```wl
MyFunction[5]
```
```wl-output
6
```
````

This format is for feedback only - callers should not include `wl-output` blocks in their input.

### Symbol References

Reference other symbols using standard link syntax:
- For paclet symbols: `[MyOtherFunction](paclet:PublisherID/PacletName/ref/MyOtherFunction)`
- For system symbols: `[Plus](ref/Plus)`

### Inline Formulas

For inline Wolfram Language expressions that should be formatted as code:
- Use backticks: `` `MyFunction[x]` ``

---

## Error Handling

### CreateSymbolPacletDocumentation Errors

| Error Code | Description |
|------------|-------------|
| `FileExists` | Notebook already exists at target location |
| `InvalidPacletDirectory` | Specified directory is not a valid paclet |
| `InvalidSymbolName` | Symbol name contains invalid characters |
| `EmptyUsage` | No usage cases provided |
| `InvalidUsageFormat` | Usage markdown doesn't contain valid usage cases |
| `DirectoryCreationFailed` | Could not create Documentation directories |

### EditSymbolPacletDocumentation Errors

| Error Code | Description |
|------------|-------------|
| `NotebookNotFound` | Specified notebook does not exist |
| `InvalidNotebook` | File is not a valid documentation notebook |
| `SectionNotFound` | Specified section does not exist in notebook |
| `InvalidPosition` | Position is out of range for the section |
| `InvalidOperation` | Unknown operation specified |
| `InvalidContent` | Content format doesn't match operation requirements |

### EditSymbolPacletDocumentationExamples Errors

| Error Code | Description |
|------------|-------------|
| `NotebookNotFound` | Specified notebook does not exist |
| `InvalidNotebook` | File is not a valid documentation notebook |
| `SectionNotFound` | Specified example section does not exist |
| `SubsectionNotFound` | Specified subsection does not exist (for Options) |
| `InvalidPosition` | Position is out of range for the section |
| `InvalidOperation` | Unknown operation specified |
| `EvaluationError` | Error occurred while evaluating example code |
| `InvalidContent` | Content format doesn't match operation requirements |

---

## Future Expansion

### Guide Pages

Future `CreateGuidePacletDocumentation` and `EditGuidePacletDocumentation` tools will handle guide pages with sections like:
- Title
- Description
- Function groups with descriptions
- Related guides
- Related tutorials

### Tutorial Pages

Future `CreateTutorialPacletDocumentation` and `EditTutorialPacletDocumentation` tools will handle tech notes/tutorials with:
- Title
- Narrative content
- Code examples
- Subsections
- Related links

---

## Examples

### Creating a New Symbol Page (with Publisher ID)

```json
{
  "tool": "CreateSymbolPacletDocumentation",
  "parameters": {
    "pacletDirectory": "/path/to/MyPaclet",
    "symbolName": "AddOne",
    "pacletName": "MathUtils",
    "publisherID": "JohnDoe",
    "usage": "- `AddOne[x]` adds one to *x*.\n- `AddOne[x, y]` adds *x* and *y*.",
    "notes": "`AddOne` automatically threads over lists.\n\nThe value for *x* can be any numeric expression.",
    "seeAlso": "Plus\nIncrement",
    "keywords": "add, increment, plus one",
    "newInVersion": "1.0",
    "basicExamples": "Add one to a number:\n\n```wl\nAddOne[5]\n```\n\n---\n\nAdd one to a symbolic expression:\n\n```wl\nAddOne[x]\n```"
  }
}
```

This creates documentation with:
- URI: `JohnDoe/MathUtils/ref/AddOne`
- Context: `JohnDoe\`MathUtils\``

### Creating a New Symbol Page (without Publisher ID - Legacy Style)

```json
{
  "tool": "CreateSymbolPacletDocumentation",
  "parameters": {
    "pacletDirectory": "/path/to/MyLegacyPaclet",
    "symbolName": "MyFunction",
    "pacletName": "MyLegacyPaclet",
    "usage": "- `MyFunction[x]` does something with *x*."
  }
}
```

This creates documentation with:
- URI: `MyLegacyPaclet/ref/MyFunction`
- Context: `MyLegacyPaclet\``

### Creating a New Symbol Page (Publisher ID in pacletName)

You can also include the publisher ID directly in the `pacletName` parameter:

```json
{
  "tool": "CreateSymbolPacletDocumentation",
  "parameters": {
    "pacletDirectory": "/path/to/MyPaclet",
    "symbolName": "AddOne",
    "pacletName": "JohnDoe/MathUtils",
    "usage": "- `AddOne[x]` adds one to *x*."
  }
}
```

This is equivalent to specifying `publisherID` and `pacletName` separately.

### Editing: Updating Usage

```json
{
  "tool": "EditSymbolPacletDocumentation",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "setUsage",
    "content": "- `AddOne[x]` adds one to *x*.\n- `AddOne[x, y]` adds *x* and *y* together.\n- `AddOne[list]` adds one to each element of *list*."
  }
}
```

### Editing: Updating See Also

```json
{
  "tool": "EditSymbolPacletDocumentation",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "setSeeAlso",
    "content": "Plus, Minus\nIncrement, Decrement"
  }
}
```

### Editing: Adding Related Links

```json
{
  "tool": "EditSymbolPacletDocumentation",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "setRelatedLinks",
    "content": "[Wolfram Documentation](https://reference.wolfram.com)\n[Math Functions Guide](https://example.com/math)"
  }
}
```

### Editing Examples: Adding a Basic Example

```json
{
  "tool": "EditSymbolPacletDocumentationExamples",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "appendExample",
    "section": "BasicExamples",
    "content": "Add one to a symbolic expression:\n\n```wl\nAddOne[x + y]\n```"
  }
}
```

**Tool response:**
```json
{
  "file": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
  "operation": "appendExample",
  "section": "BasicExamples",
  "generatedContent": "Add one to a symbolic expression:\n\n```wl\nAddOne[x + y]\n```\n```wl-output\n1 + x + y\n```"
}
```

### Editing Examples: Adding a Scope Example

```json
{
  "tool": "EditSymbolPacletDocumentationExamples",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "appendExample",
    "section": "Scope",
    "content": "AddOne works on lists:\n\n```wl\nAddOne[{1, 2, 3}]\n```"
  }
}
```

### Editing Examples: Adding Option Documentation

```json
{
  "tool": "EditSymbolPacletDocumentationExamples",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "appendExample",
    "section": "Options",
    "subsection": "Method",
    "content": "Use Method -> \"Fast\" for optimized computation:\n\n```wl\nAddOne[Range[1000], Method -> \"Fast\"]\n```"
  }
}
```

### Editing Examples: Replacing All Examples in a Section

```json
{
  "tool": "EditSymbolPacletDocumentationExamples",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "setExamples",
    "section": "BasicExamples",
    "content": "Add one to a number:\n\n```wl\nAddOne[5]\n```\n\n---\n\nAdd one to a symbol:\n\n```wl\nAddOne[x]\n```\n\n---\n\nAdd one to a list:\n\n```wl\nAddOne[{1, 2, 3}]\n```"
  }
}
```
