# Dot-Claude

> The best `.claude` configuration for Claude Code - A curated collection of hooks, commands, agents, and settings to supercharge your Claude Code experience.

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

### 🛡️ Pre-Tool Use Safety Guard (The Star Feature!)

**File**: [`.claude/hooks/pre-tool-use.sh`](.claude/hooks/pre-tool-use.sh)

**Purpose**: A comprehensive safety system that runs before every tool call to protect against common mistakes and enforce best practices.

This hook combines multiple intelligent guardrails into one powerful safety system:

#### 1. 💥 Bash Command Safety

Blocks potentially destructive commands before they execute:
- `rm -rf /` or `rm -rf ~` (filesystem destruction)
- Fork bombs `:(){ :|:& };:`
- `mkfs` (format disk)
- `dd` writing to devices
- Redirects to `/dev/sd*`

**Also warns** about force pushes to main/master branches.

**Example**:
```json
{
  "decision": "deny",
  "reason": "Potentially destructive command blocked: rm -rf /"
}
```

```json
{
  "decision": "ask",
  "reason": "Force push to main/master detected. Are you sure?"
}
```

#### 2. 📦 Large File Warning

Warns before reading files larger than 1MB to prevent context overflow.

**Example**:
```json
{
  "decision": "ask",
  "reason": "Large file (5 MB). This may use significant context. Continue?"
}
```

#### 3. 📝 Package.json Modification Alert

Logs a reminder to run `npm install` when `package.json` is modified.

#### 4. 📁 Markdown Structure Enforcement

Prevents documentation sprawl by enforcing strict file organization:

**✅ Allowed locations:**
- `docs/` and subdirectories (`implementation/`, `architecture-transformation/`, `refactoring-phases/`, `guides/`, `freeway/`)
- `.claude/commands/` and `.claude/agents/`
- `README.md` files in root, `tools/`, and `src/docs/`

**❌ Blocked locations:**
- Root directory (except `README.md`)
- `.cursor/` directory (use `.claude/` instead)
- Session logs and preserved context directories
- Any undocumented locations

**🚨 Special handling** for COMPLETE/SUMMARY/REPORT/ANALYSIS/GUIDE files:
- Must be placed in `docs/implementation/`
- Requires confirmation before creating (encourages updating existing files)

**Example outputs**:
```json
{
  "decision": "deny",
  "reason": "Only README.md allowed in root. Put documentation in docs/. Attempted: NOTES.md. Use: docs/NOTES.md"
}
```

```json
{
  "decision": "ask",
  "message": "⚠️  Creating new documentation file. We have 50+ already! Think twice: Can you update an existing file in docs/implementation/ instead?"
}
```

**Why it's useful**: This single hook prevents data loss, maintains organized documentation, protects against accidental destructive operations, and keeps your project clean and safe.

### 🔄 Session Hooks

**Files**:
- [`.claude/hooks/session-start.sh`](.claude/hooks/session-start.sh)
- [`.claude/hooks/session-end.sh`](.claude/hooks/session-end.sh)
- [`.claude/hooks/stop.sh`](.claude/hooks/stop.sh)

**Purpose**: Placeholder hooks for custom session lifecycle management.

**Current state**: Ready for customization - currently exit successfully without action.

**Use cases**:
- Initialize project-specific settings on session start
- Clean up temporary files on session end
- Save context or state between sessions
- Trigger custom notifications

### 📋 User Prompt Hook

**File**: [`.claude/hooks/user-prompt-submit.sh`](.claude/hooks/user-prompt-submit.sh)

**Purpose**: Intercept and validate user prompts before processing.

**Current state**: Ready for customization - currently exits successfully without action.

**Use cases**:
- Add project context to prompts
- Validate prompt format
- Log user interactions
- Pre-process or enhance prompts

### 🎨 File Formatting Hook

**File**: [`.claude/hooks/format-file.sh`](.claude/hooks/format-file.sh)

**Purpose**: Automatically format files after Write or Edit operations.

**Current state**: Ready for customization - currently exits successfully without action.

**Use cases**:
- Run Prettier, ESLint, or other formatters
- Ensure consistent code style
- Add headers or comments automatically
- Validate file contents

### 📦 Pre-Compact Hook

**File**: [`.claude/hooks/pre-compact.sh`](.claude/hooks/pre-compact.sh)

**Purpose**: Execute actions before context compaction.

**Current state**: Ready for customization - currently exits successfully without action.

**Use cases**:
- Save important context before compaction
- Log conversation state
- Archive previous context
- Optimize what gets preserved

### 🔔 Notification Hook

**File**: [`.claude/hooks/notification.sh`](.claude/hooks/notification.sh)

**Purpose**: Handle system notifications from Claude Code.

**Current state**: Ready for customization - currently exits successfully without action.

**Use cases**:
- Send desktop notifications
- Log important events
- Integrate with Slack/Discord/other services
- Custom alerting logic

## Configuration

### Settings File

The [`.claude/settings.json`](.claude/settings.json) file configures all hooks and network policies. Key sections:

```json
{
  "hooks": {
    "SessionStart": [...],
    "SessionEnd": [...],
    "UserPromptSubmit": [...],
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...],
    "SubagentStop": [...],
    "PreCompact": [...],
    "Notification": [...]
  },
  "network": {
    "allowlist": [...]
  }
}
```

### Customizing Hooks

Each hook script can be customized for your needs. Hook scripts should:
- Exit with code `0` on success
- Return JSON with `decision` and `reason` fields for blocking hooks
- Complete within the configured timeout
- Be executable (`chmod +x`)

**Example blocking hook response**:
```json
{
  "decision": "deny",
  "reason": "Explanation of why the action was blocked"
}
```

**Example proceed with message**:
```json
{
  "decision": "proceed",
  "message": "Warning or information message"
}
```

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