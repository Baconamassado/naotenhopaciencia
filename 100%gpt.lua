local ESP = {}
ESP.Players = {}
ESP.Enabled = false
ESP.BoxEnabled = false
ESP.HealthEnabled = false
ESP.NameEnabled = false
ESP.BoxColor = Color3.fromRGB(120, 0, 255)
ESP.NameColor = Color3.fromRGB(255,255,255)
ESP.HealthColor = Color3.fromRGB(0,255,0)
ESP.MaxDistance = 175

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Cria ESP para um jogador
local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = ESP.BoxColor
    box.Visible = false

    local name = Drawing.new("Text")
    name.Text = player.Name
    name.Color = ESP.NameColor
    name.Size = 18
    name.Outline = true
    name.Center = true
    name.Visible = false

    local health = Drawing.new("Square")
    health.Thickness = 0
    health.Filled = true
    health.Color = ESP.HealthColor
    health.Visible = false

    ESP.Players[player] = {Box = box, Name = name, Health = health}
end

-- Atualiza ESP
local function updateESP()
    for player, objects in pairs(ESP.Players) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid

            local distance = (hrp.Position - localHRP.Position).Magnitude

            if ESP.MaxDistance > 0 and distance > ESP.MaxDistance then
                objects.Box.Visible = false
                objects.Name.Visible = false
                objects.Health.Visible = false
                continue
            end
            
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

            if onScreen and ESP.Enabled then
                local size = Vector2.new(40, 40)

                -- Define cor da box baseado no time
                if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    objects.Box.Color = Color3.fromRGB(0, 0, 255) -- Azul (aliado)
                else
                    objects.Box.Color = Color3.fromRGB(255, 0, 0) -- Vermelho (inimigo)
                end

                objects.Box.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
                objects.Box.Size = size
                objects.Box.Visible = ESP.BoxEnabled

                objects.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                objects.Name.Visible = ESP.NameEnabled

                local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local healthSize = Vector2.new(size.X * healthRatio, 5)
                objects.Health.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2 - 10)
                objects.Health.Size = healthSize
                objects.Health.Visible = ESP.HealthEnabled
                objects.Health.Color = Color3.fromHSV(healthRatio/3, 1, 1)
            else
                objects.Box.Visible = false
                objects.Name.Visible = false
                objects.Health.Visible = false
            end
        else
            objects.Box.Visible = false
            objects.Name.Visible = false
            objects.Health.Visible = false
        end
    end
end


-- Inicializa ESP para todos os jogadores
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

RunService.RenderStepped:Connect(updateESP)

-- Funções públicas
function ESP:Toggle(state)
    ESP.Enabled = state
end

function ESP:ToggleBox(state)
    ESP.BoxEnabled = state
end

function ESP:ToggleHealth(state)
    ESP.HealthEnabled = state
end

function ESP:ToggleName(state)
    ESP.NameEnabled = state
end

function ESP:SetColors(boxColor, nameColor, healthColor)
    ESP.BoxColor = boxColor
    ESP.NameColor = nameColor
    ESP.HealthColor = healthColor
    for _, objects in pairs(ESP.Players) do
        objects.Box.Color = boxColor
        objects.Name.Color = nameColor
        objects.Health.Color = healthColor
    end
end

return ESP
