local sharedVars = require(game.ReplicatedStorage.Shared.SharedVariables)

local vars = {}

--------- Globals ----------------------------------------------------

vars.Loaded = {}

-- TODO: SET SAMPLERS AND RENDERERS BASED ON AMOUNT OF PLAYERS (Example: 16 players * 16 chunks --> 256 samplers, 256 terrain renderers and 128 environment renderers
vars.GENERATION_SAMPLERS = 256
vars.GENERATION_RENDERERS = 384


-- TODO: Wipe feature similar to Rust
vars.HEIGHT_MAP_SEED = nil
vars.BIOME_MAP_SEED = nil
vars.RESOURCE_MAP_SEED = nil

vars.VOXEL_RESOLUTION = 4 -- DONT CHANGE, THIS IS STRICT FOR THE ROBLOX TERRAIN ENGINE


-- Heightmap noise
vars.HM_SCALE = 80
vars.HM_AMPLITUDE = 32
vars.HM_OCTAVES = 3
vars.HM_PERSISTENCE = 0.4
vars.HM_LACUNARITY = 1.5

-- Biomemap noise
vars.BM_SCALE = 3000
vars.BM_AMPLITUDE = 6.5
vars.BM_OCTAVES = 2
vars.BM_PERSISTENCE = 0.5
vars.BM_LACUNARITY = 1.5

-- Resourcemap noise
vars.RM_SCALE = 100
vars.RM_AMPLITUDE = 60

vars.MACROAREAS_PER_CHUNKSIDE = 8

vars.T_SAMPLE_BATCH_SIZE = 3200
vars.E_SAMPLE_BATCH_SIZE = 3200
vars.T_RENDER_BATCH_SIZE = 3200
vars.E_RENDER_BATCH_SIZE = 3200

vars.studChunkHeight = vars.HM_AMPLITUDE * 3 + 1


vars.CELLS_PER_MACROAREA_SIDE = sharedVars.CELLS_PER_CHUNKSIDE / vars.MACROAREAS_PER_CHUNKSIDE


vars.cellsPerChunkSide = nil
if sharedVars.PRELOADED then
	vars.cellsPerChunkSide = sharedVars.PRELOAD_CELLS_PER_CHUNKSIDE
else
	vars.cellsPerChunkSide = sharedVars.CELLS_PER_CHUNKSIDE
end

vars.worldChunkSize = vars.cellsPerChunkSide * sharedVars.CELL_SIZE
vars.worldMacroareaSize = sharedVars.CELL_SIZE * vars.CELLS_PER_MACROAREA_SIDE

-- Preload all materials to know what materials to replace when creating a resource
local BiomeList = require(script.Parent.BiomeList)

vars.materialTable = {}

for i, level in BiomeList do
	for j, biome in level.Biomes do 
		table.insert(vars.materialTable, biome.Material)
	end
end



return vars