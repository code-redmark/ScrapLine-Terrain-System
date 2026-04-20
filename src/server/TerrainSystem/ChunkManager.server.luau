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
	local latest = state.LatestRequests[player.UserId]
	
	if latest == nil or latest ~= ChunkPos then
		for xOffset = -1, 1 do
			for zOffset = -1, 1 do
				local aroundX = ChunkPos.x + xOffset
				local aroundZ = ChunkPos.z + zOffset

				state.addPlrActiveChunk(aroundX, aroundZ, player.Name)
			end
		end


		ManagerModule.SampleChunk(ChunkPos, TerrainOffset, EnvironmentOffset)

		if (latest) then
			local plrs = -1 -- We dont count the current player whose latest chunk needs to be changed
			for i, v in state.getChunk(latest.x, latest.z) do
				plrs += 1
				if plrs > 0 then break end
			end
			if plrs <= 0 then -- unload
				ManagerModule.UnloadInactive(latest)
				state.removePlrFromChunk(latest.x, latest.z, player.Name)
			end
		end
		
		state.LatestRequests[player.UserId] = ChunkPos
	end


end)

ManagerEvents.ChunkSampled.Event:Connect(function(ChunkPos, TerrainMap, EnvironmentMap)  
	ManagerModule.RenderChunk(ChunkPos, TerrainMap, EnvironmentMap) 
end)







