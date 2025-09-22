local ESP = {}
ESP.Players = {}
ESP.Enabled = true
ESP.BoxColor = Color3.fromRGB(120, 0, 255)
ESP.NameColor = Color3.fromRGB(255,255,255)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = ESP.BoxColor

    local name = Drawing.new("Text")
    name.Text = player.Name
    name.Color = ESP.NameColor
    name.Size = 18
    name.Outline = true
    name.Center = true

    ESP.Players[player] = {Box = box, Name = name}
end

local function updateESP()
    for player, objects in pairs(ESP.Players) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local size = Vector2.new(50, 100) -- tamanho da caixa
                objects.Box.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
                objects.Box.Size = size
                objects.Box.Visible = ESP.Enabled

                objects.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 60)
                objects.Name.Visible = ESP.Enabled
            else
                objects.Box.Visible = false
                objects.Name.Visible = false
            end
        else
            objects.Box.Visible = false
            objects.Name.Visible = false
        end
    end
end

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

function ESP:Toggle(state)
    ESP.Enabled = state
end

function ESP:SetColors(boxColor, nameColor)
    ESP.BoxColor = boxColor
    ESP.NameColor = nameColor
    for _, objects in pairs(ESP.Players) do
        objects.Box.Color = boxColor
        objects.Name.Color = nameColor
    end
end

return ESP
