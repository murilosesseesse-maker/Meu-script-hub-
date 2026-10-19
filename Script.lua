-- ==========================================
-- SCRIPT UNIVERSAL (PC + MOBILE)
-- Basta copiar, colar no executor e dar Play.
-- ==========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Limpeza segura de scripts antigos
if _G.FPS_HUB_CLEANUP then pcall(_G.FPS_HUB_CLEANUP) end
if getgenv and getgenv().FPS_HUB_CLEANUP then pcall(getgenv().FPS_HUB_CLEANUP) end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local BTN_H = isMobile and 46 or 38
local MENU_W = isMobile and 400 or 380 
local FLOAT_SIZE = isMobile and 56 or 52
local OPT_H = isMobile and 40 or 32
local FONT = Enum.Font.GothamBold
local FONT_REG = Enum.Font.Gotham

local MAX_ESP_DISTANCE = 2000
local UI_OFFSET = Vector3.new(0, 2.8, 0)

-- Verifica se a API Drawing existe (para o Skeleton)
local hasDrawing = pcall(function() return Drawing.new("Line") end)

local Colors = {
    Bg = Color3.fromRGB(14, 14, 20),
    BgTop = Color3.fromRGB(22, 22, 32),
    Button = Color3.fromRGB(34, 34, 48),
    ButtonHover = Color3.fromRGB(44, 44, 62),
    Stroke = Color3.fromRGB(50, 50, 72),
    Accent = Color3.fromRGB(130, 110, 255),
    Success = Color3.fromRGB(80, 200, 120),
    SuccessBg = Color3.fromRGB(30, 60, 42),
    Danger = Color3.fromRGB(240, 80, 80),
    DangerBg = Color3.fromRGB(60, 30, 40),
    Text = Color3.fromRGB(235, 235, 245),
    TextDim = Color3.fromRGB(150, 150, 170),
}

local ESP_ColorOptions = {
    {name = "Health", color = nil},
    {name = "White", color = Color3.fromRGB(255, 255, 255)},
    {name = "Red", color = Color3.fromRGB(255, 60, 60)},
    {name = "Green", color = Color3.fromRGB(60, 255, 60)},
    {name = "Blue", color = Color3.fromRGB(60, 150, 255)},
    {name = "Purple", color = Color3.fromRGB(200, 60, 255)},
    {name = "Cyan", color = Color3.fromRGB(60, 255, 255)},
}
local ESP_ColorIndex = 1

local FOV_ColorOptions = {
    {name = "White", color = Color3.fromRGB(255, 255, 255)},
    {name = "Red", color = Color3.fromRGB(255, 60, 60)},
    {name = "Green", color = Color3.fromRGB(60, 255, 60)},
    {name = "Blue", color = Color3.fromRGB(60, 150, 255)},
    {name = "Purple", color = Color3.fromRGB(200, 60, 255)},
    {name = "Cyan", color = Color3.fromRGB(60, 255, 255)},
    {name = "Yellow", color = Color3.fromRGB(255, 255, 60)},
}
local FOV_ColorIndex = 1

-- ================== CONTAINERS ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UI_Menu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "UI_Tracers"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.DisplayOrder = 1
tracerGui.Parent = playerGui

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "UI_FOV"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 2
fovGui.Parent = playerGui

local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "UI_FPS"
fpsGui.ResetOnSpawn = false
fpsGui.IgnoreGuiInset = true
fpsGui.DisplayOrder = 3
fpsGui.Parent = playerGui

-- ================== BOTÃO FLUTUANTE ==================
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.fromOffset(FLOAT_SIZE, FLOAT_SIZE)
toggleButton.Position = UDim2.new(0, 20, 0.5, -25)
toggleButton.BackgroundColor3 = Colors.Button
toggleButton.Text = "" 
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = false
toggleButton.ClipsDescendants = true 
toggleButton.Parent = screenGui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.fromScale(1, 1)
logoImage.Position = UDim2.fromScale(0.5, 0.5)
logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://116484091506817" 
logoImage.Parent = toggleButton
Instance.new("UICorner", logoImage).CornerRadius = UDim.new(1, 0)

local toggleGlow = Instance.new("UIStroke", toggleButton)
toggleGlow.Color = Colors.Accent
toggleGlow.Thickness = 2
toggleGlow.Transparency = 0.5

local pulseConn = RunService.RenderStepped:Connect(function()
    if not toggleGlow.Parent then pulseConn:Disconnect() return end
    local pulse = (math.sin(tick() * 2) + 1) / 2
    toggleGlow.Transparency = 0.3 + pulse * 0.4
end)

