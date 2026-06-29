if not game:IsLoaded() then
    game.Loaded:Wait()
end

local repo = "https://raw.githubusercontent.com/yourusername/MountScripts/main/"

function getgitpath(where)
    if where == "src" then
        return repo .. "src/"
    elseif where == "games" then
        return repo .. "src/games/"
    end
end

local ui = loadstring(game:HttpGet(getgitpath("src") .. "elements.lua"))()
ui:Init()
