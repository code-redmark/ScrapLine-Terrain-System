local Voxel = require(game.ServerScriptService.Server.TerrainSystem.Rendering.VoxelModule)

local actor = script:GetActor()

actor:BindToMessageParallel('RenderChunkTerrain', function(ChunkPosition, TerrainMap) 
	Voxel.RenderChunkTerrain(ChunkPosition, TerrainMap) 
end)

actor:BindToMessageParallel('RenderChunkEnvironment', function(ChunkPosition, EnvironmentMap) 
	Voxel.RenderChunkEnvironment(ChunkPosition, EnvironmentMap)
end)