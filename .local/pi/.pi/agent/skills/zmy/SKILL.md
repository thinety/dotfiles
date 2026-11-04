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
4. **Never alter the session's scrollback**: `zmy history` reads it, so anything that wipes
   or resets it destroys your own output record — `clear`, `reset`, `tput clear`, `tput rs1`,
   form feeds, full-screen programs (use their CLI/batch mode instead, e.g. `git --no-pager`,
   `less` alternatives), or commands that print ANSI clear sequences.
5. **Interrupt a hung command with Ctrl-C via the session**: `printf '\x03' | zmy send dev`.
   Then check with a quick raw command (e.g. `ps aux | grep <prog>`) that it really exited.

## Reading output & polling

- **Use `zmy history` to read output — don't pipe commands through `tail`/`head`/`grep` inside the session.**
  Pipes inside the session buffer everything until the command finishes (you lose progress
  and error output). Send the command plainly, then poll with `zmy history <session> N` and
  filter *that* output on your own side:

  ```bash
  printf 'cmake --build build\r' | zmy send dev && sleep 60
  zmy history dev 400 | grep -E "error|Built target" | tail -20
  ```

- **Don't redirect long-running output to a file either** (`> /tmp/run.log`) — you won't be
  able to see its progress via `zmy history`. Keep output on the terminal so it lands in the
  session history.

- **For long-running commands, poll in a loop**: send the command once, then repeatedly run
  `sleep T && zmy history <session> N`. You can tell the command is still making progress
  because the history output changes between polls. Scale T to the task (seconds for REPL
  steps, 30–90 s for builds/simulations), but don't sleep the full estimated duration up
  front — if a poll times out, just poll again.

- **The session shell persists between commands** — `cd` carries over, so `cd` once at the
  start (or whenever you need to change directory) and keep working from there. Don't prefix
  every command with `cd <dir> &&`.

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
