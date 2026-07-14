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

loop :: [Task] -> IO ()
loop taskList = do
    line <- getLine
    case words line of
        ["quit"] -> putStrLn "Bye!"
        ["list"] -> do
            putStrLn (renderAll taskList)
            loop taskList
        ("add":rest) -> loop (addTask (unwords rest) taskList)
        ("done":rest) -> loop (completeTask (unwords rest) taskList)
        _ -> do
            putStrLn "commands: add <task>, done <task>, list, quit"
            loop taskList

main :: IO ()
main = do
    let greeting = "Your TODO list. Commands: add, done, list, quit"
    putStrLn greeting
    loop []