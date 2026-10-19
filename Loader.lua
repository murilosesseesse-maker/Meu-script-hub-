-- ==========================================
-- SISTEMA DE KEY
-- ==========================================
local KeyCorreta = "murilo" -- 👈 TROQUE PELA SUA SENHA
local LinkDoMenu = "https://raw.githubusercontent.com/murilosesseesse-maker/Meu-script-hub-/main/Script.lua" -- Link do seu menu principal

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Se já acertou a key nesta sessão, abre o menu direto
if getgenv().FPS_HUB_KEY_VERIFICADA then
    loadstring(game:HttpGet(LinkDoMenu))()
    return
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ================== CONTAINERS ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 220)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
main.BorderSizePixel = 0
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(130, 110, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🔒 Acesso Restrito"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = main

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.8, 0, 0, 42)
textBox.Position = UDim2.new(0.1, 0, 0.25, 0)
textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Digite a Key aqui..."
textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
textBox.Text = ""
textBox.TextSize = 16
textBox.Font = Enum.Font.Gotham
textBox.BorderSizePixel = 0
textBox.Parent = main
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 42)
button.Position = UDim2.new(0.1, 0, 0.55, 0)
button.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
button.Text = "Verificar Key"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Parent = main
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = main

-- Lógica do Botão
button.MouseButton1Click:Connect(function()
    if textBox.Text == KeyCorreta then
        -- Acertou a key!
        statusLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
        statusLabel.Text = "Key correta! Carregando menu..."
        button.BackgroundColor3 = Color3.fromRGB(30, 60, 42)
        textBox.TextEditable = false
        button.Text = "Carregando..."
        
        getgenv().FPS_HUB_KEY_VERIFICADA = true
        
        task.wait(1)
        screenGui:Destroy()
        loadstring(game:HttpGet(LinkDoMenu))()
    else
        -- Errou a key
        statusLabel.Text = "Key incorreta. Tente novamente."
        textBox.Text = ""
        textBox.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        task.wait(1)
        textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    end
end)
