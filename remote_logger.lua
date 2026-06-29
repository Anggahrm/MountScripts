-- Remote Event Logger + Fire Tool
local rep = game:GetService("ReplicatedStorage")
local hui = gethui or get_hidden_gui

local remotes = {}
for _, v in ipairs(rep:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        table.insert(remotes, v)
    end
end

for _, v in ipairs(remotes) do
    print(v:GetFullName())
end
print("Total: " .. #remotes)

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteLogger"
gui.ResetOnSpawn = false
gui.Parent = hui and hui() or game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(40, 40, 50)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
header.Text = "Remote Events (" .. #remotes .. ")"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local filter = Instance.new("TextBox")
filter.Size = UDim2.new(1, -12, 0, 28)
filter.Position = UDim2.new(0, 6, 0, 38)
filter.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
filter.TextColor3 = Color3.fromRGB(255, 255, 255)
filter.Font = Enum.Font.Gotham
filter.TextSize = 12
filter.PlaceholderText = "Cari (checkpoint, summit, bc...)"
filter.PlaceholderColor3 = Color3.fromRGB(80, 80, 95)
filter.ClearTextOnFocus = false
filter.Text = ""
filter.Parent = frame
Instance.new("UICorner", filter).CornerRadius = UDim.new(0, 4)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -76)
scroll.Position = UDim2.new(0, 6, 0, 70)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = scroll

local function refreshList(search)
    for _, v in ipairs(scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    for _, remote in ipairs(remotes) do
        local name = remote.Name:lower()
        local full = remote:GetFullName()

        if search and search ~= "" then
            if not name:find(search:lower()) and not full:lower():find(search:lower()) then
                continue
            end
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 200, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = remote.Name
        label.TextColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 200, 100)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn

        local typeLabel = Instance.new("TextLabel")
        typeLabel.Size = UDim2.new(0, 60, 1, 0)
        typeLabel.Position = UDim2.new(0, 210, 0, 0)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = remote.ClassName:match("Remote(.+)")
        typeLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
        typeLabel.Font = Enum.Font.Gotham
        typeLabel.TextSize = 10
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        typeLabel.Parent = btn

        local fireBtn = Instance.new("TextButton")
        fireBtn.Size = UDim2.new(0, 50, 1, -4)
        fireBtn.Position = UDim2.new(1, -54, 0, 2)
        fireBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        fireBtn.Text = "Fire"
        fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        fireBtn.Font = Enum.Font.GothamBold
        fireBtn.TextSize = 10
        fireBtn.BorderSizePixel = 0
        fireBtn.Parent = btn
        Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 3)

        fireBtn.MouseButton1Click:Connect(function()
            if remote:IsA("RemoteEvent") then
                local success, err = pcall(function()
                    remote:FireServer(unpack({}))
                end)
                print("Fired:", remote:GetFullName(), success and "OK" or err)
            else
                local success, result = pcall(function()
                    return remote:InvokeServer(unpack({}))
                end)
                print("Invoked:", remote:GetFullName(), success and result or err)
            end
        end)
    end
end

refreshList(nil)

filter:GetPropertyChangedSignal("Text"):Connect(function()
    refreshList(filter.Text)
end)
