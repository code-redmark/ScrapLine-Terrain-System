--[[
	Handles all chunk requests and splits the generation into Sampling and
	Rendering and then splits both into smaller parts such as Terrain and Environment
	generation
]]--

local ManagerModule = require(script.Parent.Manager)
local ManagerEvents = script.Parent.Events

local Request = game.ReplicatedStorage.Events.RequestChunk
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)
local state = require(game.ServerScriptService.Server.TerrainSystem.State.StateModule)

Request.OnServerEvent:Connect(function(player, ChunkPos: types.Position2D)
	table.insert(state.ActiveChunks, ChunkPos)
	local latest = state.LatestRequests[player.Name]
	if latest == ChunkPos then 
		return 
	else
		state.LatestRequest[player.Name] = ChunkPos
		ManagerModule.OnChunkRequest(ChunkPos)
	end	 
end)

ManagerEvents.ChunkSampled.Event:Connect(function(ChunkPos, TerrainMap, EnvironmentMap)  
	ManagerModule.OnChunkSampled(ChunkPos, TerrainMap, EnvironmentMap) 
end)







