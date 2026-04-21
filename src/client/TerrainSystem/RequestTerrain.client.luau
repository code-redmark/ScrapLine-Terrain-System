local plr = game:GetService("Players").LocalPlayer 
local request = game.ReplicatedStorage.Events.RequestChunk
local vars = require(game.ReplicatedStorage.Shared.SharedVariables)
local RunServ = game:GetService("RunService")

local function WorldToChunkPos(wX, wZ)
    local ChunkX = math.floor(wX / (vars.CELL_SIZE * vars.CELLS_PER_CHUNKSIDE))
    local ChunkZ = math.floor(wZ / (vars.CELL_SIZE * vars.CELLS_PER_CHUNKSIDE))
    return { x = ChunkX, z = ChunkZ}
end

task.wait(3) -- Wait for the character to load and be in the world before sending the first request

local lastX = nil
local lastZ = nil

RunServ.Heartbeat:Connect(function()
    if plr.Character and plr.Character.PrimaryPart then
        local ChunkPosition = WorldToChunkPos(plr.Character.PrimaryPart.Position.X, plr.Character.PrimaryPart.Position.Z)
        if (ChunkPosition.x ~= lastX or ChunkPosition.z ~= lastZ) or (lastX == nil or lastZ == nil) then
            print('old chunk: ', lastX, lastZ)
            print('new chunk: ', ChunkPosition.x, ChunkPosition.z)
            request:FireServer(ChunkPosition)
            lastX = ChunkPosition.x
            lastZ = ChunkPosition.z
        end
    end
end)