-- ================== MENU BASE ==================
local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(MENU_W, 300)
menu.BackgroundColor3 = Colors.Bg
menu.BorderSizePixel = 0
menu.Visible = false
menu.ClipsDescendants = true
menu.Parent = screenGui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 14)

local menuGrad = Instance.new("UIGradient", menu)
menuGrad.Rotation = 90
menuGrad.Color = ColorSequence.new(Colors.BgTop, Colors.Bg)

local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = Colors.Stroke
menuStroke.Thickness = 1

local menuScale = Instance.new("UIScale", menu)
menuScale.Scale = 1

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 0, 40)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✦ MENU"
titleLabel.TextColor3 = Colors.Text
titleLabel.TextSize = isMobile and 17 or 15
titleLabel.Font = FONT
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = menu

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 4)
closeBtn.BackgroundColor3 = Colors.Button
closeBtn.Text = "X"
closeBtn.TextColor3 = Colors.Text
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 5
closeBtn.Parent = menu
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
local closeStroke = Instance.new("UIStroke", closeBtn)
closeStroke.Color = Colors.Stroke
closeStroke.Thickness = 1

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.Danger }):Play()
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.Button }):Play()
    closeBtn.TextColor3 = Colors.Text
end)

local dragHandle = Instance.new("TextButton")
dragHandle.Size = UDim2.new(1, -50, 0, 40)
dragHandle.Position = UDim2.new(0, 0, 0, 0)
dragHandle.BackgroundTransparency = 1
dragHandle.Text = ""
dragHandle.Parent = menu

-- ================== TAB BAR ==================
local TAB_NAMES = { "AIM", "ESP", "COMBAT", "MISC" }
local tabBarY = 46
local tabBarH = 32

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, tabBarH)
tabBar.Position = UDim2.new(0, 10, 0, tabBarY)
tabBar.BackgroundColor3 = Colors.Button
tabBar.BorderSizePixel = 0
tabBar.Parent = menu
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

local tabButtons = {}
for i, name in ipairs(TAB_NAMES) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #TAB_NAMES, 0, 1, 0)
    btn.Position = UDim2.new((i - 1) / #TAB_NAMES, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Colors.TextDim
    btn.TextSize = isMobile and 12 or 10
    btn.Font = FONT
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = tabBar
    tabButtons[i] = btn
end

local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(1 / #TAB_NAMES, -8, 0, 3)
tabIndicator.Position = UDim2.new(0, 4, 1, -4)
tabIndicator.BackgroundColor3 = Colors.Accent
tabIndicator.BorderSizePixel = 0
tabIndicator.Parent = tabBar
Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(1, 0)

-- ================== CONTENT ==================
local contentY = tabBarY + tabBarH + 8
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 0)
content.Position = UDim2.new(0, 0, 0, contentY)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.Parent = menu

-- ================== HELPERS ==================
local function makeSection(parent, text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Colors.Accent
    lbl.TextSize = isMobile and 11 or 10
    lbl.Font = FONT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function makeButton(parent, text, yPos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, BTN_H)
    b.Position = UDim2.new(0, 10, 0, yPos)
    b.BackgroundColor3 = color or Colors.Button
    b.Text = text
    b.TextColor3 = Colors.Text
    b.TextSize = isMobile and 15 or 13
    b.Font = FONT
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Colors.Stroke
    stroke.Thickness = 1

    local pad = Instance.new("UIPadding", b)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)

    return b
end

-- ================== GLOBAL STATES ==================
local teamCheckEnabled = false
local function isEnemy(other)
    if other == player then return false end
    if teamCheckEnabled and other.Team == player.Team then return false end
    return true
end

-- ================== PAGE: AIM ==================
local aimPage = Instance.new("Frame")
aimPage.Size = UDim2.new(1, 0, 0, 0)
aimPage.Position = UDim2.new(0, 0, 0, 0)
aimPage.BackgroundTransparency = 1
aimPage.Parent = content

local aimY = 8
makeSection(aimPage, "Aimbot", aimY)
aimY = aimY + 22

local aimlockToggle = makeButton(aimPage, "Aimlock: OFF", aimY)
aimY = aimY + BTN_H + 8

local aimlockEnabled = false
local aimConnection = nil

local fovFrame = Instance.new("Frame")
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.fromScale(0.5, 0.5)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.Size = UDim2.fromOffset(300, 300)
fovFrame.Visible = false
fovFrame.Parent = fovGui
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovFrame)
fovStroke.Color = FOV_ColorOptions[FOV_ColorIndex].color
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.2

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, -20, 0, 20)
fovLabel.Position = UDim2.new(0, 10, 0, aimY)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV Size"
fovLabel.TextColor3 = Colors.TextDim
fovLabel.TextSize = isMobile and 14 or 12
fovLabel.Font = FONT_REG
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = aimPage

