data Task = Task {
    description :: String,
    done :: Bool
} deriving(Show)

render :: Task -> String
render t = if done t
    then "[x] " ++ description t
    else "[ ] " ++ description t

addTask :: String -> [Task] -> [Task]
addTask desc taskList = Task { description = desc, done = False } : taskList

renderAll :: [Task] -> String
renderAll taskList = unlines (map render taskList)

