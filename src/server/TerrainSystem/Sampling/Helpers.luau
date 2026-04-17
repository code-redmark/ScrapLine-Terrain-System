local BiomeList = require(game.ServerScriptService.Server.TerrainSystem.Data.BiomeList)
local genUtils = require(game.ServerScriptService.Server.TerrainSystem.Utils.GenerationUtils)
local types = require(game.ServerScriptService.Server.TerrainSystem.Data.GenerationTypes)

local helper = {}

-- Pre compute Alias Buckets for every biome in the game
function helper.PrecomputeBiomeAliasMap()
	
	local AliasMap: {
		[string] : {
			Precompute : {[number] : {prob: number, aliasIndex: number, value: types.Biome}},
			ResourcesAmount : number
		}
		
	} = {}
	
	for _, Level in ipairs(BiomeList) do
		for _, Biome in ipairs(Level.Biomes) do
			if AliasMap[Biome.Name] then
				warn('Cant have 2 biomes with the same name, AliasMap isnt being stored correctly')
			end
				AliasMap[Biome.Name] = {
					Precompute = genUtils.AliasResourcePrecompute(Biome.BiomeResources),
					ResourcesAmount = #Biome.BiomeResources
				}
		end
	end
	
	return AliasMap
	
end

function helper.PickResource(biomeName: string, biomeResources, PrecomputeMap)

	local Biome = PrecomputeMap[biomeName]

	local bucket = Biome.Precompute[math.random(1, #Biome.Precompute)]

	if bucket.aliasIndex == nil or math.random() <= bucket.prob  then
		return bucket.value
	else
		return biomeResources[bucket.aliasIndex]
	end
	
end


return helper
