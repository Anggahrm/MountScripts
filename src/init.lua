if not game:IsLoaded() then
    game.Loaded:Wait()
end

local repo = "https://raw.githubusercontent.com/Anggahrm/MountScripts/main/"
local env = getgenv()

function env.getgitpath(where)
    if where == "src" then
        return repo .. "src/"
    elseif where == "games" then
        return repo .. "src/games/"
    end
end

local ui = loadstring(game:HttpGet(getgitpath("src") .. "elements.lua"))()
ui:Init()