local fovValueLabel = Instance.new("TextLabel")
fovValueLabel.Size = UDim2.new(0, 60, 0, 20)
fovValueLabel.Position = UDim2.new(1, -70, 0, aimY)
fovValueLabel.BackgroundTransparency = 1
fovValueLabel.Text = "150 px"
fovValueLabel.TextColor3 = Colors.Text
fovValueLabel.TextSize = isMobile and 14 or 12
fovValueLabel.Font = FONT
fovValueLabel.TextXAlignment = Enum.TextXAlignment.Right
fovValueLabel.Parent = aimPage
aimY = aimY + 22

local SLIDER_H = isMobile and 14 or 10
local HANDLE_SIZE = isMobile and 24 or 18

local fovSlider = Instance.new("TextButton")
fovSlider.Size = UDim2.new(1, -20, 0, SLIDER_H)
fovSlider.Position = UDim2.new(0, 10, 0, aimY)
fovSlider.BackgroundColor3 = Colors.Button
fovSlider.Text = ""
fovSlider.BorderSizePixel = 0
fovSlider.AutoButtonColor = false
fovSlider.Parent = aimPage
Instance.new("UICorner", fovSlider).CornerRadius = UDim.new(1, 0)

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(0.6, 0, 1, 0)
fovFill.BackgroundColor3 = Colors.Accent
fovFill.BorderSizePixel = 0
fovFill.Parent = fovSlider
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(1, 0)

local fovDot = Instance.new("Frame")
fovDot.Size = UDim2.fromOffset(HANDLE_SIZE, HANDLE_SIZE)
fovDot.Position = UDim2.new(0.6, -HANDLE_SIZE / 2, 0.5, -HANDLE_SIZE / 2)
fovDot.BackgroundColor3 = Colors.Text
fovDot.BorderSizePixel = 0
fovDot.Parent = fovSlider
Instance.new("UICorner", fovDot).CornerRadius = UDim.new(1, 0)

local currentFOV = 150
local MIN_FOV, MAX_FOV = 30, 800
local function updateFOVUI(value)
    currentFOV = math.clamp(value, MIN_FOV, MAX_FOV)
    local alpha = (currentFOV - MIN_FOV) / (MAX_FOV - MIN_FOV)
    fovFill.Size = UDim2.new(alpha, 0, 1, 0)
    fovDot.Position = UDim2.new(alpha, -HANDLE_SIZE / 2, 0.5, -HANDLE_SIZE / 2)
    fovValueLabel.Text = string.format("%d px", math.floor(currentFOV))
end

local sliderDragging = false
fovSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        local rel = (input.Position.X - fovSlider.AbsolutePosition.X) / fovSlider.AbsoluteSize.X
        updateFOVUI(MIN_FOV + rel * (MAX_FOV - MIN_FOV))
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local rel = (input.Position.X - fovSlider.AbsolutePosition.X) / fovSlider.AbsoluteSize.X
        updateFOVUI(MIN_FOV + rel * (MAX_FOV - MIN_FOV))
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)
aimY = aimY + SLIDER_H + 12

local wallCheckEnabled = false 
local wallCheckToggle = makeButton(aimPage, "Wall Check: OFF", aimY, Colors.Button)
aimY = aimY + BTN_H + 8

local fovColorBtn = makeButton(aimPage, "FOV Color: " .. FOV_ColorOptions[FOV_ColorIndex].name, aimY)
fovColorBtn.MouseButton1Click:Connect(function()
    FOV_ColorIndex = (FOV_ColorIndex % #FOV_ColorOptions) + 1
    local newColor = FOV_ColorOptions[FOV_ColorIndex]
    fovColorBtn.Text = "FOV Color: " .. newColor.name
    fovStroke.Color = newColor.color
end)
aimY = aimY + BTN_H + 8
aimPage.Size = UDim2.new(1, 0, 0, aimY)

-- ================== PAGE: ESP ==================
local espPage = Instance.new("Frame")
espPage.Size = UDim2.new(1, 0, 0, 0)
espPage.Position = UDim2.new(0, 0, 0, 0)
espPage.BackgroundTransparency = 1
espPage.Visible = false
espPage.Parent = content

local espY = 8
makeSection(espPage, "Visual", espY)
espY = espY + 22

local espToggle = makeButton(espPage, "ESP: OFF", espY)
espY = espY + BTN_H + 8

local espEnabled = false
local espOptions = { Box = true, Name = true, Distance = true, Line = true, Skeleton = false }
local espCache = {}
local espConnection = nil

local espToggleColor = function(on) return on and Colors.SuccessBg or Colors.Button end

local OPT_GAP = 5
local optW = (MENU_W - 20 - OPT_GAP * 4) / 5

local function makeOptButton(label, xPos, key)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, optW, 0, OPT_H)
    b.Position = UDim2.new(0, 10 + xPos * (optW + OPT_GAP), 0, espY)
    b.BackgroundColor3 = espOptions[key] and Colors.Accent or Colors.Button
    b.Text = label
    b.TextColor3 = Colors.Text
    b.TextSize = isMobile and 11 or 9
    b.Font = FONT
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = espPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        espOptions[key] = not espOptions[key]
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = espOptions[key] and Colors.Accent or Colors.Button
        }):Play()
    end)
