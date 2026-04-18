local plr = game:GetService("Players").LocalPlayer 
local request = game.ReplicatedStorage.Events.RequestChunk

local lastX = plr.Character.PrimaryPart.Position.X
local lastZ = plr.Character.PrimaryPart.Position.Z

local function distance(x1, x2, z1, z2)
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(z1 - z2, 2))
end

while true do
    task.wait(1)
    local position = {
        x = plr.Character.PrimaryPart.Position.X,
        z = plr.Character.PrimaryPart.Position.Z
    }
    local dist = distance(lastX, position.x, lastZ, position.z)
    if dist > 100 then -- TODO: make relative to chunk size
        request:FireServer(position)
    end
end
