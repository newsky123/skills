# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Claude Code skills marketplace repository. Skills extend Claude's capabilities with specialized knowledge, workflows, or tool integrations. Users can add this repository as a skill source via `/plugin` in Claude Code.

## Skill Structure

Each skill is a directory containing:
```
skill-name/
├── SKILL.md              # Required: metadata and instructions
└── references/           # Optional: additional documentation
    ├── api-reference.md
    └── examples.md
```

### SKILL.md Format

```markdown
---
name: skill-name
description: Clear description of what this skill does and when Claude should use it. Include trigger keywords.
---

# Skill Title

[Main content with instructions for Claude]

## Detailed Documentation

- **[API Reference](references/api-reference.md)**: Complete interface documentation
- **[Code Examples](references/examples.md)**: Usage patterns and samples
```

## Current Skills

- `tianqin-networking/` - Xiaomi Tianqin (天琴/Lyra) Networking SDK documentation for cross-device discovery and communication

## Creating New Skills

1. Create a directory with the skill name (lowercase, hyphenated)
2. Add `SKILL.md` with YAML frontmatter containing `name` and `description`
3. Write instructions for Claude, not end users
4. Include trigger keywords in the description so Claude knows when to activate the skill
5. Add reference files in `references/` subdirectory for detailed documentation