end
makeOptButton("Box", 0, "Box")
makeOptButton("Name", 1, "Name")
makeOptButton("Dist", 2, "Distance")
makeOptButton("Line", 3, "Line")
makeOptButton("Skel", 4, "Skeleton")
espY = espY + OPT_H + 8

local espColorBtn = makeButton(espPage, "ESP Color: " .. ESP_ColorOptions[ESP_ColorIndex].name, espY)
espColorBtn.MouseButton1Click:Connect(function()
    ESP_ColorIndex = (ESP_ColorIndex % #ESP_ColorOptions) + 1
    espColorBtn.Text = "ESP Color: " .. ESP_ColorOptions[ESP_ColorIndex].name
end)
espY = espY + BTN_H + 8

espPage.Size = UDim2.new(1, 0, 0, espY)

-- ================== PAGE: COMBAT ==================
local combatPage = Instance.new("Frame")
combatPage.Size = UDim2.new(1, 0, 0, 0)
combatPage.Position = UDim2.new(0, 0, 0, 0)
combatPage.BackgroundTransparency = 1
combatPage.Visible = false
combatPage.Parent = content

local combatY = 8
makeSection(combatPage, "Combo Matador", combatY)
combatY = combatY + 22

local teamCheckToggle = makeButton(combatPage, "Team Check: OFF", combatY)
teamCheckToggle.MouseButton1Click:Connect(function()
    teamCheckEnabled = not teamCheckEnabled
    teamCheckToggle.Text = "Team Check: " .. (teamCheckEnabled and "ON" or "OFF")
    TweenService:Create(teamCheckToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = teamCheckEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
end)
combatY = combatY + BTN_H + 8

local hitboxEnabled = false
local hitboxToggle = makeButton(combatPage, "Hitbox Expander: OFF", combatY)
hitboxToggle.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    hitboxToggle.Text = "Hitbox Expander: " .. (hitboxEnabled and "ON" or "OFF")
    TweenService:Create(hitboxToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = hitboxEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
end)
combatY = combatY + BTN_H + 8

local autoReloadEnabled = false
local autoReloadToggle = makeButton(combatPage, "Auto-Reload: OFF", combatY)
autoReloadToggle.MouseButton1Click:Connect(function()
    autoReloadEnabled = not autoReloadEnabled
    autoReloadToggle.Text = "Auto-Reload: " .. (autoReloadEnabled and "ON" or "OFF")
    TweenService:Create(autoReloadToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = autoReloadEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
end)
combatY = combatY + BTN_H + 8

local noRecoilEnabled = false
local noRecoilToggle = makeButton(combatPage, "No Recoil: OFF", combatY)
noRecoilToggle.MouseButton1Click:Connect(function()
    noRecoilEnabled = not noRecoilEnabled
    noRecoilToggle.Text = "No Recoil: " .. (noRecoilEnabled and "ON" or "OFF")
    TweenService:Create(noRecoilToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = noRecoilEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
end)
combatY = combatY + BTN_H + 8
combatPage.Size = UDim2.new(1, 0, 0, combatY)

-- ================== PAGE: MISC ==================
local miscPage = Instance.new("Frame")
miscPage.Size = UDim2.new(1, 0, 0, 0)
miscPage.Position = UDim2.new(0, 0, 0, 0)
miscPage.BackgroundTransparency = 1
miscPage.Visible = false
miscPage.Parent = content

local miscY = 8
makeSection(miscPage, "Utilidades", miscY)
miscY = miscY + 22

local antiFlingEnabled = false
local antiFlingToggle = makeButton(miscPage, "Anti-Fling: OFF", miscY)
antiFlingToggle.MouseButton1Click:Connect(function()
    antiFlingEnabled = not antiFlingEnabled
    antiFlingToggle.Text = "Anti-Fling: " .. (antiFlingEnabled and "ON" or "OFF")
    TweenService:Create(antiFlingToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = antiFlingEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
end)
miscY = miscY + BTN_H + 8

local antiVoidEnabled = false
local antiVoidToggle = makeButton(miscPage, "Anti-Void: OFF", miscY)
antiVoidToggle.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    antiVoidToggle.Text = "Anti-Void: " .. (antiVoidEnabled and "ON" or "OFF")
    TweenService:Create(antiVoidToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = antiVoidEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
end)
miscY = miscY + BTN_H + 8

local fpsEnabled = false
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.fromOffset(120, 30)
fpsLabel.Position = UDim2.new(1, -130, 0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextStrokeTransparency = 0
fpsLabel.TextSize = 18
fpsLabel.Font = FONT
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
fpsLabel.Parent = fpsGui
fpsLabel.Visible = false

local fpsToggle = makeButton(miscPage, "FPS Counter: OFF", miscY)
fpsToggle.MouseButton1Click:Connect(function()
    fpsEnabled = not fpsEnabled
    fpsToggle.Text = "FPS Counter: " .. (fpsEnabled and "ON" or "OFF")
    TweenService:Create(fpsToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = fpsEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
    fpsLabel.Visible = fpsEnabled
end)
miscY = miscY + BTN_H + 8

local unloadButton = makeButton(miscPage, "Unload / Panic", miscY, Colors.DangerBg)
unloadButton.TextColor3 = Color3.fromRGB(255, 140, 140)
miscY = miscY + BTN_H + 8
miscPage.Size = UDim2.new(1, 0, 0, miscY)

-- ================== TAB SWITCH ==================
local pageHeights = { aimY, espY, combatY, miscY }
local pages = { aimPage, espPage, combatPage, miscPage }
local activeTab = 1
local menuBaseHeight = 0

local function setActiveTab(idx)
    activeTab = idx
    for i, p in ipairs(pages) do p.Visible = (i == idx) end
    for i, b in ipairs(tabButtons) do
        b.TextColor3 = (i == idx) and Colors.Text or Colors.TextDim
    end
    TweenService:Create(tabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Position = UDim2.new((idx - 1) / #TAB_NAMES, 4, 1, -4)
    }):Play()
    local newHeight = contentY + pageHeights[idx] + 8
    menuBaseHeight = newHeight
    TweenService:Create(menu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.fromOffset(MENU_W, newHeight)
    }):Play()
    content.Size = UDim2.new(1, 0, 0, pageHeights[idx])
end

for i, btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function() setActiveTab(i) end)
end

-- ================== LOOP DE PROTEÇÃO E FPS ==================
task.spawn(function()
    while screenGui.Parent do
        task.wait(1)
        if not screenGui.Parent then
            screenGui.Parent = playerGui
        end
        if not toggleButton.Visible then
            toggleButton.Visible = true
        end
    end
end)

local frames, fpsTimer = 0, 0
RunService.RenderStepped:Connect(function(dt)
    frames = frames + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then
        if fpsEnabled then
            fpsLabel.Text = "FPS: " .. tostring(math.floor(frames / fpsTimer))
        end
        frames = 0
        fpsTimer = 0
    end
end)

-- ================== LOGICAS DE COMBATE ==================
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if hitboxEnabled then
                for _, other in ipairs(Players:GetPlayers()) do
                    if isEnemy(other) and other.Character then
                        local head = other.Character:FindFirstChild("Head")
                        if head and not other.Character:FindFirstChild("P") then
                            local hb = Instance.new("Part")
                            hb.Name = "P" 
                            hb.Size = Vector3.new(head.Size.X * 3, head.Size.Y * 3, head.Size.Z * 3)
                            hb.Transparency = 1
                            hb.CanCollide = false
                            hb.Massless = true
                            hb.Parent = other.Character
                            
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = head
                            weld.Part1 = hb
                            weld.Parent = hb
                            hb.CFrame = head.CFrame
                        end
                    end
                end
            else
                for _, other in ipairs(Players:GetPlayers()) do
                    if other.Character then
                        local hb = other.Character:FindFirstChild("P")
                        if hb then hb:Destroy() end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            if autoReloadEnabled and player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local name = obj.Name:lower()
                            if name:find("reload") or name:find("recarregar") or name:find("clip") then
                                pcall(function() obj:FireServer() end)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if noRecoilEnabled and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.CameraOffset = Vector3.new(0, 0, 0)
            end
        end
    end)
end)

-- ================== LOGICAS DE MISC ==================
local lastSafePosition = Vector3.new(0, 50, 0)
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                if hrp.Position.Y > -50 and hrp.Position.Y < 500 then
                    lastSafePosition = hrp.Position
                end
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                if antiVoidEnabled and hrp.Position.Y < -50 then
                    hrp.CFrame = CFrame.new(lastSafePosition + Vector3.new(0, 5, 0))
                end
                if antiFlingEnabled then
                    if hrp.Velocity.Y > 50 or hrp.Velocity.Magnitude > 150 then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.RotVelocity = Vector3.new(0, 0, 0)
                    end
                    for _, v in pairs(player.Character:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then
                            v:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

-- ================== AIM LOGIC ==================
local function hasLineOfSight(targetChar, targetHead)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { camera }
    if player.Character then table.insert(ignore, player.Character) end
    table.insert(ignore, targetChar)
    rp.FilterDescendantsInstances = ignore
    return workspace:Raycast(camera.CFrame.Position, targetHead.Position - camera.CFrame.Position, rp) == nil
end

local function getClosestPlayer()
    local closest, shortest = nil, currentFOV
    local origin = isMobile and Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2) or UserInputService:GetMouseLocation()
    
    for _, other in ipairs(Players:GetPlayers()) do
        if isEnemy(other) and other.Character then
            local head = other.Character:FindFirstChild("Head")
            local hum = other.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local sp, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - origin).Magnitude
                    if d < shortest then
                        if wallCheckEnabled and not hasLineOfSight(other.Character, head) then
                        else
                            shortest = d
                            closest = other
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function aimlockLoop()
    if not aimlockEnabled then return end
    fovFrame.Size = UDim2.fromOffset(currentFOV * 2, currentFOV * 2)
    fovFrame.Visible = true
    local target = getClosestPlayer()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local randomOffset = Vector3.new(math.random(-15, 15) / 100, math.random(-15, 15) / 100, math.random(-15, 15) / 100)
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, head.Position + randomOffset), 0.2)
        end
    end
