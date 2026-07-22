-- L3y Hub | Operation 1 - NATIVE UI (NO EXTERNAL LIBRARY) + ALL FEATURES
-- Copy and run this entire block.

task.wait(3)

-- DRAGGABLE
local function MakeDraggable(gui)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- BYPASS
local function bypass()
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        if method == "Report" or method == "Send" or method == "Track" or method == "Detect" then
            return nil
        end
        return old_namecall(self, ...)
    end
    setreadonly(mt, true)
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "DetectCheat") then
            rawset(v, "DetectCheat", function() return false end)
        end
    end
end
bypass()

-- NO RECOIL
local function noRecoil()
    local mt = getrawmetatable(game)
    local old_index = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if key == "Recoil" or key == "CameraShake" or key == "WeaponRecoil" then
            return 0
        end
        return old_index(self, key)
    end
    setreadonly(mt, true)
    spawn(function()
        while true do
            wait(0.1)
            local player = game.Players.LocalPlayer
            local char = player and player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Recoil") then
                    tool.Recoil = 0
                end
                for _, child in pairs(char:GetDescendants()) do
                    if child:IsA("NumberValue") and child.Name:lower():find("recoil") then
                        child.Value = 0
                    end
                    if child:IsA("Attribute") and child.Name:lower():find("recoil") then
                        child.Value = 0
                    end
                end
            end
        end
    end)
end
noRecoil()

-- STATE
local espEnabled = false
local showLine = true
local showInventory = true
local outlineColor = Color3.fromRGB(255, 0, 0)
local autofireEnabled = false
local aimAssistEnabled = false
local noClipEnabled = false
local triggerbotEnabled = false
local radarEnabled = false
local clientAimEnabled = false
local fovCircleEnabled = false
local hitboxExpanderEnabled = false
local antiFlashEnabled = false
local flyEnabled = false
local hitEffectsEnabled = false
local killAuraEnabled = false
local killAuraRange = 30
local crosshairColor = Color3.fromRGB(255, 255, 255)
local crosshairSize = 20
local fovRadius = 100

-- WEAPONDB
local WeaponDB = {
    AssaultRifles = {"AUG","Famas","L85A2","M16","M4","SCAR-H","AK-12","G36"},
    Shotguns = {"AC-12","M590","SPAS-12"},
    GrenadeLaunchers = {"HK69"},
    SniperRifles = {"AW50","Harrow M82","M24"},
    DesignatedMarksmanRifles = {"L1A1","M14"},
    SubmachineGuns = {"MP5","MP7","Vector","P90"},
    LightMachineGuns = {"M249","M60"},
    PrimaryShields = {"Ballistic Shield","Riot Shield"},
    Pistols = {"MAC-11","Skorpion"},
    Revolvers = {"Anaconda","RSh-12","Reaper"},
    Gadgets = {"Drone","Sticky Camera","Proximity Alarm","C4","Breaching Kit","Gas Mask","Scuba Gear","NVGs","Spec Ops Uniform","Radar Jammer","Smoke Grenade","Flashbang","Grenade"},
    Equipment = {"Armor Plate","Shield","Med Kit","Ammo Pack","Tool Kit","Barbed Wire","Metal Plates","Wall Charges","Repair Tool","Defibrillator","Grappling Hook","Parachute","Binoculars","Laser Designator","Motion Sensor","Claymore","Land Mine"}
}

local ImageDB = {
    ["M4"] = "rbxassetid://1234567894",
    ["AK-12"] = "rbxassetid://1234567896",
    ["G36"] = "rbxassetid://1234567897",
    ["Drone"] = "rbxassetid://1234567920",
    ["C4"] = "rbxassetid://1234567923",
    ["Armor Plate"] = "rbxassetid://1234567933",
    ["Med Kit"] = "rbxassetid://1234567935",
}
local DEFAULT_IMAGE = "rbxassetid://9999999999"

local function getImageForItem(name)
    for item, id in pairs(ImageDB) do
        if name:find(item) or item:find(name) then
            return id
        end
    end
    return DEFAULT_IMAGE
end

