if not game:IsLoaded() then
    game.Loaded:Wait()
end

local repo = "https://raw.githubusercontent.com/Anggahrm/MountScripts/main/"

local ui = loadstring(game:HttpGet(repo .. "src/elements.lua"))()
ui:Init()