end

local function setAimlock(state)
    if state == aimlockEnabled then return end
    aimlockEnabled = state
    aimlockToggle.Text = "Aimlock: " .. (state and "ON" or "OFF")
    TweenService:Create(aimlockToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = state and Colors.SuccessBg or Colors.Button
    }):Play()
    if aimConnection then aimConnection:Disconnect() aimConnection = nil end
    if state then
        aimConnection = RunService.RenderStepped:Connect(aimlockLoop)
    else
        fovFrame.Visible = false
        camera.CameraType = Enum.CameraType.Custom
    end
end

aimlockToggle.MouseButton1Click:Connect(function() setAimlock(not aimlockEnabled) end)

wallCheckToggle.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    wallCheckToggle.Text = "Wall Check: " .. (wallCheckEnabled and "ON" or "OFF")
    TweenService:Create(wallCheckToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = wallCheckEnabled and Colors.SuccessBg or Colors.Button
    }):Play()
end)

-- ================== ESP & SKELETON LOGIC ==================
local function drawSkeletonLine(lineObj, p1, p2, color)
    if not lineObj then return end
    lineObj.From = p1
    lineObj.To = p2
    lineObj.Color = color
    lineObj.Visible = true
end

local function createESP(char, head)
    local hl = Instance.new("Highlight")
    hl.Name = "H"
    hl.Adornee = char
    hl.FillTransparency = 0.7
    hl.FillColor = Color3.new(1, 1, 1)
    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Name = "T"
    bb.Adornee = head
    bb.Size = UDim2.fromOffset(140, 40)
    bb.StudsOffset = UI_OFFSET
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.ResetOnSpawn = false
    bb.Parent = char

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "N"
    nameLbl.BackgroundTransparency = 1
    nameLbl.Size = UDim2.new(1, 0, 0, 16)
    nameLbl.Text = ""
    nameLbl.TextColor3 = Colors.Text
    nameLbl.TextSize = 14
    nameLbl.Font = FONT
    nameLbl.TextStrokeTransparency = 0
    nameLbl.Parent = bb

    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "D"
    distLbl.BackgroundTransparency = 1
    distLbl.Size = UDim2.new(1, 0, 0, 14)
    distLbl.Position = UDim2.new(0, 0, 0, 18)
    distLbl.Text = ""
    distLbl.TextColor3 = Colors.Text
    distLbl.TextSize = 12
    distLbl.Font = FONT
    distLbl.TextStrokeTransparency = 0
    distLbl.Parent = bb

    local line = Instance.new("Frame")
    line.Name = "L"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.new(1, 1, 1)
    line.BackgroundTransparency = 0
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 1
    line.Parent = tracerGui

    local lineCorner = Instance.new("UICorner", line)
    lineCorner.CornerRadius = UDim.new(1, 0)

    local skelLines = {}
    if hasDrawing then
        for i = 1, 15 do
            local sl
            pcall(function()
                sl = Drawing.new("Line")
                sl.Thickness = 1.5
                sl.Visible = false
            end)
            if sl then
                table.insert(skelLines, sl)
            end
        end
    end

    return { highlight = hl, billboard = bb, name = nameLbl, distance = distLbl, line = line, skel = skelLines }
