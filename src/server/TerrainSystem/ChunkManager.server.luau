local ManagerModule = require(game.ServerScriptService.Server.TerrainSystem.Manager)
local ManagerEvents = script.Parent.Events

local Request = game.ReplicatedStorage.Events.RequestChunk
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)
local state = require(game.ServerScriptService.Server.TerrainSystem.State.StateModule)
local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)

local HmGen = Random.new(variables.HEIGHT_MAP_SEED)
local BmGen = Random.new(variables.BIOME_MAP_SEED)
local RmGen = Random.new(variables.RESOURCE_MAP_SEED)

local TerrainOffset = {
    HeightMap = {x = HmGen:NextInteger(0, 100000), z = HmGen:NextInteger(0, 100000)},
    BiomeMap = {x = BmGen:NextInteger(0, 100000), z = BmGen:NextInteger(0, 100000)}
}

local EnvironmentOffset = {
    ResourceMap = {x = RmGen:NextInteger(0, 100000), z = RmGen:NextInteger(0, 100000)},
}


Request.OnServerEvent:Connect(function(player, ChunkPos: types.Position2D)
    local userId = player.UserId
    local latest = state.LatestRequests[userId]

    local changed = (latest == nil) or (latest.x ~= ChunkPos.x or latest.z ~= ChunkPos.z)
    if not changed then
        return
    end
    
    local function makeKey(x, z) return x..', '..z end

    -- Build new 3x3 set
    local newSet = {}
    for xOffset = -1, 1 do
        for zOffset = -1, 1 do
            local aroundX = ChunkPos.x + xOffset
            local aroundZ = ChunkPos.z + zOffset
            newSet[makeKey(aroundX, aroundZ)] = {x = aroundX, z = aroundZ}
        end
    end

    -- Build old 3x3 set (if any)
    local oldSet = {}
    if latest then
        for xOffset = -1, 1 do
            for zOffset = -1, 1 do
                local aroundX = latest.x + xOffset
                local aroundZ = latest.z + zOffset
                oldSet[makeKey(aroundX, aroundZ)] = {x = aroundX, z = aroundZ}
            end
        end
    end

    -- Add player to newly needed chunks; detect if any chunk needs sampling
    local needSample = false
    for k, coords in pairs(newSet) do
        -- add (idempotent)
        state.addPlrActiveChunk(coords.x, coords.z, userId)
        if not state.isChunkLoaded(coords.x, coords.z) and not state.isChunkSampling(coords.x, coords.z) then
            needSample = true
        end
    end

    if needSample then
        ManagerModule.SampleChunk(ChunkPos, TerrainOffset, EnvironmentOffset)
    end

    -- Remove player from chunks they no longer require
    if latest then
        for k, coords in pairs(oldSet) do
            if not newSet[k] then
                state.removePlrFromChunk(coords.x, coords.z, userId)
                if not state.isChunkActive(coords.x, coords.z) then
                    ManagerModule.UnloadInactive({x = coords.x, z = coords.z})
                end
            end
        end
    end

    state.LatestRequests[userId] = {x = ChunkPos.x, z = ChunkPos.z}
end)

ManagerEvents.ChunkSampled.Event:Connect(function(ChunkPos, TerrainMap, EnvironmentMap)
    -- Authoritative state updates happen in manager context
    state.unmarkChunkSampling(ChunkPos.x, ChunkPos.z)
    if state.isChunkActive(ChunkPos.x, ChunkPos.z) then
        state.markChunkLoaded(ChunkPos.x, ChunkPos.z)
        ManagerModule.RenderChunk(ChunkPos, TerrainMap, EnvironmentMap)
    else
        -- Chunk became inactive while sampling; skip rendering.
    end
end)
