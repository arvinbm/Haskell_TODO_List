module Main where
import System.Directory (doesFileExist)
import System.IO (readFile')
import Text.Read (readMaybe)
import Data.List (sortOn) 
import Data.Ord (Down(..))

-- The priority data type
data Priority = Low | Normal | High
    deriving (Show, Read, Eq, Ord)

-- A single to-do item: what it says, and whether it's finished.
data Task = Task {
    description :: String,
    done :: Bool,
    priority :: Priority
} deriving(Show, Read)  -- Show: Task -> text, Read: text -> Task (used for saving/loading)

------------------------------------------------------------
-- Pure functions: no input/output, same answer every time --
------------------------------------------------------------

-- One task as a display line, e.g. "1. [x] buy milk"
render :: Int -> Task -> String
render n task = if done task
    then show n ++ ". " ++ "[x] " ++ description task ++ " - Priority Level: " ++ show (priority task)
    else show n ++ ". " ++ "[ ] " ++ description task ++ " - Priority Level: " ++ show (priority task)

-- A new (not done) task, attached to the front of the list.
addTask :: Priority -> String -> [Task] -> [Task]
addTask priorityLevel desc taskList = Task { description = desc, done = False, priority = priorityLevel} : taskList

-- The whole list as display text, one task per line.
renderAll :: [Task] -> String
renderAll taskList = unlines (map (\(n, task) -> render n task ) (zip [1..] taskList))

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

-- Remove a task with a given number
removeTaskAt :: Int -> [Task] -> [Task]
removeTaskAt n taskList = map snd (filter (\(i, _) -> i /= n) (zip [1..] taskList))

-- Counts the number of undone tasks
countUndone :: [Task] -> Int
countUndone taskList = length (filter (\task -> not (done task)) taskList)

-- Removes the tasks marked done.
clearTasks :: [Task] -> [Task]
clearTasks taskList = filter (\task -> not (done task)) taskList

-- Sorts tasks based on the priority.
sortTasks :: [Task] -> [Task]
sortTasks taskList = sortOn (\task -> Down (priority task)) taskList

-- Marks the nth task as done.
completeTaskAt :: Int -> [Task] -> [Task]
completeTaskAt n taskList = map (\(i, task) -> if i == n then task {done = True} else task) (zip [1..] taskList)

--------------------------------------------------------
-- IO actions: reading/writing files, talking to user --
--------------------------------------------------------

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

-- Does any task in the list have this description?
taskExists :: String -> [Task] -> Bool
taskExists desc taskList = any (\task -> description task == desc) taskList

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
