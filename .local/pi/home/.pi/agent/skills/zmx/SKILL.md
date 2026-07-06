---
name: zmx
description: Terminal multiplexer used for session management. Use zmx to create persistent terminal sessions, send commands interactively, and capture output — ideal for GDB, build tools, or any interactive CLI workflow.
---

# zmx — Session Persistence for Terminal Processes

zmx is like tmux but simpler: it manages persistent terminal sessions with PTY support. Each session runs a shell that stays alive between commands, letting you interact with programs (like GDB) step by step.

## Quick Reference

| Task | Command |
|------|---------|
| Run (non-interactive) command | `zmx run <session-name> command arg1 arg2` |
| Send command (interactive) | `printf 'command arg1 arg2\r' \| zmx send <session-name>` |
| Read output (interactive) | `zmx history <session-name> \| tail -<N>` |
| List sessions | `zmx list` |
| Kill a session | `zmx kill <session-name>` |

## Important Rules

1. **Never use `zmx attach` or `zmx detach`**: they mess up the Pi TUI.
2. **Always use the provided session name**: if the user doesn't provide one, choose a suitable session name.
3. **Create the session if necessary**: if the session doesn't exist, create it with a simple `zmx run <session-name> echo ready`.
6. **Avoid destructive operations**: prefer to keep the session after you are done. Only use `zmx kill` if the session is somehow unresponsive.
4. **For non-interactive commands, use `zmx run`**: it immediately tails the output until the command is complete and then exits with the exit code of the command that was sent.
5. **For interactive commands, use `zmx send && sleep && zmx history`**.

## Typical GDB Workflow

### 1. Launch GDB

```bash
printf 'gdb ./program\r' | zmx send debug-session && sleep 1.0 && zmx history debug-session | tail -10
```

### 2. Set breakpoints and run

```bash
printf 'break some_function\r' | zmx send debug-session && sleep 0.1 && zmx history debug-session | tail -10
printf 'run\r' | zmx send debug-session && sleep 0.1 && zmx history debug-session | tail -10
```

### 3. Step through and inspect

```bash
printf 'next\r' | zmx send debug-session && sleep 0.1 && zmx history debug-session | tail -10
printf 'bt\r' | zmx send debug-session && sleep 0.1 && zmx history debug-session | tail -10
```
