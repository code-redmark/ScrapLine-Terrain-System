local vars = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local sharedVars = require(game.ReplicatedStorage.Shared.SharedVariables)
local state = require(game.ServerScriptService.Server.TerrainSystem.State.StateModule)
local ManagerModule = require(game.ServerScriptService.Server.TerrainSystem.Manager)
local ManagerEvents = game.ServerScriptService.Server.TerrainSystem.Events

local HmGen = Random.new(vars.HEIGHT_MAP_SEED)
local BmGen = Random.new(vars.BIOME_MAP_SEED)
local RmGen = Random.new(vars.RESOURCE_MAP_SEED)

local TerrainOffset = {
    HeightMap = {x = HmGen:NextInteger(0, 100000), z = HmGen:NextInteger(0, 100000)},
    BiomeMap = {x = BmGen:NextInteger(0, 100000), z = BmGen:NextInteger(0, 100000)}
}

local EnvironmentOffset = {
    ResourceMap = {x = RmGen:NextInteger(0, 100000), z = RmGen:NextInteger(0, 100000)},
}

ManagerEvents.ChunkSampled.Event:Connect(function(ChunkPos, TerrainMap, EnvironmentMap)
    -- Authoritative state updates happen in manager context
    state.unmarkChunkSampling(ChunkPos.x, ChunkPos.z)
        state.markChunkLoaded(ChunkPos.x, ChunkPos.z)
        ManagerModule.RenderChunk(ChunkPos, TerrainMap, EnvironmentMap)
end)

local function PreloadWorld() 
    for x = -sharedVars.PRELOAD_RADIUS, sharedVars.PRELOAD_RADIUS do
        for z = -sharedVars.PRELOAD_RADIUS, sharedVars.PRELOAD_RADIUS do
                ManagerModule.SampleChunk({x = x , z = z}, TerrainOffset, EnvironmentOffset)
                task.wait()
        end
    end
end


local start = os.clock()
PreloadWorld()
print("Took "..start - os.clock())
