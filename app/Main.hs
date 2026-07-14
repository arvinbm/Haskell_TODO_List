module Main where

import System.Directory (doesFileExist)

-- A single to-do item: what it says, and whether it's finished.
data Task = Task {
    description :: String,
    done :: Bool
} deriving(Show, Read)  -- Show: Task -> text, Read: text -> Task (used for saving/loading)

------------------------------------------------------------
-- Pure functions: no input/output, same answer every time --
------------------------------------------------------------

-- One task as a display line, e.g. "[x] buy milk"
render :: Task -> String
render task = if done task
    then "[x] " ++ description task
    else "[ ] " ++ description task

-- A new (not done) task, attached to the front of the list.
addTask :: String -> [Task] -> [Task]
addTask desc taskList = Task { description = desc, done = False } : taskList

-- The whole list as display text, one task per line.
renderAll :: [Task] -> String
renderAll taskList = unlines (map render taskList)

-- One task: a copy marked done if the description matches, untouched otherwise.
markTaskDone :: String -> Task -> Task
markTaskDone desc task = if description task == desc
    then task {done = True}
    else task

-- The whole list, with the matching task marked done.
completeTask :: String -> [Task] -> [Task]
completeTask desc taskList = map (markTaskDone desc) taskList

-- Remove a task with a given description.
removeTask :: String -> [Task] -> [Task]
removeTask desc taskList = filter (\task -> description task /= desc) taskList

--------------------------------------------------------
-- IO actions: reading/writing files, talking to user --
--------------------------------------------------------

-- Read tasks back from tasks.txt; empty list on the very first run.
loadTasks :: IO [Task]
loadTasks = do
    exists <- doesFileExist "tasks.txt"
    if exists
        then do
            text <- readFile "tasks.txt"
            return (read text)
        else
            return []

-- Store the whole list in tasks.txt as text.
saveTasks :: [Task] -> IO ()
saveTasks taskList = writeFile "tasks.txt" (show taskList)

-- The heart of the app: read a command, act on it, then loop
-- again with the updated list. The list is never modified --
-- each round passes a new list to the next round.
loop :: [Task] -> IO ()
loop taskList = do
    line <- getLine
    case words line of
        ["quit"] -> do
            saveTasks taskList
            putStrLn "Bye!"
        ["list"] -> do
            putStrLn (renderAll taskList)
            loop taskList
        ("add":rest) -> loop (addTask (unwords rest) taskList)
        ("remove":rest) -> loop (removeTask (unwords rest) taskList)
        ("done":rest) -> loop (completeTask (unwords rest) taskList)
        _ -> do
            putStrLn "Commands: add <task>, done <task>, remove <task>, list, quit"
            loop taskList

main :: IO ()
main = do
    putStrLn "Commands: add <task>, done <task>, remove <task>, list, quit"
    taskList <- loadTasks
    loop taskList
