local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)
local vars = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationVariables)
local sharedVars = require(game.ReplicatedStorage.Shared.SharedVariables)

local Generation = require(game.ServerScriptService.Server.TerrainSystem.Aggregates.Generation)

local Helpers = require(script.Parent.Helpers)

local CS = {}

CS.AliasMap = Helpers.PrecomputeBiomeAliasMap()

local cellsPerChunkSide = vars.cellsPerChunkSide
local cellSize = sharedVars.CELL_SIZE
local cellsPerMacroAreaSide = vars.CELLS_PER_MACROAREA_SIDE
local macroAreasPerChunkSide = vars.MACROAREAS_PER_CHUNKSIDE
local worldChunkSide = vars.worldChunkSize
local heightScale = vars.HM_AMPLITUDE / vars.HM_SCALE

--[[
	Calculates all the height and biome data for each position inside of the
	specified chunk, used by WorkerScripts to make heavy terrain generation
	calculations in parallel
]]--
function CS.SampleChunkTerrain(ChunkPosition: types.Position2D, TerrainOffset: {[string] : {x: number, z: number}})

	local batchSize = vars.T_SAMPLE_BATCH_SIZE
	local processed = 0

	local TerrainMap: {[number]: types.TerrainSample} = {}
	local AreaFrequencyMap: {[number]: types.BiomeFrequencyContainer} = {}

	local chunkBaseX = ChunkPosition.x * worldChunkSide
	local chunkBaseZ = ChunkPosition.z * worldChunkSide

	for x = 0, cellsPerChunkSide - 1 do
		local worldX = chunkBaseX + (cellSize * x)
		local macroAreaX = math.floor(x / cellsPerMacroAreaSide)
		for z = 0, cellsPerChunkSide - 1 do
			local worldZ = chunkBaseZ + (cellSize * z)

			local height = Generation.HeightMap.GetHeight(worldX, worldZ, TerrainOffset.HeightMap) * heightScale 
			local biome: types.Biome = Generation.BiomeMap.GetBiome(worldX, worldZ, TerrainOffset.BiomeMap)

			local sample: types.TerrainSample = {
				position = {x = worldX, z = worldZ},
				height = height * 3,
				biome = biome
			}

			local macroAreaZ = math.floor(z / cellsPerMacroAreaSide)
			local key = macroAreaX * macroAreasPerChunkSide + macroAreaZ + 1

			local macroArea = AreaFrequencyMap[key]
			if macroArea == nil then
				macroArea = {
					AreaPosition = {x = macroAreaX, z = macroAreaZ},
					Biomes = {},
					DominantBiome = biome,
					DominantFrequency = 0,
				}
				AreaFrequencyMap[key] = macroArea
			end

			local biomeEntry = macroArea.Biomes[biome.Name]
			if biomeEntry == nil then
				biomeEntry = {
					BiomeData = biome,
					Frequency = 1
				}
				macroArea.Biomes[biome.Name] = biomeEntry
			else
				biomeEntry.Frequency += 1
			end

			biomeEntry = macroArea.Biomes[biome.Name]
			if biomeEntry.Frequency > macroArea.DominantFrequency then
				macroArea.DominantFrequency = biomeEntry.Frequency
				macroArea.DominantBiome = biomeEntry.BiomeData
			end

			TerrainMap[(x * cellsPerChunkSide + z) + 1] = sample -- Lua 1-indexed

			if processed >= batchSize then
				task.wait()
				processed = 0
				continue
			else
				processed += 1
			end
		end
	end

	return TerrainMap, AreaFrequencyMap
end


--[[
	Samples the structures and resources that need 
	to spawn inside of a chunk through perlin noise by dividing it in many
	smaller areas that can be occupied by one of the two
]]--



function CS.SampleChunkEnvironment(AreaFrequencyMap: {[number]: types.BiomeFrequencyContainer}, EnvironmentOffset: {[string] : types.Position2D}) 

	local batchSize = vars.E_SAMPLE_BATCH_SIZE
	local processed = 0

	local EnvironmentMap: {[number]: types.EnvironmentSample} = {}

	for key, area in pairs(AreaFrequencyMap) do

		-- 1. Determine area biome
		local areaBiome = area.DominantBiome
		if areaBiome == nil then
			local bestFrequency = -1
			for _, BiomeElement in pairs(area.Biomes) do
				if BiomeElement.Frequency > bestFrequency then
					areaBiome = BiomeElement.BiomeData
					bestFrequency = BiomeElement.Frequency
				end
			end
			area.DominantBiome = areaBiome
			area.DominantFrequency = bestFrequency
		end

		if areaBiome == nil then
			continue
		end

		if next(areaBiome.BiomeResources) == nil then
			warn(areaBiome.Name..' has no resources')
		end

		-- 2. decide whether there should or shouldnt be a resource
		local areaX = area.AreaPosition.x
		local areaZ = area.AreaPosition.z
		local OffsetChunk: types.Position2D = {
			x = areaX + EnvironmentOffset.ResourceMap.x,
			z = areaZ + EnvironmentOffset.ResourceMap.z
		}

		local noise = ((math.noise(OffsetChunk.x, OffsetChunk.z) + 1) / 2) / vars.RM_SCALE * vars.RM_AMPLITUDE

		local mapKey = key

		if noise >= 0.3 then

			-- 1. Pick resource with biome bias
			local Resource: types.EnvironmentResource = Helpers.PickResource(areaBiome.Name, areaBiome.BiomeResources, CS.AliasMap)

			-- 2. Pick random position for center
			local seed = areaX * 73856093 + areaZ * 19349663

			local Center: types.Position2D = {
				x = (((seed * 16807) % 2147483647) / 2147483647) * (cellsPerMacroAreaSide - 1),
				z = ((((seed + 1) * 48271) % 2147483647) / 2147483647) * (cellsPerMacroAreaSide - 1)
			}

			local sample: types.EnvironmentSample = {
				Resource = Resource,
				Center = Center	
			}


			EnvironmentMap[mapKey] = sample

			if processed >= batchSize then
				task.wait()
				processed = 0
				continue
			else
				processed += 1
			end
		end
	end

	return EnvironmentMap
end


return CS
