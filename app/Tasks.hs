-- The pure core of the app: the task types and every function that
-- transforms tasks, with no input/output anywhere.
module Tasks where

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

-- Does any task in the list have this description?
taskExists :: String -> [Task] -> Bool
taskExists desc taskList = any (\task -> description task == desc) taskList
