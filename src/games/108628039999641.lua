-- Search For The Needle : Farmhouse (auto farm + auto claim)

return function(ui)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local plr = Players.LocalPlayer

    local FOLDER_NAME = "NeedleHaystack"
    local PILE = Vector3.new(-199.18, 2.1, 30.24)

    local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
    local PickHay = folder:WaitForChild("PickHay")

    local running = false
    local needleRunning = false
    local delaySec = 0.4
    local batchSize = 40
    local grabCount = 5
    local grabRadius = 3.8

    local GRAB_LEVELS = {
        { Count = 1, Radius = 0 },
        { Count = 2, Radius = 1.35 },
        { Count = 3, Radius = 1.8 },
        { Count = 4, Radius = 2.35 },
        { Count = 5, Radius = 2.9 },
        { Count = 5, Radius = 3.8 },
    }
    local SPEED_COOLDOWNS = { 0.55, 0.5, 0.45, 0.4, 0.35, 0.3 }

    -- Baca level upgrade asli dari server biar count/radius selalu pas
    local function detectUpgrades()
        local ok, state = pcall(function()
            return folder:WaitForChild("GetUpgradeState"):InvokeServer()
        end)
        if ok and type(state) == "table" and type(state.levels) == "table" then
            local g = GRAB_LEVELS[state.levels.Grab] or GRAB_LEVELS[6]
            grabCount, grabRadius = g.Count, g.Radius
            local cd = SPEED_COOLDOWNS[state.levels.Speed]
            return "Grab x" .. grabCount .. " (r=" .. grabRadius .. ")" .. (cd and (" | Speed cd=" .. cd .. "s") or "")
        end
        return nil
    end

    local function getHrp()
        if plr.Character then
            return plr.Character:FindFirstChild("HumanoidRootPart")
        end
    end

    local function getCash()
        local ls = plr:FindFirstChild("leaderstats")
        local c = ls and ls:FindFirstChild("Cash")
        return c and tostring(c.Value) or "?"
    end

    local function getRemaining()
        local r = folder:GetAttribute("RemainingHay")
        return r and tostring(r) or "?"
    end

    -- Scan rendered hay parts, return array of {id, pos}
    local function scanHay(maxCount)
        local out = {}
        for _, d in ipairs(workspace:GetDescendants()) do
            if #out >= maxCount then break end
            if d:IsA("BasePart") then
                local ok, id = pcall(function() return d:GetAttribute("HayId") end)
                if ok and type(id) == "number" then
                    table.insert(out, { id = id, pos = d.Position })
                end
            end
        end
        return out
    end

    -- Nearby hay ids around a position (grab candidates, like the client does)
    local function grabCandidates(pos, excludeId, count, radius)
        local out = {}
        local op = OverlapParams.new()
        op.MaxParts = 24
        for _, v in ipairs(workspace:GetPartBoundsInRadius(pos, radius, op)) do
            if #out >= count then break end
            local ok, id = pcall(function() return v:GetAttribute("HayId") end)
            if ok and type(id) == "number" and id ~= excludeId then
                table.insert(out, id)
            end
        end
        return out
    end

    local function findNeedlePart()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                local ok, v = pcall(function() return d:GetAttribute("IsNeedleObjective") end)
                if ok and v then return d end
            end
        end
        return nil
    end

    local function goNearPile()
        local hrp = getHrp()
        if hrp and (hrp.Position - PILE).Magnitude > 25 then
            hrp.CFrame = CFrame.new(PILE + Vector3.new(0, 8, 0))
            task.wait(0.5)
        end
    end

    ui:Header("Needle Farmhouse")

    ui:Label("Delay antar pick (detik, min 0.35)")
    ui:Textbox("Delay (detik)", "0.4", function(val)
        local num = tonumber(val)
        if num and num >= 0.35 then delaySec = num end
    end)

    ui:Label("Jumlah hay per batch scan")
    ui:Textbox("Batch size", "40", function(val)
        local num = tonumber(val)
        if num and num > 0 and num <= 200 then batchSize = math.floor(num) end
    end)

    ui:Toggle("Auto Farm Hay", false, function(bool)
        running = bool
        if not running then
            ui:SetStatus("Idle", false)
            return
        end

        local info = detectUpgrades()
        ui:SetStatus("Auto farm jalan..." .. (info and (" (" .. info .. ")") or ""), true)

        while running do
            goNearPile()
            local batch = scanHay(batchSize)

            if #batch == 0 then
                ui:SetStatus("Tidak ada hay ter-render, tunggu...", true)
                task.wait(2)
            else
                for _, h in ipairs(batch) do
                    if not running then break end
                    local cands = grabCandidates(h.pos, h.id, grabCount - 1, grabRadius)
                    pcall(function()
                        PickHay:FireServer(h.id, cands)
                    end)
                    ui:SetStatus("Farm | Cash: " .. getCash() .. " | Sisa: " .. getRemaining(), true)
                    task.wait(delaySec)
                end
            end
        end

        ui:SetStatus("Idle", false)
    end)

    ui:Toggle("Auto Claim Needle", false, function(bool)
        needleRunning = bool
        if not needleRunning then
            ui:SetStatus("Idle", false)
            return
        end

        ui:SetStatus("Menunggu needle muncul...", true)

        while needleRunning do
            local part = findNeedlePart()

            if part then
                local hrp = getHrp()
                if hrp then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 4, 0))
                    task.wait(0.4)
                end
                pcall(function()
                    PickHay:FireServer("Objective")
                end)
                ui:SetStatus("Needle ditemukan, claim dikirim!", true)
                task.wait(3)

                if folder:GetAttribute("NeedleClaimed") then
                    ui:SetStatus("Needle claimed! 🏆", true)
                    needleRunning = false
                    break
                end
            end

            task.wait(2)
        end

        if not needleRunning then
            ui:SetStatus("Idle", false)
        end
    end)

    ui:Button("Teleport ke Pile", function()
        local hrp = getHrp()
        if hrp then
            hrp.CFrame = CFrame.new(PILE + Vector3.new(0, 8, 0))
            ui:SetStatus("Di pile | Cash: " .. getCash(), false)
        end
    end)

    ui:Button("Cek Status", function()
        ui:SetStatus("Cash: " .. getCash() .. " | Sisa hay: " .. getRemaining(), false)
    end)
end
