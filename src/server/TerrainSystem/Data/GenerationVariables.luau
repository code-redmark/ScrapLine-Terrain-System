local sharedVars = require(game.ReplicatedStorage.Shared.SharedVariables)

local vars = {}

--------- Globals ----------------------------------------------------

vars.Loaded = {}

-- TODO: SET SAMPLERS AND RENDERERS BASED ON AMOUNT OF PLAYERS (Example: 16 players * 16 chunks --> 256 samplers, 256 terrain renderers and 128 environment renderers
vars.GENERATION_SAMPLERS = 256
vars.GENERATION_RENDERERS = 384

vars.HEIGHT_MAP_SEED = nil
vars.BIOME_MAP_SEED = nil
vars.RESOURCE_MAP_SEED = nil

-- Chunk System variable, represents studs
vars.CELLS_PER_CHUNKSIDE = sharedVars.CELLS_PER_CHUNKSIDE
vars.CELL_SIZE = sharedVars.CELL_SIZE


vars.VOXEL_RESOLUTION = 4 -- DONT CHANGE, THIS IS STRICT FOR THE ROBLOX TERRAIN ENGINE

vars.HM_SCALE = 50
vars.HM_AMPLITUDE = 16
vars.HM_OCTAVES = 3
vars.HM_PERSISTENCE = 0.4
vars.HM_LACUNARITY = 1.5

vars.BM_SCALE = 3000
vars.BM_AMPLITUDE = 6.5
vars.BM_OCTAVES = 2
vars.BM_PERSISTENCE = 0.5
vars.BM_LACUNARITY = 1.5

vars.MACROAREAS_PER_CHUNKSIDE = 8

vars.T_SAMPLE_BATCH_SIZE = 3200
vars.E_SAMPLE_BATCH_SIZE = 3200
vars.T_RENDER_BATCH_SIZE = 3200
vars.E_RENDER_BATCH_SIZE = 3200

vars.ChunkHeight = vars.HM_AMPLITUDE * 3 + 1

-- Calculations and precomputing

vars.CELLS_PER_MACROAREA_SIDE = vars.CELLS_PER_CHUNKSIDE / vars.MACROAREAS_PER_CHUNKSIDE


return vars