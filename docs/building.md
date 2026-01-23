# Building the Paclet

This guide covers how to build MCPServer for distribution.

## Basic Build

Build the paclet using:

```bash
wolframscript -f Scripts/BuildPaclet.wls
```

This script builds the paclet and performs necessary checks.

## Build Options

| Option | Description | Default |
|--------|-------------|---------|
| `--check` | Run code checks | `true` |
| `--install` | Install the paclet after building | `false` |
| `--mx` | Build MX files | `true` |

## Examples

Build and install:

```bash
wolframscript -f Scripts/BuildPaclet.wls --install=true
```

Build without code checks (faster, for quick iteration):

```bash
wolframscript -f Scripts/BuildPaclet.wls --check=false
```

Build without MX file:

```bash
wolframscript -f Scripts/BuildPaclet.wls --mx=false
```

## Build Output

The built paclet will be placed in the `build/` directory. The output includes:

- The `.paclet` file for distribution
- MX files (unless disabled) for faster loading

## MX Files

MX files are pre-compiled versions of the paclet that load faster. During the MX build, error handling tags are also rewritten to include source file locations for easier debugging (see [Error Handling - Modified Definition](error-handling.md#modified-definition)).

During development, you may want to:

- **Disable MX building** with `--mx=false` for faster build iterations
- **Delete existing MX files** (`Kernel/64Bit/MCPServer.mx`) when testing source changes

See [Getting Started](getting-started.md#important-mx-files) for more details on MX files during development.

## See Also

- [Getting Started](getting-started.md) - Development environment setup
- [Testing](testing.md) - Writing and running tests
- [Error Handling](error-handling.md) - Error handling architecture and patterns
- [AGENTS.md](../AGENTS.md) - Detailed development guidelines