local function getFullInventory(char)
    local inv = {Primary="None", Secondary="None", Gadgets={}, Equipment={}, Tools={}}
    if not char then return inv end
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local name = child.Name
            local found = false
            for cat, list in pairs(WeaponDB) do
                if type(list)=="table" then
                    for _, item in pairs(list) do
                        if name:find(item) or item:find(name) then
                            if cat=="AssaultRifles" or cat=="Shotguns" or cat=="GrenadeLaunchers" or cat=="SniperRifles" or cat=="DesignatedMarksmanRifles" or cat=="LightMachineGuns" or cat=="PrimaryShields" then
                                if inv.Primary=="None" then inv.Primary=item else table.insert(inv.Tools,item) end
                            elseif cat=="SubmachineGuns" or cat=="Pistols" or cat=="Revolvers" then
                                if inv.Secondary=="None" then inv.Secondary=item else table.insert(inv.Tools,item) end
                            elseif cat=="Gadgets" then table.insert(inv.Gadgets,item)
                            elseif cat=="Equipment" then table.insert(inv.Equipment,item) end
                            found=true; break
                        end
                    end
                end
                if found then break end
            end
            if not found then table.insert(inv.Tools, name) end
        end
    end
    return inv
end

local function isTeammate(player)
    local localPlayer = game.Players.LocalPlayer
    if player == localPlayer then return true end
    if player.Team and localPlayer.Team and player.Team == localPlayer.Team then return true end
    if player:FindFirstChild("Team") and localPlayer:FindFirstChild("Team") then
        return player.Team.Value == localPlayer.Team.Value
    end
    if player:FindFirstChild("TeamColor") and localPlayer:FindFirstChild("TeamColor") then
        return player.TeamColor.Value == localPlayer.TeamColor.Value
    end
    return false
end

local function addEnvironmentESP()
    local targetNames = {"Barricade","Wooden Barricade","Metal Barricade","Trap","Bear Trap","Tripwire","Proximity Mine","Claymore"}
    local blueColor = Color3.fromRGB(0,0,255)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name
            local shouldOutline = false
            for _, tName in pairs(targetNames) do
                if string.find(name, tName) then shouldOutline = true; break end
            end
            if shouldOutline and not obj:FindFirstChild("ESP_TrapBox") then
                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart")
                local adornee = hrp or obj
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESP_TrapBox"
                box.Size = adornee:IsA("BasePart") and adornee.Size + Vector3.new(1,1,1) or Vector3.new(4,4,4)
                box.Adornee = adornee
                box.Color3 = blueColor
                box.Transparency = 0.3
                box.ZIndex = 10
                box.AlwaysOnTop = true
                box.Parent = adornee
                obj.AncestryChanged:Connect(function()
                    if not obj.Parent then box:Destroy() end
                end)
            end
        end
    end
end

