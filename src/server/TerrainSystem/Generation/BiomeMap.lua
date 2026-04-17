local variables = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)
local Noise = require(game.ServerScriptService.Server.TerrainSystem.Generation.MyNoise2D)
local BiomeList = require(game.ServerScriptService.Server.TerrainSystem.Data.BiomeList)

local chunkWorldSpan = variables.CELL_SIZE * variables.CELLS_PER_CHUNKSIDE
local bmOctaves = variables.BM_OCTAVES
local bmPersistence = variables.BM_PERSISTENCE
local bmLacunarity = variables.BM_LACUNARITY
local bmScale = variables.BM_SCALE

local module = {}

function module.getPosLevel(worldX: number, worldZ: number): types.BiomeLevel
	local posLevel: types.BiomeLevel = BiomeList[1]
	local distance = 0

	for _, level in ipairs(BiomeList) do
		-- World pos is distance from origin, for every level calculate distance from origin and check if its bigger than worldpos
		distance += level.Radius * chunkWorldSpan
		if math.abs(worldX) < distance and math.abs(worldZ) < distance then
			posLevel = level
		end
	end


	return posLevel
end


function module.GetBiome(worldX: number, worldZ: number, BmOffset: types.Position2D): types.Biome?

	local level = module.getPosLevel(worldX, worldZ)

	if #level.LevelParameters == 1 then
		local parameter = level.LevelParameters[1]
		local noise = Noise.Fractal(bmOctaves, worldX + BmOffset.x, worldZ + BmOffset.z, bmPersistence, bmLacunarity, bmScale)
		local normalized = (noise + 1) * 15

		local biomes = level.Biomes
		local lo, hi = 1, #biomes
		local found = biomes[1]

		while lo <= hi do
			local mid = math.floor((lo + hi) / 2)
			if normalized >= biomes[mid][parameter] then
				found = biomes[mid]
				lo = mid + 1
			else
				hi = mid - 1
			end
		end

		return found
	else
		warn('u havent made multiple Parameter biome decision bro')
		return nil
	end
end

return module
