#!/bin/bash
# PreToolUse Hook - Runs before tool calls (can block dangerous operations)
# Protects against common mistakes and adds intelligent guardrails

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# ==============================================================================
# BASH COMMAND SAFETY - Warn about dangerous commands
# ==============================================================================
if [[ "$TOOL_NAME" == "Bash" ]]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # Check for dangerous patterns
  if [[ "$COMMAND" =~ rm\ -rf\ / ]] || \
     [[ "$COMMAND" =~ rm\ -rf\ \~ ]] || \
     [[ "$COMMAND" =~ :\(\)\{\ :\|:\& ]] || \
     [[ "$COMMAND" =~ mkfs ]] || \
     [[ "$COMMAND" =~ dd\ if=.*of=/dev ]] || \
     [[ "$COMMAND" =~ \>.*\/dev\/sd ]]; then
    echo "{\"decision\": \"deny\", \"reason\": \"Potentially destructive command blocked: $COMMAND\"}"
    exit 0
  fi

  # Warn about force push to main/master
  if [[ "$COMMAND" =~ git\ push.*--force ]] && \
     [[ "$COMMAND" =~ (main|master) ]]; then
    echo "{\"decision\": \"ask\", \"reason\": \"Force push to main/master detected. Are you sure?\"}"
    exit 0
  fi
fi

# ==============================================================================
# LARGE FILE WARNING - Warn before reading very large files
# ==============================================================================
if [[ "$TOOL_NAME" == "Read" ]]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

  if [ -f "$FILE_PATH" ]; then
    FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null)
    MAX_SIZE=$((1024 * 1024))  # 1MB

    if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
      SIZE_MB=$((FILE_SIZE / 1024 / 1024))
      echo "{\"decision\": \"ask\", \"reason\": \"Large file ($SIZE_MB MB). This may use significant context. Continue?\"}"
      exit 0
    fi
  fi
fi

# ==============================================================================
# PACKAGE.JSON MODIFICATIONS - Extra validation
# ==============================================================================
if [[ "$TOOL_NAME" == "Edit" ]] && [[ "$FILE_PATH" == *"package.json" ]]; then
  # Just log for now, could add validation
  echo "Modifying package.json - remember to run npm install" >&2
fi

# ==============================================================================
# MARKDOWN FILE STRUCTURE ENFORCEMENT - Prevent scattered documentation
# ==============================================================================
if [[ "$TOOL_NAME" == "Write" ]] || [[ "$TOOL_NAME" == "Edit" ]]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

  # Check if this is a markdown file
  if [[ "$FILE_PATH" == *.md ]]; then
    FILENAME=$(basename "$FILE_PATH")

    # ALLOWED LOCATIONS
    if [[ "$FILE_PATH" == docs/* ]] || \
       [[ "$FILE_PATH" == docs/implementation/* ]] || \
       [[ "$FILE_PATH" == docs/architecture-transformation/* ]] || \
       [[ "$FILE_PATH" == docs/refactoring-phases/* ]] || \
       [[ "$FILE_PATH" == docs/guides/* ]] || \
       [[ "$FILE_PATH" == docs/freeway/* ]] || \
       [[ "$FILE_PATH" == .claude/commands/*.md ]] || \
       [[ "$FILE_PATH" == .claude/agents/*.md ]] || \
       [[ "$FILE_PATH" == README.md ]] || \
       [[ "$FILE_PATH" == tools/README.md ]] || \
       [[ "$FILE_PATH" == src/docs/README.md ]]; then

      # Extra check for COMPLETE/SUMMARY/REPORT files
      if [[ "$FILENAME" == *COMPLETE*.md ]] || \
         [[ "$FILENAME" == *SUMMARY*.md ]] || \
         [[ "$FILENAME" == *REPORT*.md ]] || \
         [[ "$FILENAME" == *ANALYSIS*.md ]] || \
         [[ "$FILENAME" == *GUIDE*.md ]]; then

        if [[ "$FILE_PATH" != docs/implementation/* ]]; then
          echo "{\"decision\": \"deny\", \"reason\": \"COMPLETE/SUMMARY/REPORT/ANALYSIS/GUIDE files must go in docs/implementation/. We already have 50+ such files! Attempted: $FILE_PATH. Use: docs/implementation/$FILENAME\"}"
          exit 0
        fi

        # BLOCK creation of unnecessary documentation files
        echo "{\"decision\": \"ask\", \"message\": \"⚠️  Creating new documentation file. We have 50+ already! Think twice: Can you update an existing file in docs/implementation/ instead? This creates maintenance burden.\"}" | jq -c
        exit 0
      fi

      # Allow the write
      exit 0
    fi

    # BLOCKED LOCATIONS
    if [[ "$FILE_PATH" == .cursor/* ]]; then
      echo "{\"decision\": \"deny\", \"reason\": \"No new .md files here. Use .claude/ instead. Attempted: $FILE_PATH\"}"
      exit 0
    fi

    if [[ "$FILE_PATH" == .claude/session-logs/* ]] || \
       [[ "$FILE_PATH" == .claude/preserved-context/* ]]; then
      echo "{\"decision\": \"deny\", \"reason\": \"No manual files in session-logs/ or preserved-context/. These are for automated context only. Attempted: $FILE_PATH\"}"
      exit 0
    fi

    # Root directory (only README.md allowed)
    if [[ "$FILE_PATH" != */* ]] && [[ "$FILENAME" != "README.md" ]]; then
      echo "{\"decision\": \"deny\", \"reason\": \"Only README.md allowed in root. Put documentation in docs/. Attempted: $FILE_PATH. Use: docs/$FILENAME\"}"
      exit 0
    fi

    # Catch-all: Block any other .md location
    echo "{\"decision\": \"deny\", \"reason\": \"NO MORE MARKDOWN FILES! Only allowed locations: docs/, docs/implementation/, .claude/commands/, .claude/agents/, or README.md. Think twice before creating documentation - update existing files instead! Attempted: $FILE_PATH\"}"
    exit 0
  fi
fi



# Allow the operation
exit 0
