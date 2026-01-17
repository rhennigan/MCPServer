# Paclet Documentation Tools - Detailed Specification

## Overview

This specification defines MCP tools for creating and editing Wolfram Language paclet documentation notebooks. These tools enable LLMs to programmatically generate and modify symbol reference pages (and eventually guide pages and tutorials).

## Goals

- Create MCP tools for creating and editing paclet documentation notebooks
- Notebook content should be specified as markdown and converted to cells with `importMarkdownString` (declared in `Kernel/Tools/Tools.wl`)
- Tool definitions should be placed in `Kernel/Tools/PacletDocumentation.wl`
- Initial tools focus on symbol pages (most common documentation type):
    - `CreateSymbolPacletDocumentation`
    - `EditSymbolPacletDocumentation`
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
| `usage` | Array | Yes | Array of usage case objects (see below) |
| `notes` | Array | No | Array of strings for the Details & Options section |
| `seeAlso` | Array | No | Array of related symbol names |
| `techNotes` | Array | No | Array of tutorial/tech note references |
| `relatedGuides` | Array | No | Array of related guide page references |
| `relatedLinks` | Array | No | Array of related link objects `{label, url}` |
| `keywords` | Array | No | Array of keyword strings for search |
| `newInVersion` | String | No | Version string for "New in:" field (e.g., `"1.0"`) |
| `basicExamples` | String | No | Markdown content for Basic Examples section |

#### Usage Case Object Structure

Each element in the `usage` array should be an object with:

```json
{
  "syntax": "MyFunction[x]",
  "description": "computes the result for x."
}
```

The `syntax` field should use Wolfram Language syntax. Parameters should be italicized in the description using markdown (e.g., `*x*`).

### Output File Location

The tool will create the notebook at:
```
{pacletDirectory}/Documentation/English/ReferencePages/Symbols/{symbolName}.nb
```

The tool should create any missing intermediate directories.

### Implementation Notes

1. **Template System**: Use `TemplateApply` with `TemplateObject` and `TemplateSlot` to generate the notebook structure.

2. **Cell ID Generation**: Generate unique `CellID` values using `RandomInteger[{1, 999999999}]` or similar.

3. **Required Sections** (in order):
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

4. **Notebook Metadata**: Set `TaggingRules` and `StyleDefinitions` appropriately:
   ```wl
   TaggingRules -> <|"Paclet" -> "{pacletBase}"|>,
   StyleDefinitions -> FrontEnd`FileName[{"Wolfram"}, "FunctionPageStylesExt.nb", CharacterEncoding -> "UTF-8"]
   ```

5. **Paclet Base Construction**: The paclet base (used in URIs and metadata) should be constructed as:
   - If `publisherID` is provided: `"{publisherID}/{pacletName}"`
   - If `publisherID` is omitted but `pacletName` contains `/`: use `pacletName` as-is (e.g., `"Wolfram/MCPServer"`)
   - If `publisherID` is omitted and `pacletName` has no `/`: use `pacletName` alone (e.g., `"MyPaclet"`)

6. **URI Construction**: The documentation URI should be:
   ```
   {pacletBase}/ref/{symbolName}
   ```

   Examples:
   - With publisher: `Wolfram/MCPServer/ref/CreateMCPServer`
   - Without publisher: `MyPaclet/ref/MyFunction`

7. **Link Button Data**: Internal links should use:
   ```
   ButtonData -> "paclet:{pacletBase}/ref/{symbolName}"
   ```

8. **Context Construction**: The default context should be:
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

Edits an existing symbol documentation page, allowing targeted modifications to specific sections without regenerating the entire notebook.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `notebook` | String | Yes | Path to the notebook file or documentation URI |
| `operation` | String | Yes | The edit operation to perform (see operations below) |
| `section` | String | Conditional | Target section for the operation |
| `content` | String/Object | Conditional | New content (format depends on operation) |
| `position` | Integer/String | No | Position for insert operations (0-indexed, or "start"/"end") |
| `subsection` | String | No | Target subsection (for Options, etc.) |

### Operations

#### 1. `setUsage` - Replace Usage Section

Completely replaces the usage cases in the Usage cell.

**Required parameters:**
- `content`: Array of usage case objects (same format as CreateSymbolPacletDocumentation)

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setUsage",
  "content": [
    {"syntax": "MyFunction[x]", "description": "computes the result for *x*."},
    {"syntax": "MyFunction[x, y]", "description": "computes the result for *x* and *y*."}
  ]
}
```

#### 2. `setNotes` - Replace Notes Section

Replaces all notes in the Details & Options section.

