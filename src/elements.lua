local ui = {}
local coregui = game:GetService("CoreGui")
local hui = gethui or get_hidden_gui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MountScripts"
screenGui.ResetOnSpawn = false
screenGui.Parent = hui and hui() or coregui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 20, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
header.Text = "MOUNT SCRIPTS"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 16
header.BorderSizePixel = 0
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -45)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = scroll

function ui:Label(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scroll
end

function ui:Toggle(text, default, callback)
    local togFrame = Instance.new("Frame")
    togFrame.Size = UDim2.new(1, -10, 0, 30)
    togFrame.BackgroundTransparency = 1
    togFrame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = togFrame

    local tog = Instance.new("Frame")
    tog.Size = UDim2.new(0, 30, 0, 20)
    tog.Position = UDim2.new(1, -35, 0.5, -10)
    tog.BackgroundColor3 = default and Color3.fromRGB(59, 164, 57) or Color3.fromRGB(164, 58, 58)
    tog.BorderSizePixel = 0
    tog.Parent = togFrame
    Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = tog
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = togFrame

    local isOn = default
    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            tog.BackgroundColor3 = Color3.fromRGB(59, 164, 57)
            circle.Position = UDim2.new(1, -17, 0.5, -7)
        else
            tog.BackgroundColor3 = Color3.fromRGB(164, 58, 58)
            circle.Position = UDim2.new(0, 3, 0.5, -7)
        end
        callback(isOn)
    end)

    task.defer(function() callback(isOn) end)
end

function ui:Button(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

function ui:Init()
    loadstring(game:HttpGet(getgitpath("games") .. tostring(game.PlaceId) .. ".lua"))()(ui)
end

return ui
