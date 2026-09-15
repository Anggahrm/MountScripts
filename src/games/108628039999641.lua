-- Search For The Needle : Farmhouse (auto farm + auto sell + auto claim)

return function(ui)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local plr = Players.LocalPlayer

    local FOLDER_NAME = "NeedleHaystack"
    local PILE = Vector3.new(-199.18, 2.1, 30.24)
    local SELL_POS = Vector3.new(-164, 6, 56)
    local FARMER_POS = Vector3.new(-162, 5, 18)

    local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
    local PickHay = folder:WaitForChild("PickHay")
    local SellHay = folder:WaitForChild("SellHay")
    local NeedleHandIn = folder:WaitForChild("NeedleHandIn")

    local farming = false
    local selling = false
    local claiming = false
    local delaySec = 0.4
    local batchSize = 40

    local function getHrp()
        if plr.Character then
            return plr.Character:FindFirstChild("HumanoidRootPart")
        end
    end

    local function numAttr(name, fallback)
        local v = tonumber(plr:GetAttribute(name))
        return v or fallback
    end

    local function stats()
        return "Cash: " .. getCash() .. " | Tangan: " .. numAttr("HayHeld", 0)
            .. "/" .. numAttr("HayCapacity", 25) .. " | Sisa: " .. tostring(folder:GetAttribute("RemainingHay"))
    end

    local function getCash()
        local ls = plr:FindFirstChild("leaderstats")
        local c = ls and ls:FindFirstChild("Cash")
        return c and tostring(c.Value) or "?"
    end

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

    -- Server cek jarak (~20 stud), jadi avatar WAJIB dekat pile.
    -- Cukup teleport sekali ke atas pile, tidak perlu per-hay.
    local function goNearPile()
        local hrp = getHrp()
        if hrp and (hrp.Position - PILE).Magnitude > 25 then
            hrp.CFrame = CFrame.new(PILE + Vector3.new(0, 8, 0))
            task.wait(0.5)
        end
    end

    local function doSell()
        local hrp = getHrp()
        if not hrp then return end
        local back = hrp.CFrame
        hrp.CFrame = CFrame.new(SELL_POS)
        task.wait(0.6)
        pcall(function() SellHay:FireServer() end)
        task.wait(0.8)
        hrp.CFrame = back
    end

    ui:Header("Needle Farmhouse")

    ui:Label("Delay antar pick (min 0.35)")
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
        farming = bool
        if not farming then
            ui:SetStatus("Idle", false)
            return
        end

        local gc = numAttr("HayGrabCount", 5)
        local gr = numAttr("HayGrabRadius", 3.8)
        local cd = numAttr("HayPickCooldown", 0.3)
        ui:SetStatus("Farm x" .. gc .. " (cd " .. cd .. "s)...", true)

        while farming do
            goNearPile()
            local batch = scanHay(batchSize)

            if #batch == 0 then
                ui:SetStatus("Tidak ada hay ter-render, tunggu...", true)
                task.wait(2)
            else
                for _, h in ipairs(batch) do
                    if not farming then break end
                    -- Tangan penuh? jual dulu kalau auto sell nyala
                    if selling and numAttr("HayHeld", 0) >= numAttr("HayCapacity", 25) - gc then
                        doSell()
                        goNearPile()
                    end
                    local cands = grabCandidates(h.pos, h.id, gc - 1, gr)
                    pcall(function()
                        PickHay:FireServer(h.id, cands)
                    end)
                    ui:SetStatus("Farm x" .. gc .. " | " .. stats(), true)
                    task.wait(delaySec)
                end
            end
        end

        ui:SetStatus("Idle", false)
    end)

    ui:Toggle("Auto Sell (saat tangan penuh)", false, function(bool)
        selling = bool
        ui:SetStatus(bool and "Auto sell ON" or "Idle", bool)
    end)

    ui:Toggle("Auto Claim Needle", false, function(bool)
        claiming = bool
        if not claiming then
            ui:SetStatus("Idle", false)
            return
        end

        ui:SetStatus("Menunggu needle spawn...", true)

        while claiming do
            local revealed = folder:GetAttribute("NeedleRevealed")
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
                task.wait(1.5)

                -- Serahkan ke farmer (NeedleHandIn), lalu cek hasil
                local hrp2 = getHrp()
                if hrp2 then
                    hrp2.CFrame = CFrame.new(FARMER_POS)
                    task.wait(0.5)
                end
                pcall(function()
                    NeedleHandIn:FireServer()
                end)
                task.wait(1.5)

                if folder:GetAttribute("NeedleClaimed") or plr:GetAttribute("NeedleOwned") then
                    ui:SetStatus("Needle claimed! 🏆", true)
                    claiming = false
                    break
                else
                    ui:SetStatus("Claim dikirim, cek hasil...", true)
                end
            else
                ui:SetStatus("Needle belum spawn (revealed=" .. tostring(revealed) .. ") | " .. stats(), true)
            end

            task.wait(3)
        end

        if not claiming then
            ui:SetStatus("Idle", false)
        end
    end)

    ui:Button("Teleport ke Pile", function()
        local hrp = getHrp()
        if hrp then
            hrp.CFrame = CFrame.new(PILE + Vector3.new(0, 8, 0))
            ui:SetStatus("Di pile | " .. stats(), false)
        end
    end)

    ui:Button("Sell Sekarang", function()
        doSell()
        ui:SetStatus("Sell | " .. stats(), false)
    end)
end
