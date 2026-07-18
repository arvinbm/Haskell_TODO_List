-- The IO half of the app: reading/writing files, talking to the user.
-- All task types and logic come from the Tasks module.
module Main where

import System.Directory (doesFileExist)
import System.IO (readFile')
import Text.Read (readMaybe)

import Tasks

-- Read tasks back from tasks.txt; empty list on the very first run.
loadTasks :: IO [Task]
loadTasks = do
    exists <- doesFileExist "tasks.txt"
    if exists
        then do
            text <- readFile' "tasks.txt"
            case readMaybe text of
                Just tasks -> return tasks
                Nothing -> return []
        else
            return []

-- Store the whole list in tasks.txt as text.
saveTasks :: [Task] -> IO ()
saveTasks taskList = writeFile "tasks.txt" (show taskList)

-- The command overview, shown at start and after an unknown command.
help :: String
help = unlines
    [ "Commands:"
    , "  add <priority> <task>       add a new task"
    , "  done <number>    mark a task as done (done <task> works too)"
    , "  remove <number>  delete a task (remove <task> works too)"
    , "  list             show all tasks"
    , "  count            show how many tasks are left to do"
    , "  sort             sort the list by priority"
    , "  clear            delete all completed tasks"
    , "  quit             save and exit"
    ]

-- The heart of the app: read a command, act on it, then loop
-- again with the updated list. The list is never modified --
-- each round passes a new list to the next round.
loop :: [Task] -> IO ()
loop taskList = do
    line <- getLine
    case words line of
        ["quit"] -> do
            saveTasks taskList
            putStrLn "Saved. Bye!"

        ["list"] -> do
            if null taskList
                then putStrLn "Nothing to do!"
                else putStr (renderAll taskList)
            loop taskList

        ["count"] -> do
            putStrLn (show (countUndone taskList) ++ " task(s) left to do")
            loop taskList

        ["clear"] -> do
            let newList = clearTasks taskList
            putStrLn ("Cleared " ++ show (length taskList - length newList) ++ " completed task(s)")
            loop newList
        
        ["sort"] -> do
            putStrLn ("sorted list based on tasks' priorities")
            loop (sortTasks taskList)

        ("add":rest) -> do
            let (priorityLevel, descWords) = case rest of
                    ("high":more) -> (High, more)
                    ("low":more) -> (Low, more)
                    _ -> (Normal, rest)
            let desc = unwords descWords
            if null desc
                then do
                    putStrLn "Nothing to add. Try: add buy milk"
                    loop taskList
                else do
                    putStrLn ("Added: " ++ desc ++ " with priority level: " ++ show priorityLevel)
                    loop (addTask priorityLevel desc taskList)

        ("remove":rest) ->
            case readMaybe (unwords rest) of
            Just n -> if n >= 1 && n <= length taskList
                then do
                    putStrLn ("Removed task: " ++ show n)
                    loop (removeTaskAt n taskList)
                else do
                    putStrLn ("Task " ++ show n ++ " does not exist")
                    loop taskList

            Nothing -> do
                let desc = unwords rest
                if taskExists desc taskList
                    then do
                        putStrLn ("Removed: " ++ desc)
                        loop (removeTask desc taskList)
                    else do
                        putStrLn ("No task called '" ++ desc ++ "'")
                        loop taskList

        ("done":rest) ->
            case readMaybe (unwords rest) of
                Just n -> if n >= 1 && n <= length taskList
                    then do
                        -- !! picks an item by position, counting from 0
                        putStrLn ("Done: " ++ description (taskList !! (n - 1)))
                        loop (completeTaskAt n taskList)
                    else do
                        putStrLn ("Task " ++ show n ++ " does not exist")
                        loop taskList
                Nothing -> do
                    let desc = unwords rest
                    if taskExists desc taskList
                        then do
                            putStrLn ("Done: " ++ desc)
                            loop (completeTask desc taskList)
                        else do
                            putStrLn ("No task called '" ++ desc ++ "'")
                            loop taskList

        _ -> do
            putStr help
            loop taskList

main :: IO ()
main = do
    putStrLn "Your TODO list."
    putStr help
    taskList <- loadTasks
    loop taskList
