data Task = Task {
    description :: String,
    done :: Bool
} deriving(Show)

render :: Task -> String
render task = if done task
    then "[x] " ++ description task
    else "[ ] " ++ description task

addTask :: String -> [Task] -> [Task]
addTask desc taskList = Task { description = desc, done = False } : taskList

renderAll :: [Task] -> String
renderAll taskList = unlines (map render taskList)

markTaskDone :: String -> Task -> Task
markTaskDone desc task = if description task == desc
    then task {done = True}
    else task

completeTask :: String -> [Task] -> [Task]
completeTask desc taskList = map (markTaskDone desc) taskList