local function createESP(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not head then return end

    local isTeam = isTeammate(player)
    local color = isTeam and Color3.fromRGB(0,255,0) or outlineColor

    local box = Instance.new("BoxHandleAdornment")
    box.Name="ESP_Box"; box.Size=Vector3.new(5,6,3); box.Adornee=hrp; box.Color3=color; box.Transparency=0.2; box.ZIndex=10; box.AlwaysOnTop=true; box.Parent=char

    local nameLabel = Instance.new("BillboardGui")
    nameLabel.Name="ESP_Name"; nameLabel.Adornee=head; nameLabel.Size=UDim2.new(0,200,0,50); nameLabel.StudsOffset=Vector3.new(0,3.5,0); nameLabel.AlwaysOnTop=true
    local text=Instance.new("TextLabel",nameLabel); text.Text=player.Name; text.TextColor3=isTeam and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255); text.TextScaled=true; text.BackgroundTransparency=1; text.Size=UDim2.new(1,0,1,0); nameLabel.Parent=char

    local healthBar = Instance.new("BillboardGui")
    healthBar.Name = "ESP_HealthBar"
    healthBar.Adornee = head
    healthBar.Size = UDim2.new(0, 100, 0, 10)
    healthBar.StudsOffset = Vector3.new(0, 4.0, 0)
    healthBar.AlwaysOnTop = true
    healthBar.Parent = char
    local barBg = Instance.new("Frame", healthBar)
    barBg.Size = UDim2.new(1,0,1,0)
    barBg.BackgroundColor3 = Color3.fromRGB(30,30,30)
    barBg.BorderSizePixel = 0
    local barFill = Instance.new("Frame", healthBar)
    barFill.Name = "HealthFill"
    barFill.Size = UDim2.new(1,0,1,0)
    barFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    barFill.BorderSizePixel = 0

    local healthLabel = Instance.new("BillboardGui")
    healthLabel.Name="ESP_Health"
    healthLabel.Adornee=head
    healthLabel.Size=UDim2.new(0,100,0,30)
    healthLabel.StudsOffset=Vector3.new(0,4.8,0)
    healthLabel.AlwaysOnTop=true
    local hText=Instance.new("TextLabel",healthLabel)
    hText.Text="HP: "..(humanoid and math.floor(humanoid.Health) or "?")
    hText.TextColor3=Color3.fromRGB(255,255,255)
    hText.TextScaled=true
    hText.BackgroundTransparency=1
    hText.Size=UDim2.new(1,0,1,0)
    healthLabel.Parent=char

    local invPanel = Instance.new("BillboardGui")
    invPanel.Name="ESP_InventoryPanel"
    invPanel.Adornee=hrp
    invPanel.Size=UDim2.new(0,400,0,80)
    invPanel.StudsOffset=Vector3.new(0,-2.5,0)
    invPanel.AlwaysOnTop=true
    invPanel.Parent=char
    for i = 1, 4 do
        local frame = Instance.new("Frame", invPanel)
        frame.Size = UDim2.new(0, 60, 0, 60)
        frame.Position = UDim2.new(0, (i-1)*70 + 10, 0, 5)
        frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(255,255,255)
        local img = Instance.new("ImageLabel", frame)
        img.Name = "SlotImage"
        img.Size = UDim2.new(1, -10, 1, -10)
        img.Position = UDim2.new(0, 5, 0, 5)
        img.BackgroundTransparency = 1
        img.Image = DEFAULT_IMAGE
    end

    local line=Instance.new("Attachment"); line.Name="ESP_Line"; line.Parent=hrp
    return {box=box,nameLabel=nameLabel,healthBar=healthBar,healthLabel=healthLabel,invPanel=invPanel,line=line}
end

