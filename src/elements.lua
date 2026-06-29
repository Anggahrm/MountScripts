local ui = {}
local coregui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local hui = gethui or get_hidden_gui

-- Colors
local BG = Color3.fromRGB(18, 18, 22)
local SURFACE = Color3.fromRGB(28, 28, 36)
local ACCENT = Color3.fromRGB(99, 102, 241)
local ACCENT_HOVER = Color3.fromRGB(129, 132, 255)
local TEXT = Color3.fromRGB(230, 230, 240)
local SUBTEXT = Color3.fromRGB(160, 160, 175)
local TOG_ON = Color3.fromRGB(52, 211, 153)
local TOG_OFF = Color3.fromRGB(239, 68, 68)
local INPUT_BG = Color3.fromRGB(22, 22, 28)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MountScriptsUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = hui and hui() or coregui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0, 20, 0.5, -210)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 50)
stroke.Thickness = 1
stroke.Parent = frame

-- Drag
local dragging, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = SURFACE
header.BorderSizePixel = 0
header.ClipsDescendants = true
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local headerFill = Instance.new("Frame")
headerFill.Size = UDim2.new(1, 0, 0, 10)
headerFill.Position = UDim2.new(0, 0, 1, -10)
headerFill.BackgroundColor3 = SURFACE
headerFill.BorderSizePixel = 0
headerFill.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Mount Scripts"
title.TextColor3 = TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -34, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = SUBTEXT
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Content scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -52)
scroll.Position = UDim2.new(0, 6, 0, 46)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.BorderSizePixel = 0
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 4)
padding.PaddingRight = UDim.new(0, 4)
padding.Parent = scroll

-- Status bar
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 30)
statusFrame.BackgroundColor3 = SURFACE
statusFrame.BorderSizePixel = 0
statusFrame.LayoutOrder = -9999
statusFrame.Parent = scroll

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusFrame

local statusIcon = Instance.new("Frame")
statusIcon.Size = UDim2.new(0, 8, 0, 8)
statusIcon.Position = UDim2.new(0, 10, 0.5, -4)
statusIcon.BackgroundColor3 = TOG_OFF
statusIcon.BorderSizePixel = 0
statusIcon.Parent = statusFrame

local statusIconCorner = Instance.new("UICorner")
statusIconCorner.CornerRadius = UDim.new(1, 0)
statusIconCorner.Parent = statusIcon

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -22, 1, 0)
statusText.Position = UDim2.new(0, 22, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Idle"
statusText.TextColor3 = SUBTEXT
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusFrame

function ui:SetStatus(text, isActive)
    statusText.Text = text
    statusIcon.BackgroundColor3 = isActive and Color3.fromRGB(52, 211, 153) or TOG_OFF
end

function ui:Label(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = SUBTEXT
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scroll
end

function ui:Header(text)
    local head = Instance.new("TextLabel")
    head.Size = UDim2.new(1, 0, 0, 28)
    head.BackgroundTransparency = 1
    head.Text = text
    head.TextColor3 = ACCENT
    head.Font = Enum.Font.GothamBold
    head.TextSize = 13
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.Parent = scroll

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = ACCENT
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = head
end

function ui:Toggle(text, default, callback)
    local togFrame = Instance.new("Frame")
    togFrame.Size = UDim2.new(1, 0, 0, 34)
    togFrame.BackgroundColor3 = SURFACE
    togFrame.BorderSizePixel = 0
    togFrame.Parent = scroll

    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(0, 6)
    togCorner.Parent = togFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = TEXT
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = togFrame

    local tog = Instance.new("Frame")
    tog.Size = UDim2.new(0, 36, 0, 20)
    tog.Position = UDim2.new(1, -44, 0.5, -10)
    tog.BackgroundColor3 = default and TOG_ON or TOG_OFF
    tog.BorderSizePixel = 0
    tog.Parent = togFrame
    Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = tog
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local isOn = default
    local function updateToggle()
        if isOn then
            tog.BackgroundColor3 = TOG_ON
            circle.Position = UDim2.new(1, -19, 0.5, -8)
        else
            tog.BackgroundColor3 = TOG_OFF
            circle.Position = UDim2.new(0, 3, 0.5, -8)
        end
        callback(isOn)
    end

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.BorderSizePixel = 0
    button.Parent = togFrame

    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggle()
    end)

    task.defer(function() callback(isOn) end)
end

function ui:Button(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = ACCENT
    btn.Text = text
    btn.TextColor3 = TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT_HOVER}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
end

function ui:Textbox(text, default, callback)
    local tbFrame = Instance.new("Frame")
    tbFrame.Size = UDim2.new(1, 0, 0, 50)
    tbFrame.BackgroundColor3 = SURFACE
    tbFrame.BorderSizePixel = 0
    tbFrame.Parent = scroll

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 6)
    tbCorner.Parent = tbFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = SUBTEXT
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tbFrame

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -12, 0, 24)
    inputFrame.Position = UDim2.new(0, 10, 0, 24)
    inputFrame.BackgroundColor3 = INPUT_BG
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = tbFrame
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 4)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -10, 1, 0)
    input.Position = UDim2.new(0, 6, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = tostring(default or "")
    input.TextColor3 = TEXT
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.PlaceholderText = "Ketik nilai..."
    input.PlaceholderColor3 = Color3.fromRGB(80, 80, 95)
    input.ClearTextOnFocus = false
    input.Parent = inputFrame

    input.FocusLost:Connect(function()
        local val = input.Text
        pcall(callback, val)
    end)

    return input
end

function ui:Init()
    local success, result = pcall(function()
        return game:HttpGet(getgitpath("games") .. tostring(game.PlaceId) .. ".lua")
    end)
    if success and result and result ~= "404: Not Found" then
        local gameModule = loadstring(result)()
        gameModule(ui)
    else
        ui:Header("Unsupported Game")
        ui:Label("Belum ada script untuk game ini.")
    end
end

return ui
