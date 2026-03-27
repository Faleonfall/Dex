Use [XcodeBuildMCP's CLI](https://github.com/getsentry/XcodeBuildMCP/blob/main/docs/CLI.md) (`xcodebuildmcp`) for building, testing, and running this project.
Run it with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` in this environment so it uses full Xcode instead of Command Line Tools.

Defaults for this repository:
- Scheme: `Dex`
- Project path: `./Dex.xcodeproj`
- Preferred simulator name: `iPhone 16`

Behavior:
- Do not run or test the project unless explicitly requested.
- Building the project is allowed when needed to verify compilation.
- Prefer the configured project path, scheme, and simulator above instead of rediscovering them each time.
- If using XcodeBuildMCP, use the installed XcodeBuildMCP skill before calling XcodeBuildMCP tools.