local function updateESP()
    while espEnabled do
        wait(0.1)
        local localPlayer=game.Players.LocalPlayer
        local localChar=localPlayer.Character
        if not localChar then goto continue end
        local localHrp=localChar:FindFirstChild("HumanoidRootPart")
        if not localHrp then goto continue end
        for _, player in pairs(game.Players:GetPlayers()) do
            if player~=localPlayer and player.Character then
                local char=player.Character
                local hrp=char:FindFirstChild("HumanoidRootPart")
                local head=char:FindFirstChild("Head")
                local humanoid=char:FindFirstChild("Humanoid")
                if hrp and head and humanoid then
                    local healthBar = char:FindFirstChild("ESP_HealthBar")
                    if healthBar then
                        local fill = healthBar:FindFirstChild("HealthFill")
                        if fill then
                            local percent = math.max(humanoid.Health / humanoid.MaxHealth, 0)
                            fill.Size = UDim2.new(percent, 0, 1, 0)
                            fill.BackgroundColor3 = percent > 0.5 and Color3.fromRGB(0,255,0) or (percent > 0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
                        end
                    end
                    local healthLabel = char:FindFirstChild("ESP_Health")
                    if healthLabel then
                        local hText=healthLabel:FindFirstChildOfClass("TextLabel")
                        if hText then
                            hText.Text="HP: "..math.floor(humanoid.Health).."/"..humanoid.MaxHealth
                        end
                    end
                    if showInventory then
                        local inv = getFullInventory(char)
                        local panel = char:FindFirstChild("ESP_InventoryPanel")
                        if panel then
                            local slots = {}
                            for _, child in pairs(panel:GetChildren()) do
                                if child:IsA("Frame") then
                                    local img = child:FindFirstChild("SlotImage")
                                    if img then table.insert(slots, img) end
                                end
                            end
                            local items = {}
                            if inv.Primary ~= "None" then table.insert(items, inv.Primary) end
                            if inv.Secondary ~= "None" then table.insert(items, inv.Secondary) end
                            for _, g in pairs(inv.Gadgets) do table.insert(items, g) end
                            for _, e in pairs(inv.Equipment) do table.insert(items, e) end
                            for _, t in pairs(inv.Tools) do table.insert(items, t) end
                            for i = 1, 4 do
                                if slots[i] then
                                    slots[i].Image = i <= #items and getImageForItem(items[i]) or DEFAULT_IMAGE
                                end
                            end
                        end
                    end
                    if showLine then
                        local line=char:FindFirstChild("ESP_Line")
                        if line then
                            local attach0=localHrp:FindFirstChild("ESP_LineAttach") or Instance.new("Attachment",localHrp)
                            attach0.Name="ESP_LineAttach"
                            local beam=Instance.new("Beam")
                            beam.Name="ESP_Beam"
                            beam.Attachment0=attach0
                            beam.Attachment1=line
                            beam.Color=ColorSequence.new(outlineColor)
                            beam.Transparency=NumberSequence.new(0.3)
                            beam.Width=0.2
                            beam.Parent=workspace
                            game:GetService("Debris"):AddItem(beam,0.15)
                        end
                    end
                end
            end
        end
        spawn(addEnvironmentESP)
        ::continue::
    end
end

local function toggleESP(state)
    espEnabled = state
    if state then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player~=game.Players.LocalPlayer then createESP(player) end
        end
        spawn(updateESP)
    else
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                for _, obj in pairs(player.Character:GetDescendants()) do
                    if obj.Name:find("ESP_") or obj.Name=="ESP_Beam" then obj:Destroy() end
                end
            end
        end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name=="ESP_TrapBox" then obj:Destroy() end
        end
    end
end

local function aimAssistLoop()
    while aimAssistEnabled do
        wait()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end
        local closest = nil
        local closestDist = math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                local targetHead = v.Character.Head
                local pos = targetHead.Position
                local dist = (pos - head.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = v
                end
            end
        end
        if closest and closest.Character and closest.Character:FindFirstChild("Head") then
            local targetPos = closest.Character.Head.Position
            local mouse = player:GetMouse()
            local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetPos)
            if onScreen then
                mousemoverel((screenPos.X - mouse.X) * 0.2, (screenPos.Y - mouse.Y) * 0.2)
            end
        end
    end
end

local function autofireLoop()
    while autofireEnabled do
        wait()
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("Head") then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end
end

local function triggerbotLoop()
    while triggerbotEnabled do
        wait()
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target and target.Parent then
            local head = target.Parent:FindFirstChild("Head")
            if head and target == head then
                local humanoid = target.Parent:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local char = player.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end
    end
end

local function createRadar()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_Radar"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local radarSize = 150
    local radarFrame = Instance.new("Frame", screenGui)
    radarFrame.Size = UDim2.new(0, radarSize, 0, radarSize)
    radarFrame.Position = UDim2.new(0, 10, 0, 10)
    radarFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    radarFrame.BackgroundTransparency = 0.4
    radarFrame.BorderSizePixel = 1
    radarFrame.BorderColor3 = Color3.fromRGB(255,255,255)
    local centerDot = Instance.new("Frame", radarFrame)
    centerDot.Size = UDim2.new(0,3,0,3)
    centerDot.Position = UDim2.new(0.5,-1.5,0.5,-1.5)
    centerDot.BackgroundColor3 = Color3.fromRGB(0,255,0)
    centerDot.BorderSizePixel = 0
    local enemyDots = {}
    while radarEnabled and screenGui.Parent do
        wait(0.1)
        local localPlayer = game.Players.LocalPlayer
        local localChar = localPlayer.Character
        if not localChar then continue end
        local localPos = localChar:FindFirstChild("HumanoidRootPart")
        if not localPos then continue end
        for _, dot in pairs(enemyDots) do dot:Destroy() end
        enemyDots = {}
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local relPos = hrp.Position - localPos.Position
                    local angle = math.atan2(relPos.X, relPos.Z)
                    local dist = math.min(relPos.Magnitude / 50, 1) * (radarSize * 0.4)
                    local cx = radarSize / 2
                    local x = cx + math.sin(angle) * dist
                    local z = cx - math.cos(angle) * dist
                    local dot = Instance.new("Frame", radarFrame)
                    dot.Size = UDim2.new(0,3,0,3)
                    dot.Position = UDim2.new(0, x-1.5, 0, z-1.5)
                    dot.BackgroundColor3 = isTeammate(player) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    dot.BorderSizePixel = 0
                    table.insert(enemyDots, dot)
                end
            end
        end
    end
end

local function clientAimLoop()
    while clientAimEnabled do
        wait()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end
        local closest = nil
        local closestDist = math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                local targetHead = v.Character.Head
                local pos = targetHead.Position
                local dist = (pos - head.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = v
                end
            end
        end
        if closest and closest.Character and closest.Character:FindFirstChild("Head") then
            local targetPos = closest.Character.Head.Position
            local camera = workspace.CurrentCamera
            local direction = (targetPos - camera.CFrame.Position).unit
            local newCFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + direction)
            camera.CFrame = newCFrame
        end
    end
end

local function createFOVCircle()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVCircle"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local circle = Instance.new("Frame", screenGui)
    circle.Name = "CircleFrame"
    circle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    circle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 2
    circle.BorderColor3 = Color3.fromRGB(255,0,0)
    circle.ClipsDescendants = false
    while fovCircleEnabled and screenGui.Parent do
        wait()
        local mouse = game.Players.LocalPlayer:GetMouse()
        circle.Position = UDim2.new(0, mouse.X - fovRadius, 0, mouse.Y - fovRadius)
    end
end

local function expandHitbox()
    while hitboxExpanderEnabled do
        wait(0.5)
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(8,10,5) end
            end
        end
    end
end

local function antiFlash()
    while antiFlashEnabled do
        wait(0.1)
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local flash = head:FindFirstChild("FlashbangEffect")
                if flash then flash:Destroy() end
            end
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui.Name:lower():find("flash") or gui.Name:lower():find("white") then
                    gui:Destroy()
                end
            end
        end
    end
end

local function flyHack()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    local flying = false
    local speed = 50
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
    while flyEnabled do
        wait()
        if not flying then
            flying = true
            humanoid.PlatformStand = true
            bodyVelocity.Parent = hrp
        end
        local move = Vector3.new()
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0,-1,0) end
        if move.Magnitude > 0 then
            move = move.unit * speed
            bodyVelocity.Velocity = move
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end
    if bodyVelocity.Parent then bodyVelocity:Destroy() end
    if humanoid then humanoid.PlatformStand = false end
