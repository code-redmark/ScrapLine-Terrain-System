local sharedVars = require(game.ReplicatedStorage.Shared.SharedVariables)
if not sharedVars.INFINITE_WORLD then return end

local plr = game:GetService("Players").LocalPlayer 
local request = game.ReplicatedStorage.Events.RequestChunk
local RunServ = game:GetService("RunService")

local function WorldToChunkPos(wX, wZ)
    local ChunkX = math.floor(wX / (sharedVars.CELL_SIZE * sharedVars.CELLS_PER_CHUNKSIDE))
    local ChunkZ = math.floor(wZ / (sharedVars.CELL_SIZE * sharedVars.CELLS_PER_CHUNKSIDE))
    return { x = ChunkX, z = ChunkZ}
end

task.wait(3) -- Wait for the character to load and be in the world before sending the first request

local lastX = nil
local lastZ = nil

RunServ.Heartbeat:Connect(function()
    local ChunkPosition = WorldToChunkPos(plr.Character.PrimaryPart.Position.X, plr.Character.PrimaryPart.Position.Z)
    if sharedVars.PRELOADED == false or (math.abs(ChunkPosition.x) > sharedVars.PRELOAD_RADIUS and math.abs(ChunkPosition.z) > sharedVars.PRELOAD_RADIUS) then
        if plr.Character and plr.Character.PrimaryPart then
            if (ChunkPosition.x ~= lastX or ChunkPosition.z ~= lastZ) or (lastX == nil or lastZ == nil) then
                request:FireServer(ChunkPosition)
                lastX = ChunkPosition.x
                lastZ = ChunkPosition.z
            end
        end
    end
end)
