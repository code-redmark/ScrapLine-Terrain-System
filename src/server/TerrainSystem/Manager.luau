local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local CM = {}

-- Random Stuff
----------------
local HeightMapGenerator = Random.new()
local BiomeMapGenerator = Random.new()

local ResourceMapGenerator = Random.new()

local TerrainOffset = {
	HeightMap = {
		x = HeightMapGenerator:NextNumber(-10000, 10000),
		z = HeightMapGenerator:NextNumber(-10000, 10000)
	},
	BiomeMap = {
		x = BiomeMapGenerator:NextNumber(-10000, 10000),
		z = BiomeMapGenerator:NextNumber(-10000, 10000)
	}
}

local EnvironmentOffset = {
	ResourceMap = {
		x = ResourceMapGenerator:NextNumber(-10000, 10000),
		z = ResourceMapGenerator:NextNumber(-10000, 10000)
	}
}


----------------

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

function CM.OnChunkRequest(ChunkPosition: types.Position2D)
	nextSampler():SendMessage('SampleChunk', ChunkPosition, TerrainOffset, EnvironmentOffset)
end

function CM.OnChunkSampled(ChunkPosition: types.Position2D, TerrainMap: {types.TerrainSample}, EnvironmentMap: {types.EnvironmentSample})
	nextRenderer():SendMessage('RenderChunkTerrain', ChunkPosition, TerrainMap)
	nextRenderer():SendMessage('RenderChunkEnvironment', ChunkPosition, EnvironmentMap)
end


return CM
