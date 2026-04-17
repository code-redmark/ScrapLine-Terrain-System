local vars = {}

--------- Globals ----------------------------------------------------

vars.Loaded = {}


vars.GENERATION_SAMPLERS = 4
vars.GENERATION_RENDERERS = 4

vars.HEIGHT_MAP_SEED = nil
vars.BIOME_MAP_SEED = nil
vars.RESOURCE_MAP_SEED = nil

vars.CELLS_PER_CHUNKSIDE = 80
vars.CELL_SIZE = 4 -- Chunk System variable, represents studs

vars.VOXEL_RESOLUTION = 4 -- DONT CHANGE, THIS IS STRICT FOR THE ROBLOX TERRAIN ENGINE

vars.HM_SCALE = 50
vars.HM_AMPLITUDE = 16
vars.HM_OCTAVES = 4
vars.HM_PERSISTENCE = 0.4
vars.HM_LACUNARITY = 1.5

vars.BM_SCALE = 1600
vars.BM_AMPLITUDE = 20
vars.BM_OCTAVES = 8
vars.BM_PERSISTENCE = 0.5
vars.BM_LACUNARITY = 1.5

vars.MACROAREAS_PER_CHUNKSIDE = 8

vars.T_SAMPLE_BATCH_SIZE = 3200
vars.E_SAMPLE_BATCH_SIZE = 3200
vars.T_RENDER_BATCH_SIZE = 3200
vars.E_RENDER_BATCH_SIZE = 3200


-- Calculations and precomputing

vars.CELLS_PER_MACROAREA_SIDE = vars.CELLS_PER_CHUNKSIDE / vars.MACROAREAS_PER_CHUNKSIDE


return vars