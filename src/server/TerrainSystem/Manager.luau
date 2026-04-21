local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)
local state = require(game.ServerScriptService.Server.TerrainSystem.State.StateModule)

local CM = {}

local Samplers: {Actor} = {}
local currentSampler = 0

local Renderers: {Actor} = {}
local currentRenderer = 0

-- Make Samplers
for i = 1, variables.GENERATION_SAMPLERS do
	local actor = Instance.new('Actor')
	local samplerScript = game.ServerScriptService.Server.TerrainSystem.Sampling.SamplerScript:Clone()
	actor.Parent = game.ServerScriptService.Server.TerrainSystem.Units.Samplers
	samplerScript.Parent = actor
	samplerScript.Enabled = true
	
	table.insert(Samplers, actor)
end

-- Make Renderers
for i = 1, variables.GENERATION_RENDERERS do
	local actor = Instance.new('Actor')
	local rendererScript = game.ServerScriptService.Server.TerrainSystem.Rendering.RendererScript:Clone()
	actor.Parent = game.ServerScriptService.Server.TerrainSystem.Units.Renderers
	rendererScript.Parent = actor
	rendererScript.Enabled = true
	
	table.insert(Renderers, actor)
end

local function nextSampler()
	currentSampler = (currentSampler % #Samplers) + 1
	return Samplers[currentSampler]
end

local function nextRenderer()
	currentRenderer = (currentRenderer % #Renderers) + 1
	return Renderers[currentRenderer]
end

function CM.SampleChunk(RequestChunkPos: types.Position2D, TerrainOffset, EnvironmentOffset)


	-- Priority order: center first, then orthogonals, then diagonals
	local offsets = {
		{0,0},
		{-1,0},{1,0},{0,-1},{0,1},
		{-1,-1},{1,-1},{-1,1},{1,1}
	}

	local targets = {}
	for _, off in ipairs(offsets) do
		local chunkX = RequestChunkPos.x + off[1]
		local chunkZ = RequestChunkPos.z + off[2]
		if not state.isChunkLoaded(chunkX, chunkZ) and not state.isChunkSampling(chunkX, chunkZ) then
			state.markChunkSampling(chunkX, chunkZ)
			table.insert(targets, {x = chunkX, z = chunkZ})
		end
	end

	if #targets == 0 then return end

	-- Dispatch prioritized samples immediately
	for _, coords in ipairs(targets) do
		nextSampler():SendMessage('SampleChunk', coords, TerrainOffset, EnvironmentOffset)
	end
end

function CM.RenderChunk(ChunkPosition: types.Position2D, TerrainMap: {types.TerrainSample}, EnvironmentMap: {types.EnvironmentSample})
	nextRenderer():SendMessage('RenderChunkTerrain', ChunkPosition, TerrainMap)
	nextRenderer():SendMessage('RenderChunkEnvironment', ChunkPosition, EnvironmentMap)
end

--[[
	Goes through the given chunk and its 8 adjacent chunks, for
	each inactive chunk the chunk is unloaded
]]--
function CM.UnloadInactive(ChunkPosition: types.Position2D)
	for xOffset = -1, 1 do
		for zOffset = -1, 1 do
			local aroundX = ChunkPosition.x + xOffset
			local aroundZ = ChunkPosition.z + zOffset

			if not state.isChunkActive(aroundX, aroundZ) then
				-- clear authoritative loaded/sampling flags before instructing renderer to clear terrain
				state.unmarkChunkLoaded(aroundX, aroundZ)
				state.unmarkChunkSampling(aroundX, aroundZ)
				nextRenderer():SendMessage('UnloadChunk', {x = aroundX, z = aroundZ})
			end
		end
	end
end




return CM
