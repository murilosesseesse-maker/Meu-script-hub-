-- ==========================================
-- GERADOR DE KEY DIÁRIA
-- ==========================================
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Calcula a data de hoje (mesma fórmula do seu Loader)
local t = os.date("*t")
local dia = t.day
local mes = t.month
local keyHoje = "MURILO-" .. tostring((dia * mes) + 123)

-- Criando a Interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeyGenerator"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 160)
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
title.Text = "🔑 Sua Key de Hoje"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = main

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0.8, 0, 0, 40)
keyLabel.Position = UDim2.new(0.1, 0, 0.3, 0)
keyLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
keyLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
keyLabel.Text = keyHoje
keyLabel.TextSize = 20
keyLabel.Font = Enum.Font.GothamBold
keyLabel.BorderSizePixel = 0
keyLabel.Parent = main
Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0, 8)

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 36)
button.Position = UDim2.new(0.1, 0, 0.65, 0)
button.BackgroundColor3 = Color3.fromRGB(130, 110, 255)
button.Text = "Copiar Key"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Parent = main
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

-- Lógica do Botão de Copiar
button.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(keyHoje)
        button.Text = "Copiada!"
        button.BackgroundColor3 = Color3.fromRGB(30, 60, 42)
        task.wait(2)
        button.Text = "Copiar Key"
        button.BackgroundColor3 = Color3.fromRGB(130, 110, 255)
    else
        button.Text = "Copie manualmente"
    end
end)