**Required parameters:**
- `content`: Array of note strings (markdown supported)

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setNotes",
  "content": [
    "The value for *x* must be positive.",
    "MyFunction automatically threads over lists."
  ]
}
```

#### 3. `addNote` - Add a Single Note

Adds a new note to the Details & Options section.

**Required parameters:**
- `content`: String (the note text, markdown supported)

**Optional parameters:**
- `position`: Integer or "start"/"end" (default: "end")

#### 4. `setDetailsTable` - Set a Details Table

Creates or replaces a details table (like the "values can be" tables in standard docs).

**Required parameters:**
- `content`: Object with `header` (string) and `rows` (array of `{value, description}` pairs)

**Example:**
```json
{
  "notebook": "path/to/MyFunction.nb",
  "operation": "setDetailsTable",
  "content": {
    "header": "The value for *x* can be any of the following:",
    "rows": [
      {"value": "*int*", "description": "an Integer"},
      {"value": "*expr*", "description": "any expression"},
      {"value": "{*x*_1, *x*_2, ...}", "description": "a list of expressions"}
    ]
  },
  "position": 2
}
```

#### 5. `setSeeAlso` - Replace See Also Section

**Required parameters:**
- `content`: Array of symbol names (strings)

#### 6. `setTechNotes` - Replace Tech Notes Section

**Required parameters:**
- `content`: Array of tutorial/tech note references

#### 7. `setRelatedGuides` - Replace Related Guides Section

**Required parameters:**
- `content`: Array of guide page references

#### 8. `setRelatedLinks` - Replace Related Links Section

**Required parameters:**
- `content`: Array of `{label, url}` objects

#### 9. `setKeywords` - Replace Keywords

**Required parameters:**
- `content`: Array of keyword strings

#### 10. `setHistory` - Set Version History

**Required parameters:**
- `content`: Object with optional fields:
  - `new`: Version when symbol was introduced
  - `modified`: Version when symbol was modified
  - `obsolete`: Version when symbol became obsolete

### Example Section Operations

These operations target the example sections of the documentation.

#### 11. `appendExample` - Append to Example Section

Adds content to the end of an example section.

**Required parameters:**
- `section`: One of:
  - `"BasicExamples"`
  - `"Scope"`
  - `"GeneralizationsExtensions"`
  - `"Options"`
  - `"Applications"`
  - `"PropertiesRelations"`
  - `"PossibleIssues"`
  - `"InteractiveExamples"`
  - `"NeatExamples"`
- `content`: Markdown string with example content

**Optional parameters:**
- `subsection`: For "Options" section, the option name to add examples under

**Content Format:**

The content should be markdown that can include:
- Text descriptions (become "ExampleText" cells)
- Code blocks with `wl` language tag (become "Input" cells)

**Important:** Do NOT include expected outputs in the markdown. The tool will:
1. Parse the input code blocks
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

The tool evaluates `MyFunction[x + y]` and generates the appropriate output cell automatically.

#### 12. `prependExample` - Prepend to Example Section

Same as `appendExample` but adds content at the beginning of the section.

#### 13. `insertExample` - Insert at Position in Example Section

Same as `appendExample` but with required `position` parameter specifying where to insert (0-indexed, counting example groups).

#### 14. `replaceExample` - Replace Example at Position

**Required parameters:**
- `section`: Target section name
- `position`: Index of the example group to replace (0-indexed)
- `content`: New content for that example group

#### 15. `removeExample` - Remove Example at Position

**Required parameters:**
- `section`: Target section name
- `position`: Index of the example group to remove (0-indexed)

#### 16. `clearExamples` - Clear All Examples in Section

**Required parameters:**
- `section`: Target section name

**Optional parameters:**
- `subsection`: For "Options" section, specific option to clear

### Example Delimiters

When multiple independent examples exist within a section, they should be separated by "ExampleDelimiter" cells. The tool should automatically:
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
- `section`: The section that was modified (if applicable)
- `generatedContent`: (For example operations) Markdown representation of the cells that were added, including evaluated outputs. This provides feedback showing exactly what was inserted.

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

### Internal Functions

#### Template Functions

```wl
(* Lazily load the symbol page template *)
$symbolPageTemplate := $symbolPageTemplate = Get[
    FileNameJoin[{$thisPacletDirectory, "Assets", "Templates", "SymbolPage.wl"}]
];

(* Generate a new symbol page notebook *)
createSymbolPageNotebook[params_Association] := TemplateApply[$symbolPageTemplate, params]
```

#### Editing Functions

```wl
(* Load and parse a documentation notebook *)
loadDocumentationNotebook[path_String] := ...

(* Find a section by style/tag *)
findSection[nb_Notebook, sectionName_String] := ...

