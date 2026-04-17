--[[
	Handles all chunk requests and splits the generation into Sampling and
	Rendering and then splits both into smaller parts such as Terrain and Environment
	generation
]]--

local ManagerModule = require(script.Parent.Manager)
local ManagerEvents = script.Parent.Events

local Request = game.ReplicatedStorage.Events.RequestChunk
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

Request.OnServerEvent:Connect(function(player, ChunkPos: types.Position2D)
	ManagerModule.OnChunkRequest(ChunkPos)
end)

ManagerEvents.ChunkSampled.Event:Connect(function(ChunkPos, TerrainMap, EnvironmentMap)  
	-- Terrainmaps good here
	ManagerModule.OnChunkSampled(ChunkPos, TerrainMap, EnvironmentMap) 
end)