end

local function createHitEffect(position, damage)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HitEffect"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local label = Instance.new("TextLabel", screenGui)
    label.Text = "-" .. math.floor(damage)
    label.TextColor3 = Color3.fromRGB(255,0,0)
    label.TextScaled = true
    label.Font = Enum.Font.Bold
    label.Size = UDim2.new(0,50,0,30)
    label.BackgroundTransparency = 1
    local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(position)
    if onScreen then
        label.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 15)
    end
    spawn(function()
        for i = 1, 30 do
            wait(0.03)
            label.Position = label.Position - UDim2.new(0,0,0,1)
            label.TextColor3 = Color3.fromRGB(255, 255 - (i * 8), 0)
            label.TextTransparency = i / 30
        end
        label:Destroy()
    end)
end

local function killAuraLoop()
    while killAuraEnabled do
        wait(0.1)
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local closest = nil
        local closestDist = killAuraRange
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character then
                local targetHrp = v.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    local dist = (targetHrp.Position - hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = v
                    end
                end
            end
        end
        if closest and closest.Character then
            local targetHrp = closest.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = closest.Character:FindFirstChild("Humanoid")
            if targetHrp and humanoid and humanoid.Health > 0 then
                local lookAt = CFrame.lookAt(hrp.Position, targetHrp.Position)
                hrp.CFrame = CFrame.new(hrp.Position, lookAt.LookVector * 1000)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    if hitEffectsEnabled then
                        spawn(function()
                            createHitEffect(targetHrp.Position + Vector3.new(0,2,0), math.random(10,30))
                        end)
                    end
                end
            end
        end
    end
end

local function createWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Watermark"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0,200,0,30)
    frame.Position = UDim2.new(1,-210,0,10)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BackgroundTransparency = 0.5
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextScaled = true
    label.Font = Enum.Font.Code
    while true do
        wait(1)
        local fps = math.floor(1 / workspace:GetRealPhysicsFramerate())
        local ping = game:GetService("Stats"):FindFirstChild("Network") and game:GetService("Stats").Network:FindFirstChild("Ping")
        local pingVal = ping and math.floor(ping.Value) or 0
        label.Text = "FPS: " .. fps .. " | Ping: " .. pingVal .. "ms"
    end
end

local function createCrosshair()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomCrosshair"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local crosshair = Instance.new("Frame", screenGui)
    crosshair.Name = "Crosshair"
    crosshair.Size = UDim2.new(0,2,0,crosshairSize)
    crosshair.Position = UDim2.new(0.5,-1,0.5,-crosshairSize/2)
    crosshair.BackgroundColor3 = crosshairColor
    crosshair.BorderSizePixel = 0
    local crosshair2 = Instance.new("Frame", screenGui)
    crosshair2.Name = "Crosshair2"
    crosshair2.Size = UDim2.new(0,crosshairSize,0,2)
    crosshair2.Position = UDim2.new(0.5,-crosshairSize/2,0.5,-1)
    crosshair2.BackgroundColor3 = crosshairColor
    crosshair2.BorderSizePixel = 0
    while true do
        wait(0.1)
        crosshair.BackgroundColor3 = crosshairColor
        crosshair2.BackgroundColor3 = crosshairColor
        crosshair.Size = UDim2.new(0,2,0,crosshairSize)
        crosshair.Position = UDim2.new(0.5,-1,0.5,-crosshairSize/2)
        crosshair2.Size = UDim2.new(0,crosshairSize,0,2)
        crosshair2.Position = UDim2.new(0.5,-crosshairSize/2,0.5,-1)
    end
end

-- NATIVE UI
local function createNativeUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "L3yHub"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 350, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    mainFrame.BackgroundTransparency = 0.1

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "⚡ L3y Hub | Operation 1 ⚡"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextScaled = true
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local scroll = Instance.new("ScrollingFrame", mainFrame)
    scroll.Size = UDim2.new(1, -10, 1, -50)
    scroll.Position = UDim2.new(0, 5, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4

    local y = 5
    local function addToggle(name, callback, default)
        local frame = Instance.new("Frame", scroll)
        frame.Size = UDim2.new(1, -10, 0, 30)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        frame.BackgroundTransparency = 0.5
        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.7, -10, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 255)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 60, 0, 24)
        btn.Position = UDim2.new(1, -70, 0.5, -12)
        btn.Text = default and "ON" or "OFF"
        btn.TextColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(100, 20, 20)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        local corner2 = Instance.new("UICorner", btn)
        corner2.CornerRadius = UDim.new(0, 4)

        local state = default or false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = state and "ON" or "OFF"
            btn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(100, 20, 20)
            callback(state)
        end)

        y = y + 35
        scroll.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        return btn
    end

    MakeDraggable(mainFrame)

    -- TOGGLES
    addToggle("ESP (Wallhack)", function(state) toggleESP(state) end, false)
    addToggle("Show Line to Enemy", function(state) showLine = state end, true)
    addToggle("Show Inventory", function(state) showInventory = state end, true)
    addToggle("Autofire", function(state) autofireEnabled = state; if state then spawn(autofireLoop) end end, false)
    addToggle("Aim Assist", function(state) aimAssistEnabled = state; if state then spawn(aimAssistLoop) end end, false)
    addToggle("No Clip", function(state) 
        noClipEnabled = state
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CanCollide = not state
        end
    end, false)
    addToggle("Triggerbot", function(state) triggerbotEnabled = state; if state then spawn(triggerbotLoop) end end, false)
    addToggle("Radar", function(state) radarEnabled = state; if state then spawn(createRadar) end end, false)
    addToggle("Client Aim", function(state) clientAimEnabled = state; if state then spawn(clientAimLoop) end end, false)
    addToggle("FOV Circle", function(state) fovCircleEnabled = state; if state then spawn(createFOVCircle) end end, false)
    addToggle("Hitbox Expander", function(state) hitboxExpanderEnabled = state; if state then spawn(expandHitbox) end end, false)
    addToggle("Anti-Flash", function(state) antiFlashEnabled = state; if state then spawn(antiFlash) end end, false)
    addToggle("Fly Hack", function(state) flyEnabled = state; if state then spawn(flyHack) else
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if hrp then
                local bv = hrp:FindFirstChild("BodyVelocity")
                if bv then bv:Destroy() end
            end
            if humanoid then humanoid.PlatformStand = false end
        end
    end end, false)
    addToggle("Hit Effects", function(state) hitEffectsEnabled = state end, false)
    addToggle("Kill Aura", function(state) killAuraEnabled = state; if state then spawn(killAuraLoop) end end, false)

    print("Native UI loaded - check your screen")
end

createNativeUI()
spawn(createWatermark)
spawn(createCrosshair)
print("L3y Hub | Operation 1 - Native UI Loaded")