end

local function destroyESPFor(p)
    local e = espCache[p]
    if not e then return end
    if e.billboard then e.billboard:Destroy() end
    if e.highlight then e.highlight:Destroy() end
    if e.line then e.line:Destroy() end
    if e.skel then
        for _, sl in pairs(e.skel) do 
            pcall(function() sl:Remove() end)
        end
    end
    espCache[p] = nil
end

local function updateESP()
    for _, other in ipairs(Players:GetPlayers()) do
        pcall(function()
            if not isEnemy(other) then return end
            local char = other.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if not (char and hrp and head and hum and hum.Health > 0) then
                destroyESPFor(other)
                return
            end

            local dist = (camera.CFrame.Position - hrp.Position).Magnitude
            if dist > MAX_ESP_DISTANCE then
                destroyESPFor(other)
                return
            end

            local e = espCache[other]
            if not e or not e.highlight.Parent then
                e = createESP(char, head)
                espCache[other] = e
            end
            local hpRatio = hum.Health / math.max(hum.MaxHealth, 1)
            
            local color = ESP_ColorOptions[ESP_ColorIndex].color
            if not color then 
                color = Color3.fromHSV(hpRatio / 3, 1, 1) 
            end

            e.highlight.Enabled = espOptions.Box
            e.highlight.OutlineColor = color
            e.name.Visible = espOptions.Name
            e.name.Text = other.Name
            e.name.TextColor3 = color
            e.distance.Visible = espOptions.Distance
            e.distance.Text = string.format("%d m", math.floor(dist))
            e.distance.TextColor3 = color

            if espOptions.Line then
                local targetPos = head.Position + UI_OFFSET
                local headScreen, onScreen = camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local origin = Vector2.new(camera.ViewportSize.X / 2, 0)
                    local target = Vector2.new(headScreen.X, headScreen.Y - 10)
                    local delta = target - origin
                    local mid = origin + delta / 2

                    e.line.Visible = true
                    e.line.Position = UDim2.fromOffset(mid.X, mid.Y)
                    e.line.Size = UDim2.fromOffset(delta.Magnitude, isMobile and 1.5 or 1)
                    e.line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                    e.line.BackgroundColor3 = color
                else
                    e.line.Visible = false
                end
            else
                e.line.Visible = false
            end

            if espOptions.Skeleton and hasDrawing then
                local function getScreenPos(part)
                    if not part then return nil end
                    local sp, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then return Vector2.new(sp.X, sp.Y) end
                    return nil
                end

                local connections = {}
                if char:FindFirstChild("UpperTorso") then
                    local h = char:FindFirstChild("Head")
                    local ut = char:FindFirstChild("UpperTorso")
                    local lt = char:FindFirstChild("LowerTorso")
                    local lua = char:FindFirstChild("LeftUpperArm")
                    local lla = char:FindFirstChild("LeftLowerArm")
                    local lh = char:FindFirstChild("LeftHand")
                    local rua = char:FindFirstChild("RightUpperArm")
                    local rla = char:FindFirstChild("RightLowerArm")
                    local rh = char:FindFirstChild("RightHand")
                    local lul = char:FindFirstChild("LeftUpperLeg")
                    local lll = char:FindFirstChild("LeftLowerLeg")
                    local lf = char:FindFirstChild("LeftFoot")
                    local rul = char:FindFirstChild("RightUpperLeg")
                    local rll = char:FindFirstChild("RightLowerLeg")
                    local rf = char:FindFirstChild("RightFoot")

                    connections = {
                        {h, ut}, {ut, lt},
                        {ut, lua}, {lua, lla}, {lla, lh},
                        {ut, rua}, {rua, rla}, {rla, rh},
                        {lt, lul}, {lul, lll}, {lll, lf},
                        {lt, rul}, {rul, rll}, {rll, rf}
                    }
                else
                    local h = char:FindFirstChild("Head")
                    local t = char:FindFirstChild("Torso")
                    local la = char:FindFirstChild("Left Arm")
                    local ra = char:FindFirstChild("Right Arm")
                    local ll = char:FindFirstChild("Left Leg")
                    local rl = char:FindFirstChild("Right Leg")
                    
                    connections = {
                        {h, t},
                        {t, la}, {t, ra},
                        {t, ll}, {t, rl}
                    }
                end

                local lineCount = 0
                for _, pair in ipairs(connections) do
                    local p1, p2 = pair[1], pair[2]
                    if p1 and p2 then
                        local sp1 = getScreenPos(p1)
                        local sp2 = getScreenPos(p2)
                        if sp1 and sp2 then
                            lineCount = lineCount + 1
                            if lineCount <= #e.skel then
                                drawSkeletonLine(e.skel[lineCount], sp1, sp2, color)
                            end
                        end
                    end
                end
                
                for i = lineCount + 1, #e.skel do
                    if e.skel[i] then e.skel[i].Visible = false end
                end
            else
                if e.skel then
                    for _, sl in pairs(e.skel) do 
                        if sl then sl.Visible = false end
                    end
                end
            end
        end)
    end
