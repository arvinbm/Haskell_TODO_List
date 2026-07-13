data Task = Task {
    description :: String,
    done :: Bool
} deriving(Show)

render :: Task -> String
render t = if done t
    then "[x] " ++ description t
    else "[ ] " ++ description t