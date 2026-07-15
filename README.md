# TODO List

A simple command-line to-do list written in Haskell — my first Haskell project.

## What it does

Tasks are kept in memory while the app runs and saved to `tasks.txt` when you quit,
so your list survives between runs.

## Commands

| Command | What it does |
|---|---|
| `add <task>` | add a new task, e.g. `add buy milk` |
| `done <number>` | mark a task as done by its number, e.g. `done 2` (`done <task>` works too) |
| `remove <number>` | delete a task by its number (`remove <task>` works too) |
| `clear` | delete all completed tasks |
| `list` | show all tasks, numbered (`[x]` = done, `[ ]` = not yet) |
| `count` | show how many tasks are left to do |
| `quit` | save and exit |

Every command confirms what it did (`Added: buy milk`, `Cleared 2 completed task(s)`),
and invalid input gets a helpful message instead of a crash — `done 99` tells you the
task doesn't exist, `done banana` falls back to matching by description.

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
- **`Maybe` for things that might not exist** — `readMaybe` returns `Just 2` or `Nothing` instead of crashing on bad input, and pattern matching forces me to handle both cases
- **Tuples and `zip`** — numbering tasks by zipping them with the infinite list `[1..]`; laziness means only the needed numbers ever get made
- **Validating user input** — bounds-checking task numbers and giving friendly error messages instead of silent failures
- **Laziness has sharp edges too** — lazy `readFile` kept the file open and crashed a later write; strict `readFile'` fixed it
- **Project structure** — GHCup for the toolchain, `cabal init`, `build-depends`, `cabal run`

## Project structure

- `app/Main.hs` — all the code: pure functions for the task logic, IO actions for the loop and file storage
- `todo.cabal` — project definition and dependencies
- `tasks.txt` — your saved tasks (created on first quit, not checked into git)