end

local function setESP(state)
    if state == espEnabled then return end
    espEnabled = state
    espToggle.Text = "ESP: " .. (state and "ON" or "OFF")
    TweenService:Create(espToggle, TweenInfo.new(0.15), {
        BackgroundColor3 = espToggleColor(state)
    }):Play()
    if espConnection then espConnection:Disconnect() espConnection = nil end
    if state then
        espConnection = RunService.RenderStepped:Connect(updateESP)
    else
        for p in pairs(espCache) do destroyESPFor(p) end
    end
end

espToggle.MouseButton1Click:Connect(function() setESP(not espEnabled) end)
Players.PlayerRemoving:Connect(destroyESPFor)

-- ================== UNLOAD ==================
local function unload()
    if aimConnection then aimConnection:Disconnect() aimConnection = nil end
    if espConnection then espConnection:Disconnect() espConnection = nil end
    if pulseConn then pulseConn:Disconnect() pulseConn = nil end
    for p in pairs(espCache) do destroyESPFor(p) end
    
    for _, other in ipairs(Players:GetPlayers()) do
        if other.Character then
            local hb = other.Character:FindFirstChild("P")
            if hb then hb:Destroy() end
        end
    end
    
    fovGui:Destroy()
    tracerGui:Destroy()
    fpsGui:Destroy()
    screenGui:Destroy()
    
    _G.FPS_HUB_CLEANUP = nil
    if getgenv then getgenv().FPS_HUB_CLEANUP = nil end
    print("[UI] Descarregado com sucesso.")
