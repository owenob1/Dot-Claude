# Dot-Claude

> A curated `.claude` configuration of hooks, commands, agents, and settings to supercharge your Claude Code experience.

> [!WARNING]
> **Under Active Development** - This project is currently being built and refined. Features and documentation may change frequently. Feel free to use and contribute, but expect updates!

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Overview](#overview)
- [Installation](#installation)
- [Features](#features)
- [Tools & Hooks](#tools--hooks)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

</details>

## Overview

Dot-Claude provides a production-ready `.claude` directory with powerful hooks and configurations to enhance Claude Code's capabilities. Whether you're managing documentation, enforcing code standards, or streamlining your workflow, this configuration has you covered.

## Installation

### Quick Setup

1. **Clone this repository** into your project:
   ```bash
   git clone https://github.com/owenob1/Dot-Claude.git
   cd Dot-Claude
   ```

2. **Copy the `.claude` directory** to your project root:
   ```bash
   cp -r .claude /path/to/your/project/
   ```

3. **Make hooks executable**:
   ```bash
   chmod +x .claude/hooks/*.sh
   ```

4. **Restart Claude Code** to load the new configuration.

### Manual Setup

Alternatively, you can copy individual files from the `.claude` directory into your existing setup:

```bash
# Copy settings
cp .claude/settings.json /path/to/your/project/.claude/

# Copy specific hooks
cp .claude/hooks/pre-tool-use.sh /path/to/your/project/.claude/hooks/
```

## Features

### 🎯 Smart Hooks System

The configuration includes a comprehensive hooks system that runs automatically during Claude Code operations:

- **Session Management**: Hooks for session start and end events
- **Tool Use Controls**: Pre and post-tool execution hooks
- **Formatting**: Automatic file formatting after edits
- **Notifications**: Custom notification handling
- **Compaction Control**: Pre-compact hooks for context management

### 🔒 Network Security

Configured allowlist for safe external API access:
- NPM Registry
- GitHub (including raw content)
- MCP Context services

## Tools & Hooks

### 🛡️ Pre-Tool Use Safety Guard

**The Star Feature!** - A comprehensive safety system that runs before every tool call.

**File**: [`.claude/hooks/pre-tool-use.sh`](.claude/hooks/pre-tool-use.sh)

<details>
<summary><strong>View Details</strong></summary>

This hook combines 4 intelligent guardrails into one powerful safety system:

#### 1. 💥 Bash Command Safety
Blocks destructive commands: `rm -rf /`, fork bombs, `mkfs`, dangerous `dd` operations, and warns about force pushes to main/master.

#### 2. 📦 Large File Warning
Warns before reading files >1MB to prevent context overflow.

#### 3. 📝 Package.json Alerts
Reminds you to run `npm install` after modifications.

#### 4. 📁 Markdown Structure Enforcement
Enforces organized documentation structure. Only allows markdown files in designated locations (`docs/`, `.claude/commands/`, `.claude/agents/`, `README.md`).

**Example responses:**
```json
{"decision": "deny", "reason": "Potentially destructive command blocked: rm -rf /"}
{"decision": "ask", "reason": "Large file (5 MB). This may use significant context. Continue?"}
```

</details>

### Other Hooks (Customizable)

All hooks below are **placeholder templates** ready for your customization. They currently exit successfully without taking action.

<details>
<summary><strong>🔄 Session Hooks</strong> - Session lifecycle management</summary>

**Files**: [`session-start.sh`](.claude/hooks/session-start.sh) • [`session-end.sh`](.claude/hooks/session-end.sh) • [`stop.sh`](.claude/hooks/stop.sh)

**Use cases**: Initialize settings on start, clean up files on end, save context between sessions, trigger notifications.

</details>

<details>
<summary><strong>📋 User Prompt Hook</strong> - Intercept and validate prompts</summary>

**File**: [`.claude/hooks/user-prompt-submit.sh`](.claude/hooks/user-prompt-submit.sh)

**Use cases**: Add project context, validate format, log interactions, pre-process prompts.

</details>

<details>
<summary><strong>🎨 File Formatting Hook</strong> - Auto-format after edits</summary>

**File**: [`.claude/hooks/format-file.sh`](.claude/hooks/format-file.sh)

**Use cases**: Run Prettier/ESLint, ensure consistent style, add headers, validate contents.

</details>

<details>
<summary><strong>📦 Pre-Compact Hook</strong> - Actions before compaction</summary>

**File**: [`.claude/hooks/pre-compact.sh`](.claude/hooks/pre-compact.sh)

**Use cases**: Save context, log state, archive previous context, optimize preservation.

</details>

<details>
<summary><strong>🔔 Notification Hook</strong> - Handle system notifications</summary>

**File**: [`.claude/hooks/notification.sh`](.claude/hooks/notification.sh)

**Use cases**: Desktop notifications, event logging, Slack/Discord integration, custom alerts.

</details>

## Configuration

<details>
<summary><strong>⚙️ Settings & Customization</strong></summary>

### Settings File

The [`.claude/settings.json`](.claude/settings.json) file configures all hooks and network policies:

```json
{
  "hooks": {
    "SessionStart": [...],
    "PreToolUse": [...],
    "PostToolUse": [...]
    // ... and more
  },
  "network": {
    "allowlist": ["registry.npmjs.org", "*.github.com", ...]
  }
}
```

### Customizing Hooks

Hook scripts should:
- Exit with code `0` on success
- Return JSON with `decision` and `reason` for blocking actions
- Complete within configured timeout
- Be executable (`chmod +x`)

**Response examples**:
```json
{"decision": "deny", "reason": "Explanation..."}
{"decision": "proceed", "message": "Warning..."}
```

</details>

## Project Structure

```
.claude/
├── settings.json              # Main configuration file
└── hooks/                     # Hook scripts directory
    ├── pre-tool-use.sh       # 🛡️ Multi-feature safety guard (main tool!)
    ├── session-start.sh      # Session initialization
    ├── session-end.sh        # Session cleanup
    ├── user-prompt-submit.sh # Prompt preprocessing
    ├── format-file.sh        # Post-edit formatting
    ├── pre-compact.sh        # Pre-compaction actions
    ├── stop.sh               # Stop event handler
    └── notification.sh       # Notification handler
```

## Contributing

Contributions are welcome! If you have useful hooks, commands, or agents to share:

1. Fork the repository
2. Create a feature branch
3. Add your improvements
4. Submit a pull request

Please ensure your hooks are well-documented and include usage examples.

## License

MIT License - feel free to use and modify for your projects.

## Acknowledgments

Built for the Claude Code community to help maintain clean, organized, and efficient AI-assisted development workflows.

---

**Made with ❤️ for Claude Code users**