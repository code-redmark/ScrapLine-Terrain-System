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

print('r: '..#Renderers..' s: '..#Samplers)

local function nextSampler()
	currentSampler = (currentSampler % #Samplers) + 1
	return Samplers[currentSampler]
end

local function nextRenderer()
	currentRenderer = (currentRenderer % #Renderers) + 1
	return Renderers[currentRenderer]
end

function CM.SampleChunk(RequestChunkPos: types.Position2D, TerrainOffset, EnvironmentOffset)
	for xOffset = -1, 1 do
		for zOffset = -1, 1 do
			local chunkX = RequestChunkPos.x + xOffset
			local chunkZ = RequestChunkPos.z + zOffset
			-- TODO: check if chunk is already loaded first
			nextSampler():SendMessage('SampleChunk', {x = chunkX, z = chunkZ}, TerrainOffset, EnvironmentOffset)
		end
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

			if state.isChunkActive(aroundX, aroundZ) == nil then  
				print('Unloading chunk at '..aroundX..', '..aroundZ)
				nextSampler():SendMessage('UnloadChunk', ChunkPosition)
			else
				print(state.ActiveChunks)
			end
		end
	end
end




return CM
