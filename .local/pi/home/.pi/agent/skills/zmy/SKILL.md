---
name: zmy
description: Terminal multiplexer used for session management. Use zmy to create persistent terminal sessions, send commands interactively, and capture output — ideal for GDB, build tools, or any interactive CLI workflow.
---

# zmy — Session Persistence for Terminal Processes

zmy is like tmux but simpler: it manages persistent terminal sessions with PTY support. Each session runs a shell that stays alive between commands, letting you interact with programs (like GDB) step by step.

## Quick Reference

| Task | Command |
|------|---------|
| Send command | `printf 'command arg1 arg2\r' \| zmy send <session-name>` |
| Read output | `zmy history <session-name> [lines]` |

## Important Rules

1. **Never use `zmy attach` or `zmy detach`**: they mess up the Pi TUI.
2. **Always use the provided session name**: if the user doesn't provide one, choose a suitable session name and report it to the user.
3. **Execute commands and read the output by running `zmy send && sleep && zmy history`**.

## Typical GDB Workflow

### 1. Launch GDB

```bash
printf 'gdb ./program\r' | zmy send debug-session && sleep 1.0 && zmy history debug-session 10
```

### 2. Set breakpoints and run

```bash
printf 'break some_function\r' | zmy send debug-session && sleep 0.1 && zmy history debug-session 10
printf 'run\r' | zmy send debug-session && sleep 0.1 && zmy history debug-session 10
```

### 3. Step through and inspect

```bash
printf 'next\r' | zmy send debug-session && sleep 0.1 && zmy history debug-session 10
printf 'bt\r' | zmy send debug-session && sleep 0.1 && zmy history debug-session 10
```
