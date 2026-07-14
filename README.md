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
| `remove <task>` | delete a task from the list |
| `list` | show all tasks (`[x]` = done, `[ ]` = not yet) |
| `count` | show how many tasks are left to do |
| `quit` | save and exit |

## How to run

You need GHC and cabal (easiest via [GHCup](https://www.haskell.org/ghcup/)). Then:

```bash
cabal run
```

## What I learned

Building this taught me the Haskell basics, hands-on:

- **Defining my own types** — the `Task` record, and `deriving` abilities like `Show`, `Read`, `Eq`
- **Pure functions** — `addTask`, `completeTask`, `renderAll` always give the same answer for the same input and can't touch the outside world; the type says so
- **Pattern matching** — `case words line of` to pick apart user commands by shape
- **Working with lists** — `map`, `filter`, `length`, `:`, `words`/`unwords`, `unlines` instead of writing loops
- **Lambdas** — nameless mini-functions like `\task -> not (done task)` for quick tests and transforms
- **Recursion instead of loops** — the app "remembers" the task list by each round of `loop` passing a new list to the next round; nothing is ever modified in place
- **IO vs pure code** — `do` blocks, `<-` vs `let`, and why `main :: IO ()`
- **Persistence with `show` and `read`** — turning the whole task list into text and back
- **Project structure** — GHCup for the toolchain, `cabal init`, `build-depends`, `cabal run`

## Project structure

- `app/Main.hs` — all the code: pure functions for the task logic, IO actions for the loop and file storage
- `todo.cabal` — project definition and dependencies
- `tasks.txt` — your saved tasks (created on first quit, not checked into git)
