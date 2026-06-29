-- Mount Game

return function(ui)
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer

    local cps = {}
    for i = 0, 21 do
        cps[i] = CFrame.new()
    end
    cps[0]  = CFrame.new(-15, 25.435009002685548, 25, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    cps[1]  = CFrame.new(-20, 42.3125, -1045, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    cps[2]  = CFrame.new(372, 294.5235290527344, -2030, 0.9146232008934021, 0, -0.4043073356151581, 0, 1, 0, 0.4043073356151581, 0, 0.9146232008934021)
    cps[3]  = CFrame.new(385, 293.78125, -3020.999755859375, 0.8943938612937927, 0, -0.44728031754493716, 0, 1, 0, 0.44728031754493716, 0, 0.8943938612937927)
    cps[4]  = CFrame.new(-419.449462890625, 292.90625, -3719.3388671875, 0.6874574422836304, 0, -0.7262246608734131, 0, 1, 0, 0.7262246608734131, 0, 0.6874574422836304)
    cps[5]  = CFrame.new(-540.033935546875, 294.8125, -4767.44140625, 0.3242985010147095, 0, 0.9459547996520996, 0, 1, 0, -0.9459547996520996, 0, 0.3242985010147095)
    cps[6]  = CFrame.new(-401.99951171875, 679.203125, -5176.0009765625, 0.985408365726471, 0, 0.1702069491147995, 0, 1, 0, -0.1702069491147995, 0, 0.985408365726471)
    cps[7]  = CFrame.new(60, 680.125, -6023.0009765625, 0.9408937096595764, 0, 0.338701993227005, 0, 1, 0, -0.338701993227005, 0, 0.9408937096595764)
    cps[8]  = CFrame.new(841.9995727539063, 425.40625, -6804, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    cps[9]  = CFrame.new(1590.0001220703126, 424.171875, -6537, 0.9999937415122986, 0, 0.0035372376441955568, 0, 1, 0, -0.0035372376441955568, 0, 0.9999937415122986)
    cps[10] = CFrame.new(2226.59814453125, 1251.3125, -6426.65625, -0.2598099708557129, 0, 0.9656597971916199, 0, 1, 0, -0.9656597971916199, 0, -0.2598099708557129)
    cps[11] = CFrame.new(3119.551513671875, 1042.5625, -6256.40625, 0.8185842037200928, 0, 0.5743865370750427, 0, 1, 0, -0.5743865370750427, 0, 0.8185842037200928)
    cps[12] = CFrame.new(3940.944580078125, 1043.4375, -6623.72119140625, -0.2598099708557129, 0, 0.9656597971916199, 0, 1, 0, -0.9656597971916199, 0, -0.2598099708557129)
    cps[13] = CFrame.new(4617.0791015625, 1044.453125, -5996.47802734375, -0.7078604698181152, 0, 0.7063522338867188, 0, 1, 0, -0.7063522338867188, 0, -0.7078604698181152)
    cps[14] = CFrame.new(5280.8759765625, 1416.484375, -5660.8310546875, -0.7359836101531982, 0, 0.6769993901252747, 0, 1, 0, -0.6769993901252747, 0, -0.7359836101531982)
    cps[15] = CFrame.new(5816.79541015625, 1416.265625, -4856.607421875, -0.7944316864013672, 0, 0.6073541045188904, 0, 1, 0, -0.6073541045188904, 0, -0.7944316864013672)
    cps[16] = CFrame.new(6534.30615234375, 1662.359375, -4379.53857421875, -0.38431692123413088, 0, 0.9232012629508972, 0, 1, 0, -0.9232012629508972, 0, -0.38431692123413088)
    cps[17] = CFrame.new(7065, 1661, -4086, -0.5387980937957764, 0, 0.8424350619316101, 0, 1, 0, -0.8424350619316101, 0, -0.5387980937957764)
    cps[18] = CFrame.new(7350.1962890625, 2155.828125, -3840.182861328125, -0.9542553424835205, 0, 0.29899320006370547, 0, 1, 0, -0.29899320006370547, 0, -0.9542553424835205)
    cps[19] = CFrame.new(7794.9775390625, 2155.6875, -3115.046142578125, -0.04537475109100342, 0, 0.998970091342926, 0, 1, 0, -0.998970091342926, 0, -0.04537475109100342)
    cps[20] = CFrame.new(8646, 2155.015625, -3003.000244140625, -0.008770346641540528, 0, 0.9999614953994751, 0, 1, 0, -0.9999614953994751, 0, -0.008770346641540528)
    cps[21] = CFrame.new(9017.9873046875, 2397.5, -3006.50048828125, -0.008770346641540528, 0, 0.9999614953994751, 0, 1, 0, -0.9999614953994751, 0, -0.008770346641540528)

    local CP_TOTAL = 21
    local running = false
    local delaySec = 5
    local autoBC = false

    local function getHrp()
        if plr.Character then
            return plr.Character:FindFirstChild("HumanoidRootPart")
        end
    end

    local function findCurrentCP()
        local hrp = getHrp()
        if not hrp then return 0 end

        local pos = hrp.Position
        local closest = 0
        local closestDist = (pos - cps[0].Position).Magnitude

        for i = 1, CP_TOTAL do
            local dist = (pos - cps[i].Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = i
            end
        end

        return closest
    end

    ui:Header("Auto Summit")

    ui:Label("Delay antar checkpoint (detik)")
    local delayInput = ui:Textbox("Delay (detik)", "5", function(val)
        local num = tonumber(val)
        if num and num > 0 then
            delaySec = num
        end
    end)

    local autoBCToggle
    autoBCToggle = ui:Toggle("Auto BC setelah summit", false, function(bool)
        autoBC = bool
    end)

    local currentCP = findCurrentCP()
    ui:Label("CP terdekat: " .. currentCP .. "/" .. CP_TOTAL)

    ui:Toggle("Mulai Auto Summit", false, function(bool)
        running = bool

        if not running then
            ui:SetStatus("Idle", false)
            return
        end

        ui:SetStatus("Auto Summit berjalan...", true)

        while running do
            local hrp = getHrp()
            if not hrp then
                task.wait(1)
                continue
            end

            local startCP = findCurrentCP()
            if startCP >= CP_TOTAL then
                startCP = 0
            end

            for i = startCP, CP_TOTAL do
                if not running then break end

                hrp = getHrp()
                if not hrp then break end

                hrp.CFrame = cps[i]
                ui:SetStatus("Checkpoint " .. i .. "/" .. CP_TOTAL, true)

                if i == CP_TOTAL then
                    ui:SetStatus("Puncak tercapai! 🏔️", true)
                end

                for remaining = delaySec, 1, -1 do
                    if not running then break end
                    task.wait(1)
                end
            end

            if autoBC and running then
                hrp = getHrp()
                if hrp then
                    hrp.CFrame = cps[0]
                    ui:SetStatus("Balik ke basecamp...", false)
                    task.wait(2)
                end
            end
        end

        ui:SetStatus("Idle", false)
    end)

    ui:Button("Reset ke Basecamp", function()
        local hrp = getHrp()
        if hrp then
            hrp.CFrame = cps[0]
            ui:SetStatus("Teleport ke basecamp", false)
        end
    end)
end
