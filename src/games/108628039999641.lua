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
    local prioritize = true
    local delaySec = 0.4
    local batchSize = 40
    local pickCount = 0
    local staleCount = 0
    local activeSet = nil

    -- Daftar hay id yang masih bisa dipanen menurut server.
    -- Id yang sudah dipanen diam-diam ditolak server (hasil +1/+0).
    -- WAJIB di-refresh berkala karena tiap panen mengubah daftarnya.
    local nActive = 0
    local function refreshActive()
        local ok, state = pcall(function()
            return folder:WaitForChild("GetHayState"):InvokeServer()
        end)
        if ok and type(state) == "table" then
            local list = state.activeIds or state.activeSlots
            if type(list) == "table" then
                local set, n = {}, 0
                for _, id in ipairs(list) do
                    if type(id) == "number" then set[id] = true n = n + 1 end
                end
                activeSet, nActive = set, n
                return true
            end
        end
        return false
    end

    local function isActive(id)
        if activeSet == nil then return true end
        return activeSet[id] == true
    end

    local function nearCount(pos, radius)
        local n = 0
        local op = OverlapParams.new()
        op.MaxParts = 30
        for _, v in ipairs(workspace:GetPartBoundsInRadius(pos, radius, op)) do
            local ok, id = pcall(function() return v:GetAttribute("HayId") end)
            if ok and type(id) == "number" and isActive(id) then
                n = n + 1
            end
        end
        return n
    end

    -- Mutasi hay (dari Config game): hitung client-side, deterministik
    local MUTATIONS = {
        { Name = "Void",     RoundChance = 0.02, CountMin = 1,  CountMax = 1,  ValueMultiplier = 20,   Salt = 991 },
        { Name = "Electric", RoundChance = 0.03, CountMin = 1,  CountMax = 2,  ValueMultiplier = 8,    Salt = 761 },
        { Name = "Gold",     RoundChance = 0.15, CountMin = 2,  CountMax = 4,  ValueMultiplier = 6,    Salt = 647 },
        { Name = "Burnt",    RoundChance = 0.08, CountMin = 2,  CountMax = 3,  ValueMultiplier = 4,    Salt = 541 },
        { Name = "Glass",    RoundChance = 0.35, CountMin = 4,  CountMax = 6,  ValueMultiplier = 3,    Salt = 433 },
        { Name = "Muddy",    RoundChance = 0.6,  CountMin = 6,  CountMax = 9,  ValueMultiplier = 2,    Salt = 317 },
        { Name = "Grassy",   RoundChance = 0.8,  CountMin = 8,  CountMax = 12, ValueMultiplier = 1.5,  Salt = 211 },
        { Name = "Damp",     RoundChance = 1,    CountMin = 10, CountMax = 15, ValueMultiplier = 1.25, Salt = 101 },
    }
    local TOTAL_HAY = 100000
    local PLACEMENT_SEED = 8242026
    local RAINBOW_CHANCE = 0.0025
    local mutCache, mutSeed = {}, nil

    local function frac(x) return x - math.floor(x) end

    local function getMutSeed()
        return tonumber(folder:GetAttribute("MutationSeed")) or PLACEMENT_SEED
    end

    local function buildMutationRound()
        local seed = getMutSeed()
        if mutSeed == seed then return mutCache end
        mutSeed, mutCache = seed, {}
        for _, v in ipairs(MUTATIONS) do
            if v.RoundChance > 0 and frac(math.sin(v.Salt * 17.119 + seed * 0.00037 + 413.57) * 24634.6345) < v.RoundChance then
                local count = v.CountMin + math.floor(frac(math.sin((v.Salt + 37) * 17.119 + seed * 0.00037 + 413.57) * 24634.6345) * (v.CountMax - v.CountMin + 1))
                local span = math.floor(TOTAL_HAY * (v.MaxDepthFraction or 1))
                local per = math.max(1, math.floor(span / count))
                for i2 = 1, count do
                    local lo = math.floor((i2 - 1) * span / count) + 1
                    local range = math.max(1, math.floor(i2 * span / count) - lo + 1)
                    local idx = lo + math.floor(frac(math.sin((v.Salt + i2 * 101) * 17.119 + seed * 0.00037 + 413.57) * 24634.6345) * range)
                    local tries = 0
                    while mutCache[idx] and tries < TOTAL_HAY do
                        idx = idx % TOTAL_HAY + 1
                        tries = tries + 1
                    end
                    if tries < TOTAL_HAY then mutCache[idx] = v.Name end
                end
            end
        end
        return mutCache
    end

    local function mutationValue(id)
        if type(id) ~= "number" then return 1, "Normal" end
        id = math.floor(id)
        if id < 1 or id > TOTAL_HAY then return 1, "Normal" end
        if frac(math.sin(id * 7.31413 + getMutSeed() * 0.00037 + 1913.77) * 24634.6345) < RAINBOW_CHANCE then
            return 10, "Rainbow"
        end
        local name = buildMutationRound()[id] or "Normal"
        for _, v in ipairs(MUTATIONS) do
            if v.Name == name then return v.ValueMultiplier, name end
        end
        return 1, "Normal"
    end

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

    -- Scan rendered hay; kalau prioritize nyala, urutkan dari pengali tertinggi.
    -- Ambil sampel secukupnya (bukan full-scan) biar tiap batch cepat.
    local function scanHay(maxCount)
        local out = {}
        local cap = math.max(maxCount, 40) * 8
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                local ok, id = pcall(function() return d:GetAttribute("HayId") end)
                if ok and type(id) == "number" and isActive(id) then
                    local mult, mut = 1, "Normal"
                    if prioritize then mult, mut = mutationValue(id) end
                    table.insert(out, { id = id, pos = d.Position, mult = mult, mut = mut })
                    if #out >= cap then break end
                end
            end
        end
        if prioritize then
            table.sort(out, function(a, b)
                if a.mult == b.mult then return a.id < b.id end
                return a.mult > b.mult
            end)
            while #out > maxCount do table.remove(out) end
        else
            while #out > maxCount do table.remove(out) end
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
            if ok and type(id) == "number" and id ~= excludeId and isActive(id) then
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

    ui:Toggle("Prioritaskan hay mahal", true, function(bool)
        prioritize = bool
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
        refreshActive()
        pickCount, staleCount = 0, 0
        ui:SetStatus("Farm x" .. gc .. " (cd " .. cd .. "s)...", true)

        while farming do
            goNearPile()
            refreshActive()
            local okS, batch = pcall(scanHay, batchSize)
            if not okS then
                ui:SetStatus("Scan err: " .. tostring(batch):sub(1, 60), true)
                task.wait(1)
            elseif #batch == 0 then
                ui:SetStatus("Tidak ada hay ter-render, tunggu...", true)
                task.wait(2)
            else
                -- Server hanya terima pick dalam ~20 stud: filter yang dekat,
                -- kalau tidak ada, teleport ke hay terdekat lalu ulangi
                local hrp0 = getHrp()
                local near = {}
                if hrp0 then
                    for _, h in ipairs(batch) do
                        if (h.pos - hrp0.Position).Magnitude <= 18 then
                            table.insert(near, h)
                        end
                    end
                end

                if #near == 0 then
                    local closest, cd = nil, 1e9
                    for _, h in ipairs(batch) do
                        local d = hrp0 and (h.pos - hrp0.Position).Magnitude or 1e9
                        if d < cd then cd, closest = d, h end
                    end
                    if closest and hrp0 then
                        hrp0.CFrame = CFrame.new(closest.pos + Vector3.new(0, 6, 0))
                        ui:SetStatus("Pindah spot...", true)
                        task.wait(0.6)
                    else
                        task.wait(2)
                    end
                else
                    for _, h in ipairs(near) do
                        if not farming then break end
                        -- Tiap pick dibungkus pcall biar 1 error tidak membunuh loop.
                        -- Yield dilacak: kalau 3x beruntun zonk, refresh active set.
                        local heldBefore = numAttr("HayHeld", 0)
                        local ok, err = pcall(function()
                            -- Tangan penuh? jual dulu kalau auto sell nyala
                            if selling and numAttr("HayHeld", 0) >= numAttr("HayCapacity", 25) - gc then
                                doSell()
                                goNearPile()
                            end
                            local cands = grabCandidates(h.pos, h.id, gc - 1, gr)
                            PickHay:FireServer(h.id, cands)
                        end)
                        if not ok then
                            ui:SetStatus("Err: " .. tostring(err):sub(1, 60), true)
                        else
                            local gained = numAttr("HayHeld", 0) - heldBefore
                            pickCount = pickCount + 1
                            if gained >= gc then
                                staleCount = 0
                            else
                                -- Hasil parsial (+1..+4) = kandidat basi -> refresh
                                staleCount = staleCount + 1
                            end
                            if staleCount >= 2 then
                                staleCount = 0
                                refreshActive()
                                ui:SetStatus("Refresh state (" .. nActive .. ")... | " .. stats(), true)
                                break
                            end
                            ui:SetStatus("Farm #" .. pickCount .. " x" .. gc .. " #" .. h.id .. " (" .. h.mut .. " x" .. h.mult .. " +" .. gained .. ") | " .. stats(), true)
                        end
                        task.wait(delaySec)
                    end
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
