local plr = game:GetService("Players").LocalPlayer 
local request = game.ReplicatedStorage.Events.RequestChunk
local vars = require(game.ReplicatedStorage.Shared.SharedVariables)

local function WorldToChunkPos(wX, wZ)
    local ChunkX = math.floor(wX / (vars.CELL_SIZE * vars.CELLS_PER_CHUNKSIDE))
    local ChunkZ = math.floor(wZ / (vars.CELL_SIZE * vars.CELLS_PER_CHUNKSIDE))
    return { x = ChunkX, z = ChunkZ}
end

task.wait(3) -- Wait for the character to load and be in the world before sending the first request

local lastX = plr.Character.PrimaryPart.Position.X or plr.Character:WaitForChild('HumanoidRootPart')
local lastZ = plr.Character.PrimaryPart.Position.Z or plr.Character:WaitForChild('HumanoidRootPart')

-- Last request position, if the player is in the same chunk try not to send the request at all

while true do
    task.wait(1.5)
    local pos = plr.Character.PrimaryPart.Position
    local ChunkPosition = WorldToChunkPos(pos.X, pos.Z)
    if ChunkPosition ~= {x = lastX, z = lastZ} then
        request:FireServer(ChunkPosition)
        lastX = ChunkPosition.x
        lastZ = ChunkPosition.z
    end
end