(* Find example section by name *)
findExampleSection[nb_Notebook, sectionName_String] := ...

(* Replace cells in a section *)
replaceSectionContent[nb_Notebook, section_, newCells_] := ...

(* Insert cells at position within a section *)
insertInSection[nb_Notebook, section_, position_, cells_] := ...
```

#### Cell Generation Functions

```wl
(* Generate usage cell from usage cases *)
generateUsageCell[symbolName_String, usageCases_List, context_String] := ...

(* Generate notes cells from markdown strings *)
generateNotesCells[notes_List] := ...

(* Generate example cells from markdown, evaluating inputs to produce outputs *)
generateExampleCells[markdown_String] := Module[{cells, inputCells},
    cells = parseMarkdownToExampleCells[markdown];
    (* For each Input cell, evaluate and insert Output cell after *)
    evaluateAndInsertOutputs[cells]
]

(* Parse markdown into preliminary cell structure *)
parseMarkdownToExampleCells[markdown_String] := ...

(* Evaluate input cells and generate corresponding output cells *)
evaluateAndInsertOutputs[cells_List] := Module[{result},
    Flatten @ Map[
        If[MatchQ[#, Cell[_, "Input", ___]],
            {#, generateOutputCell[evaluateInputCell[#]]},
            {#}
        ] &,
        cells
    ]
]

(* Evaluate an input cell and return the result *)
evaluateInputCell[Cell[BoxData[boxes_], "Input", ___]] := ToExpression[boxes, StandardForm]

(* Generate an output cell from an evaluated result *)
generateOutputCell[result_] := Cell[
    BoxData[ToBoxes[result, StandardForm]],
    "Output",
    CellLabel -> "Out[n]=",  (* Label will be set appropriately *)
    CellID -> generateCellID[]
]

(* Generate a details table cell *)
generateDetailsTable[header_String, rows_List] := ...

(* Convert cells back to markdown for feedback *)
cellsToMarkdown[cells_List] := ...
```

#### Utility Functions

```wl
(* Generate unique CellID *)
generateCellID[] := RandomInteger[{1, 999999999}]

(* Convert markdown inline formatting to TextData *)
markdownToTextData[text_String] := ...

(* Build paclet base from components - handles both conventions *)
buildPacletBase[pacletName_String] := pacletName (* already contains / or is standalone *)
buildPacletBase[publisherID_String, pacletName_String] := publisherID <> "/" <> pacletName

(* Build paclet URI from components *)
buildPacletURI[pacletBase_String, symbolName_String] := pacletBase <> "/ref/" <> symbolName

(* Build context from paclet base *)
buildContext[pacletBase_String] := StringReplace[pacletBase, "/" -> "`"] <> "`"
```

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
    "usage": [
      {
        "syntax": "AddOne[x]",
        "description": "adds one to *x*."
      },
      {
        "syntax": "AddOne[x, y]",
        "description": "adds *x* and *y*."
      }
    ],
    "notes": [
      "AddOne automatically threads over lists.",
      "The value for *x* can be any numeric expression."
    ],
    "seeAlso": ["Plus", "Increment"],
    "keywords": ["add", "increment", "plus one"],
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
    "usage": [
      {
        "syntax": "MyFunction[x]",
        "description": "does something with *x*."
      }
    ]
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
    "usage": [
      {
        "syntax": "AddOne[x]",
        "description": "adds one to *x*."
      }
    ]
  }
}
```

This is equivalent to specifying `publisherID` and `pacletName` separately.

### Editing: Adding a Scope Example

```json
{
  "tool": "EditSymbolPacletDocumentation",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "appendExample",
    "section": "Scope",
    "content": "AddOne works on lists:\n\n```wl\nAddOne[{1, 2, 3}]\n```"
  }
}
```

**Tool response:**
```json
{
  "file": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
  "operation": "appendExample",
  "section": "Scope",
  "generatedContent": "AddOne works on lists:\n\n```wl\nAddOne[{1, 2, 3}]\n```\n```wl-output\n{2, 3, 4}\n```"
}
```

### Editing: Adding Option Documentation

```json
{
  "tool": "EditSymbolPacletDocumentation",
  "parameters": {
    "notebook": "/path/to/MyPaclet/Documentation/English/ReferencePages/Symbols/AddOne.nb",
    "operation": "appendExample",
    "section": "Options",
    "subsection": "Method",
    "content": "Use Method -> \"Fast\" for optimized computation:\n\n```wl\nAddOne[Range[1000], Method -> \"Fast\"]\n```"
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
    "content": ["Plus", "Minus", "Increment", "Decrement"]
  }
}
```
