# Claude Preferences System

## Overview

This directory contains a modular preference system for Claude across different interfaces (Desktop, VSCode Copilot, and Claude Code). The system is designed to:

- Maintain version-controlled preferences
- Avoid duplication while allowing interface-specific customization
- Enable updates from any Claude interface
- Preserve critical information even if the knowledge graph is lost

## File Structure

```
claude/
├── base.md              # Core preferences shared by all interfaces
├── desktop.md           # Claude Desktop specific instructions
├── copilot.md           # VSCode Copilot specific instructions
├── code.md              # Claude Code specific instructions
├── setup-symlinks.sh    # Script to create/update symlinks
└── README.md            # This file
```

## How It Works

### 1. Modular Design

- **base.md**: Contains all shared preferences (identity, memory system, communication style, professional context, coding standards)
- **Interface files**: Each interface has a minimal file that:
  - References base.md for core preferences
  - Adds only interface-specific instructions
  - Focuses on role identification and available tools

### 2. Symlink System

The `setup-symlinks.sh` script creates symlinks from our version-controlled files to where each Claude interface expects them:

- `desktop.md` → `~/dotfiles/settings/claude.md`
- `copilot.md` → `~/Library/Application Support/Code/User/prompts/.instructions.md`
- `code.md` → `~/.claude/CLAUDE.md`

### 3. Version Control

All files in this directory are version controlled, allowing you to:

- Track changes over time
- Roll back if needed
- Share configurations across machines
- Maintain a backup of your preferences

## Initial Setup

1. Run the setup script:

   ```bash
   ./setup-symlinks.sh
   ```

2. The script will:
   - Check that all source files exist
   - Create necessary directories
   - Backup any existing files (with timestamp)
   - Create symlinks to the appropriate locations

## Updating Preferences

### To update shared preferences:

1. Edit `base.md`
2. Commit changes to version control
3. All Claude interfaces will automatically use the updated preferences

### To update interface-specific settings:

1. Edit the appropriate interface file (`desktop.md`, `copilot.md`, or `code.md`)
2. Commit changes to version control
3. That specific interface will use the updated settings

### Preference Synchronization with Knowledge Graph

When updating preferences:

1. Claude should first update the appropriate file in this directory
2. Then sync the changes to the knowledge graph entities
3. Both systems should maintain matching version numbers

## Interface Roles

### Claude Desktop

- **Purpose**: Conceptual work, architecture, design
- **Tools**: Full MCP server access, web search, artifacts
- **Focus**: Planning and thinking, not implementation

### VSCode Copilot

- **Purpose**: Primary implementation interface
- **Tools**: Knowledge graph + Claude Code delegation
- **Focus**: Planning implementation, then delegating to Claude Code

### Claude Code

- **Purpose**: Autonomous implementation execution with comprehensive development tools
- **Tools**: Development ecosystem with data processing (jq/yq), semantic search (ast-grep), type analysis (mypy), semantic diff (difftastic), Python/shell/infrastructure toolchain
- **Focus**: Getting things done with analytical and processing capabilities

## Knowledge Graph Recovery

If the knowledge graph is lost, the `base.md` file contains complete instructions for rebuilding it, including:

- Core organizational entities
- Preference entities
- Implementation guides
- Recovery steps

## Best Practices

1. **Keep interface files minimal** - Most content belongs in base.md
2. **Version everything** - Increment version numbers when making changes
3. **Document changes** - Use meaningful commit messages
4. **Test after changes** - Verify each interface still loads correctly
5. **Regular backups** - The symlink script automatically backs up existing files

## Troubleshooting

### Symlinks not working

- Ensure the setup script has execute permissions: `chmod +x setup-symlinks.sh`
- Check that source files exist in this directory
- Verify target directories exist and have write permissions

### Preferences not loading

- Check symlink targets: `ls -la [target path]`
- Ensure files have correct read permissions
- Verify file syntax (no parsing errors)

### VSCode Copilot inconsistent

- This is a known issue mentioned in the original request
- The symlink system should help improve consistency
- Monitor and document any persistent issues

## Future Enhancements

Potential improvements to consider:

- Automated testing of preference files
- Git hooks for version number updates
- Sync status monitoring
- Preference validation script
- Automated knowledge graph backup/restore
