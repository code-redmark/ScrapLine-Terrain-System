local ManagerEvents = game.ServerScriptService.Server.TerrainSystem.Events
local Sampler = require(game.ServerScriptService.Server.TerrainSystem.Sampling.SamplerModule)

local actor = script:GetActor()

actor:BindToMessageParallel('SampleChunk', function(ChunkPosition, TerrainOffset, EnvironmentOffset)

	local TerrainMap, AreaFrequencyMap = Sampler.SampleChunkTerrain(ChunkPosition, TerrainOffset)
	local EnvironmentMap = Sampler.SampleChunkEnvironment(AreaFrequencyMap, EnvironmentOffset)

	task.synchronize()
	ManagerEvents.ChunkSampled:Fire(ChunkPosition, TerrainMap, EnvironmentMap)
	task.desynchronize()
end)
