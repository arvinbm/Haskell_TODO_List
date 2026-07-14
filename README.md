# TODO List

A simple command-line to-do list written in Haskell — my first Haskell project.

## What it does

Tasks are kept in memory while the app runs and saved to `tasks.txt` when you quit,
so your list survives between runs.

## Commands

| Command | What it does |
|---|---|
| `add <task>` | add a new task, e.g. `add buy milk` |
| `done <task>` | mark a task as done, e.g. `done buy milk` |
| `list` | show all tasks (`[x]` = done, `[ ]` = not yet) |
| `quit` | save and exit |

## How to run

You need GHC and cabal (easiest via [GHCup](https://www.haskell.org/ghcup/)). Then:

```bash
cabal run
```

## Project structure

- `app/Main.hs` — all the code: pure functions for the task logic, IO actions for the loop and file storage
- `todo.cabal` — project definition and dependencies
- `tasks.txt` — your saved tasks (created on first quit, not checked into git)