end

unloadButton.MouseButton1Click:Connect(unload)

-- Salva a função de limpeza no _G e getgenv para evitar scripts duplicados
_G.FPS_HUB_CLEANUP = unload
if getgenv then getgenv().FPS_HUB_CLEANUP = unload end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.End then
        unload()
    end
end)

-- ================== DRAG ==================
local function makeDraggable(handle, onDrag, target)
    target = target or handle
    local dragging, wasDragged = false, false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, wasDragged = true, false
            dragStart, startPos = input.Position, target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then wasDragged = true end
        if wasDragged then
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            if onDrag then onDrag() end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return function() return wasDragged end
end

makeDraggable(dragHandle, nil, menu)

local function repositionMenu()
    menu.Position = UDim2.new(
        toggleButton.Position.X.Scale, toggleButton.Position.X.Offset + FLOAT_SIZE + 10,
        toggleButton.Position.Y.Scale, toggleButton.Position.Y.Offset - menuBaseHeight / 2)
end

local wasDraggedToggle = makeDraggable(toggleButton, function()
    if menu.Visible then repositionMenu() end
end)

-- ================== OPEN/CLOSE ==================
local function closeMenu()
    local t = TweenService:Create(menuScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Scale = 0.85 })
    t:Play()
    t.Completed:Once(function() menu.Visible = false end)
end

local function openMenu()
    setActiveTab(activeTab)
    repositionMenu()
    menuScale.Scale = 0.85
    menu.Visible = true
    TweenService:Create(menuScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

closeBtn.MouseButton1Click:Connect(closeMenu)

toggleButton.MouseButton1Click:Connect(function()
    if wasDraggedToggle() then return end
    if menu.Visible then closeMenu() else openMenu() end
end)

-- Aba inicial
setActiveTab(1)
